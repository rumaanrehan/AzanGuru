import 'dart:developer';
import 'package:azan_guru_mobile/constant/app_colors.dart';
import 'package:flutter/material.dart';



const defaultValue = 56.0;

class AGLoader extends StatelessWidget {
  static OverlayEntry? _currentLoader;

  const AGLoader._(this._progressIndicator);

  final Widget? _progressIndicator;

  static OverlayState? _overlayState;

  /// If you need to check your loader is being shown or
  /// not just call the property ```Loader.isShown'''
  static bool get isShown => _currentLoader != null;

  /// If you need to show a normal overlay loader,
  /// just call ```Loader.show(context)``` with a build context.
  static void show(
    BuildContext context, {
    Widget? progressIndicator,
    Color? overlayColor,
    double? overlayFromTop,
    double? overlayFromBottom,
    bool isAppbarOverlay = true,
    bool isBottomBarOverlay = true,
    bool isSafeAreaOverlay = true,
  }) {
    var safeBottomPadding = MediaQuery.of(context).padding.bottom;
    var defaultPaddingTop = 0.0;
    var defaultPaddingBottom = 0.0;
    if (!isAppbarOverlay) {
      isSafeAreaOverlay = false;
    }
    if (!isSafeAreaOverlay) {
      defaultPaddingTop = defaultValue;
      defaultPaddingBottom = defaultValue + safeBottomPadding;
    } else {
      defaultPaddingTop = defaultValue;
      defaultPaddingBottom = defaultValue;
    }
    _overlayState = Overlay.of(context);
    if (_currentLoader == null) {
      /// Create current Loader Entry
      _currentLoader = OverlayEntry(
        builder: (context) {
          return Stack(
            children: <Widget>[
              // GestureDetector to detect taps outside the loader
              GestureDetector(
                onTap: () {
                  hide(); // Hide the loader on tap anywhere outside the loader
                },
                child: _overlayWidget(
                  isSafeAreaOverlay,
                  overlayColor ?? Colors.black26,
                  isAppbarOverlay ? 0.0 : overlayFromTop ?? defaultPaddingTop,
                  isBottomBarOverlay
                      ? 0.0
                      : overlayFromBottom ?? defaultPaddingBottom,
                ),
              ),
              // Loader widget
              Center(
                child: AGLoader._(progressIndicator),
              ),
            ],
          );
        },
      );
      try {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            if (_currentLoader != null) {
              _overlayState?.insert(_currentLoader!);
            }
          },
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  static Widget _overlayWidget(bool isSafeArea, Color overlayColor,
      double overlayFromTop, double overlayFromBottom) {
    return isSafeArea
        ? Container(
            color: overlayColor,
            margin:
                EdgeInsets.only(top: overlayFromTop, bottom: overlayFromBottom),
          )
        : SafeArea(
            child: Container(
              color: overlayColor,
              margin: EdgeInsets.only(
                  top: overlayFromTop, bottom: overlayFromBottom),
            ),
          );
  }

  /// You have to call ```Loader.hide()``` method inside the [dispose()] to clear loader.
  /// You also call this method to hide the overlay loader manually.
  static void hide() {
    if (_currentLoader != null) {
      try {
        _currentLoader?.remove();
      } catch (e) {
        debugPrint(e.toString());
      } finally {
        _currentLoader = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        hide();
        return false;
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
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
              _progressIndicator ??
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.buttonGreenColor,
                    ),
                    backgroundColor: AppColors.buttonGreenColor.withOpacity(0.3),
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
    );
  }
}
