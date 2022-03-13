// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart';

abstract class MenuItemMaterialStateProperty<T> implements MaterialStateProperty<T?> {
  T? get enabled => resolve({});
  T? get disabled => resolve({MaterialState.disabled});
  T? get hovered => resolve({MaterialState.hovered});
  T? get focused => resolve({MaterialState.focused});
  T? get pressed => resolve({MaterialState.pressed});

  MenuItemMaterialStateProperty<T> copyWith({
    T? enabled,
    T? disabled,    
    T? hovered,
    T? focused,
    T? pressed
  }) {
    return ResolvedMenuItemMaterialStateProperty<T>(
      enabled: enabled ?? this.enabled,
      disabled: disabled ?? this.disabled,
      hovered: hovered ?? this.hovered,
      focused: focused ?? this.focused,
      pressed: pressed ?? this.pressed
    );
  }

  static MenuItemMaterialStateProperty<T>? effectiveProperty<T>(
    MenuItemMaterialStateProperty<T>? first, 
    MenuItemMaterialStateProperty<T>? second, 
    MenuItemMaterialStateProperty<T>? third
  ) {
    final resolve = makeResolver(first, second, third);

    return ResolvedMenuItemMaterialStateProperty(
      enabled: resolve((property) => property.enabled),
      disabled: resolve((property) => property.disabled),
      hovered: resolve((property) => property.hovered),
      focused: resolve((property) => property.focused),
      pressed: resolve((property) => property.pressed)
    );
  }

  static MenuItemMaterialStateProperty<T>? merge<T>(MenuItemMaterialStateProperty<T>? a, MenuItemMaterialStateProperty<T>? b) {
    if (a == null) return b;
    else if (b == null) return a;
    else return a.copyWith(
      enabled: b.enabled,
      disabled: b.disabled,
      hovered: b.hovered,
      focused: b.focused,
      pressed: b.pressed
    );
  }

  static MenuItemMaterialStateProperty<T> resolveWith<T>(MaterialPropertyResolver<T?> callback) => _MenuItemMaterialStatePropertyWith<T>(callback);

  @override
  int get hashCode => Object.hash(
    enabled, disabled, hovered, focused, pressed
  );

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    if (other is MenuItemMaterialStateProperty) {
      assert(resolve({MaterialState.dragged}) == enabled && other.resolve({MaterialState.dragged}) == other.enabled);
      assert(resolve({MaterialState.selected}) == enabled && other.resolve({MaterialState.selected}) == other.enabled);
      assert(resolve({MaterialState.scrolledUnder}) == enabled && other.resolve({MaterialState.scrolledUnder}) == other.enabled);
      assert(resolve({MaterialState.error}) == enabled && other.resolve({MaterialState.error}) == other.enabled);

      return other.enabled == enabled
          && other.disabled == disabled
          && other.hovered == hovered
          && other.focused == focused
          && other.pressed == pressed;
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return '{ enabled: $enabled; disabled: $disabled; hovered: $hovered; focused: $focused; pressed: $pressed; }';
  }
}

class _MenuItemMaterialStatePropertyWith<T> extends MenuItemMaterialStateProperty<T> {
  _MenuItemMaterialStatePropertyWith(this._resolve);

  final MaterialPropertyResolver<T?> _resolve;

  @override
  T? resolve(Set<MaterialState> states) => _resolve(states);
}

class ResolvedMenuItemMaterialStateProperty<T> extends MenuItemMaterialStateProperty<T> {
  ResolvedMenuItemMaterialStateProperty({
    this.enabled,
    this.disabled,
    this.hovered,
    this.focused,
    this.pressed
  });

  final T? enabled;
  final T? disabled;
  final T? hovered;
  final T? focused;
  final T? pressed;

  @override
  T? resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled))
      return disabled;
    if (states.contains(MaterialState.pressed))
      return pressed;
    if (states.contains(MaterialState.focused))
      return focused;
    if (states.contains(MaterialState.hovered))
      return hovered;
    return enabled;
  }
}

MenuItemMaterialStateProperty<T>? lerpMenuItemProperties<T>(
  MenuItemMaterialStateProperty<T>? a,
  MenuItemMaterialStateProperty<T>? b, 
  double t, 
  T Function(T, T, double) lerp
) {
  if (a == null && b == null) return null;
  return LerpMenuItemProperties<T>(a, b, t, lerp);
}

class LerpMenuItemProperties<T> extends MenuItemMaterialStateProperty<T> {
  LerpMenuItemProperties(this.a, this.b, this.t, this.lerp);

  final MenuItemMaterialStateProperty<T?>? a, b;
  final double t;
  final T Function(T, T, double) lerp;

  @override
  T? resolve(Set<MaterialState> states) {
    return lerpIfNotNulls(a?.resolve(states), b?.resolve(states), t, lerp);
  }
}