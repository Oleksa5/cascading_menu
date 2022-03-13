import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart';

import 'menu_tile.dart';
import 'resolved_menu_style.dart';
import 'menu_theme.dart';
import 'menu.dart';
import 'menu_action_button.dart';
import 'open_menu_button.dart';
import 'resolved_menu_theme.dart';

/// An interface for items used in a cascading menu.
/// 
/// A menu item pads its contents with a large padding according to 
/// a resolved [startPaddingStyle]. Subclasses can call [shouldHaveLargeStartPadding] 
/// to determine if they should use large start padding.
abstract class MenuItemWidget implements Widget {
  /// If a menu item has a leading widget, the latter takes a start
  /// padding if the padding is large.
  bool get hasLeadingWidget;

  static bool shouldHaveLargeStartPadding(BuildContext context) {
    final menuStyle = ResolvedMenuTheme.of(context)!;
    final itemStyle = ResolvedMenuItemTheme.of(context)!;

    return menuStyle.axis == Axis.vertical &&
      (itemStyle.startPaddingStyle == StartPaddingStyle.alwaysLargeForVerticalMenu ||
      (itemStyle.startPaddingStyle == StartPaddingStyle.alwaysLargeForVerticalMenuWithAtLeastOneLeadingWidget &&
      Menu.of(context)!.hasAtLeastOneLeadingWidget()));
  }
}   

/// An item in a cascading menu.
/// 
/// To trigger an action use [intent], [onPressed] or [shortcutActivator].
/// Only one of them can be specified for a particular item.
class MenuItem extends StatelessWidget implements MenuItemWidget {
  /// For an item created with this constructor, [shortcutActivator], 
  /// if provided, is used to make an item's shortcut label.
  MenuItem({
    Key? key,
    Widget? leading,
    required Widget title,
    Widget? trailing,
    this.shortcutActivator, 
    this.intent,
    this.onPressed,
    this.style,
    this.enabled,
    this.closeMenuOnAction = true,
    this.submenu 
  }) :
    tileDelegate = MenuItemTileDelegateForLTT(
      leading, title, trailing, 
      shortcutActivator, submenu != null
    ),
    super(key: key) {
    assert(configurationIsCorrect());
  }

  MenuItem.fromChild({
    Key? key,
    Widget? title,
    required Widget child, 
    this.shortcutActivator,
    this.intent,
    this.onPressed,
    this.style,
    this.enabled,
    this.closeMenuOnAction = true,
    this.submenu 
  }) : 
    tileDelegate = MenuItemTileDelegateForChild(title, child),
    super(key: key) {
    assert(configurationIsCorrect());
  }

  bool configurationIsCorrect() {
    bool isSubmenuContainer = submenu != null;
    bool enabled = isSubmenuContainer || onPressed != null || intent != null || shortcutActivator != null;
    bool isActionActivator = enabled && !isSubmenuContainer;

    if (isActionActivator)
      assert(atMostOneIsTrue3(onPressed != null, shortcutActivator != null, intent != null));

    assert(!(isSubmenuContainer && isActionActivator));

    if (this.enabled != null) {
      assert(!(isSubmenuContainer && !this.enabled!));
      assert(!(!enabled && this.enabled!));
    }

    return true;
  }

  final MenuItemTileDelegate tileDelegate;
  final ShortcutActivator? shortcutActivator;
  final Intent? intent;
  final VoidCallback? onPressed;
  final MenuItemStyle? style;
  /// Used to disable an item when a shortcutActivator is used to trigger an action.
  /// It also can be used with an intent or onPressed callback, but it's not the only
  /// option in this case: an item is disabled when [intent], [onPressed] and [shortcutActivator]
  /// are all null.
  /// 
  /// Items with submenus cannot be disabled. Also items with no [intent], [onPressed], 
  /// [shortcutActivator] or [submenu] cannot be enabled by this flag. 
  final bool? enabled;
  final bool closeMenuOnAction;
  final Widget? submenu;

  @override
  bool get hasLeadingWidget => tileDelegate.hasLeadingWidget;

  @override
  Widget build(BuildContext context) {
    Widget result = tileDelegate.build();

    if (submenu == null)
      result = enabled == null || enabled! ? 
        MenuActionButton(
          onPressed: onPressed,
          intent: intent,
          shortcutActivator: shortcutActivator,
          closeMenu: closeMenuOnAction,
          child: result,
        ) : 
        MenuActionButton(
          child: result
        );
    else
      result = OpenMenuButton(
        menu: submenu!,
        child: result
      );

    if (style != null) {
      result = ResolvedMenuItemTheme(
        style: resolveMenuItemStyle(style, ResolvedMenuTheme.of(context)!), 
        child: result
      );
    }

    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    MenuTile.debugAddTitleProperty(properties, tileDelegate.title);
  }
}

@immutable
abstract class MenuItemTileDelegate {
  const MenuItemTileDelegate(this.title);

  final Widget? title; 
  bool get hasLeadingWidget;

  Widget build();
}

class MenuItemTileDelegateForLTT extends MenuItemTileDelegate {
  const MenuItemTileDelegateForLTT(
    this.leading, 
    Widget title, 
    this.trailing, 
    this.shortcutActivator,
    this.itemHasSubmenu
  ) : super(title);
  
  final Widget? leading;
  @override
  Widget get title => super.title!;
  final Widget? trailing; 
  final ShortcutActivator? shortcutActivator;
  final bool itemHasSubmenu;

  @override
  bool get hasLeadingWidget => leading != null;

  @override
  Widget build() => MenuTile(
    leading: leading,
    title: title,
    trailing: trailing,
    shortcutActivator: shortcutActivator,
    itemHasSubmenu: itemHasSubmenu
  );
}

class MenuItemTileDelegateForChild extends MenuItemTileDelegate {
  const MenuItemTileDelegateForChild(
    Widget? title, 
    this.child
  ) : super(title);

  final Widget child;

  @override
  bool get hasLeadingWidget => false;

  @override
  Widget build() => MenuTile.fromChild(
    title: title,
    child: child
  );
}