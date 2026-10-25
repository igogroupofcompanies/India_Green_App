import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';


// ── Data ─────────────────────────────────────────────────────────────────────

class _SubCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _SubCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

const _kSubCategories = <_SubCategory>[
  _SubCategory(
    title: 'Goat Farming',
    icon: Icons.pets_rounded,
    color: Color(0xFF558B2F),
    items: [
      'Commercial Goat Farming',
      'Integrated Goat Farming',
    ],
  ),
  _SubCategory(
    title: 'Sheep Farming',
    icon: Icons.blur_circular_rounded,
    color: Color(0xFF6D4C41),
    items: [
      'Commercial Sheep Farming',
    ],
  ),
  _SubCategory(
    title: 'Dairy Farming',
    icon: Icons.local_drink_rounded,
    color: Color(0xFF1565C0),
    items: [
      'Dairy Farm Setup',
      'Automated Dairy Systems',
    ],
  ),
  _SubCategory(
    title: 'Poultry Farming',
    icon: Icons.egg_rounded,
    color: Color(0xFFE65100),
    items: [
      'Broiler Chicken Farms',
      'Layer Chicken Farms',
    ],
  ),
  _SubCategory(
    title: 'Integrated Livestock Farming',
    icon: Icons.hub_rounded,
    color: Color(0xFF37474F),
    items: [
      'Goat + Fish Farming',
      'Dairy + Crop Farming',
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class LivestockProjectsScreen extends StatefulWidget {
  const LivestockProjectsScreen({super.key});

  @override
  State<LivestockProjectsScreen> createState() =>
      _LivestockProjectsScreenState();
}

class _LivestockProjectsScreenState extends State<LivestockProjectsScreen> {
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = List.filled(_kSubCategories.length, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalItems =
        _kSubCategories.fold(0, (sum, c) => sum + c.items.length);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Livestock Farming Projects',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_kSubCategories.length} categories • $totalItems projects',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
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
                _expanded =
                    List.filled(_kSubCategories.length, !allExpanded);
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _kSubCategories.length,
        itemBuilder: (context, index) {
          final cat = _kSubCategories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SubCategoryCard(
              category: cat,
              index: index,
              isExpanded: _expanded[index],
              onToggle: () =>
                  setState(() => _expanded[index] = !_expanded[index]),
            ),
          );
        },
      ),
    );
  }
}

// ── Card widget ───────────────────────────────────────────────────────────────

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
            InkWell(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
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
                      child: Icon(category.icon,
                          color: Colors.white, size: 22),
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
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: Colors.white70),
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
        final i = entry.key;
        final item = entry.value;
        final isLast = i == category.items.length - 1;
        return InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(item),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
