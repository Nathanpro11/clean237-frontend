import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/app_search_field.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/filter_chip_group.dart';
import '../../../common/widgets/report_card.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../viewmodels/reports_viewmodel.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  late final ReportsViewModel _viewModel;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _viewModel = ReportsViewModel(
      adminRepository: context.read<AdminRepository>(),
    );
    _searchController = TextEditingController(text: _viewModel.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveContainer.isMobile(context);

    return AdminScaffold(
      currentNavIndex: 2,
      onNavTabSelected: (index) {
        if (index == 0) {
          context.go('/admin/dashboard');
        } else if (index == 1) {
          context.go('/admin/zones');
        }
      },
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final filteredReports = _viewModel.filteredReports;

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
                        description: 'Consultez et gérez vos analyses, synthèses et exports périodiques.',
                      ),
                      const SizedBox(height: 6),

                      // Hero button: Nouveau rapport
                      _buildNewReportHero(context),

                      const SizedBox(height: 20),

                      // Barre de recherche
                      AppSearchField(
                        controller: _searchController,
                        hintText: 'Rechercher un rapport...',
                        onChanged: _viewModel.setSearchQuery,
                        onClear: () => _viewModel.setSearchQuery(''),
                      ),
                      const SizedBox(height: 14),

                      // Filtres par statut
                      Row(
                        children: [
                          Expanded(
                            child: FilterChipGroup(
                              filters: _viewModel.statusFilters,
                              selectedFilter: _viewModel.selectedStatus,
                              onSelected: _viewModel.setStatusFilter,
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
                            description: 'Aucun document ne correspond à vos critères de recherche.',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 220,
                            child: SecondaryButton(
                              label: 'Réinitialiser les filtres',
                              onPressed: () {
                                _searchController.clear();
                                _viewModel.resetFilters();
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
                            onTap: () =>
                                context.push('/admin/reports/${report.id}'),
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
                        onTap: () =>
                            context.push('/admin/reports/${report.id}'),
                      );
                    }, childCount: filteredReports.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
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
            context.push('/admin/reports/generate');
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
                        'Générer un export PDF/Excel pour une ou plusieurs zones.',
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
