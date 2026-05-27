// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/budget_controller.dart';
import 'controllers/theme_controller.dart';
import 'utils/app_theme.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinanceMeApp());
}

class FinanceMeApp extends StatelessWidget {
  const FinanceMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..loadTheme()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => TransactionController()),
        ChangeNotifierProvider(create: (_) => BudgetController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeCtrl, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeCtrl.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr', 'FR')],
            home: const _AppEntry(),
          );
        },
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthController>().checkAutoLogin();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 64, color: AppTheme.primary),
              SizedBox(height: 16),
              Text(AppConstants.appName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppTheme.primary),
            ],
          ),
        ),
      );
    }

    final isAuth = context.watch<AuthController>().isAuthenticated;
    return isAuth ? const HomeScreen() : const LoginScreen();
  }
}
