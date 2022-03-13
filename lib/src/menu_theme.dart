import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart' hide TweenVisitor;

import 'material_state.dart';

class MenuTheme extends InheritedWidget {
  const MenuTheme({ 
    Key? key, 
    required Widget child, 
    required this.style 
  }) : super(key: key, child: child);

  final MenuStyle style;

  static MenuStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MenuTheme>()?.style;
  }

  @override
  bool updateShouldNotify(MenuTheme oldWidget) => style != oldWidget.style;
}

@immutable
class MenuStyle with Diagnosticable {
  MenuStyle({
    this.axis,
    this.visualDensity,
    this.vertMenuMinWidth, 
    this.vertPadding, 
    this.vertSubmenuMargin,
    this.horzSubmenuMargin,
    this.areaPadding,
    this.buttonMenuPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.textStyle,
    this.itemStyle,
    this.dividerStyle,
    this.isAnimated,
    this.animationDuration
  });

  final Axis? axis;
  final VisualDensity? visualDensity;
  final double? vertMenuMinWidth;
  /// Distance from the top of a menu to its first item and 
  /// from the bottom of the menu to its last item. 
  final double? vertPadding;
  final double? vertSubmenuMargin;
  final double? horzSubmenuMargin;
  /// Minimum distance from the available for menu positioning 
  /// area's edges to menus edges.  
  final double? areaPadding;
  final double? buttonMenuPadding;
  final Color? backgroundColor;
  final MenuItemMaterialStateProperty<Color>? foregroundColor;
  final double? elevation;
  final TextStyle? textStyle;
  final MenuItemStyle? itemStyle;
  final DividerThemeData? dividerStyle;
  final bool? isAnimated;
  final Duration? animationDuration;

  MenuStyle copyWith({
    Axis? axis,
    VisualDensity? visualDensity,
    double? vertMenuMinWidth,
    double? vertPadding,
    double? vertSubmenuMargin,
    double? horzSubmenuMargin,
    double? areaPadding,
    double? buttonMenuPadding,
    Color? backgroundColor,
    MenuItemMaterialStateProperty<Color>? foregroundColor,
    double? elevation,
    TextStyle? textStyle,
    MenuItemStyle? itemStyle,
    DividerThemeData? dividerStyle,
    bool? isAnimated,
    Duration? animationDuration,  
  }) {
    return MenuStyle(
      axis: axis ?? this.axis,
      visualDensity: visualDensity ?? this.visualDensity,
      vertMenuMinWidth: vertMenuMinWidth ?? this.vertMenuMinWidth, 
      vertPadding: vertPadding ?? this.vertPadding, 
      vertSubmenuMargin: vertSubmenuMargin ?? this.vertSubmenuMargin,
      horzSubmenuMargin: horzSubmenuMargin ?? this.horzSubmenuMargin,
      areaPadding: areaPadding ?? this.areaPadding,
      buttonMenuPadding: buttonMenuPadding ?? this.buttonMenuPadding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: MenuItemMaterialStateProperty.merge(this.foregroundColor, foregroundColor),
      elevation: elevation ?? this.elevation,
      textStyle: textStyle ?? this.textStyle,
      itemStyle: itemStyle ?? this.itemStyle,
      dividerStyle: dividerStyle ?? this.dividerStyle,
      isAnimated: isAnimated ?? this.isAnimated,
      animationDuration: animationDuration ?? this.animationDuration
    );
  }

