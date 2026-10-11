import 'package:clean237_frontend/features/administration_reporting/models/zone_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../common/widgets/zone_score_gauge.dart';
import '../viewmodels/zone_details_cubit.dart';

class AdminZoneAnalysisPage extends StatefulWidget {
  final String zoneId;

  const AdminZoneAnalysisPage({super.key, required this.zoneId});

  @override
  State<AdminZoneAnalysisPage> createState() => _AdminZoneAnalysisPageState();
}

class _AdminZoneAnalysisPageState extends State<AdminZoneAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ZoneDetailsCubit(context.read<AdminRepository>(), widget.zoneId),
      child: BlocBuilder<ZoneDetailsCubit, ZoneDetailsState>(
        builder: (context, state) {
          final zone = state.zone;
          if (zone == null) {
            return _buildZoneNotFound(context);
          }
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
                      title: 'Analyse approfondie',
                      subtitle: 'Clean237 · Administration',
                      showBackButton: true,
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.zoneDetails(widget.zoneId));
                        }
                      },
                    ),

                    // Giant gauge card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
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
                        children: [
                          ZoneScoreGauge(
                            score: zone.score,
                            size: 110,
                            strokeWidth: 7,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            zone.name,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StatusBadge.critical(label: zone.status.label),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Interprétation card
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
                                Icons.insights_rounded,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Diagnostic & Interprétation',
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            zone.interpretation.isNotEmpty
                                ? zone.interpretation
                                : 'Aucune anomalie critique détectée pour cette zone.',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Priorités section
                    Text(
                      'Recommandations opérationnelles',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...zone.priorities.map(
                      (priority) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 20,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                priority,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button: Ajouter au rapport
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
                label: 'Générer un rapport pour cette zone',
                icon: const Icon(
                  Icons.post_add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  context.push(
                    AppRoutes.generateReport(preselectedZoneId: zone.id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
          );
        },
      ),
    );
  }

  Widget _buildZoneNotFound(BuildContext context) {
    return ResponsiveContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const EmptyState(
              title: 'Zone introuvable',
              description: 'La zone demandée n’existe pas ou a été supprimée.',
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Retourner aux zones',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.zones);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
