import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';

class AdminExportFailurePage extends StatelessWidget {
  final String title;
  final String? errorMessage;
  final String? retryPath;

  const AdminExportFailurePage({
    super.key,
    required this.title,
    this.errorMessage,
    this.retryPath,
  });

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      body: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.criticalRedLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.criticalRed,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Échec de l’export',
                style: AppTextStyles.pageTitle.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ??
                    'Impossible de générer le document pour "$title". Veuillez vérifier vos paramètres ou réessayer ultérieurement.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Réessayer',
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  if (retryPath != null) {
                    context.go(retryPath!);
                  } else if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.generateReport());
                  }
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Retourner aux rapports',
                onPressed: () {
                  context.go(AppRoutes.reports);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Aller au tableau de bord'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
