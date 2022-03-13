import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart';
import 'package:avocado_utils/avocado_utils.dart' as avocado;

import 'menu_item.dart';
import 'menu_theme.dart';
import 'menu_tile.dart';
import 'resolved_menu_theme.dart';

/// The widget is visible only for a vertical menu. 
/// Returns shrunk [SizedBox] for horizontal one.
class MenuDivider extends StatelessWidget implements MenuItemWidget {
  const MenuDivider({ Key? key }) : super(key: key);

  @override
  bool get hasLeadingWidget => false;

  @override
  Widget build(BuildContext context) {
    if (ResolvedMenuTheme.of(context)!.axis == Axis.vertical)
         return const avocado.Divider();
    else return const SizedBox.shrink();
  }
}

class SliderMenuItem extends StatelessWidget implements MenuItemWidget {
  const SliderMenuItem({ 
    Key? key,
    required this.title, 
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.mouseCursor,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.semanticFormatterCallback,
    this.focusNode,
    this.autofocus = false,
    this.adaptive = false
  }) : super(key: key);

  final Widget title;
  final double value; 
  final ValueSetter<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min; 
  final double max; 
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final MouseCursor? mouseCursor;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool adaptive;

  @override
  bool get hasLeadingWidget => false;

  @override
  Widget build(BuildContext context) {
    return MenuTile.fromChild(
      title: title,
      child: SliderOverlappedPadding(
        slider: !adaptive ? 
          Slider(
            value: value,
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
            min: min, 
            max: max,                        
            divisions: divisions,
            label: label ?? value.toString(),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            thumbColor: thumbColor,
            mouseCursor: mouseCursor,
            semanticFormatterCallback: semanticFormatterCallback,
            focusNode: focusNode,
            autofocus: autofocus
          ) :
          Slider.adaptive(
            value: value,
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
            min: min, 
            max: max,                        
            divisions: divisions,
            label: label ?? value.toString(),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            thumbColor: thumbColor,
            mouseCursor: mouseCursor,
            semanticFormatterCallback: semanticFormatterCallback,
            focusNode: focusNode,
            autofocus: autofocus          
          )
      ),
    );
  }
}

/// Specifies on which edge of [MenuItem] to place a control.
enum MenuItemControlAffinity {
  leading, trailing
}

