import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_interceptor/touch_interceptor.dart';

void main() {
  testWidgets(
    'TouchInterceptor receives pointer events (up and then down)',
    (tester) async {
      const testingWidget = TestApplicationWidget();
      // pump
      await tester.pumpWidget(testingWidget);
      // check
      expect(find.text('none'), findsOneWidget);
      // press the widget (down)
      final gesture = await tester.press(find.byKey(const ValueKey('TI')));
      // pump again
      await tester.pumpAndSettle();
      // check
      expect(find.text('down'), findsOneWidget);
      // release from press (up)
      await gesture.up();
      // pump again
      await tester.pumpAndSettle();
      // check
      expect(find.text('up'), findsOneWidget);
    },
  );

  testWidgets(
    'TouchInterceptor receives pointer events (enter and then up)',
    (tester) async {
      const testingWidget = TestApplicationWidget();
      // pump
      await tester.pumpWidget(testingWidget);
      // check
      expect(find.text('none'), findsOneWidget);
      // move the pointer in
      final gesture = await tester.startGesture(Offset.zero);
      const position = Offset(
        TestApplicationWidget.padding,
        TestApplicationWidget.padding,
      );
      await gesture.moveTo(position);
      // pump again
      await tester.pumpAndSettle();
      // check
      expect(find.text('enter'), findsOneWidget);
      // release from press (up)
      await gesture.up();
      // pump again
      await tester.pumpAndSettle();
      // check
      expect(find.text('up'), findsOneWidget);
    },
  );

  testWidgets(
    'TouchInterceptor receives pointer events (enter and then exit)',
    (tester) async {
      const testingWidget = TestApplicationWidget();
      // pump
      await tester.pumpWidget(testingWidget);
      // check
      expect(find.text('none'), findsOneWidget);
      // move the pointer in
      final gesture = await tester.startGesture(Offset.zero);
      const position = Offset(
        TestApplicationWidget.padding,
        TestApplicationWidget.padding,
      );
      await gesture.moveTo(position);
      // pump again
      await tester.pumpAndSettle();
      // check
      expect(find.text('enter'), findsOneWidget);
      // move the pointer out
      await gesture.moveTo(-position);
      // pump again
      await tester.pumpAndSettle();
      // check
      expect(find.text('exit'), findsOneWidget);
    },
  );

  testWidgets(
    'TouchInterceptor receives pointer events (enter and then cancel)',
    (tester) async {
      const testingWidget = TestApplicationWidget();
      // pump
      await tester.pumpWidget(testingWidget);
      // check
      expect(find.text('none'), findsOneWidget);
      // move the pointer in
      final gesture = await tester.startGesture(Offset.zero);
      const position = Offset(
        TestApplicationWidget.padding,
        TestApplicationWidget.padding,
      );
      await gesture.moveTo(position);
      // pump again
      await tester.pumpAndSettle();
      // check
      expect(find.text('enter'), findsOneWidget);
      // cancel the gesture
      await gesture.cancel();
      // pump again
      await tester.pumpAndSettle();
      // check
      expect(find.text('exit'), findsOneWidget);
    },
  );
}

class TestApplicationWidget extends StatefulWidget {
  const TestApplicationWidget({Key? key}) : super(key: key);

  static const padding = 16.0;

  @override
  State<TestApplicationWidget> createState() => _TestApplicationWidgetState();
}

class _TestApplicationWidgetState extends State<TestApplicationWidget> {
  String _consumerEvent = 'none';

  @override
  Widget build(BuildContext context) {
    return TouchInterceptor(
      key: const ValueKey('TI'),
      child: Padding(
        padding: const EdgeInsets.all(TestApplicationWidget.padding),
        child: TouchConsumer(
          key: const ValueKey('TC'),
          onTouchDown: () => setState(() => _consumerEvent = 'down'),
          onTouchUp: () => setState(() => _consumerEvent = 'up'),
          onTouchEnter: () => setState(() => _consumerEvent = 'enter'),
          onTouchExit: () => setState(() => _consumerEvent = 'exit'),
          child: Text(
            '$_consumerEvent',
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
