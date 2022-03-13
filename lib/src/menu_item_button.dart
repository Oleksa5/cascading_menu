import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart';

class MenuItemButton extends Button {
  const MenuItemButton({
    Key? key,
    VoidCallback? onPressed,
    VoidCallback? onReleased,
    VoidCallback? onLongPress,
    Intent? intent,
    ShortcutActivator? shortcutActivator,
    BuildContext? targetContext,
    ButtonType type = ButtonType.momentary,
    ExtendedButtonStyle? style,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    bool autofocus = false,
    String? tooltip,
    ButtonController? controller,
    required Widget child
  }) : super(
    key: key,
    onPressed: onPressed,
    onReleased: onReleased,
    onLongPress: onLongPress, 
    intent: intent, 
    shortcutActivator: shortcutActivator,
    targetContext: targetContext,
    type: type,
    style: style,
    focusNode: focusNode,
    autofocus: autofocus,
    clipBehavior: clipBehavior,
    tooltip: tooltip,
    controller: controller,
    child: child,
  );

  @override
  ExtendedButtonStyle defaultStyleOf(BuildContext context) {
    return super.defaultStyleOf(context).copyWith(
      padding: MaterialStatePropertyAll(null),
      margin: MaterialStatePropertyAll(null)
    );
  }

  @override
  ExtendedButtonStyle? themeStyleOf(BuildContext context) {
    return MenuItemButtonTheme.of(context);
  }
}

class MenuItemButtonTheme extends InheritedWidget {
  const MenuItemButtonTheme({
    Key? key,
    required this.style,
    required Widget child
  }) : super(key: key, child: child);

  final ExtendedButtonStyle style;

  static ExtendedButtonStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MenuItemButtonTheme>()?.style;
  }

  @override
  bool updateShouldNotify(MenuItemButtonTheme oldWidget) {
    return style != oldWidget.style;
  }
}