class Tea {
  const Tea({
    required this.id,
    required this.name,
    required this.category,
    required this.origin,
    required this.flavor,
    required this.aroma,
    required this.brewTemp,
    required this.ratio,
    required this.vessel,
    required this.steeps,
    required this.summary,
    required this.story,
    required this.source,
    this.image,
    this.appearance = '',
    this.liquor = '',
    this.taste = '',
    this.leaf = '',
    this.brewNote = '',
    this.tasteNote = '',
    this.group = '',
    this.originDetail = '',
  });

  final String id;
  final String name;
  final String category;
  final String origin;
  final String flavor;
  final String aroma;
  final int brewTemp;
  final String ratio;
  final String vessel;
  final List<int> steeps;
  final String summary;
  final String story;
  final String source;
  final String? image;

  /// 以下字段仅《中国茶图鉴》条目有值，手写条目留空。
  final String appearance; // 外形
  final String liquor; // 汤色
  final String taste; // 滋味（感官档案用）
  final String leaf; // 叶底
  final String brewNote; // 书里的泡法原文
  final String tasteNote; // 书里的品饮原文
  final String group; // 书中的分组小标题，如「闽南乌龙」
  final String originDetail; // 完整产地描述

  /// 是否有书的感官档案可展示。
  bool get hasSensory =>
      appearance.isNotEmpty ||
      liquor.isNotEmpty ||
      taste.isNotEmpty ||
      leaf.isNotEmpty;

  /// 是否有书的冲泡原文可展示。
  bool get hasBookNotes => brewNote.isNotEmpty || tasteNote.isNotEmpty;

  String get sealChar => name.isEmpty ? '茶' : name.substring(0, 1);

  String get firstSteep => steeps.isEmpty ? '' : formatSeconds(steeps.first);

  int get totalSteepSeconds => steeps.fold<int>(0, (sum, e) => sum + e);
}

String formatSeconds(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
