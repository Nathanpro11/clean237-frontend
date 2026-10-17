import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/error_state.dart';
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
        final cubit = context.read<AnalysisResultCubit>();
        if (state.status == AnalysisResultStatus.loading) {
          return const AdminScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == AnalysisResultStatus.failure) {
          return AdminScaffold(
            body: ErrorState(
              message: state.errorMessage ?? 'Erreur de chargement.',
              onRetry: cubit.load,
            ),
          );
        }
        if (state.status == AnalysisResultStatus.notFound) {
          return AdminScaffold(
            body: ErrorState(
              message: 'Cette analyse n’existe pas ou n’est plus disponible.',
              onRetry: cubit.load,
              actionLabel: 'Nouvelle analyse',
              onAction: () => context.go(AppRoutes.newAnalysis()),
            ),
          );
        }
        if (state.analysis == null) return const SizedBox.shrink();
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
  const _AnalysisSummary({required this.analysis});

  final Analysis analysis;

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
          'Zone : ${analysis.zoneName ?? analysis.zoneId ?? 'Toutes les zones'}',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 4),
        Text(
          '${analysis.indicators.totalPoints} points de données',
          style: AppTextStyles.bodySecondary,
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
        subtitle: 'Points de données utilisés',
        countColor: AppColors.textPrimary,
        countBgColor: const Color(0xFFF1F5F9),
      ),
      ...indicators.byType.entries.map(
        (entry) => _AnalysisTypeMetrics(type: entry.key, indicator: entry.value),
      ),
    ],
  );
}

class _AnalysisTypeMetrics extends StatelessWidget {
  const _AnalysisTypeMetrics({required this.type, required this.indicator});

  final String type;
  final AnalysisTypeIndicator indicator;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(type, style: AppTextStyles.cardTitle),
        const SizedBox(height: 4),
        Text(
          '${indicator.count} mesures${indicator.unit == null ? '' : ' · ${indicator.unit}'}',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            _MetricValue(label: 'Moyenne', value: indicator.average),
            _MetricValue(label: 'Minimum', value: indicator.minimum),
            _MetricValue(label: 'Maximum', value: indicator.maximum),
            _MetricValue(label: 'Somme', value: indicator.sum),
          ],
        ),
      ],
    ),
  );
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 120,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Text(value.toString(), style: AppTextStyles.cardTitle),
      ],
    ),
  );
}
