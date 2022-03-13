import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:avocado_utils/avocado_utils.dart';

import 'menu.dart' as pkg;
import 'menu_manager.dart';
import 'menu_theme.dart';

typedef ShowMenu = Route Function(
  BuildContext context, 
  Widget menu, { 
  Axis? menuAxis, 
  Position? menuPosition,
  BuildContext? alignmentContext,
  MenuStyle? menuStyle,
  MenuManagerController? menuManagerController,
  Color? barrierColor,
  VoidCallback? didClose
});

typedef CallShowMenu = Route Function(ShowMenu);

class MenuRouter {
  MenuRouter(this.callShowMenu);

  CallShowMenu callShowMenu;
  final key = UniqueKey();
  Route? _route;
  late VoidCallback didClose;
  late MenuManagerController menuManagerController;
  bool get open => _route != null && _route!.isActive;

  Route _showMenu(  
    BuildContext context, 
    Widget menu, { 
    Axis? menuAxis, 
    Position? menuPosition,
    BuildContext? alignmentContext,
    MenuStyle? menuStyle,
    MenuManagerController? menuManagerController,
    Color? barrierColor,
    VoidCallback? didClose
  }) {
    this.didClose = () {
      _route = null;
      didClose?.call();
    };

    this.menuManagerController = menuManagerController ?? MenuManagerController(); 

    return pkg.showMenu(
      context, menu,
      menuAxis: menuAxis,
      menuPosition: menuPosition,
      alignmentContext: alignmentContext,
      menuStyle: menuStyle,
      menuManagerController: this.menuManagerController,
      barrierColor: barrierColor,
      route: _route
    );
  }

  void showMenu() {
    assert(_route == null);
    Route route = callShowMenu(_showMenu);
    _route = route;
    _route!.popped.then((value) => didClose());
  }

  void updateMenu() {
    if (_route != null)
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        callShowMenu(_showMenu);
      });
  }
}