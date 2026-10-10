import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import '../widgets/dialogs.dart';
import 'credit_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'transaction_form_screen.dart';

/// Holds the four tabs (Home, History, Credit, Profile) and the bottom bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex = widget.initialIndex;

  void _selectTab(int index) => setState(() => _currentIndex = index);

  Future<void> _openAddTransaction() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    );
    if (saved == true && mounted) {
      showMessage(context, 'Transaction saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onSeeAll: () => _selectTab(1)),
          const HistoryScreen(),
          const CreditScreen(),
          ProfileScreen(onBack: () => _selectTab(0)),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _selectTab,
        onAddPressed: _openAddTransaction,
      ),
    );
  }
}
