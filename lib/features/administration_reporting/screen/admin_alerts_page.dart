import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/alert_card.dart';
import '../../../common/widgets/app_search_field.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/filter_chip_group.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../viewmodels/alerts_viewmodel.dart';

class AdminAlertsPage extends StatefulWidget {
  const AdminAlertsPage({super.key});

  @override
  State<AdminAlertsPage> createState() => _AdminAlertsPageState();
}

class _AdminAlertsPageState extends State<AdminAlertsPage> {
  late final AlertsViewModel _viewModel;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _viewModel = AlertsViewModel(
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
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final filteredAlerts = _viewModel.filteredAlerts;

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
                            context.go('/admin/dashboard');
                          }
                        },
                      ),
                      AppSearchField(
                        controller: _searchController,
                        hintText: 'Rechercher une alerte, un quartier...',
                        onChanged: _viewModel.setSearchQuery,
                        onClear: () => _viewModel.setSearchQuery(''),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilterChipGroup(
                              filters: _viewModel.filters,
                              selectedFilter: _viewModel.selectedFilter,
                              onSelected: _viewModel.setFilter,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.count(
                            label: '${filteredAlerts.length} alertes',
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
                      children: filteredAlerts.map((alert) {
                        return SizedBox(
                          width: (860 - 16) / 2,
                          child: AlertCard(
                            alert: alert,
                            onTap: () =>
                                context.push('/admin/alerts/${alert.id}'),
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
                        onTap: () => context.push('/admin/alerts/${alert.id}'),
                      );
                    }, childCount: filteredAlerts.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}
