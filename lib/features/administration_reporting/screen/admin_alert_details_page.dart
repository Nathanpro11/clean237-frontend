import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/app_feedback.dart';
import '../../../common/widgets/error_state.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../data/repositories/admin_repository.dart';
import '../models/alert_model.dart';
import '../viewmodels/alerts_cubit.dart';
import '../viewmodels/alerts_state.dart';

class AdminAlertDetailsPage extends StatefulWidget {
  final String alertId;

  const AdminAlertDetailsPage({super.key, required this.alertId});

  @override
  State<AdminAlertDetailsPage> createState() => _AdminAlertDetailsPageState();
}

class _AdminAlertDetailsPageState extends State<AdminAlertDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AlertsCubit(context.read<AdminRepository>())..loadAlert(widget.alertId),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AlertsCubit, AlertsState>(
            listenWhen: (previous, current) =>
                previous.resolutionMessage != current.resolutionMessage &&
                current.resolutionMessage != null,
            listener: (context, state) {
              AppFeedback.showSuccess(
                context,
                state.resolutionMessage,
                fallback: 'Alerte traitée avec succès.',
              );
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.alerts);
              }
            },
          ),
          BlocListener<AlertsCubit, AlertsState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage &&
                current.errorMessage != null &&
                current.alertDetails != null,
            listener: (context, state) {
              AppFeedback.showError(context, state.errorMessage);
            },
          ),
        ],
        child: BlocBuilder<AlertsCubit, AlertsState>(
          builder: (context, state) {
            if ((state.status == AlertsStatus.initial ||
                    state.status == AlertsStatus.loading) &&
                state.alertDetails == null) {
              return const AdminScaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == AlertsStatus.failure &&
                state.alertDetails == null) {
              return AdminScaffold(
                body: ErrorState(
                  message: state.errorMessage ?? 'Erreur de chargement.',
                  onRetry: () =>
                      context.read<AlertsCubit>().loadAlert(widget.alertId),
                ),
              );
            }
            final alert = state.alertDetails;

            if (alert == null) {
              return _buildAlertNotFound(context);
            }

            final isResolving = state.status == AlertsStatus.loading &&
                state.alertDetails != null;

            final actionButtonLabel = alert.isHandled
                ? 'Alerte déjà traitée'
                : (isResolving ? 'Traitement en cours...' : 'Marquer comme traitée');

            return AdminScaffold(
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ResponsiveContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AdminAppHeader(
                              title: 'Détail de l’alerte',
                              subtitle: 'Clean237 · Administration',
                              showBackButton: true,
                              onBack: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.alerts);
                                }
                              },
                            ),

                            // Alert Summary Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                  width: 1,
                                ),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      StatusBadge.critical(
                                        label: switch (alert.severity) {
                                          AlertSeverity.critical => 'Critique',
                                          AlertSeverity.warning =>
                                            'Avertissement',
                                          AlertSeverity.info => 'Information',
                                        },
                                      ),
                                      Text(
                                        alert.date,
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    alert.title,
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Lien cliquable vers la zone concernée
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      context.push(
                                        AppRoutes.zoneDetails(alert.zoneId),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.location_on_rounded,
                                            size: 16,
                                            color: AppColors.primaryGreen,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Zone : ${alert.zoneName}',
                                            style: AppTextStyles.bodySecondary
                                                .copyWith(
                                                  color: AppColors.primaryGreen,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 12,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (alert.context != null || alert.impact != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 1,
                                  ),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline_rounded,
                                          size: 18,
                                          color: AppColors.primaryGreen,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Contexte opérationnel',
                                          style:
                                              AppTextStyles.cardTitle.copyWith(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (alert.context != null)
                                      Text(
                                        alert.context!,
                                        style: AppTextStyles.body.copyWith(
                                          fontSize: 13.5,
                                          color: AppColors.textSecondary,
                                          height: 1.45,
                                        ),
                                      ),
                                    if (alert.context != null &&
                                        alert.impact != null)
                                      const Divider(height: 28),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 18,
                                          color: AppColors.criticalRed,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Détail',
                                          style:
                                              AppTextStyles.cardTitle.copyWith(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (alert.impact != null)
                                      Text(
                                        alert.impact!,
                                        style: AppTextStyles.body.copyWith(
                                          fontSize: 13.5,
                                          color: AppColors.textSecondary,
                                          height: 1.45,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Action Button avec confirmation et anti double-clic
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: ResponsiveContainer(
                      padding: EdgeInsets.zero,
                      child: PrimaryButton(
                        label: actionButtonLabel,
                        isLoading: isResolving,
                        icon: const Icon(
                          Icons.task_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: alert.isHandled || isResolving
                            ? null
                            : () => _confirmResolution(
                                context,
                                context.read<AlertsCubit>(),
                                alert,
                                'Marquer comme traitée',
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmResolution(
    BuildContext context,
    AlertsCubit viewModel,
    AdminAlert alert,
    String actionLabel,
  ) {
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer l’intervention'),
        content: Text(
          'Voulez-vous valider l’action "$actionLabel" pour l’alerte de ${alert.zoneName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        viewModel.resolveAlert(alert.id);
      }
    });
  }

  Widget _buildAlertNotFound(BuildContext context) {
    return ResponsiveContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('Alerte introuvable', style: AppTextStyles.pageTitle),
            const SizedBox(height: 8),
            Text(
              'L’alerte demandée a été résolue ou n’existe pas.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Retourner aux alertes',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.alerts);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
