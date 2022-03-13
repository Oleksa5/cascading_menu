import 'dart:math' show max;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:avocado_utils/avocado_utils.dart' hide CrossAxisAlignment;

import 'menu_item.dart';
import 'resolved_menu_theme.dart';

class MenuTile extends StatelessWidget {
  MenuTile({ 
    Key? key,
    Widget? leading,
    required Widget title,
    Widget? trailing,
    ShortcutActivator? shortcutActivator,
    required bool itemHasSubmenu
  }) :
    childDelegate = itemHasSubmenu ? 
      MenuTileForItemWithSubmenuContentsDelegateForLTT(leading, title) :
      MenuTileContentsDelegateForLTT(leading, title, trailing, shortcutActivator),
    super(key: key);

  MenuTile.fromChild({
    Key? key, 
    Widget? title,
    required Widget child
  }) : 
    childDelegate = MenuTileContentsDelegateForChild(title, child), 
    super(key: key);

  final MenuTileContentsDelegate childDelegate;

  @override
  Widget build(BuildContext context) {
    final itemStyle = ResolvedMenuItemTheme.of(context)!;
    final bool shouldHaveLargeStartPadding = MenuItemWidget.shouldHaveLargeStartPadding(context);

    MenuTileContentsPadding padding = MenuTileContentsPadding(
      shouldHaveLargeStartPadding ? 
        copyDirectionalInsets(itemStyle.padding, start: itemStyle.largeStartPadding) :
        itemStyle.padding,
      shouldHaveLargeStartPadding
    );

    final child = childDelegate.build(context, padding);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: itemStyle.minHeight
      ),
      child: Padding(
        padding: padding.edgeInsets,
        child: child
      )
    );
  }

  static void debugAddTitleProperty(DiagnosticPropertiesBuilder properties, Widget? title) {
    if (title is Text && title.data != null) {
      properties.add(StringProperty('title', title.data!, showName: false));
    } else {
      properties.add(DiagnosticsProperty<Widget>(
        'title', title, showName: false, defaultValue: null, expandableValue: true
      ));
    } 
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    debugAddTitleProperty(properties, childDelegate.title);
  }
}

/// A means of communication between [MenuTile]'s build method and 
/// its content delegate allowing the latter to take padding space. 
class MenuTileContentsPadding {
  MenuTileContentsPadding(this.edgeInsets, this.leadingShouldTakeStartPadding);
  /// When a contents delegate takes padding space, it should subtract
  /// a required amount from this insets.
  EdgeInsetsDirectional edgeInsets;
  final bool leadingShouldTakeStartPadding;
}

@immutable
abstract class MenuTileContentsDelegate {
  const MenuTileContentsDelegate(this.title);

  final Widget? title;

  Widget build(BuildContext context, MenuTileContentsPadding padding);
} 

class MenuTileContentsDelegateForChild extends MenuTileContentsDelegate {
  const MenuTileContentsDelegateForChild(Widget? title, this.child) : super(title);

  final Widget child;

  @override
  Widget build(BuildContext context, MenuTileContentsPadding padding) {
    final itemStyle = ResolvedMenuItemTheme.of(context)!;

    EdgeInsetsDirectional overlappedPadding = -subtractOverlappedPaddingIfAny(
      EdgeInsetsDirectional.zero, child, context
    ); 

    final Widget result;
    if (title != null) {
      final double contentsVertSpacing = max(
        itemStyle.contentsVertSpacing - overlappedPadding.top, 0.0
      );
      result = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          overlappedPadding != EdgeInsetsDirectional.zero ?
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: overlappedPadding.start,
                end: overlappedPadding.end
              ),
              child: title,
            ) :
            title!,
          Padding(
            padding: EdgeInsets.only(top: contentsVertSpacing),
            child: child,
          )
        ],
      );

      if (overlappedPadding != EdgeInsetsDirectional.zero) 
        overlappedPadding = copyDirectionalInsets(overlappedPadding, top: 0.0);

    } else {
      result = child;
    }

    if (overlappedPadding != EdgeInsetsDirectional.zero) 
      padding.edgeInsets = clampDirectionalInsets(
        padding.edgeInsets.subtract(overlappedPadding) as EdgeInsetsDirectional
      );

    return result;
  }
}

abstract class MenuTileContentsDelegateBaseForLTT extends MenuTileContentsDelegate {
  const MenuTileContentsDelegateBaseForLTT(this.leading, Widget title, [ this.trailing ]) 
    : super(title);

  final Widget? leading;
  final Widget? trailing;

  Widget? buildTrailingWidget(BuildContext context);

  @nonVirtual
  @override
  Widget build(BuildContext context, MenuTileContentsPadding padding) {
    final menuStyle = ResolvedMenuTheme.of(context)!;
    final itemStyle = ResolvedMenuItemTheme.of(context)!;
    Widget? trailing = this.trailing ?? buildTrailingWidget(context);

    final Widget? leading;
    if (padding.leadingShouldTakeStartPadding) {
      leading = SizedBox(
        width: padding.edgeInsets.start,
        child: this.leading,
      );
      padding.edgeInsets = copyDirectionalInsets(padding.edgeInsets, start: 0.0);
    } else if (this.leading != null) {
      leading = Padding(
        padding: EdgeInsets.only(right: itemStyle.contentsMinHorzSpacing),
        child: this.leading!,
      );
    } else {
      leading = null;
    }

    Widget result = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) leading,
        title!,
        if (menuStyle.axis == Axis.vertical) const Spacer(),
        if (trailing != null) 
          Padding(
            padding: EdgeInsets.only(left: itemStyle.contentsMinHorzSpacing),
            child: trailing,
          )
      ]
    );

    return result;
  }
}

class MenuTileContentsDelegateForLTT extends MenuTileContentsDelegateBaseForLTT {
  const MenuTileContentsDelegateForLTT(
    Widget? leading, Widget title, Widget? trailing, this.shortcutActivator
  ) : super(leading, title, trailing);
  
  final ShortcutActivator? shortcutActivator;

  @override
  Widget? buildTrailingWidget(BuildContext context) {
    final menuStyle = ResolvedMenuTheme.of(context)!;
    final itemStyle = ResolvedMenuItemTheme.of(context)!;
    return menuStyle.axis == Axis.vertical && shortcutActivator != null ?
      Text(
        makeShortcutLabel(shortcutActivator!),
        style: itemStyle.shortcutLabelTextStyle
      ) :
      null;
  }
} 

class MenuTileForItemWithSubmenuContentsDelegateForLTT extends MenuTileContentsDelegateBaseForLTT {
  const MenuTileForItemWithSubmenuContentsDelegateForLTT(
    Widget? leading, Widget title
  ) : super(leading, title);

  @override
  Widget? buildTrailingWidget(BuildContext context) {
    final itemStyle = ResolvedMenuItemTheme.of(context)!;
    return ImageIcon(
      itemStyle.arrowIconAsset, 
      size: itemStyle.arrowIconSize
    );
  }
}