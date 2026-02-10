import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:flutter/material.dart';

class AGLoader {
  static OverlayEntry? _loaderOverlay;
  static Object? _lastHideError;
  static StackTrace? _lastHideStack;

  /// Check if loader is currently shown
  static bool get isShown => _loaderOverlay != null;
  static Object? get lastHideError => _lastHideError;
  static StackTrace? get lastHideStack => _lastHideStack;

  /// Show the loader overlay
  static void show(
    BuildContext context, {
    Widget? progressIndicator,
    Color? overlayColor,
  }) {
    // Prevent duplicate loaders
    if (_loaderOverlay != null) {
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    
    _loaderOverlay = OverlayEntry(
      builder: (context) => _LoaderWidget(
        progressIndicator: progressIndicator,
        overlayColor: overlayColor ?? Colors.black26,
      ),
    );

    overlay.insert(_loaderOverlay!);
  }

  /// Hide the loader overlay
  static void hide() {
    _lastHideError = null;
    _lastHideStack = null;

    if (_loaderOverlay == null) {
      return;
    }

    try {
      _loaderOverlay?.remove();
    } catch (e) {
      debugPrint('Error removing loader: $e');
      _lastHideError = e;
      _lastHideStack = StackTrace.current;
    } finally {
      try {
        _loaderOverlay?.dispose();
      } catch (e) {
        debugPrint('Error disposing loader: $e');
      }
      _loaderOverlay = null;
    }
  }
}

class _LoaderWidget extends StatelessWidget {
  final Widget? progressIndicator;
  final Color overlayColor;

  const _LoaderWidget({
    this.progressIndicator,
    required this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          // Semi-transparent background
          Container(
            color: overlayColor,
          ),
          // Loader content centered
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  progressIndicator ??
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.buttonGreenColor,
                        ),
                        backgroundColor:
                            AppColors.buttonGreenColor.withOpacity(0.3),
                      ),
                  const SizedBox(height: 20),
                  Text(
                    "Good things take time. \nBreathe, say Bismillah.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.buttonGreenColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
