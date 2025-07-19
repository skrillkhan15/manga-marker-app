import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MultiActionFAB extends StatefulWidget {
  final List<FABAction> actions;
  final VoidCallback? onAddManga;
  final VoidCallback? onImportData;
  final VoidCallback? onScanQR;
  final VoidCallback? onStartTimer;

  const MultiActionFAB({
    super.key,
    this.actions = const [],
    this.onAddManga,
    this.onImportData,
    this.onScanQR,
    this.onStartTimer,
  });

  @override
  State<MultiActionFAB> createState() => _MultiActionFABState();
}

class _MultiActionFABState extends State<MultiActionFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Action buttons
        if (_isExpanded) ...[
          _buildActionButton(
            icon: Icons.add,
            label: 'Add Manga',
            onTap: widget.onAddManga ?? () {},
            delay: 0,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.qr_code_scanner,
            label: 'Scan QR',
            onTap: widget.onScanQR ?? () {},
            delay: 1,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.file_upload,
            label: 'Import Data',
            onTap: widget.onImportData ?? () {},
            delay: 2,
          ),
          const SizedBox(height: 8),
        ],

        // Main FAB
        Semantics(
          button: true,
          label: _isExpanded ? 'Close actions' : 'Open actions',
          child: SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              onPressed: _toggleExpanded,
              child: AnimatedRotation(
                turns: _isExpanded ? 0.125 : 0,
                duration: AppConstants.mediumAnimation,
                child: const Icon(Icons.add, semanticLabel: 'Main actions'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final scale = _animation.value;
        final opacity = _animation.value;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Semantics(
              button: true,
              label: label,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: FloatingActionButton.small(
                    onPressed: onTap,
                    heroTag: null,
                    child: Icon(icon, semanticLabel: label),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FABAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  FABAction({required this.icon, required this.label, required this.onTap});
}
