import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'common/navigator/app_router.dart';
import 'common/styles/app_theme.dart';
import 'data/repositories/admin_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const Clean237App());
}

class Clean237App extends StatelessWidget {
  const Clean237App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AdminRepository>(
      create: (_) => AdminRepository(),
      dispose: (repository) => repository.dispose(),
      child: MaterialApp.router(
        title: 'Clean237 Administration',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
