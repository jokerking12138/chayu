import 'package:flutter/material.dart';

import '../models/tea.dart';
import '../theme/tea_theme.dart';

/// 印章式角标，强调"茶"这一主体。
class TeaSeal extends StatelessWidget {
  const TeaSeal({
    super.key,
    this.char = '茶',
    this.size = 34,
    this.filled = true,
  });

  final String char;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? scheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: filled ? null : Border.all(color: TeaPalette.line, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: TextStyle(
          fontFamilyFallback: kSerif,
          fontSize: size * 0.5,
          height: 1,
          fontWeight: FontWeight.w600,
          color: filled ? scheme.onPrimary : TeaPalette.inkSoft,
        ),
      ),
    );
  }
}

/// 页首：左侧印章 + 标题，右侧动作按钮。
class TeaTopBar extends StatelessWidget {
  const TeaTopBar({
    super.key,
    this.title = '茶愉',
    this.subtitle,
    this.actions = const <Widget>[],
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (showBack)
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                tooltip: '返回',
              )
            else
              const TeaSeal(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamilyFallback: kSerif,
                      fontSize: 19,
                      height: 1.2,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: TeaPalette.inkMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

/// 小节标题：色条 + 中文标题 + 可选英文标签。
class TeaSectionTitle extends StatelessWidget {
  const TeaSectionTitle({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 3,
          height: 16,
          margin: const EdgeInsets.only(right: 10, bottom: 2),
          decoration: BoxDecoration(
            color: TeaPalette.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (eyebrow != null) ...<Widget>[
                Text(eyebrow!, style: kEyebrow),
                const SizedBox(height: 2),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontFamilyFallback: kSerif,
                  fontSize: 17,
                  letterSpacing: 2,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// 茶品缩略图 / 占位印章。
class TeaThumb extends StatelessWidget {
  const TeaThumb({
    super.key,
    required this.tea,
    this.width = 68,
    this.height = 68,
    this.radius = 14,
  });

  final Tea tea;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final child = tea.image == null
        ? Container(
            color: TeaPalette.creamDeep,
            alignment: Alignment.center,
            child: Text(
              tea.sealChar,
              style: TextStyle(
                fontFamilyFallback: kSerif,
                fontSize: height * 0.36,
                color: TeaPalette.moss.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : Image.asset(tea.image!, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

/// 茶品行：图 + 名 + 产地风味。
class TeaListTile extends StatelessWidget {
  const TeaListTile({
    super.key,
    required this.tea,
    this.onTap,
    this.trailing,
  });

  final Tea tea;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            TeaThumb(tea: tea, width: 62, height: 62),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          tea.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamilyFallback: kSerif,
                            fontSize: 15.5,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TeaPill(text: tea.category),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${tea.origin} · ${tea.flavor}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TeaPalette.inkSoft,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: TeaPalette.inkMuted,
                ),
          ],
        ),
      ),
    );
  }
}

/// 极小的语义标签。
class TeaPill extends StatelessWidget {
  const TeaPill({
    super.key,
    required this.text,
    this.active = false,
    this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = active ? scheme.primary : TeaPalette.creamDeep;
    final fg = active ? scheme.onPrimary : TeaPalette.inkSoft;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.2,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

/// 空状态。
class TeaEmptyState extends StatelessWidget {
  const TeaEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.local_cafe_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 26, color: TeaPalette.inkMuted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamilyFallback: kSerif,
              fontSize: 14.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.7,
              color: TeaPalette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

void showTeaSnack(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
