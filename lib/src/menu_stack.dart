import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:avocado_utils/avocado_utils.dart';

import 'resolved_menu_style.dart';
import 'resolved_menu_theme.dart';

class MenuStack extends MultiChildRenderObjectWidget {
  MenuStack({
    Key? key,
    this.topMenuParentData = const TopMenuParentData(),
    required List<Widget> children 
  }) : 
    super(key: key, children: children);

  final TopMenuParentData topMenuParentData;

  static Offset submenuOffset(ResolvedMenuStyle menuStyle) {
    return Offset(menuStyle.vertSubmenuMargin, -menuStyle.vertPadding);
  } 

  @override
  RenderObject createRenderObject(BuildContext context) {
    final menuTheme = ResolvedMenuTheme.of(context)!;
    return _RenderMenuStack( 
      menuTheme.axis, 
      topMenuParentData,
      menuTheme.vertPadding,
      menuTheme.vertSubmenuMargin,
      menuTheme.horzSubmenuMargin,
      menuTheme.areaPadding
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderMenuStack renderObject) {
    final menuTheme = ResolvedMenuTheme.of(context)!;
    renderObject
      ..itemAxis = menuTheme.axis
      ..topMenuParentData = topMenuParentData
      ..menuVertPadding = menuTheme.vertPadding
      ..vertSubmenuMargin = menuTheme.vertSubmenuMargin
      ..horzSubmenuMargin = menuTheme.horzSubmenuMargin      
      ..menuAreaPadding = menuTheme.areaPadding;
  }
}

@immutable
class TopMenuParentData {
  const TopMenuParentData({
    this.position = const Position()
  });

  /// Position context is [MenuStackParentData.initiatingItem] 
  /// if it's not null. Otherwise it's the menu stack.
  final Position position;

  @override
  int get hashCode => position.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is TopMenuParentData
        && other.position == position;  
  }
}

class MenuStackParentData extends ContainerBoxParentData<RenderBox> {
  /// An item caused a menu to appear. It is required for non-top menus.
  RenderBox? initiatingItem;
}

class _RenderMenuStack extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MenuStackParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, MenuStackParentData> {
  _RenderMenuStack(
    Axis itemAxis, 
    TopMenuParentData topMenuParentData,
    double menuVertPadding, 
    double vertSubmenuMargin,
    double horzSubmenuMargin,
    double menuAreaPadding
  ) : 
    _itemAxis = itemAxis,
    _topMenuParentData = topMenuParentData,
    _menuVertPadding = menuVertPadding,
    _vertSubmenuMargin = vertSubmenuMargin,
    _horzSubmenuMargin = horzSubmenuMargin,
    _menuAreaPadding = menuAreaPadding;

  Axis get itemAxis => _itemAxis;
  Axis _itemAxis;
  set itemAxis(Axis value) {
    if (value == _itemAxis) return;
    _itemAxis = value;
    markNeedsLayout();
  }

  TopMenuParentData get topMenuParentData => _topMenuParentData;
  TopMenuParentData _topMenuParentData;
  set topMenuParentData(TopMenuParentData value) {
    if (value == _topMenuParentData) return;
    _topMenuParentData = value;
    markNeedsLayout();
  }

  double get menuVertPadding => _menuVertPadding;
  double _menuVertPadding;
  set menuVertPadding(double value) {
    if (value == _menuVertPadding) return;
    _menuVertPadding = value;
    markNeedsLayout();
  }

  double get vertSubmenuMargin => _vertSubmenuMargin;
  double _vertSubmenuMargin;
  set vertSubmenuMargin(double value) {
    if (value == _vertSubmenuMargin) return;
    _vertSubmenuMargin = value;
    markNeedsLayout();
  }

  double get horzSubmenuMargin => _horzSubmenuMargin;
  double _horzSubmenuMargin;
  set horzSubmenuMargin(double value) {
    if (value == _horzSubmenuMargin) return;
    _horzSubmenuMargin = value;
    markNeedsLayout();
  }

  double get menuAreaPadding => _menuAreaPadding;
  double _menuAreaPadding;
  set menuAreaPadding(double value) {
    if (value == _menuAreaPadding) return;
    _menuAreaPadding = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MenuStackParentData)
      child.parentData = MenuStackParentData();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    throw UnimplementedError();
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    throw UnimplementedError();
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    throw UnimplementedError();
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    throw UnimplementedError();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    throw UnimplementedError();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    throw UnimplementedError();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    final BoxConstraints childConstraints = constraints.deflate(EdgeInsets.all(menuAreaPadding));
    final Rect thisRect = makeRect(size: size);
    final Rect childArea = makeRect(
      offset: Offset(menuAreaPadding, menuAreaPadding), 
      size: childConstraints.biggest
    );

