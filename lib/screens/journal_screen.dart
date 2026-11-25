import 'package:flutter/material.dart';

import '../app.dart';
import '../data/tea_library.dart';
import '../theme/tea_theme.dart';
import '../utils/format.dart';
import '../widgets/tea_widgets.dart';
import 'tea_detail_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final favorite = store.favoriteTea;
    final records = store.records;
    final level = store.level;
    final next = store.nextLevel;

    return CustomScrollView(
      slivers: <Widget>[
        const SliverToBoxAdapter(child: TeaTopBar(subtitle: 'MY TEA JOURNAL')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('YOUR TEA JOURNAL', style: kEyebrow),
                      SizedBox(height: 6),
                      Text(
                        '我的茶记',
                        style: TextStyle(
                          fontFamilyFallback: kSerif,
                          fontSize: 27,
                          height: 1.3,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '记录喝过的茶，也记录那些慢下来的时刻。',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.8,
                          color: TeaPalette.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => TabSwitcher.maybeOf(context)?.go(2),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('记一笔'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => TabSwitcher.maybeOf(context)?.go(1),
                  child: const Text('去看图鉴'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    eyebrow: 'BREWED',
                    value: '${store.brewCount}',
                    unit: '次',
                    label: '累计泡茶',
                    caption: '每一次都是与自己的相处',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    eyebrow: 'TIME',
                    value: '${store.totalMinutes}',
                    unit: '分钟',
                    label: '品茶时光',
                    caption: '时间在茶香里慢了下来',
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _FavoriteCard(
              name: favorite?.name,
              count: favorite == null ? 0 : store.recordsOf(favorite.id).length,
              onTap: favorite == null
                  ? () => TabSwitcher.maybeOf(context)?.go(1)
                  : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              TeaDetailScreen(teaId: favorite.id),
                        ),
                      ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _LevelCard(
              level: level.title,
              blurb: level.blurb,
              points: store.points,
              progress: store.levelProgress,
              next: next?.title,
              remaining: next == null ? 0 : next.min - store.points,
              span: store.levelSpan,
              into: store.pointsIntoLevel,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: TeaSectionTitle(
              eyebrow: 'RECORDS',
              title: '冲泡流水',
              trailing: records.isEmpty
                  ? null
                  : Text(
                      '共 ${records.length} 条',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: TeaPalette.inkMuted,
                      ),
                    ),
            ),
          ),
        ),
        if (records.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: TeaEmptyState(
                title: '茶记还是空的',
                description: '去茶席计时泡一次，\n每一次出汤都会自动记在这里。',
                icon: Icons.edit_note_rounded,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverList.separated(
              itemCount: records.length.clamp(0, 20),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = records[index];
                final tea = TeaLibrary.find(record.teaId);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: <Widget>[
                      if (tea != null)
                        TeaThumb(tea: tea, width: 44, height: 44, radius: 12)
                      else
                        const SizedBox(width: 44, height: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              record.teaName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamilyFallback: kSerif,
                                fontSize: 14,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '第 ${record.round} 泡 · ${formatDuration(record.seconds)} · ${formatShortDate(record.at)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: TeaPalette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (tea != null)
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TeaDetailScreen(teaId: tea.id),
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 17,
                          ),
                          tooltip: '查看茶品',
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.eyebrow,
    required this.value,
    required this.unit,
    required this.label,
    required this.caption,
  });

  final String eyebrow;
  final String value;
  final String unit;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(eyebrow, style: kEyebrow),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  fontFamilyFallback: kSerif,
                  fontSize: 30,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  color: TeaPalette.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TeaPalette.inkSoft,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.6,
              color: TeaPalette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.name,
    required this.count,
    required this.onTap,
  });

  final String? name;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TeaPalette.paper,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TeaPalette.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TeaPalette.creamDeep,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 20,
                  color: TeaPalette.clay,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('偏爱之茶', style: kEyebrow),
                    const SizedBox(height: 4),
                    Text(
                      name ?? '还没有偏好',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamilyFallback: kSerif,
                        fontSize: 16,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                name == null ? '去图鉴里标记' : '已相伴 $count 次',
                style: const TextStyle(
                  fontSize: 11,
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

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.blurb,
    required this.points,
    required this.progress,
    required this.next,
    required this.remaining,
    required this.span,
    required this.into,
  });

  final String level;
  final String blurb;
  final int points;
  final double progress;
  final String? next;
  final int remaining;
  final int span;
  final int into;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: TeaPalette.mossDeep,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'YOUR TEA PATH',
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w600,
                    color: TeaPalette.cream.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Text(
                '$points 茶识点',
                style: TextStyle(
                  fontSize: 11,
                  color: TeaPalette.cream.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                level,
                style: const TextStyle(
                  fontFamilyFallback: kSerif,
                  fontSize: 27,
                  letterSpacing: 3,
                  color: TeaPalette.cream,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  blurb,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: TeaPalette.cream.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: TeaPalette.cream.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(TeaPalette.gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            next == null
                ? '已达最高等级，继续喝就是了'
                : '再积累 $remaining 点，即可晋升「$next」 · $into / $span',
            style: TextStyle(
              fontSize: 11,
              height: 1.6,
              color: TeaPalette.cream.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}
