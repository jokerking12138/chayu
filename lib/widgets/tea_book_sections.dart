import 'package:flutter/material.dart';

import '../models/tea.dart';
import '../theme/tea_theme.dart';

/// 《中国茶图鉴》条目的感官档案：外形 / 汤色 / 滋味 / 叶底。
class SensoryBoard extends StatelessWidget {
  const SensoryBoard({super.key, required this.tea});

  final Tea tea;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('外形', tea.appearance),
      ('汤色', tea.liquor),
      ('滋味', tea.taste),
      ('叶底', tea.leaf),
    ].where((e) => e.$2.isNotEmpty).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 40,
                    child: Text(
                      rows[i].$1,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: TeaPalette.inkMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.8,
                        color: TeaPalette.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 《中国茶图鉴》条目的泡法原文与品饮记录。
class BookNotes extends StatelessWidget {
  const BookNotes({super.key, required this.tea});

  final Tea tea;

  @override
  Widget build(BuildContext context) {
    final notes = <(String, String)>[
      ('泡法', tea.brewNote),
      ('品饮', tea.tasteNote),
    ].where((e) => e.$2.isNotEmpty).toList();
    if (notes.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TeaPalette.creamDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (var i = 0; i < notes.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Icon(
                  notes[i].$1 == '泡法'
                      ? Icons.emoji_food_beverage_outlined
                      : Icons.local_cafe_outlined,
                  size: 14,
                  color: TeaPalette.gold,
                ),
                const SizedBox(width: 6),
                Text(
                  notes[i].$1,
                  style: const TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              notes[i].$2,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.95,
                color: TeaPalette.inkSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
