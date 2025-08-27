import 'package:flutter/widgets.dart';

import 'observers.dart';
import 'split_handler.dart';

/// A widget that creates a split view layout, showing two panels side-by-side
/// on wider screens and a single panel on narrower screens.
///
/// The [FlutterSplitView] widget is designed for responsive applications that
/// want to display a primary and secondary view. When the available width
/// exceeds the [breakpoint], both panels are shown side-by-side. On smaller
/// screens, only the primary panel is shown, and navigation is handled using
/// a secondary [Navigator].
///
/// The [placeholder] widget is displayed in the secondary panel when there are
/// no routes to show.
///
/// Example usage:
/// ```dart
/// FlutterSplitView(
///   breakpoint: 800,
///   placeholder: Center(child: Text('Select an item')),
///   onGenerateRoute: (settings) {
///     // Return your routes here.
///   },
/// )
/// ```
///
/// See also:
///  * [Navigator], which this widget extends.
///  * [LayoutBuilder], used internally for responsiveness.
class FlutterSplitView extends Navigator {
  /// Creates a split view layout.
  const FlutterSplitView({
    super.key,
    super.initialRoute,
    super.onGenerateInitialRoutes,
    super.onGenerateRoute,
    super.onUnknownRoute,
    super.transitionDelegate,
    super.reportsRouteUpdateToEngine,
    super.clipBehavior,
    super.observers,
    super.requestFocus,
    super.restorationScopeId,
    super.routeTraversalEdgeBehavior,
    super.onDidRemovePage,
    this.breakpoint = 600.0,
    this.placeholder = const Placeholder(),
  });

  /// The minimum width at which the split view displays both panels side-by-side.
  ///
  /// When the available width is greater than [breakpoint], the split view shows
  /// both the primary and secondary panels. Otherwise, only the primary panel is shown.
  final double breakpoint;

  /// The widget to show in the secondary panel when no route is pushed.
  ///
  /// This widget is displayed in the secondary panel when there are no routes
  /// in the secondary [Navigator]. By default, this is a [Placeholder] widget,
  /// but you can provide any widget, such as a message or illustration.
  final Widget placeholder;

  @override
  NavigatorState createState() => _FlutterSplitViewState();

  /// Returns the [NavigatorState] for the secondary panel from the closest
  /// [FlutterSplitView] ancestor of the given [context].
  ///
  /// This is useful for pushing or popping routes on the secondary panel's
  /// [Navigator]. Throws a [FlutterError] if no [FlutterSplitView] ancestor
  /// can be found in the widget tree.
  static NavigatorState of(BuildContext context) {
    return _of(context)._secondaryKey.currentState!;
  }

  /// Returns `true` if the [FlutterSplitView] ancestor of the given [context]
  /// is currently displaying both panels side-by-side (split mode).
  ///
  /// This can be used to determine whether the split view is active, based on
  /// the current layout constraints and the [breakpoint] value.
  ///
  /// Example:
  /// ```dart
  /// final isSplit = FlutterSplitView.isSplitOf(context);
  /// ```
  static bool isSplitOf(BuildContext context) {
    return _of(context).isSplit;
  }
}

class _FlutterSplitViewState extends NavigatorState with FlutterSplitHandler {
  final _secondaryKey = GlobalKey<NavigatorState>();
  late final _secondaryObserver = FlutterSplitNavigatorObserver();

  @override
  FlutterSplitView get widget => super.widget as FlutterSplitView;

  @override
  double get breakpoint => widget.breakpoint;

  @override
  bool canPop() => _secondaryKey.currentState?.canPop() ?? false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _secondaryObserver,
      builder: (context, child) {
        return super.buildSplit(context);
      },
    );
  }

  @override
  Widget buildPrimary(BuildContext context) {
    return super.build(context);
  }

  @override
  Widget buildSecondary(BuildContext context) {
    return Navigator(
      key: _secondaryKey,
      observers: [_secondaryObserver, ...widget.observers],
      onGenerateInitialRoutes: (navigator, initialRoute) {
        return [
          PageRouteBuilder(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return Builder(
                builder: (context) {
                  if (FlutterSplitView.isSplitOf(context)) {
                    return widget.placeholder;
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          )
        ];
      },
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      transitionDelegate: widget.transitionDelegate,
      reportsRouteUpdateToEngine: widget.reportsRouteUpdateToEngine,
      clipBehavior: widget.clipBehavior,
      requestFocus: widget.requestFocus,
      restorationScopeId: widget.restorationScopeId,
      routeTraversalEdgeBehavior: widget.routeTraversalEdgeBehavior,
      onDidRemovePage: widget.onDidRemovePage,
    );
  }
}

_FlutterSplitViewState _of(BuildContext context) {
  _FlutterSplitViewState? navigator;
  if (context is StatefulElement && context.state is _FlutterSplitViewState) {
    navigator = context.state as _FlutterSplitViewState;
  }
  navigator ??= context.findAncestorStateOfType<_FlutterSplitViewState>();

  assert(() {
    if (navigator == null) {
      throw FlutterError(
        'FlutterSplitView operation requested with a context that does not include a FlutterSplitView.\n'
        'The context used to push or pop routes from the FlutterSplitView must be that of a '
        'widget that is a descendant of a FlutterSplitView widget.',
      );
    }
    return true;
  }());
  return navigator!;
}