class CheckboxMenuItem extends StatelessWidget implements MenuItemWidget {
  const CheckboxMenuItem({ 
    Key? key,
    required this.value,
    this.tristate = false,
    required this.onChanged,
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.side,    
    this.size,
    required this.title,
    this.secondary,
    this.controlAffinity = MenuItemControlAffinity.leading
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool?> onChanged;
  final MouseCursor? mouseCursor;
  final Color? activeColor;
  final MaterialStateProperty<Color?>? fillColor;
  final Color? checkColor;
  final bool tristate;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final double? size;  
  final Widget title;
  final Widget? secondary;
  final MenuItemControlAffinity controlAffinity;

  @override
  bool get hasLeadingWidget => controlAffinity == MenuItemControlAffinity.leading;

  @override
  Widget build(BuildContext context) {
    final control = avocado.Checkbox(
      value: value,
      tristate: tristate,
      onChanged: onChanged,
      mouseCursor: mouseCursor,
      activeColor: activeColor,
      fillColor: fillColor,
      checkColor: checkColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      overlayColor: overlayColor,
      splashRadius: splashRadius,
      materialTapTargetSize: materialTapTargetSize,
      visualDensity: visualDensity,
      focusNode: focusNode,
      autofocus: autofocus,
      shape: shape,
      side: side      
    );

    final Widget? leading, trailing;
    switch (controlAffinity) {
      case MenuItemControlAffinity.leading:
        leading = control;
        trailing = secondary;
        break;
      case MenuItemControlAffinity.trailing:
        leading = secondary;
        trailing = control;
        break;
    }

    return MenuItem(
      leading: leading,
      title: title,
      trailing: trailing,
      onPressed: () {
        if (value == false) 
             onChanged(true);
        else onChanged(false);
      },
      closeMenuOnAction: false,
    );
  }
}

class RadioMenuItem<T> extends StatelessWidget implements MenuItemWidget {
  const RadioMenuItem({ 
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.mouseCursor,
    this.toggleable = false,
    this.activeColor,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.size,
    required this.title,
    this.secondary,
    this.itemStyle,
    this.controlAffinity = MenuItemControlAffinity.leading
  }) : super(key: key);

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final MouseCursor? mouseCursor;
  final bool toggleable;
  final Color? activeColor;
  final MaterialStateProperty<Color?>? fillColor;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final double? size;
  final Widget title;
  final Widget? secondary;
  final MenuItemStyle? itemStyle;
  final MenuItemControlAffinity controlAffinity;

  @override
  bool get hasLeadingWidget => controlAffinity == MenuItemControlAffinity.leading;

  @override
  Widget build(BuildContext context) {
    final control = avocado.Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      mouseCursor: mouseCursor,
      toggleable: toggleable,
      activeColor: activeColor,
      fillColor: fillColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      overlayColor: overlayColor,
      splashRadius: splashRadius,
      materialTapTargetSize: materialTapTargetSize,
      visualDensity: visualDensity,
      focusNode: focusNode,
      autofocus: autofocus,
      size: size
    );

    final Widget? leading, trailing;
    switch (controlAffinity) {
      case MenuItemControlAffinity.leading:
        leading = control;
        trailing = secondary;
        break;
      case MenuItemControlAffinity.trailing:
        leading = secondary;
        trailing = control;
        break;
    }

    return MenuItem(
      leading: leading,
      title: title,
      trailing: trailing,
      onPressed: () {
        onChanged(value);
      },
      style: itemStyle,
      closeMenuOnAction: false,
    );
  }
}

class MenuRadioGroup<T> extends StatelessWidget implements MenuItemWidget {
  const MenuRadioGroup({ 
    Key? key,
    required this.values,
    required this.groupValue,
    required this.onChanged,
    this.mouseCursor,
    this.toggleable = false,
    this.activeColor,
    this.fillColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.focusNode,
    this.autofocus = false,
    this.size,
    this.controlAffinity = MenuItemControlAffinity.leading
  }) : super(key: key);

  // A map of radio values to the values' string representions
  // used as menu item titles.
  final Map<T, String> values;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final MouseCursor? mouseCursor;
  final bool toggleable;
  final Color? activeColor;
  final MaterialStateProperty<Color?>? fillColor;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final double? size;
  final MenuItemControlAffinity controlAffinity;

  @override
  bool get hasLeadingWidget => values.isNotEmpty && controlAffinity == MenuItemControlAffinity.leading;

  @override
  Widget build(BuildContext context) {
    final menuStyle = ResolvedMenuTheme.of(context)!;

    return Flex(
      direction: menuStyle.axis,
      mainAxisSize: MainAxisSize.min,
      children: values.entries.map((entry) {
        return RadioMenuItem(
          value: entry.key,
          groupValue: groupValue,
          onChanged: onChanged,
          mouseCursor: mouseCursor,
          toggleable: toggleable,
          activeColor: activeColor,
          fillColor: fillColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          overlayColor: overlayColor,
          splashRadius: splashRadius,
          materialTapTargetSize: materialTapTargetSize,
          visualDensity: visualDensity,
          focusNode: focusNode,
          autofocus: autofocus,
          size: size,
          title: Text(entry.value),
          controlAffinity: controlAffinity,
        );
      }).toList(),
    );
  }
}

class MenuItemWidgetWrapper extends StatelessWidget implements MenuItemWidget {
  const MenuItemWidgetWrapper({
    Key? key,
    this.hasLeadingWidget = false,
    required this.child
  }) : super(key: key);

  @override
  final bool hasLeadingWidget;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}