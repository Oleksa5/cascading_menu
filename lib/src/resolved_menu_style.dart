// ignore_for_file: annotate_overrides

import 'dart:math' show max, min;

import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart' hide Theme;

import 'material_state.dart';
import 'menu_theme.dart';
import 'defaults.dart';
import 'resolved_menu_theme.dart';

class ResolvedMenuStyle extends MenuStyle {
  ResolvedMenuStyle({
    required Axis axis,
    required VisualDensity visualDensity,
    required double vertMenuMinWidth,
    required double vertPadding,
    required double vertSubmenuMargin,
    required double horzSubmenuMargin,
    required double areaPadding,
    required double buttonMenuPadding,
    required Color backgroundColor,
    required MenuItemMaterialStateProperty<Color>? foregroundColor,
    required double elevation,
    required TextStyle textStyle,
    required ResolvedMenuItemStyle itemStyle,
    required DividerThemeData dividerStyle,
    required Duration animationDuration
  }) : super(
    axis: axis,
    visualDensity: visualDensity,
    vertMenuMinWidth: vertMenuMinWidth,
    vertPadding: vertPadding,
    vertSubmenuMargin: vertSubmenuMargin,
    horzSubmenuMargin: horzSubmenuMargin,
    areaPadding: areaPadding,
    buttonMenuPadding: buttonMenuPadding,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevation,
    textStyle: textStyle,
    itemStyle: itemStyle,
    dividerStyle: dividerStyle,
    animationDuration: animationDuration
  );

  ResolvedMenuStyle.fromMenuStyle(MenuStyle menuStyle) : 
    super(
      axis: menuStyle.axis,
      visualDensity: menuStyle.visualDensity,
      vertMenuMinWidth: menuStyle.vertMenuMinWidth,
      vertPadding: menuStyle.vertPadding,
      vertSubmenuMargin: menuStyle.vertSubmenuMargin,
      horzSubmenuMargin: menuStyle.horzSubmenuMargin,
      areaPadding: menuStyle.areaPadding,
      buttonMenuPadding: menuStyle.buttonMenuPadding,
      backgroundColor: menuStyle.backgroundColor,
      foregroundColor: menuStyle.foregroundColor,
      elevation: menuStyle.elevation,
      textStyle: menuStyle.textStyle,
      itemStyle: ResolvedMenuItemStyle.fromMenuItemStyle(menuStyle.itemStyle!),
      dividerStyle: menuStyle.dividerStyle,
      animationDuration: menuStyle.animationDuration
    );

  Axis get axis => super.axis!;
  VisualDensity get visualDensity => super.visualDensity!;
  double get vertMenuMinWidth => super.vertMenuMinWidth!;
  double get vertPadding => super.vertPadding!;
  double get vertSubmenuMargin => super.vertSubmenuMargin!;
  double get horzSubmenuMargin => super.horzSubmenuMargin!;  
  double get areaPadding => super.areaPadding!;
  double get buttonMenuPadding => super.buttonMenuPadding!;
  Color get backgroundColor => super.backgroundColor!;
  MenuItemMaterialStateProperty<Color> get foregroundColor => super.foregroundColor!;
  double get elevation => super.elevation!;
  TextStyle get textStyle => super.textStyle!;
  ResolvedMenuItemStyle get itemStyle => super.itemStyle! as ResolvedMenuItemStyle;
  DividerThemeData get dividerStyle => super.dividerStyle!;
  bool get isAnimated => animationDuration > Duration.zero;
  Duration get animationDuration => super.animationDuration!;
}

class ResolvedMenuItemStyle extends MenuItemStyle {
  ResolvedMenuItemStyle({
    required MenuItemMaterialStateProperty<Color> overlayColor,
    required double minHeight,
    required EdgeInsetsDirectional padding,
    required double largeStartPadding,
    required StartPaddingStyle startPaddingStyle,
    required double contentsVertSpacing,
    required double contentsMinHorzSpacing,
    required TextStyle shortcutLabelTextStyle,
    required AssetImage arrowIconAsset,
    required double arrowIconSize,
    required IconThemeData iconStyle
  }) : super(
    overlayColor: overlayColor,
    minHeight: minHeight,
    padding: padding,
    largeStartPadding: largeStartPadding,
    startPaddingStyle: startPaddingStyle,
    contentsVertSpacing: contentsVertSpacing,
    contentsMinHorzSpacing: contentsMinHorzSpacing,
    shortcutLabelTextStyle: shortcutLabelTextStyle,
    arrowIconAsset: arrowIconAsset,
    arrowIconSize: arrowIconSize,
    iconStyle: iconStyle 
  );

