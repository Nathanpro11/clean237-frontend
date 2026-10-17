import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/app_feedback.dart';
import '../../../common/widgets/app_search_field.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/error_state.dart';
import '../../../common/widgets/filter_chip_group.dart';
import '../../../common/widgets/report_card.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../data/repositories/admin_repository.dart';
import '../viewmodels/reports_cubit.dart';
import '../viewmodels/reports_state.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openReport(BuildContext context, String id) async {
    await context.push(AppRoutes.reportPreview(id));
    if (context.mounted) {
      context.read<ReportsCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveContainer.isMobile(context);

    return BlocProvider(
      create: (context) => ReportsCubit(context.read<AdminRepository>()),
      child: AdminScaffold(
        currentNavIndex: 2,
        onNavTabSelected: (index) {
          if (index == 0) {
            context.go(AppRoutes.dashboard);
          } else if (index == 1) {
            context.go(AppRoutes.zones);
          }
        },
        body: BlocListener<ReportsCubit, ReportsState>(
          listenWhen: (previous, current) =>
              previous.successMessage != current.successMessage &&
              current.successMessage != null,
          listener: (context, state) {
            AppFeedback.showSuccess(context, state.successMessage);
          },
          child: BlocBuilder<ReportsCubit, ReportsState>(
            builder: (context, state) {
              final viewModel = context.read<ReportsCubit>();
              final filteredReports = state.reports;

              if (state.status == ReportsStatus.initial ||
                  state.status == ReportsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == ReportsStatus.failure) {
                return ErrorState(
                  message: state.errorMessage ?? 'Erreur de chargement.',
                  onRetry: viewModel.load,
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ResponsiveContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AdminAppHeader(
                            title: 'Rapports & Synthèses',
                            subtitle: 'Clean237 · Administration',
                            description:
                                'Consultez et gérez vos analyses, synthèses et exports périodiques.',
                          ),
                          const SizedBox(height: 6),

                          // Hero button: Nouveau rapport
                          _buildNewReportHero(context),

                          const SizedBox(height: 20),

                          // Barre de recherche
                          AppSearchField(
                            controller: _searchController,
                            hintText: 'Rechercher un rapport...',
                            onChanged: viewModel.setSearchQuery,
                            onClear: () => viewModel.setSearchQuery(''),
                          ),
                          const SizedBox(height: 14),

                          // Filtres par statut
                          Row(
                            children: [
                              Expanded(
                                child: FilterChipGroup(
                                  filters: ReportsCubit.statusFilters,
                                  selectedFilter: state.selectedStatus,
                                  onSelected: viewModel.setStatusFilter,
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge.count(
                                label: '${filteredReports.length} rapports',
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          Text(
                            'Vos rapports enregistrés',
                            style: AppTextStyles.sectionTitle,
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                  if (filteredReports.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ResponsiveContainer(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const EmptyState(
                                title: 'Aucun rapport trouvé',
                                description:
                                    'Aucun document ne correspond à vos critères de recherche.',
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 220,
                                child: SecondaryButton(
                                  label: 'Réinitialiser les filtres',
                                  onPressed: () {
                                    _searchController.clear();
                                    viewModel.resetFilters();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (isWide)
                    SliverToBoxAdapter(
                      child: ResponsiveContainer(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: filteredReports.map((report) {
                            return SizedBox(
                              width: (860 - 16) / 2,
                              child: ReportCard(
                                report: report,
                                onTap: () => _openReport(context, report.id),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final report = filteredReports[index];
                          return ReportCard(
                            report: report,
                            onTap: () => _openReport(context, report.id),
                          );
                        }, childCount: filteredReports.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNewReportHero(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2827AE60),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            context.push(AppRoutes.newAnalysis());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nouveau rapport',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Générer un rapport PDF pour une ou plusieurs zones.',
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
