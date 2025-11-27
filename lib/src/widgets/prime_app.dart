import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../theme/prime_theme.dart';
import '../theme/prime_theme_data.dart';

class PrimeApp extends StatefulWidget {
  final String title;
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
  final Map<LogicalKeySet, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final String? restorationScopeId;
  final PrimeThemeData? theme;
  final PrimeThemeData? darkTheme;

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
  Iterable<LocalizationsDelegate<dynamic>> get _localizationsDelegates sync* {
    if (widget.localizationsDelegates != null) {
      yield* widget.localizationsDelegates!;
    }
    yield GlobalMaterialLocalizations.delegate;
    yield GlobalCupertinoLocalizations.delegate;
    yield GlobalWidgetsLocalizations.delegate;
  }

  Widget _buildWidgetApp(BuildContext context) {
    if (widget.routerDelegate != null || widget.routerConfig != null) {
      return WidgetsApp.router(
        key: GlobalObjectKey(this),
        title: widget.title,
        color: (widget.theme ?? PrimeThemeData.light()).colorScheme.black,
        textStyle:
            (widget.theme ?? PrimeThemeData.light()).textTheme.bodyDefault,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        routeInformationProvider: widget.routeInformationProvider,
        routeInformationParser: widget.routeInformationParser,
        routerDelegate: widget.routerDelegate,
        routerConfig: widget.routerConfig,
        backButtonDispatcher: widget.backButtonDispatcher,
        builder: _builder,
        locale: widget.locale,
        localizationsDelegates: _localizationsDelegates,
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
      color: (widget.theme ?? PrimeThemeData.light()).colorScheme.black,
      textStyle: (widget.theme ?? PrimeThemeData.light()).textTheme.bodyDefault,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      home: widget.home,
      routes: widget.routes ?? const <String, WidgetBuilder>{},
      initialRoute: widget.initialRoute,
      navigatorKey: widget.navigatorKey,
      onGenerateRoute: widget.onGenerateRoute,
      onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
      onUnknownRoute: widget.onUnknownRoute,
      navigatorObservers:
          widget.navigatorObservers ?? const <NavigatorObserver>[],
      builder: _builder,
      locale: widget.locale,
      localizationsDelegates: _localizationsDelegates,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      localeResolutionCallback: widget.localeResolutionCallback,
      supportedLocales: widget.supportedLocales,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
      restorationScopeId: widget.restorationScopeId,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    );
  }

  Widget _builder(BuildContext context, Widget? child) {
    final effectiveTheme = widget.theme ?? PrimeThemeData.light();
    // TODO: Implement dark theme resolution based on platform brightness if needed

    return PrimeTheme(
      data: effectiveTheme,
      child: Builder(
        builder: (context) {
          final theme = PrimeTheme.of(context);
          final content = child ?? const SizedBox.shrink();
          final wrappedContent = DefaultTextStyle(
            style: theme.textTheme.bodyDefault,
            child: content,
          );
          return widget.builder?.call(context, wrappedContent) ??
              wrappedContent;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildWidgetApp(context);
  }
}
