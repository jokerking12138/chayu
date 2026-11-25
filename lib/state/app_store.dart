import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/tea_library.dart';
import '../models/tea.dart';

class BrewRecord {
  const BrewRecord({
    required this.teaId,
    required this.teaName,
    required this.round,
    required this.seconds,
    required this.at,
    this.note = '',
  });

  final String teaId;
  final String teaName;
  final int round;
  final int seconds;
  final DateTime at;
  final String note;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'teaId': teaId,
        'teaName': teaName,
        'round': round,
        'seconds': seconds,
        'at': at.toIso8601String(),
        'note': note,
      };

  factory BrewRecord.fromJson(Map<String, dynamic> json) => BrewRecord(
        teaId: json['teaId'] as String? ?? '',
        teaName: json['teaName'] as String? ?? '未知茶品',
        round: json['round'] as int? ?? 1,
        seconds: json['seconds'] as int? ?? 0,
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
        note: json['note'] as String? ?? '',
      );
}

class TeaLevel {
  const TeaLevel(this.title, this.min, this.blurb);

  final String title;
  final int min;
  final String blurb;
}

const List<TeaLevel> kLevels = <TeaLevel>[
  TeaLevel('茶童', 0, '刚识得茶的名字与水温'),
  TeaLevel('茶客', 50, '能分辨六大茶类的基本脾气'),
  TeaLevel('茶人', 130, '开始懂得候汤与出汤的分寸'),
  TeaLevel('茶翁', 240, '一泡茶里能喝出山场与季节'),
  TeaLevel('茶圣', 400, '心中有水，手中有茶'),
];

class AppStore extends ChangeNotifier {
  static const String _keyRecords = 'chayu.records.v1';
  static const String _keyFavorite = 'chayu.favorite.v1';
  static const String _keySips = 'chayu.sips.v1';
  static const String _keyLastTea = 'chayu.lastTea.v1';
  static const String _keyLastRound = 'chayu.lastRound.v1';

  final List<BrewRecord> _records = <BrewRecord>[];
  int _sips = 0;
  String? _favoriteTeaId;
  String? _lastBrewTeaId;
  int _lastRound = 1;
  bool _ready = false;

  bool get ready => _ready;

  List<BrewRecord> get records => List<BrewRecord>.unmodifiable(_records.reversed);

  int get sipCount => _sips;

  String? get favoriteTeaId => _favoriteTeaId;

  Tea? get favoriteTea => TeaLibrary.find(_favoriteTeaId);

  String? get lastBrewTeaId => _lastBrewTeaId;

  Tea get lastBrewTea => TeaLibrary.find(_lastBrewTeaId) ?? TeaLibrary.featured;

  int get lastRound => _lastRound;

  int get brewCount => _records.length;

  int get totalSeconds => _records.fold(0, (sum, r) => sum + r.seconds);

  int get totalMinutes => (totalSeconds / 60).round();

  int get points => _records.length * 6 + _sips * 2;

  int get distinctTeaCount => _records.map((r) => r.teaId).toSet().length;

  TeaLevel get level {
    TeaLevel current = kLevels.first;
    for (final lv in kLevels) {
      if (points >= lv.min) current = lv;
    }
    return current;
  }

  TeaLevel? get nextLevel {
    final index = kLevels.indexOf(level);
    if (index < 0 || index + 1 >= kLevels.length) return null;
    return kLevels[index + 1];
  }

  int get pointsIntoLevel => points - level.min;

  int get levelSpan {
    final next = nextLevel;
    if (next == null) return 1;
    final span = next.min - level.min;
    return span <= 0 ? 1 : span;
  }

  double get levelProgress {
    if (nextLevel == null) return 1;
    return (pointsIntoLevel / levelSpan).clamp(0.0, 1.0);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyRecords);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(BrewRecord.fromJson);
        _records
          ..clear()
          ..addAll(list);
      } catch (_) {
        _records.clear();
      }
    }
    _sips = prefs.getInt(_keySips) ?? 0;
    _favoriteTeaId = prefs.getString(_keyFavorite);
    _lastBrewTeaId = prefs.getString(_keyLastTea);
    _lastRound = prefs.getInt(_keyLastRound) ?? 1;
    _ready = true;
    notifyListeners();
  }

  Future<void> addRecord({
    required Tea tea,
    required int round,
    required int seconds,
    String note = '',
  }) async {
    _records.add(
      BrewRecord(
        teaId: tea.id,
        teaName: tea.name,
        round: round,
        seconds: seconds,
        at: DateTime.now(),
        note: note,
      ),
    );
    _favoriteTeaId ??= tea.id;
    _lastBrewTeaId = tea.id;
    _lastRound = round;
    notifyListeners();
    await _persist();
  }

  Future<void> addSip() async {
    _sips += 1;
    notifyListeners();
    await _persist();
  }

  Future<void> toggleFavorite(Tea tea) async {
    _favoriteTeaId = _favoriteTeaId == tea.id ? null : tea.id;
    notifyListeners();
    await _persist();
  }

  Future<void> rememberSession(Tea tea, int round) async {
    _lastBrewTeaId = tea.id;
    _lastRound = round;
    await _persist();
  }

  Future<void> clearAll() async {
    _records.clear();
    _sips = 0;
    _favoriteTeaId = null;
    _lastBrewTeaId = null;
    _lastRound = 1;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyRecords,
      jsonEncode(_records.map((r) => r.toJson()).toList()),
    );
    await prefs.setInt(_keySips, _sips);
    if (_favoriteTeaId == null) {
      await prefs.remove(_keyFavorite);
    } else {
      await prefs.setString(_keyFavorite, _favoriteTeaId!);
    }
    if (_lastBrewTeaId == null) {
      await prefs.remove(_keyLastTea);
    } else {
      await prefs.setString(_keyLastTea, _lastBrewTeaId!);
    }
    await prefs.setInt(_keyLastRound, _lastRound);
  }

  List<BrewRecord> recordsOf(String teaId) =>
      _records.where((r) => r.teaId == teaId).toList();

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return '夜已深，一盏淡茶就好';
    if (hour < 11) return '晨光正好，先温一杯水';
    if (hour < 14) return '午后宜静，茶汤宜浅';
    if (hour < 18) return '斜阳落在茶席上';
    if (hour < 22) return '饭后一盏，理气解腻';
    return '夜里煮水，听壶声';
  }
}
