import 'package:flutter/material.dart';

import '../app.dart';
import '../data/tea_library.dart';
import '../models/tea.dart';
import '../theme/tea_theme.dart';
import '../utils/format.dart';
import '../widgets/tea_widgets.dart';
import 'category_screen.dart';
import 'tea_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final now = DateTime.now();
    final featured = TeaLibrary.featured;
    final categories = TeaLibrary.categories;

    return CustomScrollView(
      slivers: <Widget>[
        const SliverToBoxAdapter(child: TeaTopBar(subtitle: 'TEA · JOY')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('今日茶事', style: kEyebrow),
                        const SizedBox(height: 6),
                        Text(
                          store.greeting(),
                          style: const TextStyle(
                            fontFamilyFallback: kSerif,
                            fontSize: 21,
                            height: 1.35,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _JournalChip(
                    count: store.brewCount,
                    onTap: () => onNavigate(4),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                formatChineseDate(now),
                style: const TextStyle(
                  fontSize: 11.5,
                  letterSpacing: 0.8,
                  color: TeaPalette.inkMuted,
                ),
              ),
              const SizedBox(height: 18),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _HeroCard(
              onStart: () => onNavigate(2),
              onExplore: () => onNavigate(1),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: TeaSectionTitle(
              eyebrow: 'SEASONAL PICK · 霜降',
              title: '霜降荐茶',
              trailing: TextButton(
                onPressed: () => onNavigate(1),
                child: const Text('全部茶品'),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _FeaturedTeaCard(
              tea: featured,
              tag: '霜降荐茶 · ${featured.category}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TeaDetailScreen(teaId: featured.id),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
          sliver: SliverToBoxAdapter(
            child: TeaSectionTitle(
              eyebrow: 'SIX FAMILIES',
              title: '六大茶类',
              trailing: TextButton(
                onPressed: () => onNavigate(1),
                child: const Text('图鉴'),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                final count = TeaLibrary.categoryCounts[category] ?? 0;
                return _CategoryTile(
                  category: category,
                  count: count,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CategoryScreen(category: category),
                    ),
                  ),
                );
              },
              childCount: categories.length.clamp(0, 6),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(child: _Colophon()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _JournalChip extends StatelessWidget {
  const _JournalChip({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TeaPalette.paper,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 7, 14, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: TeaPalette.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.edit_note_rounded,
                size: 15,
                color: TeaPalette.moss,
              ),
              const SizedBox(width: 5),
              Text(
                '我的茶记 $count',
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                  color: TeaPalette.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStart, required this.onExplore});

  final VoidCallback onStart;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 486,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              'assets/library/hero/hero_pour.webp',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.15),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x00F6F1E7),
                    Color(0x1AF6F1E7),
                    Color(0xE6F6F1E7),
                    Color(0xFFF6F1E7),
                  ],
                  stops: <double>[0.0, 0.42, 0.66, 0.85],
                ),
              ),
            ),
            Positioned(
              top: 22,
              right: 16,
              child: _VerticalLine(text: '且将新火试新茶'),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '—— 一席茶，一段留白',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: TeaPalette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '一叶知山，\n一水知心。',
                    style: TextStyle(
                      fontFamilyFallback: kSerif,
                      fontSize: 30,
                      height: 1.4,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '在快节奏的日常里，为自己留一盏茶的时间。识茶、候汤、静饮，让心有片刻安顿。',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.85,
                      letterSpacing: 0.4,
                      color: TeaPalette.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      FilledButton(
                        onPressed: onStart,
                        child: const Text('开始今日一泡'),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: onExplore,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('探索茶的世界'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 15),
                          ],
                        ),
                      ),
                    ],
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

class _VerticalLine extends StatelessWidget {
  const _VerticalLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: TeaPalette.paper.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: RotatedBox(
        quarterTurns: 1,
        child: Text(
          text,
          style: const TextStyle(
            fontFamilyFallback: kSerif,
            fontSize: 11,
            letterSpacing: 3,
            color: TeaPalette.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _FeaturedTeaCard extends StatelessWidget {
  const _FeaturedTeaCard({
    required this.tea,
    required this.tag,
    required this.onTap,
  });

  final Tea tea;
  final String tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 104,
                  height: 132,
                  child: tea.image == null
                      ? Container(
                          color: TeaPalette.creamDeep,
                          alignment: Alignment.center,
                          child: Text(
                            tea.sealChar,
                            style: const TextStyle(
                              fontFamilyFallback: kSerif,
                              fontSize: 34,
                              color: TeaPalette.moss,
                            ),
                          ),
                        )
                      : Image.asset(tea.image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 132,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(tag, style: kEyebrow),
                      const SizedBox(height: 6),
                      Text(
                        tea.name,
                        style: const TextStyle(
                          fontFamilyFallback: kSerif,
                          fontSize: 19,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          tea.summary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.75,
                            color: TeaPalette.inkSoft,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.local_fire_department_outlined,
                            size: 13,
                            color: TeaPalette.gold.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${tea.brewTemp}℃ · ${tea.vessel} · ${tea.steeps.length} 泡',
                            style: const TextStyle(
                              fontSize: 11,
                              color: TeaPalette.inkMuted,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_outward_rounded,
                            size: 16,
                            color: TeaPalette.inkMuted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final String category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TeaPalette.paper,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TeaPalette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                category,
                style: const TextStyle(
                  fontFamilyFallback: kSerif,
                  fontSize: 15,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count 款',
                style: const TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 0.6,
                  color: TeaPalette.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Colophon extends StatelessWidget {
  const _Colophon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(),
          const SizedBox(height: 14),
          Text(
            '茶愉 · 一个把喝茶这件事放慢的地方',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              color: TeaPalette.inkMuted.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '资料与图片参考：茶百科 · 灵芽AI · Teaspedia · 茶叶百科LZ',
            style: TextStyle(fontSize: 10.5, color: TeaPalette.inkMuted),
          ),
        ],
      ),
    );
  }
}
