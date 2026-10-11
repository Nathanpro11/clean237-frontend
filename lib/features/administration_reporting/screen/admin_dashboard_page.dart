import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/admin_repository.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/admin_app_header.dart';
import '../../../common/widgets/admin_scaffold.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/metric_card.dart';
import '../../../common/widgets/responsive_container.dart';
import '../../../common/widgets/status_badge.dart';
import '../../../common/widgets/zone_card.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(
      adminRepository: context.read<AdminRepository>(),
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
      currentNavIndex: 0,
      onNavTabSelected: (index) {
        if (index == 1) {
          context.go('/admin/zones');
        } else if (index == 2) {
          context.go('/admin/reports');
        }
      },
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final zonesToWatch = _viewModel.zonesToWatch;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdminAppHeader(
                        title: 'Tableau de bord',
                        subtitle: 'Clean237 · Administration',
                      ),
                      const SizedBox(height: 4),

                      // Metric cards (Responsive: Grid sur grands écrans, colonne sur mobile)
                      if (isWide)
                        _buildWideMetrics(context)
                      else
                        _buildMobileMetrics(context),

                      const SizedBox(height: 20),

                      // Section header: Zones à surveiller
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Zones à surveiller',
                              style: AppTextStyles.sectionTitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.count(
                            label: '${zonesToWatch.length} zones',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (zonesToWatch.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: EmptyState(
                            title: 'Toutes les zones sont stables',
                            description: 'Aucune zone ne nécessite une surveillance critique actuellement.',
                          ),
                        )
                      else if (isWide)
                        // Disposition 2 colonnes sur tablette / desktop
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: zonesToWatch.map((zone) {
                            return SizedBox(
                              width: (860 - 16) / 2,
                              child: ZoneCard(
                                zone: zone,
                                variant: ZoneCardVariant.squareScore,
                                onTap: () =>
                                    context.push('/admin/zones/${zone.id}'),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        // Liste mobile standard
                        ...zonesToWatch.map(
                          (zone) => ZoneCard(
                            zone: zone,
                            variant: ZoneCardVariant.squareScore,
                            onTap: () =>
                                context.push('/admin/zones/${zone.id}'),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileMetrics(BuildContext context) {
    return Column(
      children: [
        MetricCard.zones(
          count: _viewModel.totalZonesCount,
          onTap: () => context.push('/admin/zones'),
        ),
        MetricCard.critical(
          count: _viewModel.criticalZonesCount,
          onTap: () => context.push('/admin/zones/critical'),
        ),
        MetricCard.alerts(
          count: _viewModel.activeAlertsCount,
          onTap: () => context.push('/admin/alerts'),
        ),
        MetricCard.reports(
          count: _viewModel.totalReportsCount,
          onTap: () => context.go('/admin/reports'),
        ),
      ],
    );
  }

  Widget _buildWideMetrics(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 8,
      children: [
        MetricCard.zones(
          count: _viewModel.totalZonesCount,
          onTap: () => context.push('/admin/zones'),
        ),
        MetricCard.critical(
          count: _viewModel.criticalZonesCount,
          onTap: () => context.push('/admin/zones/critical'),
        ),
        MetricCard.alerts(
          count: _viewModel.activeAlertsCount,
          onTap: () => context.push('/admin/alerts'),
        ),
        MetricCard.reports(
          count: _viewModel.totalReportsCount,
          onTap: () => context.go('/admin/reports'),
        ),
      ],
    );
  }
}
