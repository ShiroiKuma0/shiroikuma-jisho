import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiroikumanojisho/src/utils/components/jidoujisho_bottom_sheet.dart';
import 'package:shiroikumanojisho/src/utils/components/pills.dart';

void main() {
  Future<void> open(WidgetTester tester, Size screen,
      List<JidoujishoBottomSheetOption> options) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: false),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              builder: (_) => JidoujishoBottomSheet(options: options),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  List<JidoujishoBottomSheetOption> options(void Function(String) ran,
          {int count = 4}) =>
      [
        JidoujishoBottomSheetOption(
          label: 'Share Current Subtitle',
          icon: Icons.share,
          opens: true,
          action: () => ran('share'),
        ),
        JidoujishoBottomSheetOption(
          label: 'Stretch to Fill Screen',
          icon: Icons.fit_screen,
          toggle: true,
          active: true,
          action: () => ran('stretch'),
        ),
        JidoujishoBottomSheetOption(
          label: 'Portrait',
          icon: Icons.stay_current_portrait,
          active: true,
          action: () => ran('portrait'),
        ),
        for (int i = 3; i < count; i++)
          JidoujishoBottomSheetOption(
            label: 'Option $i',
            icon: Icons.title,
            action: () => ran('option $i'),
          ),
      ];

  testWidgets('hugs its rows on a wide screen and sits at the bottom',
      (tester) async {
    await open(tester, const Size(840, 915), options((_) {}));

    final Rect row = tester.getRect(find
        .ancestor(
            of: find.text('Share Current Subtitle'),
            matching: find.byType(InkWell))
        .first);
    expect(row.width, lessThan(420));
    expect(row.width, greaterThanOrEqualTo(260));
    // Centred, not stretched.
    expect((row.center.dx - 420).abs(), lessThan(1));

    // Every pill is as wide as the sheet's widest row.
    final Rect other = tester.getRect(find
        .ancestor(of: find.text('Option 3'), matching: find.byType(InkWell))
        .first);
    expect(other.width, row.width);
    expect(other.bottom, lessThanOrEqualTo(915));

    // › on the row that opens something, a switch on the toggle, a tick
    // on the chosen row.
    expect(find.text('›'), findsOneWidget);
    expect(find.byType(PillSwitch), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps long labels on a narrow screen instead of overflowing',
      (tester) async {
    await open(tester, const Size(300, 600), [
      JidoujishoBottomSheetOption(
        label: 'Select Secondary Subtitle Track with a very long name indeed',
        icon: Icons.subtitles,
        opens: true,
        action: () {},
      ),
    ]);
    expect(tester.takeException(), isNull);
    final Rect row = tester.getRect(find.byType(InkWell).last);
    expect(row.right, lessThanOrEqualTo(300));
  });

  testWidgets('scrolls when there are more rows than the screen holds',
      (tester) async {
    final ran = <String>[];
    await open(tester, const Size(400, 500), options(ran.add, count: 30));
    expect(tester.takeException(), isNull);
    // Opened scrolled to the end; the last row is reachable and runs.
    await tester.tap(find.text('Option 29'));
    await tester.pumpAndSettle();
    expect(ran, ['option 29']);
    expect(find.byType(JidoujishoBottomSheet), findsNothing);
  });

  testWidgets('a tap beside the panel closes the sheet', (tester) async {
    await open(tester, const Size(840, 915), options((_) {}));
    await tester.tapAt(const Offset(20, 880));
    await tester.pumpAndSettle();
    expect(find.byType(JidoujishoBottomSheet), findsNothing);
  });
}
