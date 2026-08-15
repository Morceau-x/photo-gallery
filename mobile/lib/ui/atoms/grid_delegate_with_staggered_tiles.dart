import 'dart:math' as math;

import 'package:flutter/rendering.dart';

mixin SizedItem {
  late double aspectRatio;
}

class GridStaggeredTileLayout extends SliverGridLayout {
  /// Creates a layout that uses equally sized and spaced tiles.
  ///
  /// All of the arguments must not be negative. The `crossAxisCount` argument
  /// must be greater than zero.
  const GridStaggeredTileLayout({
    required this.items,
    required this.mainAxisSpacing,
    required this.crossAxisCount,
    required this.crossAxisStride,
    required this.childCrossAxisExtent,
    required this.reverseCrossAxis,
  }) : assert(crossAxisCount > 0),
       assert(crossAxisStride >= 0),
       assert(childCrossAxisExtent >= 0);

  final List<SizedItem> items;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of pixels from the leading edge of one tile to the leading edge
  /// of the next tile in the cross axis.
  final double crossAxisStride;

  /// The number of pixels from the leading edge of one tile to the trailing
  /// edge of the same tile in the cross axis.
  final double childCrossAxisExtent;

  /// Whether the children should be placed in the opposite order of increasing
  /// coordinates in the cross axis.
  ///
  /// For example, if the cross axis is horizontal, the children are placed from
  /// left to right when [reverseCrossAxis] is false and from right to left when
  /// [reverseCrossAxis] is true.
  ///
  /// Typically set to the return value of [axisDirectionIsReversed] applied to
  /// the [SliverConstraints.crossAxisDirection].
  final bool reverseCrossAxis;

  double getItemMainAxisExtent(int index) {
    return items[index].aspectRatio * childCrossAxisExtent;
  }

  double getItemMainAxisStride(int index) {
    return getItemMainAxisExtent(index) + mainAxisSpacing;
  }

  double compoundMainAxisOffset(int index) {
    double sum = 0;
    final int itemColumn = index % crossAxisCount;
    for (var i = 0; i < index; i++) {
      if (i % crossAxisCount == itemColumn) {
        sum += getItemMainAxisStride(i);
      }
    }
    return sum;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    for (int i = 0; i < items.length; i++) {
      if (compoundMainAxisOffset(i) >= scrollOffset) {
        return i;
      }
    }
    return 0;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    for (int i = items.length - 1; i >= 0; i--) {
      if (compoundMainAxisOffset(i) <= scrollOffset) {
        return i;
      }
    }
    return items.length - 1;
  }

  double _getOffsetFromStartInCrossAxis(double crossAxisStart) {
    if (reverseCrossAxis) {
      return crossAxisCount * crossAxisStride -
          crossAxisStart -
          childCrossAxisExtent -
          (crossAxisStride - childCrossAxisExtent);
    }
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final double crossAxisStart = (index % crossAxisCount) * crossAxisStride;
    return SliverGridGeometry(
      scrollOffset: compoundMainAxisOffset(index),
      crossAxisOffset: _getOffsetFromStartInCrossAxis(crossAxisStart),
      mainAxisExtent: getItemMainAxisExtent(index),
      crossAxisExtent: childCrossAxisExtent,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount == 0) {
      return 0.0;
    }
    List<double> columnFullSize = [];
    for (var i = items.length - crossAxisCount; i < items.length; i++) {
      columnFullSize.add(compoundMainAxisOffset(i) + getItemMainAxisExtent(i));
    }
    columnFullSize.sort((a, b) => a.compareTo(b));
    return columnFullSize.last;
  }
}

class GridDelegateWithStaggeredTiles extends SliverGridDelegate {
  const GridDelegateWithStaggeredTiles({
    required this.items,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  }) : assert(crossAxisCount > 0),
       assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0);

  final List<SizedItem> items;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent = math.max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    return GridStaggeredTileLayout(
      items: items,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisCount: crossAxisCount,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(GridDelegateWithStaggeredTiles oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.items != items;
  }
}