  ResolvedMenuItemStyle.fromMenuItemStyle(MenuItemStyle itemStyle) : 
    super(
      overlayColor: itemStyle.overlayColor,
      minHeight: itemStyle.minHeight,
      padding: itemStyle.padding,
      largeStartPadding: itemStyle.largeStartPadding,
      startPaddingStyle: itemStyle.startPaddingStyle,
      contentsVertSpacing: itemStyle.contentsVertSpacing,
      contentsMinHorzSpacing: itemStyle.contentsMinHorzSpacing,
      shortcutLabelTextStyle: itemStyle.shortcutLabelTextStyle,
      arrowIconAsset: itemStyle.arrowIconAsset,
      arrowIconSize: itemStyle.arrowIconSize,
      iconStyle: itemStyle.iconStyle 
    );

  MenuItemMaterialStateProperty<Color> get overlayColor => super.overlayColor!;
  double get minHeight => super.minHeight!;
  EdgeInsetsDirectional get padding => super.padding!;
  double get largeStartPadding => super.largeStartPadding!;
  StartPaddingStyle get startPaddingStyle => super.startPaddingStyle!; 
  double get contentsVertSpacing => super.contentsVertSpacing!;
  double get contentsMinHorzSpacing => super.contentsMinHorzSpacing!;
  TextStyle get shortcutLabelTextStyle => super.shortcutLabelTextStyle!;
  AssetImage get arrowIconAsset => super.arrowIconAsset!;
  double get arrowIconSize => super.arrowIconSize!;
  IconThemeData get iconStyle => super.iconStyle!;
}

MenuStyle createDefaultMenuStyle(BuildContext context) {
  final theme = Theme.of(context);

  return MenuStyle(
    axis: Axis.vertical,
    visualDensity: theme.visualDensity,
    vertMenuMinWidth: deviceIsMobile(context) ? 
      kVertMenuMinWidth * 1.1 : kVertMenuMinWidth, 
    vertPadding: kMenuVertPadding,
    vertSubmenuMargin: kVertSubmenuMargin,
    horzSubmenuMargin: kHorzSubmenuMargin, 
    areaPadding: kMenuAreaPadding,
    buttonMenuPadding: kButtonMenuPadding,
    backgroundColor: theme.colorScheme.surface,
    foregroundColor: MenuItemMaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled))
        return theme.colorScheme.onSurface.withOpacity(0.5);
      return theme.colorScheme.onSurface;
    }), 
    elevation: kMenuElevation,
    textStyle: theme.textTheme.bodyText2?.copyWith(
      fontSize: deviceIsMobile(context) ? 15 : 12,
      overflow: TextOverflow.ellipsis
    ),
    itemStyle: _createDefaultMenuItemStyle(context, theme),
    dividerStyle: _createDefaultDividerStyle(theme, context),
    isAnimated: true,
    animationDuration: kAnimationDuration
  );
}

DividerThemeData _createDefaultDividerStyle(ThemeData theme, BuildContext context) {
  return DividerThemeData(
    color: theme.colorScheme.onSurface.withOpacity(0.3),
    space: kPadding,
    indent: kPadding05,
    endIndent: kPadding05,
    thickness: 0
  );
}

MenuItemStyle _createDefaultMenuItemStyle(BuildContext context, ThemeData theme) {
  final double minHeight = menuItemHeight();
  return MenuItemStyle(
    overlayColor: MenuItemMaterialStateProperty.resolveWith((states) {
      return theme.brightness == Brightness.light ?
        theme.colorScheme.onSurface.withOpacity(0.1) : 
        theme.colorScheme.onSurface.withOpacity(0.2);
    }),
    minHeight: minHeight,
    padding: const EdgeInsetsDirectional.fromSTEB(
      kMenuItemStartPadding, kMenuItemTopPadding, kMenuItemEndPadding, kMenuItemBottomPadding
    ),
    largeStartPadding: kMenuItemEnlargedStartPadding,
    startPaddingStyle: StartPaddingStyle.alwaysLargeForVerticalMenu,
    contentsVertSpacing: kMenuItemContentsVertSpacing,
    contentsMinHorzSpacing: kMenuItemContentsMinHorzSpacing,
    arrowIconSize: kPadding05,
    iconStyle: _createDefaultIconThemeData(context),
  );
}

ExtendedButtonStyle createDefaultButtonStyle(
  BuildContext context, ResolvedMenuStyle menuStyle, ResolvedMenuItemStyle itemStyle
) {
  return ExtendedButtonStyle(
    textStyle: MaterialStatePropertyAll(menuStyle.textStyle),
    shape: MaterialStatePropertyAll(const RoundedRectangleBorder()),
    foregroundColor: menuStyle.foregroundColor,
    overlayColor: itemStyle.overlayColor,
    minimumSize: MaterialStatePropertyAll(Size.zero),
    mouseCursor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) 
        return SystemMouseCursors.basic;
      return SystemMouseCursors.click;      
    }),
    visualDensity: menuStyle.visualDensity,
    highlightFadeDuration: Duration.zero
  );
}

