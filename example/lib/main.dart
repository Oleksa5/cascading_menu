import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avocado_utils/avocado_utils.dart' hide Theme, Listener;
import 'package:avocado_utils/avocado_utils.dart' as avocado;
import 'package:cascading_menu/cascading_menu.dart';

void main() {
  runApp(ExampleApp());
}

class ToogleBrightnessIntent extends Intent {
  const ToogleBrightnessIntent();
}

class ExampleApp extends StatefulWidget {
  ExampleApp({ Key? key }) : super(key: key);

  static const String title = 'Cascading Menu Example';

  static const toogleBrightnessActivator = SingleActivator(LogicalKeyboardKey.keyB, control: true);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode themeMode = ThemeMode.dark;
  VisualDensity visualDensity = VisualDensity.adaptivePlatformDensity;

  ThemeData makeTheme(ColorScheme colorScheme) {
    return avocado.themeFromColorScheme(colorScheme).copyWith(
      visualDensity: visualDensity
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ExampleApp.title,
      theme: makeTheme(
        const ColorScheme.light(surface: Color(0xFFF0F0F0))
      ), 
      darkTheme: makeTheme(
        const ColorScheme.dark(),
      ),
      themeMode: themeMode,
      builder: (context, child) {
        final theme = Theme.of(context);
        
        return avocado.Theme(
          child: MenuTheme(
            style: MenuStyle(
              itemStyle: MenuItemStyle(
                overlayColor: MenuItemMaterialStateProperty.resolveWith((states) {
                  return theme.colorScheme.primary.withOpacity(0.5);
                }),
                startPaddingStyle: StartPaddingStyle.alwaysLargeForVerticalMenuWithAtLeastOneLeadingWidget
              ),
            ),
            child: child!
          ),
        );
      },
      home: Example(),
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        ExampleApp.toogleBrightnessActivator: const ToogleBrightnessIntent(),
      },
      actions: {
        ...WidgetsApp.defaultActions,
        ToogleBrightnessIntent : 
          CallbackAction(onInvoke: (_) => setState(() {
            assert(themeMode == ThemeMode.light || themeMode == ThemeMode.dark);
            if (themeMode == ThemeMode.dark)
                 themeMode = ThemeMode.light;
            else themeMode = ThemeMode.dark;
          }))
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

enum ExampleColor {
  none, red, yellow, green, blue 
}

class FillIntent extends Intent {
  const FillIntent(this.color);
  final ExampleColor color;
}

class MoveIntent extends Intent {
  const MoveIntent(this.direction);
  final VerticalDirection direction;
}

class Example extends StatefulWidget {
  static const lightColors = {
    ExampleColor.red: Color(0xFFf48686),
    ExampleColor.yellow: Color(0xFFfaf666),
    ExampleColor.green: Color(0XFF09e8ae),
    ExampleColor.blue: Color(0XFF87ccf5)
  }; 

  static const darkColors = {
    ExampleColor.red: Color(0xFF703232),
    ExampleColor.yellow: Color(0xFF76731d),
    ExampleColor.green: Color(0xFF00644a),
    ExampleColor.blue: Color(0xFF355b71)
  };

  static Color? resolveColor(ExampleColor color, Brightness brightness) {
    if (color == ExampleColor.none) return null;
    else return brightness == Brightness.light ? 
      Example.lightColors[color] : Example.darkColors[color];
  }

  static const moveUpActivator   = SingleActivator(LogicalKeyboardKey.arrowUp, alt: true);
  static const moveDownActivator = SingleActivator(LogicalKeyboardKey.arrowDown, alt: true);
  static const doNothingActivator0 = SingleActivator(LogicalKeyboardKey.keyA, control: true);
  static const doNothingActivator1 = SingleActivator(LogicalKeyboardKey.keyR, control: true);
  static const doNothingActivator2 = SingleActivator(LogicalKeyboardKey.keyT, alt: true);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context)
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double toolbarHeight = barHeight(theme.visualDensity);

    return AppBar(
      toolbarHeight: toolbarHeight,
      leadingWidth: toolbarHeight,
      title: const Text(ExampleApp.title),
      actions: [
        Center(
          child: MenuButton(
            menu: Menu(
              items: [
                MenuItem(
                  title: const Text('Toogle Brightness'),
                  shortcutActivator: ExampleApp.toogleBrightnessActivator,
                ),
                MenuItem(
                  title: const Text('Interea Venientum'),
                  onPressed: () {}
                ),
              ]
            )
          ),
        ),
      ],
      elevation: kMenuElevation,
      backgroundColor: colorScheme.surface,
      foregroundColor: theme.brightness == Brightness.light ? 
        colorScheme.onSurface.withOpacity(0.55) : colorScheme.onSurface,
    );
  } 

  List<Widget> regions = [
    ExampleRegion(
      'Region with vertical menu',
      key: GlobalKey(),
      menuAxis: Axis.vertical,
    ),
    ExampleRegion(
      'Region with horizontal menu',
      key: GlobalKey(),
      menuAxis: Axis.horizontal,
    ),
    ExampleRegion(
      'Region with centered menu',
      key: GlobalKey(),
      menuAxis: Axis.vertical,
      menuAlignment: Alignment.center
    ),
  ];

  Widget _buildBody(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        Example.moveUpActivator:      const MoveIntent(VerticalDirection.up),  
        Example.moveDownActivator:    const MoveIntent(VerticalDirection.down),

        Example.doNothingActivator0:  DoNothingIntent(),
        Example.doNothingActivator1:  DoNothingIntent(),
        Example.doNothingActivator2:  DoNothingIntent(),
      },
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPadding05),
            child: SizedBox(
              width: kUnit * 64,
              child: Column(
                children: regions.mapIndexed((region, i) {
                  return Actions(
                    actions: {
                      MoveIntent : CallbackAction<MoveIntent>(onInvoke: (intent) {
                        int? j;
                        switch (intent.direction) {
                          case VerticalDirection.up:
                            if (i > 0) j = i-1;
                            break;
                          case VerticalDirection.down:
                            if (i < (regions.length - 1)) j = i+1;
                            break;
                        }

                        if (j != null) 
                          setState(() => regions.swap(i, j!));

                        return;
                      })
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: kPadding05, 
                        bottom: region != regions.last ? 0 : kPadding
                      ),
                      child: region,
                    ),
                  );
                })
              )
            ),
          ),
        )
      )
    );
  }
}

