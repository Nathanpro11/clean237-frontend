import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/navigator/app_routes.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/app_search_field.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/filter_chip_group.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../common/widgets/zone_card.dart';
import '../viewmodels/zones_cubit.dart';
import '../viewmodels/zones_state.dart';

class AdminZonesPage extends StatefulWidget {
  final String? initialFilter;

  const AdminZonesPage({super.key, this.initialFilter});

  @override
  State<AdminZonesPage> createState() => _AdminZonesPageState();
}

class _AdminZonesPageState extends State<AdminZonesPage> {
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
      create: (context) => ZonesCubit(
        context.read<AdminRepository>(),
        initialFilter: widget.initialFilter,
      ),
      child: AdminScaffold(
        currentNavIndex: 1,
        onNavTabSelected: (index) {
          if (index == 0) {
            context.go(AppRoutes.dashboard);
          } else if (index == 2) {
            context.go(AppRoutes.reports);
          }
        },
        body: BlocBuilder<ZonesCubit, ZonesState>(
          builder: (context, state) {
            final viewModel = context.read<ZonesCubit>();
            final filteredZones = state.zones;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ResponsiveContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdminAppHeader(
                          title: 'Zones de collecte',
                          subtitle: 'Clean237 · Administration',
                          description: 'Suivi de la propreté urbaine et alertes par secteur.',
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: PopupMenuButton<ZoneSortOption>(
                              tooltip: 'Trier les zones',
                              icon: const Icon(
                                Icons.sort_rounded,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                              onSelected: viewModel.setSortOption,
                              itemBuilder: (context) => [
                                for (final option in ZoneSortOption.values)
                                  PopupMenuItem(
                                    value: option,
                                    child: Row(
                                      children: [
                                        if (state.sortOption == option)
                                          const Icon(
                                            Icons.check_rounded,
                                            size: 18,
                                            color: AppColors.primaryGreen,
                                          )
                                        else
                                          const SizedBox(width: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          option.label,
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 13,
                                            fontWeight:
                                                state.sortOption == option
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        AppSearchField(
                          controller: _searchController,
                          hintText: 'Rechercher une zone',
                          onChanged: viewModel.setSearchQuery,
                          onClear: viewModel.clearSearchQuery,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: FilterChipGroup(
                                filters: ZonesCubit.filters,
                                selectedFilter: state.selectedFilter,
                                onSelected: viewModel.setFilter,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge.count(
                              label:
                                  '${filteredZones.length} / ${state.totalCount}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (filteredZones.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ResponsiveContainer(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const EmptyState(
                              title: 'Aucune zone trouvée',
                              description: 'Aucun résultat ne correspond à votre filtre actuel ou recherche.',
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
                        children: filteredZones.map((zone) {
                          return SizedBox(
                            width: (860 - 16) / 2,
                            child: ZoneCard(
                              zone: zone,
                              variant: ZoneCardVariant.circularGauge,
                              onTap: () =>
                                  context.push(AppRoutes.zoneDetails(zone.id)),
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
                        final zone = filteredZones[index];
                        return ZoneCard(
                          zone: zone,
                          variant: ZoneCardVariant.circularGauge,
                          onTap: () =>
                              context.push(AppRoutes.zoneDetails(zone.id)),
                        );
                      }, childCount: filteredZones.length),
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
