import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../bookings/domain/booking.dart';
import '../../../bookings/presentation/widgets/booking_sheet.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

typedef _ProjectItem = ({String name, String? url});

class _SubCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<_ProjectItem> items;
  const _SubCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

const _kAgriSubCategories = <_SubCategory>[
  _SubCategory(
    title: 'Protected Farming Projects',
    icon: Icons.home_work_rounded,
    color: Color(0xFF2E7D32),
    items: [
      (name: 'Naturally Ventilated Polyhouse',  url: 'https://www.igoagritechfarms.in/projects/agri/protected/naturally-ventilated'),
      (name: 'Climate Controlled Polyhouse',    url: 'https://www.igoagritechfarms.in/projects/agri/protected/climate-controlled'),
      (name: 'Polycarbonate Greenhouse',        url: 'https://www.igoagritechfarms.in/projects/agri/protected/polycarbonate'),
      (name: 'Shade Net House',                 url: 'https://www.igoagritechfarms.in/projects/agri/protected/shade-net'),
      (name: 'Mist Chamber',                    url: 'https://www.igoagritechfarms.in/projects/agri/protected/mist-chamber'),
    ],
  ),
  _SubCategory(
    title: 'Hydroponic Farming Projects',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF0277BD),
    items: [
      (name: 'NFT Hydroponic System',        url: null),
      (name: 'Deep Water Culture System',    url: null),
      (name: 'Vertical Hydroponic Towers',   url: null),
      (name: 'Commercial Hydroponic Farms',  url: null),
      (name: 'Indoor Hydroponic Units',      url: null),
    ],
  ),
  _SubCategory(
    title: 'Vertical Farming Projects',
    icon: Icons.layers_rounded,
    color: Color(0xFF00695C),
    items: [
      (name: 'Indoor Vertical Farms',                url: null),
      (name: 'Commercial Vertical Farming Units',    url: null),
      (name: 'Smart Grow Room Systems',              url: null),
    ],
  ),
  _SubCategory(
    title: 'Open Field Cultivation Projects',
    icon: Icons.landscape_rounded,
    color: Color(0xFF558B2F),
    items: [
      (name: 'Dragon Fruit Plantation',  url: null),
      (name: 'Guava Plantation',         url: null),
      (name: 'Mango Plantation',         url: null),
      (name: 'Papaya Plantation',        url: null),
      (name: 'Fig Plantation',           url: null),
      (name: 'Blueberry Plantation',     url: null),
    ],
  ),
  _SubCategory(
    title: 'Vegetable Cultivation Projects',
    icon: Icons.eco_rounded,
    color: Color(0xFF388E3C),
    items: [
      (name: 'Cucumber Farming',    url: null),
      (name: 'Capsicum Farming',    url: null),
      (name: 'Tomato Farming',      url: null),
      (name: 'Chilli Farming',      url: null),
      (name: 'Muskmelon Farming',   url: null),
      (name: 'Watermelon Farming',  url: null),
    ],
  ),
  _SubCategory(
    title: 'Medicinal Crop Projects',
    icon: Icons.local_pharmacy_rounded,
    color: Color(0xFF6A1B9A),
    items: [
      (name: 'Aloe Vera Farming',    url: null),
      (name: 'Moringa Plantation',   url: null),
      (name: 'Ginger Farming',       url: null),
      (name: 'Turmeric Farming',     url: null),
      (name: 'Tapioca Cultivation',  url: null),
    ],
  ),
  _SubCategory(
    title: 'Floriculture Projects',
    icon: Icons.local_florist_rounded,
    color: Color(0xFFAD1457),
    items: [
      (name: 'Rose Farming',          url: null),
      (name: 'Jasmine Farming',       url: null),
      (name: 'Marigold Farming',      url: null),
      (name: 'Exotic Flower Farming', url: null),
    ],
  ),
  _SubCategory(
    title: 'Mushroom Farming Projects',
    icon: Icons.spa_rounded,
    color: Color(0xFF4E342E),
    items: [
      (name: 'Oyster Mushroom Units',      url: null),
      (name: 'Button Mushroom Units',      url: null),
      (name: 'Commercial Mushroom Farms',  url: null),
    ],
  ),
  _SubCategory(
    title: 'Urban Farming Projects',
    icon: Icons.apartment_rounded,
    color: Color(0xFF37474F),
    items: [
      (name: 'Rooftop Gardening Projects',    url: null),
      (name: 'Terrace Farming Projects',      url: null),
      (name: 'Kitchen Garden Projects',       url: null),
      (name: 'Microgreens Production Units',  url: null),
    ],
  ),
  _SubCategory(
    title: 'Nursery Projects',
    icon: Icons.yard_rounded,
    color: Color(0xFF2E7D32),
    items: [
      (name: 'Commercial Plant Nursery',     url: null),
      (name: 'Seedling Production Units',    url: null),
      (name: 'Tissue Culture Plant Nursery', url: null),
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AgriProjectsScreen extends StatefulWidget {
  const AgriProjectsScreen({super.key});

  @override
  State<AgriProjectsScreen> createState() => _AgriProjectsScreenState();
}

class _AgriProjectsScreenState extends State<AgriProjectsScreen> {
  // Track which cards are expanded; all start expanded
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = List.filled(_kAgriSubCategories.length, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agri Farming Projects',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '10 categories • ${_kAgriSubCategories.fold(0, (sum, c) => sum + c.items.length)} projects',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          // Collapse / expand all toggle
          IconButton(
            tooltip: 'Toggle all',
            icon: Icon(
              _expanded.every((e) => e)
                  ? Icons.unfold_less_rounded
                  : Icons.unfold_more_rounded,
            ),
            onPressed: () {
              final allExpanded = _expanded.every((e) => e);
              setState(() {
                _expanded = List.filled(_kAgriSubCategories.length, !allExpanded);
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _kAgriSubCategories.length,
        itemBuilder: (context, index) {
          final cat = _kAgriSubCategories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SubCategoryCard(
              category: cat,
              index: index,
              isExpanded: _expanded[index],
              onToggle: () => setState(() => _expanded[index] = !_expanded[index]),
            ),
          );
        },
      ),
    );
  }
}

// ── Sub-category card ─────────────────────────────────────────────────────────

class _SubCategoryCard extends StatelessWidget {
  final _SubCategory category;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SubCategoryCard({
    required this.category,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: category.color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // ── Header ──
            InkWell(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      category.color,
                      category.color.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(category.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${category.items.length} projects',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),

            // ── Project items ──
            AnimatedCrossFade(
              firstChild: _buildItems(context, theme),
              secondChild: const SizedBox(width: double.infinity),
              crossFadeState: isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.1);
  }

  Widget _buildItems(BuildContext context, ThemeData theme) {
    return Column(
      children: category.items.asMap().entries.map((entry) {
        final i      = entry.key;
        final item   = entry.value;
        final isLast = i == category.items.length - 1;
        final hasUrl = item.url != null;

        return InkWell(
          onTap: () async {
            if (hasUrl) {
              final uri = Uri.parse(item.url!);
              try {
                await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
              } catch (_) {
                // Fallback: try external browser
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open link: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            } else {
              showBookingSheet(context,
                  type: BookingType.project, itemTitle: item.name);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                      ),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasUrl
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                if (hasUrl) ...[
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 14,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 12),
                ],
                InkWell(
                  onTap: () => showBookingSheet(context,
                      type: BookingType.project, itemTitle: item.name),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text('Book',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: category.color)),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