  @override
  int get hashCode => Object.hashAll([
    axis, vertMenuMinWidth, vertPadding, vertSubmenuMargin, horzSubmenuMargin, 
    areaPadding, buttonMenuPadding, backgroundColor, foregroundColor, elevation, 
    textStyle, itemStyle, dividerStyle, isAnimated, animationDuration, visualDensity
  ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is MenuStyle
        && other.axis == axis
        && other.visualDensity == visualDensity
        && other.vertMenuMinWidth == vertMenuMinWidth
        && other.vertPadding == vertPadding
        && other.vertSubmenuMargin == vertSubmenuMargin
        && other.horzSubmenuMargin == horzSubmenuMargin
        && other.areaPadding == areaPadding
        && other.buttonMenuPadding == buttonMenuPadding
        && other.backgroundColor == backgroundColor 
        && other.foregroundColor == foregroundColor 
        && other.elevation == elevation
        && other.textStyle == textStyle
        && other.itemStyle == itemStyle
        && other.dividerStyle == dividerStyle
        && other.isAnimated == isAnimated
        && other.animationDuration == animationDuration;
  }

  static MenuStyle lerp(MenuStyle a, MenuStyle b, double t) {
    return MenuStyle(
      axis: t < 0.5 ? a.axis : b.axis,
      visualDensity: lerpIfNotNulls(a.visualDensity, b.visualDensity, t, lerpVisualDensity),
      vertMenuMinWidth: lerpIfNotNulls(a.vertMenuMinWidth, b.vertMenuMinWidth, t, lerpDouble),
      vertPadding: lerpIfNotNulls(a.vertPadding, b.vertPadding, t, lerpDouble),
      vertSubmenuMargin: lerpIfNotNulls(a.vertSubmenuMargin, b.vertSubmenuMargin, t, lerpDouble),
      horzSubmenuMargin: lerpIfNotNulls(a.horzSubmenuMargin, b.horzSubmenuMargin, t, lerpDouble),
      areaPadding: lerpIfNotNulls(a.areaPadding, b.areaPadding, t, lerpDouble),
      buttonMenuPadding: lerpIfNotNulls(a.buttonMenuPadding, b.buttonMenuPadding, t, lerpDouble),
      backgroundColor: lerpIfNotNulls(a.backgroundColor, b.backgroundColor, t, lerpColor),
      foregroundColor: lerpMenuItemProperties(a.foregroundColor, b.foregroundColor, t, lerpColor),
      elevation: lerpIfNotNulls(a.elevation, b.elevation, t, lerpDouble),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      itemStyle: lerpIfNotNulls(a.itemStyle, b.itemStyle, t, MenuItemStyle.lerp),
      dividerStyle: lerpIfNotNulls(a.dividerStyle, b.dividerStyle, t, DividerThemeData.lerp),
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('axis', axis, defaultValue: null));
    properties.add(DiagnosticsProperty('visualDensity', visualDensity, defaultValue: null));
    properties.add(DiagnosticsProperty('vertMenuMinWidth', vertMenuMinWidth, defaultValue: null));
    properties.add(DiagnosticsProperty('vertPadding', vertPadding, defaultValue: null));
    properties.add(DiagnosticsProperty('vertSubmenuMargin', vertSubmenuMargin, defaultValue: null));
    properties.add(DiagnosticsProperty('horzSubmenuMargin', horzSubmenuMargin, defaultValue: null));
    properties.add(DiagnosticsProperty('areaPadding', areaPadding, defaultValue: null));
    properties.add(DiagnosticsProperty('buttonMenuPadding', buttonMenuPadding, defaultValue: null));
    properties.add(DiagnosticsProperty('backgroundColor', backgroundColor, defaultValue: null));
    properties.add(DiagnosticsProperty('foregroundColor', foregroundColor, defaultValue: null));
    properties.add(DiagnosticsProperty('elevation', elevation, defaultValue: null));
    properties.add(DiagnosticsProperty('textStyle', textStyle, defaultValue: null));
    properties.add(DiagnosticsProperty('itemStyle', itemStyle, defaultValue: null));
    properties.add(DiagnosticsProperty('dividerStyle', dividerStyle, defaultValue: null));
    properties.add(DiagnosticsProperty('isAnimated', isAnimated, defaultValue: null));
    properties.add(DiagnosticsProperty('animationDuration', animationDuration, defaultValue: null));
  }
}

enum StartPaddingStyle {
  /// Icons are located inside a large padding for a vertical menu 
  /// and padded with [MenuItemStyle.padding.start] for a horizontal one.
  alwaysLargeForVerticalMenu,
  alwaysLargeForVerticalMenuWithAtLeastOneLeadingWidget,
  /// Icons are padded with [MenuItemStyle.padding.start].
  minimize
}

@immutable
class MenuItemStyle with Diagnosticable {
  /// Relying on vertical paddings may cause inconsistent menu items' heights
  /// because items' content may have different heights, e.g., when some items
  /// have icons and other don't. Consider using [minHeight] to achieve the consistency.
  MenuItemStyle({
    this.overlayColor,
    this.minHeight,
    this.padding,
    this.largeStartPadding,
    this.startPaddingStyle,
    this.contentsVertSpacing,
    this.contentsMinHorzSpacing,
    this.shortcutLabelTextStyle,
    this.arrowIconAsset,
    this.arrowIconSize,
    this.iconStyle
  });

