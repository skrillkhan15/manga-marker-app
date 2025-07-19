import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class WalkthroughScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const WalkthroughScreen({super.key, this.onComplete});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WalkthroughPage> _pages = [
    WalkthroughPage(
      title: 'Welcome to MangaMarks Local',
      description:
          'Your private, offline manga tracker for keeping track of your reading progress.',
      icon: Icons.book,
      color: AppConstants.primaryColor,
    ),
    WalkthroughPage(
      title: 'Add Your Manga',
      description:
          'Easily add manga with intelligent URL parsing, cover images, and detailed information.',
      icon: Icons.add_circle,
      color: AppConstants.secondaryColor,
    ),
    WalkthroughPage(
      title: 'Track Your Progress',
      description:
          'Monitor your reading progress, set goals, and view detailed statistics.',
      icon: Icons.trending_up,
      color: AppConstants.accentColor,
    ),
    WalkthroughPage(
      title: 'Stay Organized',
      description:
          'Use tags, bookmarks, and filters to keep your manga library organized.',
      icon: Icons.folder,
      color: Colors.green,
    ),
    WalkthroughPage(
      title: '100% Private',
      description:
          'All your data stays on your device. No accounts, no cloud, no tracking.',
      icon: Icons.security,
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeWalkthrough();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('walkthrough_completed', true);

    if (mounted) {
      widget.onComplete?.call();
    }
  }

  void _skipWalkthrough() {
    _completeWalkthrough();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mdSpacing),
                child: TextButton(
                  onPressed: _skipWalkthrough,
                  child: const Text('Skip'),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Navigation
            _buildNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(WalkthroughPage page) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 60, color: page.color),
          ),

          const SizedBox(height: AppConstants.xlSpacing),

          // Title
          Text(
            page.title,
            style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.mdSpacing),

          // Description
          Text(
            page.description,
            style: AppTheme.getBodyStyle(context).copyWith(
              fontSize: 16,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Row(
        children: [
          // Page indicators
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? AppConstants.primaryColor
                        : Colors.grey[400],
                  ),
                );
              }),
            ),
          ),

          // Navigation buttons
          Row(
            children: [
              if (_currentPage > 0)
                Semantics(
                  button: true,
                  label: 'Previous walkthrough page',
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      onPressed: _previousPage,
                      child: const Text('Previous', semanticsLabel: 'Previous'),
                    ),
                  ),
                ),
              const SizedBox(width: AppConstants.smSpacing),
              Semantics(
                button: true,
                label: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next walkthrough page',
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      semanticsLabel: _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WalkthroughPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  WalkthroughPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
