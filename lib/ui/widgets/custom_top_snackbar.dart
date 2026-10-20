import 'package:flutter/material.dart';
import 'package:chatter/constants/app_colors.dart';

class CustomTopSnackBar {
  static OverlayEntry? _currentEntry; // keep track of active snackbar

  static void show(
      BuildContext context, {
        String? title,
        required String message,
        bool isError = false,
        Duration duration = const Duration(seconds: 3),
      }) {
    _currentEntry?.remove();
    _currentEntry = null;
    final theme = Theme.of(context);
    final Color? foregroundColor;
    final Color? backgroundColor;
    if (isError) {
      foregroundColor = AppColors.white;
      backgroundColor = theme.colorScheme.error;
    } else {
      foregroundColor = AppColors.white;
      backgroundColor = AppColors.primaryGreen;
    }
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 600),
    );

    final animation = Tween<Offset>(
      begin: const Offset(0, -1), // start above screen
      end: Offset.zero, // slide to top position
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    ));

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        child: SlideTransition(
          position: animation,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              // User swipes up
              if (details.primaryDelta != null && details.primaryDelta! < -10) {
                animationController.reverse().then((_) {
                  entry.remove();
                  _currentEntry = null;
                });
              }
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: backgroundColor,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      Text(
                        title,
                        style: TextStyle(
                            color: foregroundColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    ],
                    Text(
                      message,
                      style: TextStyle(color: foregroundColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    // Start the animation
    animationController.forward();

    // Auto-dismiss after duration
    Future.delayed(duration, () async {
      if (_currentEntry == entry) {
        await animationController.reverse();
        entry.remove();
        _currentEntry = null;
      }
    });
  }
}