IconThemeData _createDefaultIconThemeData(BuildContext context) {
  final IconThemeData inheritedIconTheme = IconTheme.of(context);
  return inheritedIconTheme.copyWith(
    opacity: 0.5,
    size: inheritedIconTheme.size != null ? 
      min(inheritedIconTheme.size!, kMenuItemIconSize) : kMenuItemIconSize
  );
}

ResolveProperty<MenuStyle> makeMenuStyleResolver(BuildContext context, MenuStyle? style) {
  final MenuStyle? themeStyle = MenuTheme.of(context);
  final MenuStyle defaultStyle = createDefaultMenuStyle(context);
  return makeResolver(style, themeStyle, defaultStyle);
}

ResolvedMenuStyle resolveMenuStyle(BuildContext context, MenuStyle? widgetStyle, Axis? axis) {
  final ResolvedMenuStyle? resolvedMenuTheme = ResolvedMenuTheme.of(context);
  final MenuStyle? themeStyle;
  final MenuStyle? defaultStyle;

  if (resolvedMenuTheme == null) {
    themeStyle = MenuTheme.of(context);
    defaultStyle = createDefaultMenuStyle(context);
  } else {
    if (widgetStyle == null) return resolvedMenuTheme;
    widgetStyle = _adjustDensity(widgetStyle, widgetStyle.visualDensity ?? resolvedMenuTheme.visualDensity);
    themeStyle = resolvedMenuTheme;
    defaultStyle = null;
  }

  final resolve = makeResolver(widgetStyle, themeStyle, defaultStyle);

  axis                                ??= resolve((style) => style.axis)!;
  final VisualDensity visualDensity     = resolve((style) => style.visualDensity)!;
  final double vertMenuMinWidth         = resolve((theme) => theme.vertMenuMinWidth)!;
  final double vertPadding              = resolve((style) => style.vertPadding)!;
  final double vertSubmenuMargin        = resolve((style) => style.vertSubmenuMargin)!;
  final double horzSubmenuMargin        = resolve((style) => style.horzSubmenuMargin)!;
  final double areaPadding              = resolve((style) => style.areaPadding)!;
  final double buttonMenuPadding        = resolve((style) => style.buttonMenuPadding)!;
  final Color backgroundColor           = resolve((style) => style.backgroundColor)!;
  MenuItemMaterialStateProperty<Color> 
    foregroundColor                     = MenuItemMaterialStateProperty.effectiveProperty(widgetStyle?.foregroundColor, themeStyle?.foregroundColor, defaultStyle?.foregroundColor)!;
  final double elevation                = resolve((style) => style.elevation)!;
  final TextStyle textStyle             = resolve((style) => style.textStyle)!;
  final DividerThemeData dividerStyle   = resolveDividerThemeData(widgetStyle?.dividerStyle, themeStyle?.dividerStyle, defaultStyle?.dividerStyle);
  final bool isAnimated                 = resolve((style) => style.isAnimated)!;
  Duration animationDuration            = resolve((style) => style.animationDuration)!;

  foregroundColor = MenuItemMaterialStateProperty.merge(
    ResolvedMenuItemMaterialStateProperty(disabled: foregroundColor.resolve({})), 
    foregroundColor
  )!;

  final TextStyle secondaryTextStyle = textStyle.copyWith(color: foregroundColor.disabled);

  final ResolvedMenuItemStyle itemStyle = _resolveMenuItemStyle(
    widgetStyle?.itemStyle, 
    themeStyle?.itemStyle, 
    defaultStyle?.itemStyle, 
    axis,
    secondaryTextStyle, 
  );

  if (!isAnimated) animationDuration = Duration.zero;

  final result = ResolvedMenuStyle(
    axis: axis,
    visualDensity: visualDensity,
    vertMenuMinWidth: vertMenuMinWidth,
    vertPadding: vertPadding,
    vertSubmenuMargin: vertSubmenuMargin,
    horzSubmenuMargin: horzSubmenuMargin,
    areaPadding: areaPadding,
    buttonMenuPadding: buttonMenuPadding,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevation,
    textStyle: textStyle,
    itemStyle: itemStyle,
    dividerStyle: dividerStyle,
    animationDuration: animationDuration
  );

  return resolvedMenuTheme == null ? 
    ResolvedMenuStyle.fromMenuStyle(_adjustDensity(result, result.visualDensity)) :
    result;
}

