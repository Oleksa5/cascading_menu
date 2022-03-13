import 'package:flutter/material.dart';
import 'package:avocado_utils/avocado_utils.dart';

const double kVertMenuMinWidth        = kUnit * 28;
const double kMenuAreaPadding         = kPadding025;
const double kMenuVertPadding         = kPadding025; 
const double kVertSubmenuMargin       = -kPadding025;
const double kHorzSubmenuMargin       = 0;
const double kButtonMenuPadding       = kPadding025;
const double kMenuItemIconSize        = kIconSize;
const double kMenuItemTopPadding      = kPadding075;
const double kMenuItemBottomPadding   = kPadding075;
const double kMenuItemStartPadding    = kPadding;
const double kMenuItemEnlargedStartPadding = kMenuItemStartPadding * 2;
const double kMenuItemEndPadding      = kPadding;
const double kMenuItemContentsVertSpacing = kPadding;
const double kMenuItemContentsMinHorzSpacing = kPadding;
const double kMenuCornerRadius        = kUnit025;
const double kMenuElevation           = 2;

double menuItemHeight([ VisualDensity visualDensity = const VisualDensity() ]) { 
  return barHeight(visualDensity);
}
