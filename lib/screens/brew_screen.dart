import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/tea_library.dart';
import '../models/tea.dart';
import '../theme/tea_theme.dart';
import '../utils/format.dart';
import '../widgets/tea_widgets.dart';
import 'tea_detail_screen.dart';

class BrewScreen extends StatefulWidget {
  const BrewScreen({super.key});

  @override
  State<BrewScreen> createState() => _BrewScreenState();
}

class _BrewScreenState extends State<BrewScreen> {
  Tea? _tea;
  int _round = 1;
  int _remaining = 0;
  bool _running = false;
  Timer? _timer;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final store = AppStoreScope.of(context);
    final tea = store.lastBrewTea;
    _tea = tea;
    _round = store.lastRound.clamp(1, tea.steeps.length);
    _remaining = tea.steeps[_round - 1];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetToRound(int round) {
    final tea = _tea;
    if (tea == null) return;
    _timer?.cancel();
    setState(() {
      _running = false;
      _round = round.clamp(1, tea.steeps.length);
      _remaining = tea.steeps[_round - 1];
    });
  }

  void _toggleTimer() {
    final tea = _tea;
    if (tea == null) return;
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    var left = _remaining <= 0 ? tea.steeps[_round - 1] : _remaining;
    setState(() {
      _running = true;
      _remaining = left;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      left -= 1;
      if (left <= 0) {
        timer.cancel();
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.alert);
        setState(() {
          _running = false;
          _remaining = 0;
        });
        _completeRound();
        return;
      }
      setState(() => _remaining = left);
    });
  }

  void _completeRound() {
    final tea = _tea;
    if (tea == null) return;
    final store = AppStoreScope.of(context);
    final seconds = tea.steeps[_round - 1];
    store.addRecord(tea: tea, round: _round, seconds: seconds);
    showTeaSnack(
      context,
      _round >= tea.steeps.length
          ? '第 $_round 泡已完成 · 这泡茶喝完了'
          : '第 $_round 泡已完成，记录已写入茶记',
    );
  }

  void _nextRound() {
    final tea = _tea;
    if (tea == null) return;
    if (_round >= tea.steeps.length) {
      showTeaSnack(context, '已经是最后一泡了');
      return;
    }
    _resetToRound(_round + 1);
  }

  Future<void> _pickTea() async {
    final picked = await showModalBottomSheet<Tea>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TeaPalette.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _TeaPickerSheet(),
    );
    if (picked == null || !mounted) return;
    final store = AppStoreScope.of(context);
    store.rememberSession(picked, 1);
    _timer?.cancel();
    setState(() {
      _tea = picked;
      _round = 1;
      _remaining = picked.steeps.first;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tea = _tea;
    if (tea == null) {
      return const SizedBox.shrink();
    }
    final total = tea.steeps[_round - 1];
    final elapsed = total - _remaining;
    final progress = total == 0 ? 0.0 : (elapsed / total).clamp(0.0, 1.0);

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const TeaTopBar(subtitle: 'TEA SESSION'),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('茶席计时', style: kEyebrow),
              const SizedBox(height: 6),
              const Text(
                '水已沸，心渐静',
                style: TextStyle(
                  fontFamilyFallback: kSerif,
                  fontSize: 25,
                  height: 1.35,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '接下来，交给这一盏茶。',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.7,
                  color: TeaPalette.inkSoft,
                ),
              ),
              const SizedBox(height: 18),
              _TeaSelector(
                tea: tea,
                onTap: _pickTea,
                onDetail: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TeaDetailScreen(teaId: tea.id),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _RoundTabs(
                rounds: tea.steeps.length,
                current: _round,
                onSelect: _resetToRound,
              ),
              const SizedBox(height: 18),
              _TimerDial(
                tea: tea,
                round: _round,
                total: total,
                remaining: _running ? _remaining : total,
                progress: progress,
                running: _running,
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _toggleTimer,
                      icon: Icon(
                        _running
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: Text(_running ? '暂停' : '开始冲泡'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _resetToRound(_round);
                      },
                      child: const Text('重来'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _nextRound,
                      icon: const Icon(Icons.skip_next_rounded, size: 17),
                      label: const Text('下一泡'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final store = AppStoreScope.of(context);
                        store.addRecord(
                          tea: tea,
                          round: _round,
                          seconds: total,
                        );
                        showTeaSnack(context, '已手动记入茶记');
                      },
                      icon: const Icon(Icons.check_rounded, size: 17),
                      label: const Text('直接记下'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SessionTips(tea: tea),
              const SizedBox(height: 24),
              _SipCard(
                sips: AppStoreScope.of(context).sipCount,
                onSip: () => AppStoreScope.read(context).addSip(),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeaSelector extends StatelessWidget {
  const _TeaSelector({
    required this.tea,
    required this.onTap,
    required this.onDetail,
  });

  final Tea tea;
  final VoidCallback onTap;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Row(
        children: <Widget>[
          TeaThumb(tea: tea, width: 50, height: 50, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '当前茶品',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: TeaPalette.inkMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tea.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamilyFallback: kSerif,
                    fontSize: 16,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: const Text('更换')),
          IconButton(
            onPressed: onDetail,
            icon: const Icon(Icons.info_outline_rounded, size: 19),
            tooltip: '查看茶品',
          ),
        ],
      ),
    );
  }
}

class _RoundTabs extends StatelessWidget {
  const _RoundTabs({
    required this.rounds,
    required this.current,
    required this.onSelect,
  });

  final int rounds;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(rounds.clamp(1, 6), (index) {
        final round = index + 1;
        final active = round == current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == rounds - 1 ? 0 : 8),
            child: Material(
              color: active ? TeaPalette.mossDeep : TeaPalette.paper,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onSelect(round),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? TeaPalette.mossDeep : TeaPalette.line,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '第$round泡',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: active ? TeaPalette.paper : TeaPalette.inkSoft,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TimerDial extends StatelessWidget {
  const _TimerDial({
    required this.tea,
    required this.round,
    required this.total,
    required this.remaining,
    required this.progress,
    required this.running,
  });

  final Tea tea;
  final int round;
  final int total;
  final int remaining;
  final double progress;
  final bool running;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        color: TeaPalette.paper,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TeaPalette.line),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: TeaPalette.creamDeep,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      TeaPalette.moss,
                    ),
                  ),
                ),
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      TeaPalette.line.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.local_cafe_outlined,
                      size: 17,
                      color: TeaPalette.moss,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatClock(remaining),
                      style: TextStyle(
                        fontFamilyFallback: kSerif,
                        fontSize: 46,
                        height: 1.05,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                        color: running ? TeaPalette.mossDeep : TeaPalette.ink,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      running ? '正在计时 · 第$round泡' : '推荐第$round泡 · $total 秒',
                      style: const TextStyle(
                        fontSize: 11.5,
                        letterSpacing: 0.6,
                        color: TeaPalette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${tea.brewTemp} ℃ · ${tea.vessel}',
            style: const TextStyle(
              fontSize: 11.5,
              color: TeaPalette.inkMuted,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTips extends StatelessWidget {
  const _SessionTips({required this.tea});

  final Tea tea;

  @override
  Widget build(BuildContext context) {
    final steps = <String>[
      '温器：用沸水烫过 ${tea.vessel}，倒掉',
      '投茶：干茶入 ${tea.vessel}，水温 ${tea.brewTemp}℃',
      '润茶：注水后 3 秒内倒出',
      '正式冲泡：第 ${tea.steeps.first} 秒出汤',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const TeaSectionTitle(eyebrow: 'RITUAL', title: '四步候汤'),
        const SizedBox(height: 12),
        ...List<Widget>.generate(steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: TeaPalette.creamDeep,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: TeaPalette.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    steps[index],
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.75,
                      color: TeaPalette.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

}

class _SipCard extends StatelessWidget {
  const _SipCard({required this.sips, required this.onSip});

  final int sips;
  final VoidCallback onSip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: TeaPalette.mossDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.water_drop_outlined, size: 20, color: TeaPalette.cream),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '今日饮茶 $sips 口',
                  style: const TextStyle(
                    fontFamilyFallback: kSerif,
                    fontSize: 14.5,
                    letterSpacing: 1,
                    color: TeaPalette.cream,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '每记一口，茶识点 +2',
                  style: TextStyle(
                    fontSize: 11,
                    color: TeaPalette.cream.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onSip();
            },
            style: TextButton.styleFrom(
              foregroundColor: TeaPalette.mossDeep,
              backgroundColor: TeaPalette.cream,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('喝一口'),
          ),
        ],
      ),
    );
  }
}

class _TeaPickerSheet extends StatefulWidget {
  const _TeaPickerSheet();

  @override
  State<_TeaPickerSheet> createState() => _TeaPickerSheetState();
}

class _TeaPickerSheetState extends State<_TeaPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = TeaLibrary.all
        .where(
          (tea) =>
              _query.isEmpty ||
              tea.name.contains(_query) ||
              tea.category.contains(_query) ||
              tea.origin.contains(_query),
        )
        .toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, controller) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
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
                const SizedBox(height: 14),
                const Text(
                  '选择茶品',
                  style: TextStyle(
                    fontFamilyFallback: kSerif,
                    fontSize: 17,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => setState(() => _query = value.trim()),
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '搜索茶名 / 类 / 产地',
                    hintStyle: const TextStyle(
                      fontSize: 12.5,
                      color: TeaPalette.inkMuted,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 19),
                    filled: true,
                    fillColor: TeaPalette.cream,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                      borderSide: const BorderSide(color: TeaPalette.moss),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final tea = results[index];
                return TeaListTile(
                  tea: tea,
                  onTap: () => Navigator.of(context).pop(tea),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
