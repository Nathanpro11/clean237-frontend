import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/signalement/controller/signalement_controller.dart';
import 'features/signalement/screen/role_select_screen.dart';

void main() {
  runApp(const Clean237App());
}

class Clean237App extends StatelessWidget {
  const Clean237App({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignalementController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Clean237 - Signalement',
        theme: ThemeData(primaryColor: const Color(0xFF27AE60)),
        home: const RoleSelectScreen(),
      ),
    );
  }
}
