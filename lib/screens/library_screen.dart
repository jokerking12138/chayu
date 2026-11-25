import 'package:flutter/material.dart';

import '../data/tea_library.dart';
import '../models/tea.dart';
import '../theme/tea_theme.dart';
import '../widgets/tea_widgets.dart';
import 'tea_detail_screen.dart';

enum TeaSort { recommend, name, temperature }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _query = TextEditingController();
  String _category = '全部';
  String? _origin;
  String? _source;
  TeaSort _sort = TeaSort.recommend;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Tea> get _results {
    final keyword = _query.text.trim();
    var list = TeaLibrary.all.where((tea) {
      if (_category != '全部' && tea.category != _category) return false;
      if (_origin != null && normalizeOrigin(tea.origin) != _origin) return false;
      if (_source != null && tea.source != _source) return false;
      if (keyword.isEmpty) return true;
      return tea.name.contains(keyword) ||
          tea.origin.contains(keyword) ||
          tea.flavor.contains(keyword) ||
          tea.aroma.contains(keyword) ||
          tea.category.contains(keyword) ||
          tea.summary.contains(keyword);
    }).toList();

    switch (_sort) {
      case TeaSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
      case TeaSort.temperature:
        list.sort((a, b) => a.brewTemp.compareTo(b.brewTemp));
      case TeaSort.recommend:
        // 推荐顺序沿用茶库自身顺序：书里按茶类分章排，手写补充条目排在末尾。
        final rank = <String, int>{
          for (var i = 0; i < TeaLibrary.all.length; i++)
            TeaLibrary.all[i].id: i,
        };
        list.sort((a, b) => (rank[a.id] ?? 0).compareTo(rank[b.id] ?? 0));
    }
    return list;
  }

  bool get _filtering =>
      _category != '全部' ||
      _origin != null ||
      _source != null ||
      _query.text.trim().isNotEmpty;

  void _reset() {
    setState(() {
      _query.clear();
      _category = '全部';
      _origin = null;
      _source = null;
      _sort = TeaSort.recommend;
    });
  }

  Future<void> _pickOrigin() async {
    final options = <String?>[null, ...TeaLibrary.origins];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: TeaPalette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _FilterSheet(
        title: '按产地筛选',
        subtitle: '共 ${TeaLibrary.origins.length} 个产地',
        options: options
            .map(
              (e) => _FilterOption(
                value: e ?? '__all__',
                label: e ?? '全部产地',
                selected: (e ?? '__all__') == (_origin ?? '__all__'),
              ),
            )
            .toList(),
      ),
    );
    if (picked == null) return;
    setState(() => _origin = picked == '__all__' ? null : picked);
  }

  Future<void> _pickSource() async {
    final sources = TeaLibrary.all.map((t) => t.source).toSet().toList()..sort();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: TeaPalette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _FilterSheet(
        title: '按资料来源筛选',
        subtitle: '资料来源决定词条写法与图片出处',
        options: <_FilterOption>[
          _FilterOption(
            value: '__all__',
            label: '全部来源',
            selected: _source == null,
          ),
          ...sources.map(
            (s) => _FilterOption(
              value: s,
              label: s,
              selected: _source == s,
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    setState(() => _source = picked == '__all__' ? null : picked);
  }

  Future<void> _pickSort() async {
    const labels = <TeaSort, String>{
      TeaSort.recommend: '推荐顺序',
      TeaSort.name: '按名称',
      TeaSort.temperature: '按水温',
    };
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: TeaPalette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _FilterSheet(
        title: '排序方式',
        subtitle: '推荐顺序优先展示有图的茶品',
        options: labels.entries
            .map(
              (e) => _FilterOption(
                value: e.key.name,
                label: e.value,
                selected: _sort == e.key,
              ),
            )
            .toList(),
      ),
    );
    if (picked == null) return;
    setState(() => _sort = TeaSort.values.firstWhere(
      (e) => e.name == picked,
      orElse: () => TeaSort.recommend,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final categories = <String>['全部', ...TeaLibrary.categories];
    final sortLabel = switch (_sort) {
      TeaSort.recommend => '推荐顺序',
      TeaSort.name => '按名称',
      TeaSort.temperature => '按水温',
    };

    return CustomScrollView(
      slivers: <Widget>[
        const SliverToBoxAdapter(child: TeaTopBar(subtitle: 'ENCYCLOPEDIA')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(child: _Heading()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SearchField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              onClear: () => setState(_query.clear),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = categories[index];
                  final count = label == '全部'
                      ? TeaLibrary.all.length
                      : TeaLibrary.categoryCounts[label] ?? 0;
                  return TeaPill(
                    text: label == '全部' ? '全部 $count' : '$label $count',
                    active: _category == label,
                    onTap: () => setState(() => _category = label),
                  );
                },
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: <Widget>[
                _FilterButton(
                  label: _origin ?? '全部产地',
                  active: _origin != null,
                  onTap: _pickOrigin,
                ),
                const SizedBox(width: 8),
                _FilterButton(
                  label: _source ?? '全部来源',
                  active: _source != null,
                  onTap: _pickSource,
                ),
                const SizedBox(width: 8),
                _FilterButton(
                  label: sortLabel,
                  active: _sort != TeaSort.recommend,
                  onTap: _pickSort,
                ),
                const Spacer(),
                if (_filtering)
                  TextButton(
                    onPressed: _reset,
                    child: const Text('重置'),
                  ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: <Widget>[
                Text(
                  '共收录 ${TeaLibrary.all.length} 款 · 寻得 ${results.length} 款',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: TeaPalette.inkMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Text(
                  '含《中国茶图鉴》',
                  style: TextStyle(
                    fontSize: 10,
                    color: TeaPalette.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              '资料与图片参考：《中国茶图鉴》李韬 · 茶百科 · 灵芽AI · Teaspedia · 茶叶百科LZ',
              style: TextStyle(
                fontSize: 10,
                height: 1.6,
                color: TeaPalette.inkMuted.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
        if (results.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: TeaEmptyState(
                title: '没有找到对应的茶',
                description: '换个名字、产地或风味试试，\n也可以清空筛选看看全部 ${TeaLibrary.all.length} 款。',
                icon: Icons.search_off_rounded,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tea = results[index];
                  return _TeaGridCard(
                    tea: tea,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TeaDetailScreen(teaId: tea.id),
                      ),
                    ),
                  );
                },
                childCount: results.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('茶叶图鉴', style: kEyebrow),
        const SizedBox(height: 6),
        const Text(
          '茶叶图鉴',
          style: TextStyle(
            fontFamilyFallback: kSerif,
            fontSize: 27,
            height: 1.3,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '本地内置 ${TeaLibrary.all.length} 款茶品，其中 ${TeaLibrary.bookCount} 款取自《中国茶图鉴》· 可搜索，可按茶类、产地与来源筛选。',
          style: const TextStyle(
            fontSize: 12,
            height: 1.8,
            color: TeaPalette.inkSoft,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: '搜索茶名、产地、风味或香气',
        hintStyle: const TextStyle(fontSize: 13, color: TeaPalette.inkMuted),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: '清空',
              ),
        filled: true,
        fillColor: TeaPalette.paper,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: TeaPalette.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: TeaPalette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: TeaPalette.moss, width: 1.4),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? TeaPalette.mossDeep : TeaPalette.paper,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 7, 10, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? TeaPalette.mossDeep : TeaPalette.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: active ? TeaPalette.paper : TeaPalette.inkSoft,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: active ? TeaPalette.paper : TeaPalette.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption({
    required this.value,
    required this.label,
    required this.selected,
  });

  final String value;
  final String label;
  final bool selected;
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.title,
    required this.subtitle,
    required this.options,
  });

  final String title;
  final String subtitle;
  final List<_FilterOption> options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: TeaPalette.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamilyFallback: kSerif,
                fontSize: 17,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: TeaPalette.inkMuted),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: options
                    .map(
                      (option) => InkWell(
                        onTap: () => Navigator.of(context).pop(option.value),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: option.selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: option.selected
                                        ? TeaPalette.mossDeep
                                        : TeaPalette.ink,
                                  ),
                                ),
                              ),
                              if (option.selected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: TeaPalette.moss,
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeaGridCard extends StatelessWidget {
  const _TeaGridCard({required this.tea, required this.onTap});

  final Tea tea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: tea.image == null
                    ? Container(
                        color: TeaPalette.creamDeep,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              tea.sealChar,
                              style: TextStyle(
                                fontFamilyFallback: kSerif,
                                fontSize: 40,
                                height: 1.1,
                                color: TeaPalette.moss.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tea.category,
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: TeaPalette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.asset(tea.image!, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tea.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamilyFallback: kSerif,
                      fontSize: 14.5,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tea.origin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: TeaPalette.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
