import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/metric_card.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../data/repositories/admin_repository.dart';
import '../models/analysis_model.dart';
import '../viewmodels/analysis_result_cubit.dart';
import '../viewmodels/analysis_result_state.dart';
import 'widgets/analysis_report_progress.dart';

class AdminAnalysisResultPage extends StatelessWidget {
  const AdminAnalysisResultPage({super.key, required this.analysisId});

  final String analysisId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        AnalysisResultCubit(context.read<AdminRepository>(), analysisId),
    child: BlocBuilder<AnalysisResultCubit, AnalysisResultState>(
      builder: (context, state) {
        if (state.status == AnalysisResultStatus.notFound) {
          return AdminScaffold(
            body: ResponsiveContainer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyState(
                    title: 'Analyse introuvable',
                    description:
                        'Cette analyse n’existe pas ou n’est plus disponible.',
                  ),
                  SecondaryButton(
                    label: 'Nouvelle analyse',
                    onPressed: () => context.go(AppRoutes.newAnalysis()),
                  ),
                ],
              ),
            ),
          );
        }
        if (state.analysis == null) {
          return const AdminScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final analysis = state.analysis!;
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
                          title: 'Résultat de l’analyse',
                          subtitle: 'Clean237 · Administration',
                          showBackButton: true,
                          onBack: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.newAnalysis());
                            }
                          },
                        ),
                        const AnalysisReportProgress(reportStep: true),
                        _AnalysisSummary(
                          analysis: analysis,
                          zoneNames: state.zones
                              .map((zone) => zone.name)
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        Text('Indicateurs', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 10),
                        _AnalysisMetrics(indicators: analysis.indicators),
                        const SizedBox(height: 18),
                        Text('Résultat', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            analysis.result,
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: AppColors.surfaceWhite,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ResponsiveContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: 'Générer un rapport à partir de cette analyse',
                        icon: const Icon(
                          Icons.description_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () => context.push(
                          AppRoutes.newReport(analysisId: analysis.id),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SecondaryButton(
                        label: 'Nouvelle analyse',
                        onPressed: () => context.push(AppRoutes.newAnalysis()),
                      ),
                    ],
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

class _AnalysisSummary extends StatelessWidget {
  const _AnalysisSummary({required this.analysis, required this.zoneNames});

  final Analysis analysis;
  final List<String> zoneNames;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.borderLight),
      boxShadow: AppColors.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(analysis.type, style: AppTextStyles.cardTitle),
        const SizedBox(height: 6),
        Text(
          '${_formatDate(analysis.periodStart)} – ${_formatDate(analysis.periodEnd)}',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 10),
        Text(
          '${analysis.indicators.totalPoints} zones : ${zoneNames.join(', ')}',
          style: AppTextStyles.body,
        ),
      ],
    ),
  );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _AnalysisMetrics extends StatelessWidget {
  const _AnalysisMetrics({required this.indicators});

  final AnalysisIndicators indicators;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      MetricCard(
        count: indicators.totalPoints,
        title: 'Total des points',
        subtitle: 'Zones mesurées',
        countColor: AppColors.textPrimary,
        countBgColor: const Color(0xFFF1F5F9),
      ),
      MetricCard(
        count: indicators.average,
        title: 'Moyenne',
        subtitle: indicators.unit,
        countColor: AppColors.primaryGreen,
        countBgColor: AppColors.primaryGreenLight,
      ),
      MetricCard(
        count: indicators.minimum,
        title: 'Minimum',
        subtitle: indicators.unit,
        countColor: AppColors.warningOrange,
        countBgColor: AppColors.warningOrangeLight,
      ),
      MetricCard(
        count: indicators.maximum,
        title: 'Maximum',
        subtitle: indicators.unit,
        countColor: AppColors.criticalRed,
        countBgColor: AppColors.criticalRedLight,
      ),
      MetricCard(
        count: indicators.sum,
        title: 'Somme',
        subtitle: indicators.unit,
        countColor: AppColors.textPrimary,
        countBgColor: const Color(0xFFF1F5F9),
      ),
    ],
  );
}
