import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:touch_interceptor/touch_interceptor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: DemoView(),
    );
  }
}

class DemoView extends StatefulWidget {
  @override
  _DemoViewState createState() => _DemoViewState();
}

class _DemoViewState extends State<DemoView> {
  Color _shapeColor = CupertinoColors.destructiveRed;

  var _lastEvent = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Center(
                child: TouchInterceptor(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _shapeColor,
                        width: 4.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: TouchConsumer(
                        onTouchDown: () {
                          setState(() {
                            _shapeColor = CupertinoColors.activeGreen;
                            _lastEvent = 'down!';
                          });
                        },
                        onTouchUp: () {
                          setState(() {
                            _shapeColor = CupertinoColors.white;
                            _lastEvent = 'up!';
                          });
                        },
                        onTouchEnter: () {
                          setState(() {
                            _shapeColor = CupertinoColors.activeGreen;
                            _lastEvent = 'hover!';
                          });
                        },
                        onTouchExit: () {
                          setState(() {
                            _shapeColor = CupertinoColors.destructiveRed;
                            _lastEvent = 'away!';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _shapeColor,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 80, height: 80),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 45),
            Text('Touch: $_lastEvent'),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
