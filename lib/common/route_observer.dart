import 'package:flutter/widgets.dart';

/// Global RouteObserver used across the entire app.
/// This allows widgets to respond to navigation changes (push, pop, etc.)
final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();