  final MenuItemMaterialStateProperty<Color>? overlayColor;
  final double? minHeight;
  final EdgeInsetsDirectional? padding;
  /// The padding where an icon can be located.
  final double? largeStartPadding;
  final StartPaddingStyle? startPaddingStyle;
  final double? contentsVertSpacing;
  final double? contentsMinHorzSpacing;
  final TextStyle? shortcutLabelTextStyle;
  final AssetImage? arrowIconAsset;
  final double? arrowIconSize;
  final IconThemeData? iconStyle;

  MenuItemStyle copyWith({
    MenuItemMaterialStateProperty<Color>? overlayColor,
    double? minHeight,
    EdgeInsetsDirectional? padding,
    double? largeStartPadding,
    StartPaddingStyle? startPaddingStyle,
    double? contentsVertSpacing,
    double? contentsMinHorzSpacing,
    TextStyle? shortcutLabelTextStyle,
    AssetImage? arrowIconAsset,
    double? arrowIconSize,
    IconThemeData? iconStyle
  }) {
    return MenuItemStyle(
      overlayColor: MenuItemMaterialStateProperty.merge(this.overlayColor, overlayColor),
      minHeight: minHeight ?? this.minHeight,
      padding: padding ?? this.padding,
      largeStartPadding: largeStartPadding ?? this.largeStartPadding,
      startPaddingStyle: startPaddingStyle ?? this.startPaddingStyle,
      contentsVertSpacing: contentsVertSpacing ?? this.contentsVertSpacing,
      contentsMinHorzSpacing: contentsMinHorzSpacing ?? this.contentsMinHorzSpacing,
      shortcutLabelTextStyle: shortcutLabelTextStyle ?? this.shortcutLabelTextStyle,
      arrowIconAsset: arrowIconAsset ?? this.arrowIconAsset,
      arrowIconSize: arrowIconSize ?? this.arrowIconSize,
      iconStyle: iconStyle ?? this.iconStyle
    );
  }

  @override
  int get hashCode => Object.hash(
    overlayColor, minHeight, padding, largeStartPadding, startPaddingStyle, 
    contentsVertSpacing, contentsMinHorzSpacing, shortcutLabelTextStyle, 
    arrowIconAsset, arrowIconSize, iconStyle
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is MenuItemStyle
        && other.overlayColor == overlayColor
        && other.minHeight == minHeight
        && other.padding == padding
        && other.largeStartPadding == largeStartPadding
        && other.startPaddingStyle == startPaddingStyle
        && other.contentsVertSpacing == contentsVertSpacing
        && other.contentsMinHorzSpacing == contentsMinHorzSpacing
        && other.shortcutLabelTextStyle == shortcutLabelTextStyle
        && other.arrowIconAsset == arrowIconAsset
        && other.arrowIconSize == arrowIconSize 
        && other.iconStyle == iconStyle;
  }

