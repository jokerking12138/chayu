# 茶愉 Chayu

参照 4 张「茶愉」界面稿实现的跨平台茶事 App，一套 Flutter 代码同时构建 **Android**、**iOS** 与**网页版（PWA）**。

## 功能

| Tab | 内容 |
| --- | --- |
| 首页 | 今日茶事（问候语随时间段变化）、主图 + 竖排诗句、霜降荐茶、六大茶类入口、版权落款 |
| 图鉴 | 内置 **332 款**茶品（298 款取自《中国茶图鉴》），搜索（茶名/产地/风味/香气）、九类目筛选、产地与来源筛选、三种排序、双列图片网格 |
| 茶席 | 茶席计时：选茶、第 1–n 泡、双环倒计时、开始/暂停/重来/下一泡、直接记下、四步候汤提示、饮茶口数 |
| 详情 | 书籍原图、产地全称、水温/器皿/首泡三格参数、冲泡节奏、感官档案（外形·汤色·滋味·叶底）、泡法与品饮、茶人小记 |
| 指南 | 六大茶类建议水温图、六步成席、常见误会 |
| 茶记 | 累计泡茶、品茶时光、偏爱之茶、茶识等级（茶童/茶客/茶人/茶翁/茶圣）、冲泡流水 |

数据用 `shared_preferences` 本地持久化，无网络依赖。

## 技术

- Flutter 3.47 / Dart 3.13，Material 3
- 字体：系统衬线中文字体栈（Songti SC / Noto Serif CJK），正文用无衬线
- 配色：米纸 `#F6F1E7`、墨 `#26251F`、岩苔绿 `#41594A`、焙火金 `#BE9C5F`
- 图片：6 张茶事摄影主图 + 298 张《中国茶图鉴》茶叶图谱，全部转为 WebP 存放于 `assets/library/`（主图 0.25 MB、图谱 5.1 MB）
- 图标：`android/app/src/main/res/mipmap-*/ic_launcher*.png`（含自适应图标 `mipmap-anydpi-v26/`）与 `ios/Runner/Assets.xcassets/AppIcon.appiconset/`，源图为《中国茶图鉴》西湖龙井干茶实拍

## 运行

```bash
flutter pub get
flutter run                 # 连接设备或模拟器
flutter build apk --release --split-per-abi  # Android，按 ABI 分包（20.6 / 23.1 / 24.5 MB）
flutter build apk --release                   # Android，通用包（54.9 MB）
flutter build ios --release # iOS（需 macOS + Xcode）
```

## 目录

```
lib/
  app.dart              应用外壳、底部导航、Tab 切换
  theme/                TeaPalette 与 M3 主题
  models/tea.dart       Tea 数据模型
  data/tea_library.dart 内置茶库与解析（书籍条目 + 手写补充合并）
  data/tea_book_data.dart 《中国茶图鉴》298 款的序列化数据集
  widgets/tea_book_sections.dart 感官档案与泡法品饮区块
  state/app_store.dart  记录/收藏/口数/等级，shared_preferences 持久化
  widgets/              印章、顶栏、缩略图、药丸标签、空状态、感官档案与泡法品饮区块
  screens/              首页 / 图鉴 / 详情 / 类目 / 茶席 / 指南 / 茶记
  utils/format.dart     日期与时长格式化
```

## 网页版（PWA）与 GitHub Pages

同一套代码可构建为可安装到手机主屏的 PWA，无需 Mac、Apple 账号或签名。

**在线地址**：`https://jokerking12138.github.io/chayu/`

- 首次打开需联网，之后由 `web/sw.js` 提供离线缓存（应用外壳 + 引擎 + 已访问资源）。
- iPhone：Safari 打开 → 分享 → 「添加到主屏幕」；Android：Chrome 菜单 → 「安装应用」。
- 安装后全屏运行、无地址栏，记录仍存在本机。

构建命令：

```bash
flutter build web --release --base-href /chayu/ --no-web-resources-cdn
```

`--no-web-resources-cdn` 让 CanvasKit 走同源 `canvaskit/` 目录而非 Google CDN，墙内可用。
本地预览：把 `build/web` 放到任意静态服务器的 `/chayu/` 路径下访问。

部署：推送到 `main` 分支后，`.github/workflows/pages.yml` 自动构建并发布到 GitHub Pages。
首次使用需在仓库 Settings → Pages 把 Source 设为 **GitHub Actions**。

`web/flutter_bootstrap.js` 是自定义启动脚本，作用是**不注册** Flutter 自带的 `flutter_service_worker.js`
（该文件已弃用且会自我注销，会顶掉 `web/sw.js`），离线缓存统一由 `web/sw.js` 接管。

## 数据来源

- 332 款茶品中 298 款整理自《中国茶图鉴》（李韬 著），含图谱与感官描述，摘录与图片版权归原作者与出版方所有，仅供学习参考。
- 其余 34 款为手写补充条目，参数（水温、器皿、每泡时间）为常见参考值，非权威标准。
- 茶水比一栏已全站移除：书中该字段为「茶叶占主泡器容积的分数」（如 1/5 器），并非通行的茶水克重比，且缺乏可核对的权威数据源，故不再展示。
- 另有资料参考：茶百科 · 灵芽AI · Teaspedia · 茶叶百科LZ。