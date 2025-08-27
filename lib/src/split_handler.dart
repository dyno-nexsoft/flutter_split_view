import 'package:flutter/widgets.dart';

mixin FlutterSplitHandler<T extends StatefulWidget> on State<T> {
  bool _isSplit = false;

  bool get isSplit => _isSplit;

  double get breakpoint;

  bool canPop();

  @protected
  Widget buildPrimary(BuildContext context);

  @protected
  Widget buildSecondary(BuildContext context);

  @protected
  Widget buildSplit(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _isSplit = constraints.maxWidth > breakpoint;
      final double primaryWidth, secondaryLeft, secondaryWidth;
      if (isSplit) {
        primaryWidth = breakpoint / 2;
        secondaryLeft = primaryWidth;
        secondaryWidth = constraints.maxWidth - primaryWidth;
      } else {
        if (canPop() == true) {
          secondaryLeft = 0;
          secondaryWidth = constraints.maxWidth;
        } else {
          secondaryLeft = constraints.maxWidth;
          secondaryWidth = constraints.maxWidth;
        }
        primaryWidth = constraints.maxWidth;
      }

      return Stack(
        children: [
          Positioned(
            left: 0,
            width: primaryWidth,
            height: constraints.maxHeight,
            child: MediaQuery.removePadding(
              context: context,
              removeRight: isSplit,
              child: buildPrimary(context),
            ),
          ),
          Positioned(
            left: secondaryLeft,
            width: secondaryWidth,
            height: constraints.maxHeight,
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: isSplit,
              child: buildSecondary(context),
            ),
          ),
        ],
      );
    });
  }
}
