import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staggered_animation_demo/main.dart';

void main() {
  testWidgets('首页渲染交错动画示例并可播放一次', (WidgetTester tester) async {
    await tester.pumpWidget(const StaggeredShowcaseApp());

    expect(find.text('一个控制器，多个动画'), findsOneWidget);
    expect(find.text('点击舞台播放交错动画'), findsOneWidget);
    expect(find.byKey(const Key('stagger-demo-box')), findsOneWidget);

    final Finder boxFinder = find.byKey(const Key('stagger-demo-box'));
    final Finder stageFinder = find.byKey(const Key('stagger-demo-stage'));

    expect(tester.getSize(boxFinder).width, 50);
    expect(tester.getSize(boxFinder).height, 50);

    await tester.tap(stageFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('播放中...'), findsOneWidget);
    expect(tester.getSize(boxFinder).width, greaterThan(50));

    await tester.pumpAndSettle();

    final Size resetSize = tester.getSize(boxFinder);
    expect(resetSize.width, inInclusiveRange(49.0, 51.0));
    expect(resetSize.height, inInclusiveRange(49.0, 51.0));
    expect(find.text('播放一次'), findsOneWidget);
  });
}
