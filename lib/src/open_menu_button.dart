import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide showMenu, ButtonStyle;
import 'package:avocado_utils/avocado_utils.dart';
import 'package:avocado_utils/avocado_utils.dart' as avocado;

import 'menu.dart';
import 'menu_item_button.dart';
import 'menu_manager.dart';
import 'menu_router.dart';
import 'menu_stack.dart';
import 'menu_theme.dart';
import 'resolved_menu_style.dart';
import 'resolved_menu_theme.dart';

typedef MenuButton = OpenMenuButton;

/// Shows the [menu] when pressed or, if a pointer device kind is the mouse 
/// and the button is part of another menu — when a pointer enters the button.
/// 
/// By default the button has an appearance of [Icons.adaptive.more] 
/// icon inside a circle shape without borders.
class OpenMenuButton extends StatefulWidget {
  const OpenMenuButton({ 
    Key? key, 
    this.targetContext,
    required this.menu,
    this.menuAxis, 
    this.menuPosition,
    this.menuStyle, 
    this.barrierColor,
    this.style,
    this.menuManagerController,
    this.child,
  }) : 
    super(key: key);

  final BuildContext? targetContext;
  final Widget menu;
  final Axis? menuAxis;
  final Position? menuPosition;
  /// Ignored if the button is a part of a menu.
  final MenuStyle? menuStyle;
  final Color? barrierColor;
  final ExtendedButtonStyle? style;
  final MenuManagerController? menuManagerController;
  final Widget? child;

  @override
  State<OpenMenuButton> createState() => OpenMenuButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Widget>('child', child, showName: false, expandableValue: true));
    properties.add(DiagnosticsProperty<Widget>('menu', menu, showName: false, expandableValue: true));
  }
}

class OpenMenuButtonState extends State<OpenMenuButton> {
  final controller = MaintainedButtonController(unpressedOnPress: true);
  late MenuManagerController menuManagerController;
  MenuRouter? menuRouter;

  void managerClosedMenu() {
    if (!controller.pressed) return;
    controller.latched = false;
  }

  @override
  Widget build(BuildContext context) {
    final menuManager = MenuManager.of(context);

    assert(
      !(Menu.of(context) != null && widget.child == null), 
      'A child should be provided to use the button in a menu'
    );

    final VoidCallback onPressed;
    VoidCallback? onReleased;
    if (menuManager != null) {
      onPressed = () => menuManager.openItem(this);
      controller.pressedOnHover = true;
      controller.forceLatched = true;
    } else {
      final menu = Menu.of(context);
      Position? menuPosition = widget.menuPosition;
      menuManagerController = widget.menuManagerController ?? MenuManagerController();
      
      if (menu != null) {
        assert(widget.menuAxis == null);
        menuPosition ??= Position(
          origin: Alignment.topRight,
          alignment: Alignment.topLeft,
          offset: MenuStack.submenuOffset(ResolvedMenuTheme.of(context)!)
        );
        controller.pressedOnHover = true;
        controller.forceLatched = true;
      } else {
        final resolve = makeMenuStyleResolver(context, widget.menuStyle);
        onReleased = () { 
          if (menuRouter!.open)
            menuManagerController.close.call();
        };
        if (menuPosition == null) {
          final Alignment menuOrigin;
          final Offset menuOffset;
          if (deviceIsMobile(context)) {
            menuOrigin = Alignment.topLeft;
            menuOffset = Offset.zero;
          } else {
            menuOrigin = Alignment.bottomLeft;
            menuOffset = Offset(0, resolve((style) => style.buttonMenuPadding)!);
          }
          menuPosition = Position(
            origin: menuOrigin,
            alignment: Alignment.topLeft,
            offset: menuOffset
          );
        }
        controller.pressedOnHover = false;
        controller.forceLatched = false;
      }

      Route callShowMenu(showMenu) {
        return showMenu(
          widget.targetContext ?? context, 
          widget.menu,
          menuAxis: widget.menuAxis,
          menuPosition: menuPosition,
          alignmentContext: context,
          menuStyle: widget.menuStyle,
          menuManagerController: menuManagerController,
          barrierColor: widget.barrierColor,
          didClose: managerClosedMenu
        );
      } 

      if (menuRouter == null)
           menuRouter = MenuRouter(callShowMenu);
      else menuRouter!.callShowMenu = callShowMenu;

      onPressed = () => menuRouter!.showMenu();

      menuRouter!.updateMenu();
    }

    if (widget.child != null) {
      return MenuItemButton(
        onPressed: onPressed,
        onReleased: onReleased,
        style: widget.style,
        type: ButtonType.maintained,
        controller: controller,
        child: widget.child ?? buildChild()        
      );
    } else {   
      return avocado.IconButton(
        onPressed: onPressed,
        onReleased: onReleased,
        style: ExtendedButtonStyle.merge2(
          widget.style, 
          ExtendedButtonStyle(
            splashingEnabled: false
          )
        ),
        type: ButtonType.maintained,
        controller: controller,
        child: widget.child ?? buildChild()
      ); 
    }
  }

  Widget buildChild() => Icon(Icons.adaptive.more);

  @override
  void deactivate() {
    MenuManager.of(context)?.onItemDeactivated(this);
    super.deactivate();
  }
}