class ExampleRegion extends StatefulWidget {
  const ExampleRegion(
    this.text, {
    Key? key,
    required this.menuAxis,
    this.menuAlignment
  }) : super(key: key);

  static const double kMinFontSizeLimit = 15.0;
  static const double kFontSize = 20.0;
  static const double kMaxFontSizeLimit = 25.0;
  static const double kMinHeight = kFontSize + 2 * kPadding + kUnit * 8;

  final String text;
  final Axis menuAxis;
  final Alignment? menuAlignment;

  @override
  State<ExampleRegion> createState() => _ExampleRegionState();
}

class _ExampleRegionState extends State<ExampleRegion> {
  final focusNode = FocusNode(); 
  ExampleColor color = ExampleColor.none;
  double fontSize = ExampleRegion.kFontSize;
  static const kFontWeights = [ FontWeight.w300, FontWeight.w400, FontWeight.w600 ];
  int fontWeightIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderWidth = toLogicalPixels(1, context);
    final headline5 = theme.textTheme.headline5!;

    return ContextMenuRegion(
      menuAxis: widget.menuAxis,
      menuAlignment: widget.menuAlignment,
      menu: buildMenu(widget.menuAxis),
      child: Listener(
        onPointerDown: (_) => focusNode.requestFocus(),
        child: Focus(
          focusNode: focusNode,
          onFocusChange: (focused) => setState(() {}),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(kPadding),
            decoration: BoxDecoration(
              color: Example.resolveColor(color, theme.brightness),
              border: focusNode.hasPrimaryFocus ?
                Border.all(
                  color: theme.brightness == Brightness.light ? 
                    Colors.black : Colors.blue.shade300,
                  width: borderWidth * 3
                ) :
                Border.all(
                  color: theme.brightness == Brightness.light ? 
                    Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.5),
                  width: borderWidth,
                  style: color == ExampleColor.none ? BorderStyle.solid : BorderStyle.none
                ),
              borderRadius: const BorderRadius.all(Radius.circular(kRadius))  
            ),
            constraints: const BoxConstraints(minHeight: ExampleRegion.kMinHeight),
            child: Text(
              widget.text, 
              style: headline5.copyWith(
                color: headline5.color?.withOpacity(0.3),
                fontSize: fontSize,
                fontWeight: kFontWeights[fontWeightIndex]
              ),
            ),
          ),
        ),
      ),
    );
  }

  Menu buildMenu(Axis axis) {
    void changeColor(ExampleColor? value) => setState(() => color = value!);

    return Menu(
      items: [
        MenuItem(
          title: const Text('Ad Astra'), 
          enabled: color != ExampleColor.none,
          shortcutActivator: Example.doNothingActivator0,
        ),
        
        if (axis == Axis.vertical)
          MenuItem(
            title: const Text('Haec Concordia'), 
            onPressed: color == ExampleColor.none ? null : () {}
          ),

        MenuItem(
          title: const Text('Arrange'),
          submenu: Menu(
            items: [
              MenuItem(
                title: const Text('Move Up'),
                shortcutActivator: Example.moveUpActivator,
              ),

              MenuItem(
                title: const Text('Move Down'),
                shortcutActivator: Example.moveDownActivator,
              ),
            ]
          ),
        ), 

        MenuItem(
          leading: const Icon(Icons.star_outlined),
          title: const Text('Appearance'),
          submenu: Menu(
            items: [
              MenuItem(
                title: const Text('Fill'),
                leading: const Icon(Icons.format_color_fill_outlined),
                submenu: Menu(
                  menuStyle: MenuStyle(
                    vertMenuMinWidth: kVertMenuMinWidth * 0.75
                  ),
                  items: [
                    MenuRadioGroup<ExampleColor>(
                      values : const {
                        ExampleColor.none   : 'None',
                        ExampleColor.red    : 'Red',
                        ExampleColor.yellow : 'Yellow',
                        ExampleColor.green  : 'Green',
                        ExampleColor.blue   : 'Blue'                      
                      },
                      groupValue: color,
                      onChanged: changeColor,
                      controlAffinity: MenuItemControlAffinity.trailing,
                    )
                  ]
                ),
              ),

              MenuItem(
                leading: const Icon(Icons.text_format_outlined),
                title: const Text('Font'), 
                submenu: Menu(
                  items: [
                    SliderMenuItem(
                      title: const Text('Size'), 
                      value: fontSize, 
                      onChanged: (value) => setState(() => fontSize = value),
                      min: ExampleRegion.kMinFontSizeLimit,
                      max: ExampleRegion.kMaxFontSizeLimit,
                      divisions: 10,
                    ),
                    SliderMenuItem(
                      title: const Text('Weight'), 
                      value: fontWeightIndex.toDouble(), 
                      onChanged: (value) => setState(() => fontWeightIndex = value.toInt()),
                      min: 0.0,
                      max: 2.0,
                      divisions: 2,
                      label: kFontWeights[fontWeightIndex].toString().split('.').last,
                    ),
                  ],
                ),
              ),
              
            ]
          ),
        ),

        const MenuDivider(),

        MenuItem(
          leading: const Icon(Icons.emoji_emotions), 
          title: const Text('Conformeu'),
          shortcutActivator: Example.doNothingActivator1,
        ),

        const MenuDivider(),

        if (axis == Axis.vertical)
          MenuItem(
            title: const Text('Interea Venientum'),
            onPressed: () {}
          ),

        if (axis == Axis.vertical) 
          MenuItem(
            leading: const Icon(Icons.assessment),
            title: const Text('Tellure Levatur'), 
            shortcutActivator: Example.doNothingActivator2,
            enabled:  color != ExampleColor.none,
          ),
      ]
    );
  }
}