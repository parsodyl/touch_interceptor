import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_interceptor/touch_interceptor.dart';

void main() {
  testWidgets('adds one to input values', (tester) async {
    const child = Placeholder();
    await tester.pumpWidget(const TouchInterceptor(
      key: Key('__ti__'),
      child: TouchReceiver(child: child),
    ));
    final rl = tester.allStates;
    rl.forEach(print);
    //final keyFinder = find.byKey(Key('__ti__'));
    //expect(keyFinder, findsOneWidget);
    //await tester.tap(find.byKey(Key('__ti__')));
    //await tester.pump();
  });

  testWidgets('TouchInterceptor is added to the tree', (tester) async {
    const touchInterceptor = TouchInterceptor();
    await tester.pumpWidget(Container(child: touchInterceptor));
    // check
    expect(find.byWidget(touchInterceptor), findsOneWidget);
  });

  testWidgets('TouchInterceptor is removed from the tree', (tester) async {
    const touchInterceptor = TouchInterceptor();
    const testingWidget = TestingWidget(child: touchInterceptor);
    await tester.pumpWidget(testingWidget);
    expect(find.byWidget(touchInterceptor), findsOneWidget);
    final ts =
        tester.firstState(find.byWidget(testingWidget)) as _TestingWidgetState;
    ts.childInserted = false;
    // pump again
    await tester.pump();
    // check 2
    expect(find.byWidget(touchInterceptor), findsNothing);
  });

  testWidgets('TouchInterceptor receives pointer events', (tester) async {
    const touchInterceptor = TouchInterceptor();
    await tester.pumpWidget(Container(child: touchInterceptor));
    await tester.tap(find.byWidget(touchInterceptor));
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
