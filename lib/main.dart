import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'common/navigator/app_router.dart';
import 'common/styles/app_theme.dart';
import 'data/repositories/admin_repository.dart';
import 'data/services/admin_api_data_source.dart';
import 'data/services/admin_mock_data_source.dart';
import 'data/services/admin_remote_data_source.dart';
import 'utils/constances/api_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr');
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
    final AdminRemoteDataSource dataSource = ApiConstants.useMockApi
        ? AdminMockDataSource()
        : AdminApiDataSource();
    return RepositoryProvider<AdminRepository>(
      create: (_) => AdminRepository(dataSource: dataSource),
      child: MaterialApp.router(
        title: 'Clean237 Administration',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
