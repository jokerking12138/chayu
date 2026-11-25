import 'package:flutter/material.dart';

import '../data/tea_library.dart';
import '../theme/tea_theme.dart';
import '../widgets/tea_widgets.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const List<(String, String, String)> _steps = <(String, String, String)>[
    (
      '备器',
      '一壶一杯一公道',
      '先想清楚要喝什么，再决定器。绿茶用玻璃杯看形，乌龙用盖碗聚香，黑茶可上壶煮。器不必贵，顺手最重要。'
    ),
    (
      '择水',
      '山水上，江水中，井水下',
      '家用净水即可，矿泉水别太硬。水要现烧现用，反复煮沸的水会让茶汤发闷。'
    ),
    (
      '候汤',
      '蟹眼已过鱼眼生',
      '绿茶 80–85℃，白茶与乌龙 95–100℃。没有温控壶时，听壶声、看水泡：细密小泡是"蟹眼"，大泡翻涌就过了。'
    ),
    (
      '投茶',
      '茶水比 1:50 起步',
      '绿茶与红茶 1:50，乌龙 1:20，黑茶可到 1:15。宁可先淡，淡了可以加时，浓了就救不回来。'
    ),
    (
      '出汤',
      '快出汤，不留底',
      '第一泡多为 15–30 秒，之后逐泡延长。出汤要利落，汤不倒干净会把茶叶闷熟，下一泡就苦。'
    ),
    (
      '静饮',
      '不急着评价',
      '先闻香，再小口含住，让茶汤铺满舌面。热的时候喝香，温的时候喝甜，凉下来喝底韵。'
    ),
  ];

  static const List<(String, String)> _myths = <(String, String)>[
    ('浓茶解酒', '并不会。咖啡因与酒精叠加只会更伤胃，酒后喝温水更稳妥。'),
    ('隔夜茶有毒', '主要是氧化与落灰导致风味变差、可能滋生细菌，不是"毒"，但确实不建议喝。'),
    ('越贵的茶越耐泡', '耐泡度取决于茶多酚、氨基酸比例与叶片完整度，与价格没有必然关系。'),
    ('第一泡必须倒掉', '叫"润茶"或"醒茶"，是为了让紧压茶或焙火茶舒展，不是洗掉脏东西。嫩绿茶可以直接喝。'),
    ('空腹喝茶伤胃', '对多数人成立，尤其绿茶与生普。饭后半小时到一小时，是比较舒服的窗口。'),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const SliverToBoxAdapter(child: TeaTopBar(subtitle: 'GUIDE')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('泡茶指南', style: kEyebrow),
                const SizedBox(height: 6),
                const Text(
                  '从烧水开始',
                  style: TextStyle(
                    fontFamilyFallback: kSerif,
                    fontSize: 27,
                    height: 1.3,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '泡茶没有标准答案，只有一套可以照着走的顺序。先把这六步做熟，再谈风味。',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.9,
                    color: TeaPalette.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _TemperatureChart(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
          sliver: SliverToBoxAdapter(
            child: const TeaSectionTitle(eyebrow: 'SIX STEPS', title: '六步成席'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverList.separated(
            itemCount: _steps.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final step = _steps[index];
              return _StepCard(
                index: index + 1,
                title: step.$1,
                subtitle: step.$2,
                body: step.$3,
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
          sliver: SliverToBoxAdapter(
            child: const TeaSectionTitle(eyebrow: 'MYTHS', title: '几个常见误会'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverList.separated(
            itemCount: _myths.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _myths[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TeaPalette.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TeaPalette.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: TeaPalette.clay,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.85,
                        color: TeaPalette.inkSoft,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

class _TemperatureChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = <(String, double)>[
      ('绿茶', 82),
      ('白茶', 92),
      ('黄茶', 85),
      ('乌龙', 100),
      ('红茶', 95),
      ('黑茶', 100),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('六大茶类 · 建议水温', style: kEyebrow),
          const SizedBox(height: 14),
          ...entries.map((entry) {
            final ratio = (entry.$2 - 70) / 35;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 34,
                    child: Text(
                      entry.$1,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: TeaPalette.inkSoft,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.05, 1.0),
                        minHeight: 6,
                        backgroundColor: TeaPalette.creamDeep,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          TeaPalette.moss.withValues(alpha: 0.45 + ratio * 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${entry.$2.toInt()}℃',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            '内置茶库 ${TeaLibrary.all.length} 款茶的参数可在图鉴中查看',
            style: const TextStyle(fontSize: 10.5, color: TeaPalette.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final int index;
  final String title;
  final String subtitle;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: TeaPalette.mossDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                fontFamilyFallback: kSerif,
                fontSize: 14,
                color: TeaPalette.paper,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamilyFallback: kSerif,
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: TeaPalette.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.85,
                    color: TeaPalette.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
