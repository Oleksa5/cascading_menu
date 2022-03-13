import 'dart:async';
import 'dart:math' show max;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:avocado_utils/avocado_utils.dart' hide Listener;

import 'menu_theme.dart';
import 'resolved_menu_style.dart';
import 'resolved_menu_theme.dart';
import 'open_menu_button.dart';
import 'menu_stack.dart';

class MenuManagerController {
  VoidCallback? _close;
  VoidCallback get close => _close!;
  bool debugBarrierDismissible = true;
}

class MenuManager extends StatelessWidget {
  const MenuManager({
    Key? key,
    this.menuAxis,
    this.menuStyle,
    this.targetContext,
    required this.menu,
    required this.closeCallback,
    required this.menuPosition,
    this.alignmentContext,
    this.animateStyleUpdates = true,
    this.menuManagerController
  }) : super(key: key);

  final Axis? menuAxis;
  final Position menuPosition;
  final MenuStyle? menuStyle;
  final BuildContext? targetContext;
  final Widget menu;
  final VoidCallback closeCallback;
  final BuildContext? alignmentContext;
  final bool animateStyleUpdates;
  final MenuManagerController? menuManagerController;

  @override
  Widget build(BuildContext context) {
    menuManagerController?._close = closeCallback;

    Widget result = Stack(
      children: [
        // One reason to use Listener instead of GestureDetector is that 
        // Listener's callbacks get called before Navigator makes a pointer active. 
        // This enables other hit targets respond to the pointer's up event before 
        // it gets canceled after navigation. Note, it's not necessary to use 
        // Navigator to present a menu.
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            if (!kDebugMode || (menuManagerController?.debugBarrierDismissible ?? true)) {
              closeCallback();
            }
          }
        ),
        _MenuManager(
          menuPosition: menuPosition,
          targetContext: targetContext,
          menu: menu,
          closeCallback: closeCallback,
          alignmentContext: alignmentContext
        )
      ]
    );

    return animateStyleUpdates && menuStyle != null ?
      AnimatedResolvedMenuTheme(
        style: menuStyle!, 
        child: result
      ) :
      ResolvedMenuTheme(
        style: resolveMenuStyle(context, menuStyle, menuAxis), 
        child: result
      );
  }

  static MenuManagerState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MenuManagerScope>()?.state;
  }
}

class _MenuManager extends MultipassBuildWidget {
  const _MenuManager({
    required this.menuPosition,
    this.targetContext,
    required this.menu,
    required this.closeCallback,
    this.alignmentContext
  });

  final Position menuPosition;
  final BuildContext? targetContext;
  final Widget menu;
  final VoidCallback closeCallback;
  final BuildContext? alignmentContext;

  @override
  createState() => MenuManagerState();
}

class _MenuManagerScope extends InheritedWidget {
  const _MenuManagerScope({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  final MenuManagerState state;

  @override
  bool updateShouldNotify(_MenuManagerScope old) => false;
}

class MenuManagerState extends MultipassBuildState<_MenuManager> with TickerProviderStateMixin {
  final List<OpenMenuButtonState> _openItems = [];
  final List<_InitiatedMenu> _openMenus = [];
  int? _updatedMenuIndex;
  int _lastMenuIndex = -1;
  int get _newLastMenuIndex => _openItems.length;
  final List<AnimationController> _transitionControllers = [];
  // To enable relayout on animation updates.
  final GlobalKey _menuStackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    addTransitionController();
  }

  @override
  Widget build(BuildContext context) {
    return _MenuManagerScope(
      state: this,
      child: MenuStack(
        key: _menuStackKey,
        topMenuParentData: TopMenuParentData(
          position: widget.menuPosition
        ),
        children: _buildMenus(context),
      ),
    );
  }

  @override
  bool afterPass() {
    assert(_newLastMenuIndex <= _lastMenuIndex + 1);
    _updatedMenuIndex = _updatedMenuIndex! + 1;
    if (_updatedMenuIndex! > max(_lastMenuIndex, _newLastMenuIndex)) {
      _updatedMenuIndex = null;
      return false;
    } else {
      return true;
    }
  }

  List<_InitiatedMenu> _buildMenus(BuildContext context) {
    final menuStyle = ResolvedMenuTheme.of(context)!;

    final int i = _updatedMenuIndex ??= 0;

    if (i == (_lastMenuIndex + 1)) {
      assert(i == _newLastMenuIndex);
      _openMenus.add(const _NullMenu());
    }

    if (i == 0)
      _openMenus[i] = _buildTopMenu(menuStyle);
    else if (i < _openMenus.length) 
      _openMenus[i] = _buildSubmenu(menuStyle, i);

    _lastMenuIndex = _openMenus.length - 1;
    return _openMenus.toList();
  }

  _InitiatedMenu _buildMenu(
    ResolvedMenuStyle menuStyle, 
    Widget menu, 
    BuildContext? initiatingItem, 
    Alignment scaleTransitionAlignment, 
    int index
  ) {
    if (menuStyle.isAnimated) {
      menu = ScaleTransition(
        alignment: scaleTransitionAlignment,
        scale: _transitionControllers[index]
          ..duration = menuStyle.animationDuration
          ..forward(),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: ((notification) {
            markMenuStackNeedsLayout();
            return true;
          }),
          child: menu
        )
      );
    }

    return _InitiatedMenu(
      initiatingItem: initiatingItem?.findRenderObject() as RenderBox?,               
      child: menu
    );
  }

