import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide showMenu, PointerUpEventListener;
import 'package:avocado_utils/avocado_utils.dart' hide Listener;
import 'package:avocado_utils/avocado_utils.dart' as avocado;

import 'menu_router.dart';
import 'menu_theme.dart';
import 'menu.dart';

/// A region that opens a [menu] on a secondary button up event if 
/// a pointer device kind is the mouse and on a long press gesture if 
/// it's any other kind.
class ContextMenuRegion extends StatefulWidget {
  /// The top-left corner of a menu is located at the position
  /// of a pointer that caused the menu to appear if [menuAlignment]
  /// is null. Otherwise the menu is aligned relative to available 
  /// menu area bounds unless [alignToOrigin] is true which makes the 
  /// menu align to the position of the pointer.
  const ContextMenuRegion({
    Key? key,
    required this.menu,
    this.menuAxis,
    this.menuAlignment,
    this.menuStyle,
    this.barrierColor,
    this.alignToOrigin = false,
    required this.child
  }) : super(key: key);

  final Menu menu;
  final Axis? menuAxis;
  final Alignment? menuAlignment;
  final MenuStyle? menuStyle;
  // Used only if the menu is centered.
  final Color? barrierColor;
  final bool alignToOrigin;
  final Widget child;

  @override
  createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  late Offset lastTapPosition;
  late PointerDeviceKind deviceKind;
  late MenuRouter menuRouter;

  @override
  void initState() {
    super.initState();
    menuRouter = MenuRouter(callShowMenu);
  }

  Route callShowMenu(ShowMenu showMenu) {
    final Offset menuOffset;
    final Alignment menuOrigin;
    final Alignment menuAlignment;
    
    if (widget.menuAlignment == null) {
      menuOrigin = Alignment.topLeft;
      if (widget.menuAxis == Axis.vertical) {
        menuOffset = lastTapPosition;
        menuAlignment = Alignment.topLeft;
      } else {
        if (deviceKind == PointerDeviceKind.mouse ||
            deviceKind == PointerDeviceKind.unknown) {
          menuOffset = lastTapPosition;
          // for the mouse or unknown device a horizontal menu will appear 
          // half a menu's height below a pointer position
          menuAlignment = const Alignment(0, -2);
        } else {
          menuOffset = lastTapPosition.translate(0, -kMinInteractiveDimension / 2);
          menuAlignment = Alignment.bottomCenter;
        }
      }       
    } else {
      if (widget.alignToOrigin) {
        menuOrigin = Alignment.topLeft;
        menuOffset = lastTapPosition;
      } else {
        menuOrigin = widget.menuAlignment!;
        menuOffset = Offset.zero;
      }
      menuAlignment = widget.menuAlignment!;
    }

    return showMenu(
      context, 
      widget.menu,
      menuAxis: widget.menuAxis,
      menuPosition: Position(
        origin: menuOrigin,
        alignment: menuAlignment,
        offset: menuOffset,
      ),
      menuStyle: widget.menuStyle,
      barrierColor: widget.barrierColor
    );
  }

  @override
  Widget build(BuildContext context) {
    menuRouter.updateMenu();
    
    return Listener(
      onPointerDown: (event) => deviceKind = event.kind,
      child: avocado.Listener(
        onSecondaryPointerUp: (event) { 
          deviceKind = event.kind;
          if (deviceKind == PointerDeviceKind.mouse) 
            _onMenuRequest(event.position);
        },
        child: GestureDetector(
          onLongPressStart: (details) {
            if (deviceKind != PointerDeviceKind.mouse)
              _onMenuRequest(details.globalPosition);
          },
          child: widget.child
        ),
      ),
    );
  }

  void _onMenuRequest(Offset globalPosition) {
    lastTapPosition = globalPosition;
    menuRouter.showMenu();
  }
}