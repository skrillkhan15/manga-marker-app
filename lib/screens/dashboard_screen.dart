import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manga_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> _widgetOrder = ['statistics', 'recent', 'goals'];

  @override
  void initState() {
    super.initState();
    _loadWidgetOrder();
  }

  Future<void> _loadWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final order = prefs.getStringList('dashboard_widget_order');
    if (order != null && order.isNotEmpty) {
      setState(() {
        _widgetOrder = order;
      });
    }
  }

  Future<void> _saveWidgetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('dashboard_widget_order', _widgetOrder);
  }

  Widget _buildWidget(String key, MangaProvider provider) {
    switch (key) {
      case 'statistics':
        return _buildStatisticsGrid(context, provider);
      case 'recent':
        return _buildRecentActivity(context, provider);
      case 'goals':
        return _buildReadingGoals(context);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MangaProvider>(
      builder: (context, mangaProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.lgSpacing),
            child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) async {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _widgetOrder.removeAt(oldIndex);
                  _widgetOrder.insert(newIndex, item);
                });
                await _saveWidgetOrder();
              },
              children: [
                for (final key in _widgetOrder)
                  Padding(
                    key: ValueKey(key),
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.xlSpacing,
                    ),
                    child: _buildWidget(key, mangaProvider),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, MangaProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppConstants.mdSpacing,
      mainAxisSpacing: AppConstants.mdSpacing,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Total Manga',
          '${provider.totalManga}',
          Icons.library_books,
          AppConstants.primaryColor,
        ),
        _buildStatCard(
          context,
          'Currently Reading',
          '${provider.readingCount}',
          Icons.menu_book,
          AppConstants.statusColors['Reading']!,
        ),
        _buildStatCard(
          context,
          'Completed',
          '${provider.completedCount}',
          Icons.check_circle,
          AppConstants.statusColors['Completed']!,
        ),
        _buildStatCard(
          context,
          'Chapters Read',
          '${provider.totalChaptersRead}',
          Icons.menu_book,
          AppConstants.secondaryColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTheme.getHeadlineStyle(
              context,
            ).copyWith(fontSize: 28, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.getBodyStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, MangaProvider provider) {
    final recentManga = provider.recentlyUpdatedManga;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: AppConstants.mdSpacing),
        Container(
          decoration: AppTheme.getCardDecoration(context),
          padding: const EdgeInsets.all(AppConstants.mdSpacing),
          child: recentManga.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.xlSpacing),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppConstants.mdSpacing),
                        Text(
                          'No recent activity',
                          style: AppTheme.getBodyStyle(context).copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentManga.length,
                  itemBuilder: (context, index) {
                    final manga = recentManga[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.getStatusColor(
                          manga.status,
                        ).withValues(alpha: 0.1),
                        child: Icon(
                          Icons.menu_book,
                          color: AppTheme.getStatusColor(manga.status),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        manga.title,
                        style: AppTheme.getBodyStyle(
                          context,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Updated ${_formatRelativeTime(manga.lastUpdated)}',
                        style: AppTheme.getBodyStyle(context).copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      trailing: Text(
                        manga.progressText,
                        style: AppTheme.getBodyStyle(context).copyWith(
                          color: AppTheme.getStatusColor(manga.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReadingGoals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Goals',
          style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: AppConstants.mdSpacing),
        Container(
          decoration: AppTheme.getCardDecoration(context),
          padding: const EdgeInsets.all(AppConstants.mdSpacing),
          child: Column(
            children: [
              _buildGoalProgress(
                context,
                'Daily Goal',
                '5 chapters',
                '3/5',
                0.6,
                AppConstants.primaryColor,
              ),
              const SizedBox(height: AppConstants.mdSpacing),
              _buildGoalProgress(
                context,
                'Weekly Goal',
                '25 chapters',
                '18/25',
                0.72,
                AppConstants.secondaryColor,
              ),
              const SizedBox(height: AppConstants.mdSpacing),
              _buildGoalProgress(
                context,
                'Monthly Goal',
                '100 chapters',
                '67/100',
                0.67,
                AppConstants.accentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgress(
    BuildContext context,
    String title,
    String target,
    String progress,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.getBodyStyle(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              progress,
              style: AppTheme.getBodyStyle(
                context,
              ).copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          target,
          style: AppTheme.getBodyStyle(context).copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
