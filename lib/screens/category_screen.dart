import 'package:flutter/material.dart';

import '../data/tea_library.dart';
import '../theme/tea_theme.dart';
import '../widgets/tea_widgets.dart';
import 'tea_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final teas = TeaLibrary.all.where((t) => t.category == category).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: TeaPalette.cream,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: TeaTopBar(
              title: category,
              subtitle: '${teas.length} 款 · 图鉴',
              showBack: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                _intro(category),
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.9,
                  color: TeaPalette.inkSoft,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverList.separated(
              itemCount: teas.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tea = teas[index];
                return TeaListTile(
                  tea: tea,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TeaDetailScreen(teaId: tea.id),
                    ),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  String _intro(String category) {
    switch (category) {
      case '绿茶':
        return '不发酵，杀青定格了春天的颜色。水温宜低，器皿宜透，看芽叶在杯中舒展，是绿茶的一半乐趣。';
      case '红茶':
        return '全发酵，茶多酚转成茶黄素与茶红素。汤色红亮，甜香明显，适合清饮，也经得起加奶。';
      case '乌龙茶':
        return '半发酵，做青与焙火之间有很大的余地。香气层次最丰富，讲究高冲快出，越泡越见底韵。';
      case '白茶':
        return '微发酵，不炒不揉，只靠萎凋与干燥。新茶清甜，陈茶转药香，是少数能"存"的茶。';
      case '黑茶':
        return '后发酵，渥堆与时间共同作用。汤感厚、耐煮、耐泡，是冬天与饭后最妥帖的选择。';
      case '黄茶':
        return '多一道"闷黄"，比绿茶多一分暖意与甜。产量少，工艺娇气，是最容易被忽略的一类。';
      case '花茶':
        return '以茶为骨、以花为香。窨制让花香进入茶体，而不是浮在表面，讲究的是"鲜灵"。';
      case '普洱茶':
        return '云南大叶种的后发酵茶，分生茶与熟茶。生茶随年份转蜜转木，熟茶靠渥堆提前温厚，都能存、也都能煮。';
      case '非茶之茶':
        return '不含茶树种原料的"茶"：马黛、猫须、如意、雪菊之类。它们不属于六大茶类，却同样在杯子里。';
      default:
        return '一支一支地喝下去，茶的样子会慢慢清楚。';
    }
  }
}
