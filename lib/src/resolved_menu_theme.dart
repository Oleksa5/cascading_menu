import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart';

import 'menu_item_button.dart';
import 'menu_theme.dart';
import 'resolved_menu_style.dart';

class ResolvedMenuTheme extends StatelessWidget {
  const ResolvedMenuTheme({ 
    Key? key,
    required this.style,
    required this.child
  }) : super(key: key);

  final ResolvedMenuStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _ResolvedMenuTheme(
      style: style,
      child: DefaultTextStyle(
        style: style.textStyle,
        child: DividerTheme(
          data: style.dividerStyle,
          child: ResolvedMenuItemTheme(
            style: style.itemStyle,
            child: child
          )
        )
      ),
    );
  }

  static ResolvedMenuStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ResolvedMenuTheme>()?.style;
  }
}

class _ResolvedMenuTheme extends InheritedWidget {
  const _ResolvedMenuTheme({
    required this.style,
    required Widget child
  }) : super(
    child: child
  );

  final ResolvedMenuStyle style;

  @override
  bool updateShouldNotify(_ResolvedMenuTheme oldWidget) => style != oldWidget.style;
}

class ResolvedMenuItemTheme extends StatelessWidget {
  const ResolvedMenuItemTheme({ 
    Key? key,
    required this.style,
    required this.child
  }) : super(key: key);

  final ResolvedMenuItemStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _ResolvedMenuItemTheme(
      style: style,
      child: MenuItemButtonTheme(
        style: createDefaultButtonStyle(context, ResolvedMenuTheme.of(context)!, style),
        child: IconTheme(
          data: style.iconStyle,
          child: child
        )
      ),
    );
  }

  static ResolvedMenuItemStyle? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ResolvedMenuItemTheme>()?.style;
  }
}

class _ResolvedMenuItemTheme extends InheritedWidget {
  const _ResolvedMenuItemTheme({
    required this.style,
    required Widget child
  }) : super(
    child: child
  );

  final ResolvedMenuItemStyle style;

  @override
  bool updateShouldNotify(_ResolvedMenuItemTheme oldWidget) => style != oldWidget.style;
}

class AnimatedResolvedMenuTheme extends StatefulWidget {
  const AnimatedResolvedMenuTheme({
    Key? key,
    required this.style,
    this.axis,
    required this.child,
  }) : super(key: key);

  final MenuStyle style;
  final Axis? axis;
  final Widget child;

  @override
  State<AnimatedResolvedMenuTheme> createState() => _AnimatedMenuThemeState();
}

class _AnimatedMenuThemeState extends State<AnimatedResolvedMenuTheme> 
    with TickerProviderStateMixin, AnimatedStateMixin {
  final style = MenuStyleTween();

  @override
  Widget build(BuildContext context) {
    final resolve = makeMenuStyleResolver(context, widget.style);

    animationDuration = resolve((style) => style.animationDuration)!;

    updateTweens((visitor) {
      visitor(style, widget.style);
    });

    return ResolvedMenuTheme(
      style: resolveMenuStyle(context, evaluate(style), widget.axis),
      child: widget.child,
    );
  }
}