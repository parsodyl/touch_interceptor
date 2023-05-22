import 'package:flutter/cupertino.dart';
import 'package:touch_interceptor/touch_interceptor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: DemoView(),
    );
  }
}

class DemoView extends StatefulWidget {
  const DemoView({Key? key}) : super(key: key);

  @override
  _DemoViewState createState() => _DemoViewState();
}

class _DemoViewState extends State<DemoView> {
  static const _tiColor = CupertinoColors.white;
  Color _tcColor = CupertinoColors.white;

  var _lastEvent = 'none';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TouchInterceptor',
                      style: TextStyle(
                        color: _tiColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TouchInterceptor(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _tiColor,
                            width: 4.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(90.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TouchConsumer',
                                style: TextStyle(
                                  color: _tcColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TouchConsumer(
                                onTouchDown: () => setState(() {
                                  _tcColor = CupertinoColors.activeBlue;
                                  _lastEvent = 'down';
                                }),
                                onTouchUp: () => setState(() {
                                  _tcColor = CupertinoColors.activeOrange;
                                  _lastEvent = 'up';
                                }),
                                onTouchEnter: () => setState(() {
                                  _tcColor = CupertinoColors.activeGreen;
                                  _lastEvent = 'enter';
                                }),
                                onTouchExit: () => setState(() {
                                  _tcColor = CupertinoColors.destructiveRed;
                                  _lastEvent = 'exit';
                                }),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: _tcColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const SizedBox.square(dimension: 140),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Tap or click inside the box to change color!\n',
                children: [
                  const TextSpan(text: 'Last event: '),
                  TextSpan(
                    text: _lastEvent,
                    style: TextStyle(color: _tcColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
