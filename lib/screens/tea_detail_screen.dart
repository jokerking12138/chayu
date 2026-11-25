import 'package:flutter/material.dart';

import '../app.dart';
import '../data/tea_library.dart';
import '../models/tea.dart';
import '../theme/tea_theme.dart';
import '../utils/format.dart';
import '../widgets/tea_book_sections.dart';
import '../widgets/tea_widgets.dart';

class TeaDetailScreen extends StatelessWidget {
  const TeaDetailScreen({super.key, required this.teaId});

  final String teaId;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final tea = TeaLibrary.find(teaId);
    if (tea == null) {
      return const Scaffold(
        body: Center(child: Text('茶品不存在')),
      );
    }
    final isFavorite = store.favoriteTeaId == tea.id;
    final brews = store.recordsOf(tea.id);

    return Scaffold(
      backgroundColor: TeaPalette.cream,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _HeroHeader(
              tea: tea,
              isFavorite: isFavorite,
              onFavorite: () {
                store.toggleFavorite(tea);
                showTeaSnack(
                  context,
                  isFavorite ? '已取消收藏' : '已收藏 ${tea.name}',
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                Text(
                  '${tea.category} · ${tea.origin}',
                  style: kEyebrow,
                ),
                if (tea.originDetail.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    tea.originDetail,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.7,
                      color: TeaPalette.inkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  tea.name,
                  style: const TextStyle(
                    fontFamilyFallback: kSerif,
                    fontSize: 29,
                    height: 1.3,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tea.summary,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.95,
                    letterSpacing: 0.3,
                    color: TeaPalette.inkSoft,
                  ),
                ),
                const SizedBox(height: 20),
                _ParamGrid(tea: tea),
                const SizedBox(height: 22),
                const TeaSectionTitle(eyebrow: 'STEEPING', title: '冲泡节奏'),
                const SizedBox(height: 12),
                _SteepTimeline(tea: tea),
                const SizedBox(height: 22),
                const TeaSectionTitle(eyebrow: 'FLAVOR', title: '风味与香气'),
                const SizedBox(height: 12),
                _FlavorBlock(tea: tea),
                const SizedBox(height: 22),
                if (tea.hasSensory) ...<Widget>[
                  const TeaSectionTitle(eyebrow: 'SENSORY', title: '感官档案'),
                  const SizedBox(height: 12),
                  SensoryBoard(tea: tea),
                  const SizedBox(height: 22),
                ],
                if (tea.hasBookNotes) ...<Widget>[
                  const TeaSectionTitle(eyebrow: 'BREW NOTES', title: '泡法与品饮'),
                  const SizedBox(height: 12),
                  BookNotes(tea: tea),
                  const SizedBox(height: 22),
                ],
                const TeaSectionTitle(eyebrow: 'NOTES', title: '茶人小记'),
                const SizedBox(height: 10),
                Text(
                  tea.story,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 2,
                    color: TeaPalette.inkSoft,
                  ),
                ),
                const SizedBox(height: 22),
                TeaSectionTitle(
                  eyebrow: 'MY RECORDS',
                  title: '我的记录',
                  trailing: brews.isEmpty
                      ? null
                      : Text(
                          '${brews.length} 次',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: TeaPalette.inkMuted,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                if (brews.isEmpty)
                  TeaEmptyState(
                    title: '还没有泡过这款茶',
                    description: '去茶席计时泡一次，\n记录会自动出现在这里。',
                  )
                else
                  ...brews.reversed.take(4).map(
                        (record) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _RecordRow(
                            round: record.round,
                            seconds: record.seconds,
                            at: record.at,
                          ),
                        ),
                      ),
                const SizedBox(height: 8),
                Text(
                  tea.hasBookNotes || tea.hasSensory
                      ? '资料来源：${tea.source} · 摘录与图片版权归原作者与出版方所有'
                      : '资料来源：${tea.source} · 本页描述为整理后的示例内容',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.7,
                    color: TeaPalette.inkMuted.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 17),
                  label: const Text('返回'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    store.rememberSession(tea, 1);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    TabSwitcher.maybeOf(context)?.go(2);
                  },
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: const Text('用它泡一泡'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.tea,
    required this.isFavorite,
    required this.onFavorite,
  });

  final Tea tea;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (tea.image != null)
            Image.asset(tea.image!, fit: BoxFit.cover)
          else
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    TeaPalette.creamDeep,
                    TeaPalette.moss.withValues(alpha: 0.28),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  tea.sealChar,
                  style: TextStyle(
                    fontFamilyFallback: kSerif,
                    fontSize: 96,
                    color: TeaPalette.mossDeep.withValues(alpha: 0.35),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x33000000), Color(0x00000000), Color(0xFFF6F1E7)],
                stops: <double>[0.0, 0.42, 1.0],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: IconButton.styleFrom(
                      backgroundColor: TeaPalette.paper.withValues(alpha: 0.86),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 19),
                    tooltip: '返回',
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onFavorite,
                    style: IconButton.styleFrom(
                      backgroundColor: TeaPalette.paper.withValues(alpha: 0.86),
                    ),
                    icon: Icon(
                      isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 19,
                      color: isFavorite ? TeaPalette.clay : TeaPalette.inkSoft,
                    ),
                    tooltip: isFavorite ? '取消收藏' : '收藏',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParamGrid extends StatelessWidget {
  const _ParamGrid({required this.tea});

  final Tea tea;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('水温', '${tea.brewTemp} ℃'),
      ('器皿', tea.vessel),
      ('首泡', tea.firstSteep),
    ];
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: item == items.last ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: TeaPalette.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TeaPalette.line),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 1,
                        color: TeaPalette.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontFamilyFallback: kSerif,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SteepTimeline extends StatelessWidget {
  const _SteepTimeline({required this.tea});

  final Tea tea;

  @override
  Widget build(BuildContext context) {
    final total = tea.totalSteepSeconds;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              for (var i = 0; i < tea.steeps.length; i++)
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 3,
                        height: 10,
                        color: TeaPalette.gold.withValues(
                          alpha: 0.35 + 0.65 * (i / tea.steeps.length),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '第${i + 1}泡',
                        style: const TextStyle(
                          fontSize: 10,
                          color: TeaPalette.inkMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tea.steeps[i]}s',
                        style: const TextStyle(
                          fontFamilyFallback: kSerif,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(Icons.spa_outlined, size: 13, color: TeaPalette.inkMuted),
              const SizedBox(width: 5),
              Text(
                '共 ${tea.steeps.length} 泡 · 累计 ${formatDuration(total)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: TeaPalette.inkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlavorBlock extends StatelessWidget {
  const _FlavorBlock({required this.tea});

  final Tea tea;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tea.flavor
              .split(' · ')
              .map((e) => TeaPill(text: e))
              .toList(),
        ),
        const SizedBox(height: 10),
        Text(
          '香气：${tea.aroma}',
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

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.round,
    required this.seconds,
    required this.at,
  });

  final int round;
  final int seconds;
  final DateTime at;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.circle, size: 6, color: TeaPalette.moss.withValues(alpha: 0.55)),
          const SizedBox(width: 10),
          Text(
            '第 $round 泡',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            formatDuration(seconds),
            style: const TextStyle(fontSize: 12, color: TeaPalette.inkSoft),
          ),
          const Spacer(),
          Text(
            formatShortDate(at),
            style: const TextStyle(fontSize: 11, color: TeaPalette.inkMuted),
          ),
        ],
      ),
    );
  }
}