  _InitiatedMenu _buildTopMenu(ResolvedMenuStyle menuStyle) {
    return _buildMenu(
      menuStyle,
      widget.menu, 
      widget.alignmentContext, 
      widget.menuPosition.alignment, 
      0
    );
  }

  _InitiatedMenu _buildSubmenu(ResolvedMenuStyle menuStyle, int index) {
    return _buildMenu(
      menuStyle,
      _openItems[index-1].widget.menu, 
      _openItems[index-1].context, 
      menuStyle.axis == Axis.vertical ? Alignment.topLeft : Alignment.topCenter,
      index
    );
  }

  void addTransitionController() {
    _transitionControllers.add(AnimationController(vsync: this));
    // This mainly targets an issue when a submenu is opened on a menu currently running
    // an animation. That may result in an improper final position of the submenu. 
    // Menu stack layout depends on menus appearance. Therefore it needs to be 
    // notified when their appearance changes. ScaleTransition doesn't cause
    // relayout, only repaint. Another solution would be extending RenderTransform
    // and overriding transform setter to markNeedsLayout. 
    _transitionControllers.last.addListener(onMenuAnimationChange);
  }

  void markMenuStackNeedsLayout() => _menuStackKey.currentContext?.findRenderObject()!.markNeedsLayout();

  void onMenuAnimationChange() => markMenuStackNeedsLayout();

  void onPointerEnteredActionItem(BuildContext item) {
    int menuIndex = findMenuIndexOf(item);
    if (menuIndex == -1) return;
    _discardMenusFrom(menuIndex + 1);
  }

  int findMenuIndexOf(BuildContext item) {
    final menu = item.findAncestorWidgetOfExactType<_InitiatedMenu>()!;
    return _openMenus.indexOf(menu);
  }

  void openItem(OpenMenuButtonState item) {
    assert(item.context.findAncestorStateOfType<MenuManagerState>() == this);
    int menuIndex = findMenuIndexOf(item.context);
    // This may happen to be true when a pointer's position and 
    // the manager's data get updated faster than the tree and 
    // the pointer hits an item of a submenu that was closed 
    // but not yet removed from the tree.
    if (menuIndex == -1) return;
    int index = _openItems.indexOf(item);
    if (index == -1) {
      _discardMenusFrom(menuIndex + 1);
      _openItems.add(item);
      assert(_openItems.length <= _transitionControllers.length);
      if (_openItems.length == _transitionControllers.length)
        addTransitionController();
    } else if (index != lastIndexOf(_openItems)) {
      _discardMenusFrom(menuIndex + 2);
    } else return;
  }

  void onItemDeactivated(OpenMenuButtonState item) {
    final itemIndex = _openItems.indexOf(item);
    if (_updatedMenuIndex != null && itemIndex != -1) {
      assert(_updatedMenuIndex == itemIndex);
      _discardMenusFrom(itemIndex + 1);
    }
  }

  void _discardMenusFrom(int index) {
    assert(index != 0);

    removeClosed() {
      _openMenus.removeRange(index, _openMenus.length);
      _openItems.removeRange(index - 1, _openItems.length);
    }

    int i = _openItems.length;
    if (_updatedMenuIndex == null) {
      for (; i >= index; i--) {
        _transitionControllers[i].reset();
        _openItems[i - 1].managerClosedMenu();
      }
      setState(removeClosed);
    } else {
      scheduleMicrotask(() {
        for (; i >= index; i--)
          _transitionControllers[i].reset();
      });
      removeClosed();
    }
  }

  void close() => widget.closeCallback();

  @override
  void dispose() {
    for (var controller in _transitionControllers)
      controller.dispose();
    super.dispose();
  }  
}

class _InitiatedMenu extends ParentDataWidget<MenuStackParentData> {
  const _InitiatedMenu({
    Key? key, 
    this.initiatingItem,
    required Widget child 
  }) :
    super(key: key, child: child);

  final RenderBox? initiatingItem;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MenuStackParentData);
    final parentData = renderObject.parentData as MenuStackParentData;
    if (initiatingItem == parentData.initiatingItem) return;
    parentData.initiatingItem = initiatingItem;
    AbstractNode? renderObjectParent = renderObject.parent;
    if (renderObjectParent is RenderObject) renderObjectParent.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MenuStack;
}

class _NullMenu extends _InitiatedMenu {
  const _NullMenu() : super(child: const _NullWidget());
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}