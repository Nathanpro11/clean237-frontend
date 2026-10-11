import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/alert_card.dart';
import '../../../common/widgets/evolution_chart.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../viewmodels/zone_details_cubit.dart';
import 'widgets/priority_checklist.dart';
import 'widgets/zone_summary_card.dart';

class AdminZoneDetailsPage extends StatefulWidget {
  final String zoneId;

  const AdminZoneDetailsPage({super.key, required this.zoneId});

  @override
  State<AdminZoneDetailsPage> createState() => _AdminZoneDetailsPageState();
}

class _AdminZoneDetailsPageState extends State<AdminZoneDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ZoneDetailsCubit(context.read<AdminRepository>(), widget.zoneId),
      child: AdminScaffold(
        body: BlocBuilder<ZoneDetailsCubit, ZoneDetailsState>(
          builder: (context, state) {
          final viewModel = context.read<ZoneDetailsCubit>();
          final zone = state.zone;
          final alerts = state.alerts;

          if (zone == null) {
            return _buildZoneNotFound(context);
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ResponsiveContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdminAppHeader(
                          title: zone.name,
                          subtitle: 'Clean237 · Administration',
                          showBackButton: true,
                          onBack: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/admin/zones');
                            }
                          },
                          ),

                        ZoneSummaryCard(zone: zone),
                        const SizedBox(height: 16),

                        // Evolution 30 days chart card
                        EvolutionChartCard(
                          evolutionPoints: zone.evolutionPoints,
                          dataPoints: zone.evolution30Days,
                        ),
                        const SizedBox(height: 16),

                        if (zone.priorities.isNotEmpty)
                          PriorityChecklist(
                            priorities: zone.priorities,
                            completedPriorities:
                                state.completedPriorities,
                            onToggle: viewModel.togglePriority,
                          ),

                        // ALERTES RÉCENTES section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'ALERTES RÉCENTES DANS LA ZONE',
                                style: AppTextStyles.sectionLabelGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge.count(
                              label: '${alerts.length} alertes',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Alerts list
                        if (alerts.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Aucune alerte active pour cette zone.',
                                style: AppTextStyles.bodySecondary,
                              ),
                            ),
                          )
                        else
                          ...alerts.map(
                            (alert) => AlertCard(
                              alert: alert,
                              onTap: () =>
                                  context.push('/admin/alerts/${alert.id}'),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom action buttons (Responsive)
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final createReportButton = SecondaryButton(
                        label: 'Créer rapport',
                        icon: const Icon(
                          Icons.post_add_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          context.push(
                            '/admin/reports/generate?preselectedZoneId=${zone.id}',
                          );
                        },
                      );
                      final analyzeButton = PrimaryButton(
                        label: 'Générer une Analyse',
                        icon: const Icon(
                          Icons.analytics_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.push('/admin/zones/${zone.id}/analysis');
                        },
                      );

                      if (constraints.maxWidth < 420) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            createReportButton,
                            const SizedBox(height: 10),
                            analyzeButton,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: createReportButton),
                          const SizedBox(width: 12),
                          Expanded(child: analyzeButton),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildZoneNotFound(BuildContext context) {
    return ResponsiveContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('Zone introuvable', style: AppTextStyles.pageTitle),
            const SizedBox(height: 8),
            Text(
              'L’identifiant de zone spécifié n’existe pas dans le système Clean237.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Retourner aux zones',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/admin/zones');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
