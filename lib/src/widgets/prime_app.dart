import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import '../theme/prime_theme_data.dart';
import '../theme/prime_theme_mode.dart';
import 'prime_page_route.dart';
import 'scroll_behavior.dart';

/// The root of a Prime app: what `MaterialApp` or `CupertinoApp` is to their
/// design systems, built on [WidgetsApp] alone.
///
/// It provides everything the widgets beneath it expect from an app root:
///
///  * a [PrimeTheme], chosen from [theme] and [darkTheme] by [themeMode];
///  * a [Navigator] (or a [Router], with [PrimeApp.router]) whose pages
///    transition with [PrimePageRoute];
///  * a [HeroController], so [Hero]s fly between pages;
///  * a [ScrollConfiguration] with [PrimeScrollBehavior];
///  * default text, icon and text-selection styles from the theme;
///  * the framework's localizations, keyboard shortcuts and focus traversal.
///
/// ```dart
/// void main() => runApp(const PrimeApp(title: 'My app', home: HomeScreen()));
/// ```
///
/// ## Localization
///
/// Prime's widgets take their few built-in strings from [WidgetsLocalizations],
/// which is English and left-to-right unless told otherwise. To follow the
/// device language and text direction, add `flutter_localizations` to your
/// app and pass `GlobalWidgetsLocalizations.delegate` in
/// [localizationsDelegates], along with your [supportedLocales].
///
/// ## Mixing in Material or Cupertino widgets
///
/// A Material or Cupertino widget placed under a `PrimeApp` (your own, or one
/// from a package) may look up `MaterialLocalizations` or
/// `CupertinoLocalizations`. Provide them through [localizationsDelegates]:
/// `GlobalMaterialLocalizations.delegates` from `package:material_ui` covers
/// Material, Cupertino and the widgets layer.
class PrimeApp extends StatefulWidget {
  /// A one-line description of the app for the device, e.g. in the task
  /// switcher. See [onGenerateTitle] for a localized title.
  final String title;

  /// Generates the app title from localized strings. Wins over [title].
  final GenerateAppTitle? onGenerateTitle;
  final Widget? home;
  final Map<String, WidgetBuilder>? routes;
  final String? initialRoute;
  final bool debugShowCheckedModeBanner;
  final GlobalKey<NavigatorState>? navigatorKey;
  final RouteFactory? onGenerateRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final RouteFactory? onUnknownRoute;
  final List<NavigatorObserver>? navigatorObservers;
  final TransitionBuilder? builder;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool showPerformanceOverlay;
  final bool showSemanticsDebugger;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final String? restorationScopeId;

  /// The theme, and the light theme when [darkTheme] is also given.
  /// Defaults to [PrimeThemeData.light].
  final PrimeThemeData? theme;

  /// The theme used when [themeMode] resolves to dark. Defaults to [theme].
  final PrimeThemeData? darkTheme;

  final PrimeThemeMode themeMode;

  /// How scrollables behave throughout the app. Defaults to [PrimeScrollBehavior].
  final ScrollBehavior? scrollBehavior;

  /// Called for each navigation change, e.g. to tell the platform whether the
  /// app can handle the system back gesture. See [WidgetsApp.onNavigationNotification].
  final NotificationListenerCallback<NavigationNotification>? onNavigationNotification;

  // Router specific
  final RouteInformationProvider? routeInformationProvider;
  final RouteInformationParser<Object>? routeInformationParser;
  final RouterDelegate<Object>? routerDelegate;
  final BackButtonDispatcher? backButtonDispatcher;
  final RouterConfig<Object>? routerConfig;

  const PrimeApp({
    super.key,
    this.title = '',
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.debugShowCheckedModeBanner = false,
    this.navigatorKey,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.showSemanticsDebugger = false,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.theme,
    this.darkTheme,
    this.themeMode = PrimeThemeMode.system,
    this.scrollBehavior,
    this.onGenerateTitle,
    this.onNavigationNotification,
  }) : routeInformationProvider = null,
       routeInformationParser = null,
       routerDelegate = null,
       backButtonDispatcher = null,
       routerConfig = null;

