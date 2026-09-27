import 'package:certificat4/core/network/dio_client.dart';
import 'package:certificat4/core/storage/hive_service.dart';
import 'package:certificat4/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:certificat4/features/auth/domain/entities/user_session.dart';
import 'package:certificat4/features/auth/domain/repositories/auth_repository.dart';
import 'package:certificat4/features/auth/presentation/login_screen.dart';
import 'package:certificat4/features/auth/presentation/register_screen.dart';
import 'package:certificat4/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppState({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(dio: AppDio.create());

  final AuthRepository _authRepository;
  UserSession? _session;

  UserSession? get session => _session;
  bool get isAuthenticated => _session != null;

  Future<void> bootstrap() async {
    _session = await _authRepository.getSavedSession();
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    try {
      final session = await _authRepository.login(username, password);
      _session = session;
      await _authRepository.saveSession(session);
      notifyListeners();
      return null;
    } on Exception catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> register(String username, String email, String password) async {
    try {
      final session = await _authRepository.register(username, email, password);
      _session = session;
      await _authRepository.saveSession(session);
      notifyListeners();
      return null;
    } on Exception catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> logout() async {
    _session = null;
    await _authRepository.clearSession();
    notifyListeners();
  }

  static AppState of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_AppStateProvider>();
    assert(inherited != null, 'No AppState provided');
    return inherited!.state;
  }
}

class _AppStateProvider extends InheritedWidget {
  const _AppStateProvider({
    required this.state,
    required super.child,
  });

  final AppState state;

  @override
  bool updateShouldNotify(_AppStateProvider oldWidget) => state != oldWidget.state;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.appState});

  final AppState appState;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_handleStateChange);
    widget.appState.bootstrap();
  }

  void _handleStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _AppStateProvider(
      state: widget.appState,
      child: MaterialApp(
        title: 'Certificat4',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: widget.appState.isAuthenticated ? DashboardScreen(appState: widget.appState) : const LoginScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/dashboard': (_) => DashboardScreen(appState: widget.appState),
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.appState.removeListener(_handleStateChange);
    super.dispose();
  }
}
