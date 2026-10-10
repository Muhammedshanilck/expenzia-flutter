import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_scope.dart';
import 'controllers/credit_controller.dart';
import 'controllers/expense_controller.dart';
import 'controllers/profile_controller.dart';
import 'core/theme/app_theme.dart';
import 'database/app_database.dart';
import 'database/credit_database.dart';
import 'database/expense_database.dart';
import 'database/settings_database.dart';
import 'repositories/credit_repository.dart';
import 'repositories/expense_repository.dart';
import 'repositories/profile_repository.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final database = AppDatabase();
  runApp(
    ExpenziaApp(
      expenses: ExpenseController(ExpenseRepository(ExpenseDatabase(database))),
      credits: CreditController(CreditRepository(CreditDatabase(database))),
      profile: ProfileController(ProfileRepository(SettingsDatabase(database))),
    ),
  );
}

class ExpenziaApp extends StatelessWidget {
  const ExpenziaApp({
    super.key,
    required this.expenses,
    required this.credits,
    required this.profile,
    this.home = const SplashScreen(),
  });

  final ExpenseController expenses;
  final CreditController credits;
  final ProfileController profile;

  /// First screen. Tests can start from a different screen.
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      expenses: expenses,
      credits: credits,
      profile: profile,
      child: MaterialApp(
        title: 'Expenzia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: home,
      ),
    );
  }
}
