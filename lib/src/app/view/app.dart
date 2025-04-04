//
import 'package:shrine_example_app/src/controller.dart';

import 'package:shrine_example_app/src/model.dart';

import 'package:shrine_example_app/src/view.dart';

///
class MyApp extends AppStatefulWidget {
  ///
  // Global key to 'keep' the State object and just move around the Widget tree
  MyApp({Key? key}) : super(key: key ?? GlobalKey(debugLabel: 'shrine'));
  @override
  AppStateX createAppState() => _ShrineAppState();
}

///
class _ShrineAppState extends AppStateX {
  ///
  _ShrineAppState()
      : super(
          controller: ShrineApp(),
          errorHandler: AppErrorHandler.errorHandler,
          errorScreen: AppErrorHandler.displayErrorWidget,
          inUnknownRoute: AppErrorHandler.onUnknownRoute,
          home: HomePage(key: GlobalKey(debugLabel: 'HomePage')),
          object: AppStateModel(),
          onGenerateTitle: (context) => 'Shrine'.tr,
          initialRoute: '/login',
          inGenerateRoute: _getRoute,
          allowChangeTheme: true,
          allowChangeLocale: true,
          debugShowCheckedModeBanner: false,
//          debugPaintSizeEnabled: true,
//          debugPaintPointersEnabled: true,
//          debugPaintLayerBordersEnabled: true,
          localeResolutionCallback: L10n.localeResolutionCallback,
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            L10n.delegate,
          ],
        );

  @override
  void initState() {
    super.initState();
    L10n.translations = {
      const Locale('es', 'AR'): esWords,
      const Locale('fr', 'FR'): frWords,
    };
  }

  // Copy the platform from the main theme in order to support platform
  // toggling from the Gallery options menu.
  @override
  ThemeData? onTheme([BuildContext? context]) =>
      _kShrineTheme.copyWith(platform: Theme.of(context!).platform);

  @override
  Locale onLocale() {
    final _locale = Prefs.getString('locale', 'en_US');
    return L10n.toLocale(_locale)!;
  }
}

/// Passed to the parameter, onGenerateRoute, in the AppState object above.
Route<dynamic>? _getRoute(RouteSettings settings) {
  if (settings.name != '/login') {
    return null;
  }
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (BuildContext context) => const LoginPage(),
    fullscreenDialog: true,
  );
}

final ThemeData _kShrineTheme = _buildShrineTheme();

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: kShrineColorScheme,
    primaryColor: kShrinePink100,
    scaffoldBackgroundColor: kShrineBackgroundWhite,
    cardColor: kShrineBackgroundWhite,
//    errorColor: kShrineErrorRed,
    buttonTheme: const ButtonThemeData(
      colorScheme: kShrineColorScheme,
    ),
    primaryIconTheme: _customIconTheme(base.iconTheme),
    inputDecorationTheme:
        const InputDecorationTheme(border: CutCornersBorder()),
    textTheme: _buildShrineTextTheme(base.textTheme),
    primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
    iconTheme: _customIconTheme(base.iconTheme),
  );
}

IconThemeData _customIconTheme(IconThemeData original) {
  return original.copyWith(color: kShrineBrown900);
}

///
const ColorScheme kShrineColorScheme = ColorScheme(
  primary: kShrinePink100,
  primaryContainer: kShrineBrown900,
  secondary: kShrinePink50,
  secondaryContainer: kShrineBrown900,
  surface: kShrineSurfaceWhite,
  background: kShrineBackgroundWhite,
  error: kShrineErrorRed,
  onPrimary: kShrineBrown900,
  onSecondary: kShrineBrown900,
  onSurface: kShrineBrown900,
  onBackground: kShrineBrown900,
  onError: kShrineSurfaceWhite,
  brightness: Brightness.light,
);

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
        displayMedium:
            base.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        titleSmall: base.titleLarge?.copyWith(fontSize: 18),
        labelLarge:
            base.bodySmall?.copyWith(fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall: base.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
        labelSmall: base.labelLarge
            ?.copyWith(fontWeight: FontWeight.w500, fontSize: 14),
      )
      .apply(
        fontFamily: 'Raleway',
        displayColor: kShrineBrown900,
        bodyColor: kShrineBrown900,
      );
}