  const PrimeApp.router({
    super.key,
    this.title = '',
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.backButtonDispatcher,
    this.routerConfig,
    this.debugShowCheckedModeBanner = false,
    this.builder,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.showSemanticsDebugger = false,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.theme,
    this.darkTheme,
    this.themeMode = PrimeThemeMode.system,
    this.scrollBehavior,
    this.onGenerateTitle,
    this.onNavigationNotification,
  }) : home = null,
       routes = null,
       initialRoute = null,
       navigatorKey = null,
       onGenerateRoute = null,
       onGenerateInitialRoutes = null,
       onUnknownRoute = null,
       navigatorObservers = null;

  @override
  State<PrimeApp> createState() => _PrimeAppState();
}

class _PrimeAppState extends State<PrimeApp> {
  // Material and Cupertino apps each install one. Without it, Heroes do not fly.
  final HeroController _heroController = HeroController();

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  bool get _usesRouter => widget.routerDelegate != null || widget.routerConfig != null;

  Widget _buildWidgetApp(BuildContext context, PrimeThemeData theme) {
    if (_usesRouter) {
      return WidgetsApp.router(
        key: GlobalObjectKey(this),
        title: widget.title,
        onGenerateTitle: widget.onGenerateTitle,
        onNavigationNotification: widget.onNavigationNotification,
        color: theme.colorScheme.actionPrimaryBg,
        textStyle: theme.textTheme.bodyDefault,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        routeInformationProvider: widget.routeInformationProvider,
        routeInformationParser: widget.routeInformationParser,
        routerDelegate: widget.routerDelegate,
        routerConfig: widget.routerConfig,
        backButtonDispatcher: widget.backButtonDispatcher,
        builder: _builder,
        locale: widget.locale,
        localizationsDelegates: widget.localizationsDelegates,
        localeListResolutionCallback: widget.localeListResolutionCallback,
        localeResolutionCallback: widget.localeResolutionCallback,
        supportedLocales: widget.supportedLocales,
        showPerformanceOverlay: widget.showPerformanceOverlay,
        showSemanticsDebugger: widget.showSemanticsDebugger,
        shortcuts: widget.shortcuts,
        actions: widget.actions,
        restorationScopeId: widget.restorationScopeId,
      );
    }

    return WidgetsApp(
      key: GlobalObjectKey(this),
      title: widget.title,
      onGenerateTitle: widget.onGenerateTitle,
      onNavigationNotification: widget.onNavigationNotification,
      color: theme.colorScheme.actionPrimaryBg,
      textStyle: theme.textTheme.bodyDefault,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      home: widget.home,
      routes: widget.routes ?? const <String, WidgetBuilder>{},
      initialRoute: widget.initialRoute,
      navigatorKey: widget.navigatorKey,
      onGenerateRoute: widget.onGenerateRoute,
      onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
      onUnknownRoute: widget.onUnknownRoute,
      navigatorObservers: widget.navigatorObservers ?? const <NavigatorObserver>[],
      builder: _builder,
      locale: widget.locale,
      localizationsDelegates: widget.localizationsDelegates,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      localeResolutionCallback: widget.localeResolutionCallback,
      supportedLocales: widget.supportedLocales,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
      restorationScopeId: widget.restorationScopeId,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PrimePageRoute<T>(settings: settings, builder: builder);
      },
    );
  }

  PrimeThemeData get _theme {
    final mode = widget.themeMode;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final useDarkTheme = mode == PrimeThemeMode.dark || (mode == PrimeThemeMode.system && platformBrightness == Brightness.dark);

    final theme = widget.theme ?? PrimeThemeData.light();
    final darkTheme = widget.darkTheme ?? theme;

    if (useDarkTheme) {
      return darkTheme;
    }
    return theme;
  }

  // Runs above the Navigator, so everything here reaches every route,
  // including dialogs, sheets and overlays.
  Widget _builder(BuildContext context, Widget? child) {
    final theme = _theme;
    final colors = theme.colorScheme;
    final content = child ?? const SizedBox.shrink();

    return PrimeTheme(
      data: theme,
      child: DefaultSelectionStyle(
        cursorColor: colors.inputFocus,
        selectionColor: colors.inputFocus.withValues(alpha: 0.3),
        child: IconTheme(
          data: IconThemeData(color: colors.iconPrimary, size: 24),
          child: DefaultTextStyle(
            style: theme.textTheme.bodyDefault,
            child: Builder(builder: (context) => widget.builder?.call(context, content) ?? content),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: widget.scrollBehavior ?? const PrimeScrollBehavior(),
      child: HeroControllerScope(controller: _heroController, child: _buildWidgetApp(context, _theme)),
    );
  }
}
