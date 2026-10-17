import 'package:flutter/material.dart';
import 'package:clean237_frontend/common/navigator/app_router.dart';
import 'package:clean237_frontend/common/styles/app_theme.dart';
import 'package:clean237_frontend/utils/constances/constances.dart';

/// Ouvre le module administration (go_router) dans l'appli utilisateurs.
/// [routeInitiale] est un chemin de AppRoutes (dashboard, zones, alertes...).
class AdminModuleScreen extends StatefulWidget {
  final String routeInitiale;
  const AdminModuleScreen({super.key, required this.routeInitiale});

  @override
  State<AdminModuleScreen> createState() => _AdminModuleScreenState();
}

class _AdminModuleScreenState extends State<AdminModuleScreen> {
  @override
  void initState() {
    super.initState();
    // Le routeur est un singleton : on le replace sur la bonne page à chaque ouverture.
    AppRouter.router.go(widget.routeInitiale);
  }

  void _retour() {
    if (AppRouter.router.canPop()) {
      AppRouter.router.pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _retour();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: CleanCouleurs.blancPur,
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: CleanCouleurs.vertEco, size: 18),
                  label: const Text(
                    "Retour à l'accueil admin",
                    style: TextStyle(color: CleanCouleurs.vertEco, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: MaterialApp.router(
                  title: 'Clean237 Administration',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  routerConfig: AppRouter.router,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
