import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/alert_card.dart';
import '../../../common/widgets/app_search_field.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/error_state.dart';
import '../../../common/widgets/filter_chip_group.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../viewmodels/alerts_cubit.dart';
import '../viewmodels/alerts_state.dart';

class AdminAlertsPage extends StatefulWidget {
  const AdminAlertsPage({super.key});

  @override
  State<AdminAlertsPage> createState() => _AdminAlertsPageState();
}

class _AdminAlertsPageState extends State<AdminAlertsPage> {
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

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveContainer.isMobile(context);

    return BlocProvider(
      create: (context) => AlertsCubit(context.read<AdminRepository>()),
      child: AdminScaffold(
      body: BlocBuilder<AlertsCubit, AlertsState>(
        builder: (context, state) {
          final viewModel = context.read<AlertsCubit>();
          final filteredAlerts = state.alerts;

          if (state.status == AlertsStatus.initial ||
              state.status == AlertsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AlertsStatus.failure) {
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
                      AdminAppHeader(
                        title: 'Alertes opérationnelles',
                        subtitle: 'Clean237 · Administration',
                        description: 'Anomalies prioritaires nécessitant une intervention terrain.',
                        showBackButton: true,
                        onBack: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.dashboard);
                          }
                        },
                      ),
                      AppSearchField(
                        controller: _searchController,
                        hintText: 'Rechercher une alerte, un quartier...',
                        onChanged: viewModel.setSearchQuery,
                        onClear: () => viewModel.setSearchQuery(''),
                      ),
                      const SizedBox(height: 14),
                      Column(
                        children: [
                          FilterChipGroup(
                            filters: AlertsCubit.filters,
                            selectedFilter: state.selectedFilter,
                            onSelected: viewModel.setFilter,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: FilterChipGroup(
                                  filters: AlertsCubit.statusFilters,
                                  selectedFilter: switch (state.selectedStatus) {
                                    'active' => 'Actives',
                                    'traitee' => 'Traitées',
                                    _ => 'Toutes',
                                  },
                                  onSelected: viewModel.setStatusFilter,
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge.count(
                                label: '${filteredAlerts.length} alertes',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Alertes répertoriées',
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              if (filteredAlerts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ResponsiveContainer(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const EmptyState(
                            title: 'Aucune alerte correspondante',
                            description: 'Aucune alerte ne correspond à vos filtres actuels.',
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
                      children: filteredAlerts.map((alert) {
                        return SizedBox(
                          width: (860 - 16) / 2,
                          child: AlertCard(
                            alert: alert,
                            onTap: () =>
                                context.push(AppRoutes.alertDetails(alert.id)),
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
                      final alert = filteredAlerts[index];
                      return AlertCard(
                        alert: alert,
                        onTap: () => context.push(AppRoutes.alertDetails(alert.id)),
                      );
                    }, childCount: filteredAlerts.length),
                  ),
                ),
              if (state.page < state.totalPages)
                SliverToBoxAdapter(
                  child: ResponsiveContainer(
                    child: TextButton(
                      onPressed: viewModel.loadMore,
                      child: const Text('Charger plus'),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
      ),
    );
  }
}
