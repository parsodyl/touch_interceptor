import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_interceptor/touch_interceptor.dart';

void main() {
  testWidgets('adds one to input values', (tester) async {
    await tester.pumpWidget(TouchInterceptor(
      key: const Key('__ti__'),
      child: Column(
        children: const [
          TouchConsumer(child: Placeholder(fallbackHeight: 5)),
          TouchConsumer(child: Placeholder(fallbackHeight: 5)),
          TouchConsumer(child: Placeholder(fallbackHeight: 5)),
          TouchConsumer(child: Placeholder(fallbackHeight: 5)),
          TouchConsumer(child: Placeholder(fallbackHeight: 5)),
        ],
      ),
    ));
    final fs = tester.firstState(find.byType(TouchInterceptor));
    print(fs);
    final rl = tester.stateList(find.byType(TouchConsumer));
    rl.forEach(print);
    //final keyFinder = find.byKey(Key('__ti__'));
    //expect(keyFinder, findsOneWidget);
    //await tester.tap(find.byKey(Key('__ti__')));
    //await tester.pump();
  });

  testWidgets('TouchInterceptor is added to the tree', (tester) async {
    const touchInterceptor = TouchInterceptor();
    const testingWidget = TestingWidget(child: touchInterceptor);
    // pump
    await tester.pumpWidget(testingWidget);
    // check
    expect(find.byWidget(touchInterceptor), findsOneWidget);
  });

  testWidgets('TouchInterceptor is removed from the tree', (tester) async {
    const touchInterceptor = TouchInterceptor();
    const testingWidget = TestingWidget(child: touchInterceptor);
    // pump
    await tester.pumpWidget(testingWidget);
    // check
    expect(find.byWidget(touchInterceptor), findsOneWidget);
    // change state
    final ts =
        tester.firstState(find.byWidget(testingWidget)) as _TestingWidgetState;
    ts.childInserted = false;
    // pump again
    await tester.pump();
    // check again
    expect(find.byWidget(touchInterceptor), findsNothing);
  });

  testWidgets('A TouchConsumer is added underneath a TouchInterceptor.',
      (tester) async {
    const touchConsumer = TouchConsumer();
    const touchInterceptor = TouchInterceptor(child: touchConsumer);
    const testingWidget = TestingWidget(child: touchInterceptor);
    // pump
    await tester.pumpWidget(testingWidget);
    // check
    expect(find.byWidget(touchConsumer), findsOneWidget);
  });

  testWidgets('TouchInterceptor receives pointer events', (tester) async {
    const touchInterceptor = TouchInterceptor();
    const testingWidget = TestingWidget(child: touchInterceptor);
    // pump
    await tester.pumpWidget(testingWidget);
    // tap the widget
    await tester.tap(find.byWidget(touchInterceptor));
    // pump again
    await tester.pumpWidget(testingWidget);
    // check
    expect(find.byWidget(touchInterceptor), findsOneWidget);
  });
}

class TestingWidget extends StatefulWidget {
  const TestingWidget({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _TestingWidgetState createState() => _TestingWidgetState();
}

class _TestingWidgetState extends State<TestingWidget> {
  bool _childInserted = true;

  set childInserted(bool value) {
    setState(() {
      _childInserted = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _childInserted ? widget.child : null);
  }
}
