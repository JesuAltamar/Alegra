import 'package:flutter/material.dart';
import 'package:pro9/Pagina_inicio/UnifiedLoginPage.dart';
import 'Pagina_inicio/PagInicio.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:html' as html;
import 'ConocenosPage.dart';
import 'package:provider/provider.dart'; // NUEVO: Importar Provider
import 'package:pro9/rachas/streak_provider.dart'; // NUEVO: Importar StreakProvider

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initWebRouting();
    _listenToUrlChanges();
  }

  void _initWebRouting() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUrl = html.window.location.href;
      print('URL inicial: $currentUrl');
      _handleWebUrl(currentUrl);
    });
  }

  void _listenToUrlChanges() {
    html.window.addEventListener('popstate', (event) {
      final currentUrl = html.window.location.href;
      print('Cambio de URL detectado: $currentUrl');
      _handleWebUrl(currentUrl);
    });
  }

  void _handleWebUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    print('Procesando URL: $uri');
    print('Path: ${uri.path}');
    print('Fragment: ${uri.fragment}');
    print('Query params: ${uri.queryParameters}');

    if (uri.fragment.isNotEmpty) {
      _handleFragment(uri.fragment);
    } else if (uri.path.contains('reset-password')) {
      final token = uri.queryParameters['token'];
      print('Token encontrado en path: $token');
      _navigateToResetPassword(token);
    }
  }

  void _handleFragment(String fragment) {
    print('Fragment detectado: $fragment');

    if (fragment.startsWith('/reset-password') ||
        fragment.contains('reset-password')) {
      final tempUri = Uri.tryParse('http://temp.com/$fragment');
      if (tempUri != null) {
        final token = tempUri.queryParameters['token'];
        print('Token extraído del fragment: $token');
        _navigateToResetPassword(token);
      }
    }
  }

  void _navigateToResetPassword(String? token) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (context) =>
                    token != null && token.isNotEmpty
                        ? ResetPasswordScreen(token: token)
                        : const ForgotPasswordScreen(),
          ),
          (route) => false,
        );
      }
    });
  }

  void updateUrl(String newPath) {
    html.window.history.pushState(null, '', newPath);
  }

  @override
  Widget build(BuildContext context) {
    // NUEVO: Envolver MaterialApp con MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StreakProvider()),
        // Aquí puedes agregar más providers si los necesitas en el futuro
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Alegra',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
        initialRoute: '/',
        routes: {
          '/': (context) => const PagInicio(),
          '/login': (context) => const UnifiedLoginPage(nombreUsuario: null),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
        },
        onGenerateRoute: (settings) {
          print('Generando ruta: ${settings.name}');

          Uri uri = Uri.parse(settings.name ?? '/');

          if (uri.path == '/reset-password') {
            final token = uri.queryParameters['token'] ?? '';
            print('Token en ruta generada: $token');

            return MaterialPageRoute(
              builder:
                  (context) =>
                      token.isEmpty
                          ? const ForgotPasswordScreen()
                          : ResetPasswordScreen(token: token),
            );
          }

          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => const PagInicio());
            case '/login':
              return MaterialPageRoute(
                builder:
                    (context) => const UnifiedLoginPage(nombreUsuario: null),
              );
            case '/forgot-password':
              return MaterialPageRoute(
                builder: (context) => const ForgotPasswordScreen(),
              );
            case '/conocenos':
              return MaterialPageRoute(
                builder: (context) => const ConocenosPage(),
              );
            default:
              return MaterialPageRoute(
                builder:
                    (context) => const Scaffold(
                      body: Center(child: Text('Página no encontrada')),
                    ),
              );
          }
        },
        onUnknownRoute: (settings) {
          print('Ruta desconocida: ${settings.name}');
          return MaterialPageRoute(builder: (context) => const PagInicio());
        },
      ),
    );
  }
}
