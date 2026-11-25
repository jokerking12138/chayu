import 'package:flutter_test/flutter_test.dart';

import 'package:chayu/app.dart';
import 'package:chayu/data/tea_library.dart';

void main() {
  testWidgets('首页渲染出茶愉与今日茶事', (WidgetTester tester) async {
    await tester.pumpWidget(const TeaApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('茶愉'), findsWidgets);
    expect(find.text('今日茶事'), findsWidgets);
  });

  test('内置茶库可解析且分类齐全', () {
    expect(TeaLibrary.all.length, greaterThan(300));
    expect(TeaLibrary.bookCount, greaterThan(290));
    expect(TeaLibrary.categories.contains('绿茶'), isTrue);
    expect(TeaLibrary.categories.contains('普洱茶'), isTrue);
    expect(TeaLibrary.categories.contains('非茶之茶'), isTrue);
    expect(TeaLibrary.featured.name.isNotEmpty, isTrue);
  });

  test('书目条目带感官档案与图片', () {
    final book = TeaLibrary.all.where((t) => t.id.startsWith('bk')).toList();
    expect(book.length, greaterThan(290));
    expect(book.where((t) => t.image != null).length, greaterThan(290));
    expect(book.where((t) => t.hasSensory).length, greaterThan(290));
    expect(book.where((t) => t.hasBookNotes).length, greaterThan(290));
  });
}