    assert(() {
      SchedulerBinding.instance!.addPostFrameCallback((_) { 
        // The MenuStack can't be used locally with alignment contexts because 
        // it most likely doesn't know its global position before its ancestors 
        // is fully laid out and this makes it impossible to map global coordinates
        // to the local space.
        if ((firstChild!.parentData as MenuStackParentData).initiatingItem != null)
          assert(localToGlobal(Offset.zero) == Offset.zero);
      });
      return true;
    }());

    RenderBox? child = firstChild;
    while (child != null) {      
      final childParentData = child.parentData as MenuStackParentData;
      bool isTopMenu = child == firstChild;
      late Rect alignmentContext; 

      if (childParentData.initiatingItem != null) {
        // At this point, a menu to which childParentData.initiatingItem belongs
        // must have updated offset (because each submenu is located after its parent 
        // menu in the list). Animated transforms of all menus gets updated even
        // earlier on the build phase and there is no need to wait until painting to 
        // use them. Also calling globalPaintBounds doesn't mutate anything. Therefore 
        // calling it from here shouldn't cause any problems.
        invokeLayoutCallback((constraints) { 
          alignmentContext = paintBounds(childParentData.initiatingItem!, isTopMenu ? null : this);
        });
      } else {
        assert(isTopMenu);
        alignmentContext = thisRect; 
      }

      Size childSize = layoutChild(child, childConstraints);

      MutableRect childRect;

      MutableRect makeChildRect(
        Alignment originAlignment,
        Alignment alignment,
        Offset offset
      ) {
        return MutableRect.fromAlignmentContext(
          alignmentContext, 
          originAlignment: originAlignment,
          alignment: alignment,
          size: childSize,
          offset: offset
        );
      }

      Alignment originAlignment; 
      Alignment alignment;
      Offset offset;

      if (isTopMenu) {
        originAlignment = topMenuParentData.position.origin;
        alignment = topMenuParentData.position.alignment;
        offset = topMenuParentData.position.offset;
      } else {
        if (itemAxis == Axis.vertical) {
          originAlignment = Alignment.topRight;
          alignment = Alignment.topLeft;
          offset = Offset(vertSubmenuMargin, -menuVertPadding);
        } else {
          originAlignment = Alignment.bottomCenter;
          alignment = Alignment.topCenter;
          offset = Offset(0, horzSubmenuMargin);
        }
      }

      childRect = makeChildRect(originAlignment, alignment, offset);

      if (itemAxis == Axis.vertical) {
        if (childRect.isHorzOutside(childArea)) {
          double distanceToLeftEdge = childRect.left - childArea.left;
          double distanceToRightEdge = childArea.right - childRect.right;

          alignment = Alignment(-alignment.x, alignment.y);
          final renderTransform = child as RenderTransform;
          final renderTransformAlignment = renderTransform.alignment as Alignment;
          renderTransform.alignment = Alignment(-renderTransformAlignment.x, renderTransformAlignment.y);
          if (alignmentContext != thisRect) {
            originAlignment = Alignment(-originAlignment.x, originAlignment.y);
            offset = Offset(-offset.dx, offset.dy);
          }

          childRect = makeChildRect(originAlignment, alignment, offset);

          if (childRect.isHorzOutside(childArea)) {
            double mirroredDistanceToLeftEdge = childRect.left - childArea.left;
            double mirroredDistanceToRightEdge = childArea.right - childRect.right;

            double? leftOverflow = distanceToLeftEdge >= 0 ? null : -distanceToLeftEdge;
            double? mirroredLeftOverflow = mirroredDistanceToLeftEdge >= 0 ? null : -mirroredDistanceToLeftEdge;
            double? smallestLeftOverflow = pickLess(leftOverflow, mirroredLeftOverflow);

            double? rightOverflow = distanceToRightEdge >= 0 ? null : -distanceToRightEdge;
            double? mirroredRightOverflow = mirroredDistanceToRightEdge >= 0 ? null : -mirroredDistanceToRightEdge;
            double? smallestRightOverflow = pickLess(rightOverflow, mirroredRightOverflow);
            
            // to prevent child jumping from side to side due to rounding errors 
            // when an alignment context is located at the center of a child area
            // and the width of the child area is changing
            const tolerance = 0.001;
            if (smallestRightOverflow == null || 
                smallestLeftOverflow != null && smallestLeftOverflow + tolerance < smallestRightOverflow) {
              childRect.moveTo(x: childArea.left);
              final double transformLocalOrigin = alignmentContext.left;
              renderTransform.alignment = Alignment(
                childRect.localXAsAlignment(transformLocalOrigin),
                renderTransformAlignment.y
              );
            } else { 
              childRect.moveToHaveRightAt(childArea.right);
              final double transformLocalOrigin = alignmentContext.right - childRect.left;
              renderTransform.alignment = Alignment(
                childRect.localXAsAlignment(transformLocalOrigin),
                renderTransformAlignment.y
              );
            }
          }
        }
        childRect.ensureVertEnclosedBy(childArea);
      } else {
        childRect.ensureEnclosedBy(childArea);
      }

      childParentData.offset = childRect.leftTop;
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}