  static MenuItemStyle lerp(MenuItemStyle a, MenuItemStyle b, double t) {
    return MenuItemStyle(
      overlayColor: lerpMenuItemProperties(a.overlayColor, b.overlayColor, t, lerpColor),
      minHeight: lerpIfNotNulls(a.minHeight, b.minHeight, t, lerpDouble),
      padding: lerpIfNotNulls(a.padding, b.padding, t, EdgeInsetsDirectional.lerp),
      largeStartPadding: lerpIfNotNulls(a.largeStartPadding, b.largeStartPadding, t, lerpDouble),
      startPaddingStyle: t < 0.5 ? a.startPaddingStyle : b.startPaddingStyle,
      contentsVertSpacing: lerpIfNotNulls(a.contentsVertSpacing, b.contentsVertSpacing, t, lerpDouble),
      contentsMinHorzSpacing: lerpIfNotNulls(a.contentsMinHorzSpacing, b.contentsMinHorzSpacing, t, lerpDouble),
      shortcutLabelTextStyle: lerpIfNotNulls(a.shortcutLabelTextStyle, b.shortcutLabelTextStyle, t, TextStyle.lerp),
      arrowIconAsset: t < 0.5 ? a.arrowIconAsset : b.arrowIconAsset,
      arrowIconSize: lerpIfNotNulls(a.arrowIconSize, b.arrowIconSize, t, lerpDouble),
      iconStyle: lerpIfNotNulls(a.iconStyle, b.iconStyle, t, IconThemeData.lerp)
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('overlayColor', overlayColor, defaultValue: null));
    properties.add(DiagnosticsProperty('minHeight', minHeight, defaultValue: null));
    properties.add(DiagnosticsProperty('padding', padding, defaultValue: null));
    properties.add(DiagnosticsProperty('largeStartPadding', largeStartPadding, defaultValue: null));
    properties.add(DiagnosticsProperty('startPaddingStyle', startPaddingStyle, defaultValue: null));
    properties.add(DiagnosticsProperty('contentsVertSpacing', contentsVertSpacing, defaultValue: null));
    properties.add(DiagnosticsProperty('contentsMinHorzSpacing', contentsMinHorzSpacing, defaultValue: null));
    properties.add(DiagnosticsProperty('shortcutLabelTextStyle', shortcutLabelTextStyle, defaultValue: null));
    properties.add(DiagnosticsProperty('arrowIconAsset', arrowIconAsset, defaultValue: null));
    properties.add(DiagnosticsProperty('arrowIconSize', arrowIconSize, defaultValue: null));
    properties.add(DiagnosticsProperty('iconStyle', iconStyle, defaultValue: null));
  }
}

class MenuStyleTween extends Tween<MenuStyle?> {
  MenuStyleTween({ MenuStyle? begin, MenuStyle? end }) : super(begin: begin, end: end);

  @override
  MenuStyle lerp(double t) => MenuStyle.lerp(begin!, end!, t);
}

class AnimatedMenuTheme extends ImplicitlyAnimatedWidget {
  const AnimatedMenuTheme({
    Key? key,
    required this.style,
    Curve curve = Curves.linear,
    Duration duration = kThemeAnimationDuration,
    VoidCallback? onEnd,
    required this.child,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  final MenuStyle style;

  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedMenuTheme> createState() => _AnimatedMenuThemeState();
}

class _AnimatedMenuThemeState extends AnimatedWidgetBaseState<AnimatedMenuTheme> {
  MenuStyleTween? _style;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _style = visitor(_style, widget.style, 
      (dynamic value) => MenuStyleTween(begin: value as MenuStyle)
    )! as MenuStyleTween;
  }

  @override
  Widget build(BuildContext context) {
    return MenuTheme(
      style: _style!.evaluate(animation)!,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<MenuStyleTween>('_style', _style, showName: false, defaultValue: null));
  }
}