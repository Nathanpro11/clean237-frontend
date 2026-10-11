import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../data/repositories/admin_repository.dart';
import '../viewmodels/analysis_form_cubit.dart';
import '../viewmodels/analysis_form_state.dart';
import 'widgets/analysis_report_progress.dart';
import 'widgets/analysis_scope_form.dart';

class AdminNewAnalysisPage extends StatelessWidget {
  const AdminNewAnalysisPage({super.key, this.preselectedZoneId});

  final String? preselectedZoneId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => AnalysisFormCubit(
      context.read<AdminRepository>(),
      preselectedZoneId: preselectedZoneId,
    ),
    child: BlocBuilder<AnalysisFormCubit, AnalysisFormState>(
      builder: (context, state) {
        final cubit = context.read<AnalysisFormCubit>();
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
                          title: 'Nouvelle analyse',
                          subtitle: 'Clean237 · Administration',
                          description:
                              'Choisissez une période et les zones à analyser.',
                          showBackButton: true,
                          onBack: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.dashboard);
                            }
                          },
                        ),
                        const AnalysisReportProgress(reportStep: false),
                        if (state.errorMessage != null) ...[
                          Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.criticalRed,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        AnalysisScopeForm(
                          zones: state.zones,
                          selectedZoneIds: state.selectedZoneIds,
                          periodPreset: state.periodPreset,
                          periodStart: state.periodStart,
                          periodEnd: state.periodEnd,
                          periodError: state.periodError,
                          zonesError: state.zonesError,
                          onPeriodPresetChanged: cubit.selectPeriodPreset,
                          onCustomPeriodChanged: (start, end) =>
                              cubit.setCustomPeriod(start: start, end: end),
                          onZoneToggled: cubit.toggleZone,
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
                  child: PrimaryButton(
                    label: state.status == AnalysisSubmissionStatus.submitting
                        ? 'Analyse en cours...'
                        : 'Lancer l’analyse',
                    isLoading:
                        state.status == AnalysisSubmissionStatus.submitting,
                    icon: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                    ),
                    onPressed:
                        state.status == AnalysisSubmissionStatus.submitting
                        ? null
                        : () async {
                            final analysis = await cubit.generateAnalysis();
                            if (analysis != null && context.mounted) {
                              context.push(
                                AppRoutes.analysisResult(analysis.id),
                              );
                            }
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
