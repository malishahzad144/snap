// ============================================================
//  features/filters/widgets/filter_bar.dart
//  Horizontally scrollable filter thumbnail strip
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../filter_provider.dart';
import '../models/filter_model.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({super.key});
  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToSelected(int index, int total) {
    final itemW = AppConstants.filterThumbSize + 12;
    final target = (index * itemW) - (MediaQuery.of(context).size.width / 2) + itemW / 2;
    _scroll.animateTo(
      target.clamp(0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (_, fp, __) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          // Category label
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _categoryLabel(fp.selectedFilter.category),
              style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 0.8),
            ),
          ),
          SizedBox(
            height: AppConstants.filterBarHeight,
            child: ListView.builder(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: fp.filters.length,
              itemBuilder: (_, i) {
                final filter  = fp.filters[i];
                final selected = fp.selectedIndex == i;
                return _FilterThumb(
                  filter:   filter,
                  selected: selected,
                  onTap: () {
                    fp.selectFilter(i);
                    _scrollToSelected(i, fp.filters.length);
                  },
                );
              },
            ),
          ),
        ]);
      },
    );
  }

  String _categoryLabel(FilterCategory c) => switch (c) {
    FilterCategory.color    => '● COLOR',
    FilterCategory.artistic => '● ARTISTIC',
    FilterCategory.faceAR   => '● FACE AR',
    FilterCategory.mood     => '● MOOD',
  };
}

class _FilterThumb extends StatelessWidget {
  final FilterModel filter;
  final bool selected;
  final VoidCallback onTap;

  const _FilterThumb({required this.filter, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:  AppConstants.filterThumbSize,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: filter.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: filter.gradientColors.first.withOpacity(0.6), blurRadius: 10, spreadRadius: 1)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(filter.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              filter.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
