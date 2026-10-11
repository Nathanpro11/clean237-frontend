import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../common/widgets/zone_card.dart';
import '../viewmodels/zones_viewmodel.dart';

class AdminCriticalZonesPage extends StatefulWidget {
  const AdminCriticalZonesPage({super.key});

  @override
  State<AdminCriticalZonesPage> createState() => _AdminCriticalZonesPageState();
}

class _AdminCriticalZonesPageState extends State<AdminCriticalZonesPage> {
  late final ZonesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ZonesViewModel(
      adminRepository: context.read<AdminRepository>(),
      initialFilter: 'Critique',
    );
  }

  @override
  void dispose() {
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
          final criticalZones = _viewModel.filteredZones;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminAppHeader(
                        title: 'Zones critiques',
                        subtitle: 'Clean237 · Administration',
                        description: 'Secteurs nécessitant une intervention urgente sous 24h.',
                        showBackButton: true,
                        onBack: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/admin/dashboard');
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Interventions prioritaires',
                              style: AppTextStyles.sectionTitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.critical(
                            label: '${criticalZones.length} critiques',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (criticalZones.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: ResponsiveContainer(
                    child: Center(
                      child: EmptyState(
                        title: 'Aucune zone critique',
                        description: 'Félicitations ! Toutes les zones respectent actuellement les normes de propreté.',
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
                      children: criticalZones.map((zone) {
                        return SizedBox(
                          width: (860 - 16) / 2,
                          child: ZoneCard(
                            zone: zone,
                            variant: ZoneCardVariant.circularGauge,
                            onTap: () =>
                                context.push('/admin/zones/${zone.id}'),
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
                      final zone = criticalZones[index];
                      return ZoneCard(
                        zone: zone,
                        variant: ZoneCardVariant.circularGauge,
                        onTap: () => context.push('/admin/zones/${zone.id}'),
                      );
                    }, childCount: criticalZones.length),
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
