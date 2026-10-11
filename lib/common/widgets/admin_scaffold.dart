import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import 'admin_bottom_navigation.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final int? currentNavIndex;
  final ValueChanged<int>? onNavTabSelected;
  final Widget? floatingActionButton;
  final Widget? bottomSheet;

  const AdminScaffold({
    super.key,
    required this.body,
    this.currentNavIndex,
    this.onNavTabSelected,
    this.floatingActionButton,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(bottom: currentNavIndex == null, child: body),
      bottomNavigationBar: (currentNavIndex != null && onNavTabSelected != null)
          ? AdminBottomNavigation(
              currentIndex: currentNavIndex!,
              onTabSelected: onNavTabSelected!,
            )
          : null,
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
    );
  }
}
