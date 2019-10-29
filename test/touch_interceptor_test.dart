import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_interceptor/touch_interceptor.dart';

void main() {
  testWidgets('adds one to input values', (tester) async {
    final child = Placeholder();
    await tester.pumpWidget(TouchInterceptor(
      key: const Key('__ti__'),
      child: TouchReceiver(child: child),
    ));
    final rl = tester.allWidgets;
    rl.forEach((e) => print(e));
    //await tester.tap(find.byKey(Key('__ti__')));
    //await tester.pump();
    /*final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
    expect(() => calculator.addOne(null), throwsNoSuchMethodError);*/
  });
}
