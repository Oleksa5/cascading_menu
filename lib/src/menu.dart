import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:avocado_utils/avocado_utils.dart' hide Listener, CrossAxisAlignment, Theme;

import 'menu_manager.dart';
import 'menu_theme.dart';
import 'menu_item.dart';
import 'resolved_menu_style.dart';
import 'resolved_menu_theme.dart';
import 'defaults.dart';

class Menu extends StatefulWidget {
  const Menu({ 
    Key? key,
    required this.items,
    this.menuStyle,
    this.axis
  }) : super(key: key);
  
  final List<MenuItemWidget> items;
  final MenuStyle? menuStyle;
  final Axis? axis;

  bool hasAtLeastOneLeadingWidget() {
    for (final item in items) {
      if (item.hasLeadingWidget)
        return true;
    }
    return false;
  }

  @override
  State<Menu> createState() => _MenuState();

  static Menu? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<Menu>();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<MenuItemWidget>>('items', items, showName: false));
  }
}

class _MenuState extends State<Menu> {
  final key = GlobalKey();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final resolvedMenuTheme = ResolvedMenuTheme.of(context);
    final ResolvedMenuStyle? menuStyle;
    if (resolvedMenuTheme != null && widget.menuStyle == null)
         menuStyle = resolvedMenuTheme;
    else menuStyle = resolveMenuStyle(context, widget.menuStyle, widget.axis);

    Widget menu = Flex(
      key: key,
      direction: menuStyle.axis,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.items
    );

    if (menuStyle != resolvedMenuTheme) 
      menu = ResolvedMenuTheme(style: menuStyle, child: menu);

    if (menuStyle.axis == Axis.vertical)
      menu = Padding(
        padding: EdgeInsets.symmetric(vertical: menuStyle.vertPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: menuStyle.axis == Axis.vertical ? menuStyle.vertMenuMinWidth : 0
          ),
          child: IntrinsicWidth(child: menu),
        ),
      );

    final scrollDirection = menuStyle.axis;
    if (scrollDirection == Axis.horizontal)
      menu = Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent &&
              event.scrollDelta.dy != 0.0 &&
              (RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
               RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.shiftRight))) {
            assert(event.scrollDelta.dx == 0.0);
            GestureBinding.instance!.pointerSignalResolver.register(event, (_) {
              scrollController.position.pointerScroll(event.scrollDelta.dy);
            });
          }
        },
        child: menu
      );

    menu = SingleChildScrollView(
      scrollDirection: scrollDirection,
      controller: scrollController,
      child: menu
    );

    if (menuStyle.axis == Axis.horizontal) {
      menu = DecoratedBox(
        decoration: BoxDecoration(
          color: ElevationOverlay.applyOverlay(context, menuStyle.backgroundColor, menuStyle.elevation),
          borderRadius: BorderRadius.circular(kMenuCornerRadius),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 0.7), 
              blurRadius: 3, spreadRadius: -1.75 
            )
          ]
        ),
        child: Material(
          color: Colors.transparent,
          child: menu
        )
      );
    } else {
      menu = Material(
        color: menuStyle.backgroundColor,
        borderRadius: BorderRadius.circular(kMenuCornerRadius),
        elevation: menuStyle.elevation,
        textStyle: menuStyle.textStyle,
        child: menu,
      );
    }

    return menu;
  }
}

/// Shows the [menu] at the [menuPosition].
/// 
/// [alignmentContext] is a local space where positioning occurs.
/// The menu may be outside this space depending on [menuPosition]
/// value.
/// 
/// A barrier is built only for the centered menu.
///
/// An existing menu can be updated by providing its [route]. 
///
/// Returns the route of a shown menu. The route's [Route.popped]
/// future completes when the menu is dismissed.
Route showMenu(
  BuildContext context, 
  Widget menu, { 
  Axis? menuAxis,
  Position? menuPosition,
  BuildContext? alignmentContext,
  MenuStyle? menuStyle,
  MenuManagerController? menuManagerController,
  Color? barrierColor,
  Route? route
}) {
  menuPosition ??= const Position.centered();
  barrierColor ??= Theme.of(context).brightness == Brightness.light ? 
    Colors.black54 : Colors.black.withOpacity(0.75);

  Widget menuOverlay = MenuManager(
    menuAxis: menuAxis,
    menuStyle: menuStyle,
    targetContext: context,
    menu: menu,
    closeCallback: () {
      (route as MenuRoute).removeAndComplete(context);
    },
    menuPosition: menuPosition,
    alignmentContext: alignmentContext,
    menuManagerController: menuManagerController,
  );

  if (menuPosition.isCentered && alignmentContext == null) {
    menuOverlay = ColoredBox(
      color: barrierColor,
      child: menuOverlay
    );
  }

  if (route == null) {
    route = MenuRoute(menuOverlay);
    Navigator.push(context, route);
    return route;
  }

  final overlayRoute = route as OverlayRouteBuilder;
  overlayRoute.widget = menuOverlay;
  if (!overlayRoute.isActive) 
    Navigator.push(context, route);
  
  return route;
}

void popCurrentMenuRouteIfAny<T>(BuildContext context) {
  popCurrentRouteOfTypeIfAny<MenuRoute>(context);
}

// The reason ModalRoute is not used even as indirect base is that 
// it prevents a pointer to go through it to reach an overlay entry 
// below it. Allowing the pointer to go through is needed to enable 
// users to open a new menu without closing currently opened one 
// with an additional pointer down event.
class MenuRoute extends OverlayRouteBuilder {
  MenuRoute(Widget widget) : super.fromWidget(widget);
  MenuRoute.empty() : super.empty();
}