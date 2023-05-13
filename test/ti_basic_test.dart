import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touch_interceptor/touch_interceptor.dart';

void main() {
  testWidgets(
    'TouchInterceptor is added to the tree',
    (tester) async {
      const touchInterceptor = TouchInterceptor();
      const testingWidget = TestingWidget(child: touchInterceptor);
      // pump
      await tester.pumpWidget(testingWidget);
      // check
      expect(find.byWidget(touchInterceptor), findsOneWidget);
    },
  );

  testWidgets(
    'A TouchConsumer is placed underneath a TouchInterceptor.',
    (tester) async {
      const touchConsumer = TouchConsumer();
      const touchInterceptor = TouchInterceptor(child: touchConsumer);
      const testingWidget = TestingWidget(child: touchInterceptor);
      // pump
      await tester.pumpWidget(testingWidget);
      // check
      final touchConsumerFinder = find.byWidget(touchConsumer);
      expect(
        touchConsumerFinder,
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byWidget(touchInterceptor),
          matching: touchConsumerFinder,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'A TouchConsumer is not placed underneath a TouchInterceptor.',
    (tester) async {
      const touchConsumer = TouchConsumer();
      // try to insert
      await tester.pumpWidget(const TestingWidget(child: touchConsumer));
      // check
      expect(
        tester.takeException(),
        isA<TouchInterceptorNotFoundError>()
            .having((err) => err.toString(), 'message', isNotNull),
      );
    },
  );
}

class TestingWidget extends StatelessWidget {
  const TestingWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
