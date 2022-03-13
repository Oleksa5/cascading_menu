import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart' hide Listener;

import 'menu.dart';
import 'menu_item_button.dart';
import 'menu_manager.dart';

class MenuActionButton extends StatelessWidget {
  const MenuActionButton({ 
    Key? key,
    this.onPressed, 
    this.intent, 
    this.shortcutActivator,
    this.style,
    this.closeMenu = true,
    required this.child, 
  }) : 
    super(key: key);

  final VoidCallback? onPressed;
  final Intent? intent;
  final ShortcutActivator? shortcutActivator;
  final ExtendedButtonStyle? style;
  final bool closeMenu;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final menuManager = MenuManager.of(context);
    final enabled = onPressed != null || intent != null || shortcutActivator != null;
    return MouseRegion(
      onEnter: (_) {
        if (enabled)
          if (menuManager != null)
               menuManager.onPointerEnteredActionItem(context);
          else popCurrentMenuRouteIfAny(context);
      },
      child: Listener(
        onPointerUp: closeMenu && enabled ? (_) => menuManager?.close() : null,
        child: MenuItemButton(
          onPressed: onPressed,
          intent: intent,
          shortcutActivator: shortcutActivator,       
          style: style,
          targetContext: menuManager?.widget.targetContext,
          child: child
        ) 
      ),
    );
  }
}