ResolvedMenuItemStyle _resolveMenuItemStyle(
  MenuItemStyle? first, 
  MenuItemStyle? second, [ 
  MenuItemStyle? third, 
  Axis? axis, 
  TextStyle? secondaryTextStyle 
]) {
  assert((third != null && axis != null && secondaryTextStyle != null) || (second is ResolvedMenuItemStyle));

  final resolve = makeResolver(first, second, third);

  final overlayColor                        = MenuItemMaterialStateProperty.effectiveProperty(first?.overlayColor, second?.overlayColor, third?.overlayColor!)!;
  final double minHeight                    = resolve((style) => style.minHeight)!;
  final EdgeInsetsDirectional padding       = resolve((style) => style.padding)!;
  final double largeStartPadding            = resolve((style) => style.largeStartPadding)!;
  final StartPaddingStyle startPaddingStyle = resolve((style) => style.startPaddingStyle)!;
  final double contentsVertSpacing          = resolve((style) => style.contentsVertSpacing)!;
  final double contentsMinHorzSpacing       = resolve((style) => style.contentsMinHorzSpacing)!;
  TextStyle? shortcutLabelTextStyle         = resolve((style) => style.shortcutLabelTextStyle);
  AssetImage? arrowIconAsset                = resolve((style) => style.arrowIconAsset);
  final double arrowIconSize                = resolve((style) => style.arrowIconSize)!;
  IconThemeData iconStyle                   = resolveIconThemeData(first?.iconStyle, second?.iconStyle, third?.iconStyle);

  shortcutLabelTextStyle ??= secondaryTextStyle!;

  arrowIconAsset ??= (axis == Axis.vertical ?
    const AssetImage('assets/icons/right_aligned_arrow_right.png', package: 'cascading_menu') :
    const AssetImage('assets/icons/arrow_down.png', package: 'cascading_menu'));

  assert(
    iconStyle.size! <= largeStartPadding, 
    'An icon must fit into the large padding. Current overflow: ${iconStyle.size! - largeStartPadding}.'
  );

  return ResolvedMenuItemStyle(
    overlayColor: overlayColor,
    minHeight: minHeight,
    padding: padding,
    largeStartPadding: largeStartPadding,
    startPaddingStyle: startPaddingStyle,
    contentsVertSpacing: contentsVertSpacing,
    contentsMinHorzSpacing: contentsMinHorzSpacing,
    shortcutLabelTextStyle: shortcutLabelTextStyle,
    arrowIconAsset: arrowIconAsset,
    arrowIconSize: arrowIconSize,
    iconStyle: iconStyle
  );
}

ResolvedMenuItemStyle resolveMenuItemStyle(MenuItemStyle? itemStyle, ResolvedMenuStyle resolvedMenuTheme) {
  return _resolveMenuItemStyle(
    adjustDensityForMenuItemStyleIfAny(itemStyle, resolvedMenuTheme.visualDensity), 
    resolvedMenuTheme.itemStyle
  );
}

T? _ifAnyThen<T>(T? value, T Function(T) f) => value != null ? f(value) : null;

MenuStyle _adjustDensity(MenuStyle menuStyle, VisualDensity visualDensity) {
  final densityAdjustment = visualDensity.baseSizeAdjustment;
  final dx = densityAdjustment.dx;
  final dy = densityAdjustment.dy;

  assert(dx == dy, 'Different horizontal and vertical densities are not currently supported.');

  return menuStyle.copyWith(
    vertMenuMinWidth: _ifAnyThen(menuStyle.vertMenuMinWidth, (value) => max(value + 2 * dx, 0.0)),
    areaPadding: _ifAnyThen(menuStyle.areaPadding, (value) => max(value + dx, 0.0)),
    itemStyle: adjustDensityForMenuItemStyleIfAny(menuStyle.itemStyle, visualDensity)
  );
}

MenuItemStyle? adjustDensityForMenuItemStyleIfAny(MenuItemStyle? itemStyle, VisualDensity visualDensity) {
  if (itemStyle == null) return null;

  final densityAdjustment = visualDensity.baseSizeAdjustment;
  final dx = densityAdjustment.dx;
  final dy = densityAdjustment.dy;
  
  return itemStyle.copyWith(
    minHeight: _ifAnyThen(itemStyle.minHeight, (value) => max(value + 2 * dy, 0.0)),
    padding: _ifAnyThen(itemStyle.padding, (padding) {
      return EdgeInsetsDirectional.fromSTEB(
        max(padding.start + dx, kPadding05),
        max(padding.top + dy, kPadding025),
        max(padding.end + dx, kPadding05),
        max(padding.bottom + dy, kPadding025)     
      );
    }),
    largeStartPadding: _ifAnyThen(itemStyle.largeStartPadding, (value) => max(value + dx, 0.0)),
    contentsVertSpacing: _ifAnyThen(itemStyle.contentsVertSpacing, (value) => max(value + dy, kPadding0125)),
    contentsMinHorzSpacing: _ifAnyThen(itemStyle.contentsMinHorzSpacing, (value) => max(value + (dx < 0 ? dx : dx / 4), kPadding025))
  );
}