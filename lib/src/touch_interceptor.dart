import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that intercepts pointer events and send them to every
/// [TouchConsumer] widget placed underneath.
///
/// ## Layout behavior
///
/// _See [BoxConstraints] for an introduction to box layout models._
///
/// If it has a child, this widget defers to the child for sizing behavior. If
/// it does not have a child, it grows to fit the parent instead.
class TouchInterceptor extends StatefulWidget {
  /// The [child] contained by the interceptor.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// Creates a [TouchInterceptor] widget.
  const TouchInterceptor({Key key, this.child}) : super(key: key);

  @override
  _TouchInterceptorState createState() => _TouchInterceptorState();
}

class _TouchInterceptorState extends State<TouchInterceptor> {
  final _keySet = Set<TouchKey>();

  @override
  Widget build(BuildContext context) {
    return _KeyRegister(
      keySet: _keySet,
      child: Listener(
        onPointerDown: (details) =>
            _sendAction(_TouchAction.down, details.position),
        onPointerMove: (details) =>
            _sendAction(_TouchAction.move, details.position),
        onPointerUp: (details) =>
            _sendAction(_TouchAction.up, details.position),
        child: AbsorbPointer(child: widget.child),
      ),
    );
  }

  void _sendAction(_TouchAction ta, Offset o) {
    _keySet.forEach((TouchKey k) => k.currentState.dispatchTouch(o, ta));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> keys = _keySet.map((k) => k.toString()).toList();
    properties.add(IterableProperty<String>('keys', keys, ifEmpty: '<none>'));
  }
}

enum _TouchAction { down, move, up }

class _KeyRegister extends InheritedWidget {
  const _KeyRegister({
    Key key,
    @required Set<TouchKey> keySet,
    Widget child,
  })  : assert(keySet != null),
        _keySet = keySet,
        super(key: key, child: child);

  final Set<TouchKey> _keySet;

  TouchKey registerNewKey() {
    return _generateKey();
  }

  bool isKeyRegistered(TouchKey key) {
    return _keySet.contains(key);
  }

  void unregisterKey(TouchKey key) {
    _keySet.remove(key);
  }

  List<TouchKey> get keys => _keySet.toList(growable: false);

  TouchKey _generateKey() {
    const tries = 3;
    for (var t = 0; t < tries; t++) {
      final newKey = TouchKey();
      if (_keySet.add(newKey)) {
        return newKey;
      }
    }
    throw "Error in generating a new TouchKey";
  }

  @override
  bool updateShouldNotify(_KeyRegister oldWidget) {
    return this._keySet != oldWidget._keySet;
  }

  static _KeyRegister of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(_KeyRegister);
}

/// A widget that listen for events from the nearest [TouchInterceptor]
/// ancestor and calls callbacks in response to them.
///
/// ...
class TouchReceiver extends StatefulWidget {
  /// Called when a pointer comes into contact with the screen at this widget's
  /// location.
  final VoidCallback onTouchDown;

  /// Called when a pointer that has previously come into contact with the screen
  /// changes position and reaches this widget's location.
  final VoidCallback onTouchEnter;

  /// Called when a pointer that has previously come into contact with the screen
  /// changes position and leaves this widget's location.
  final VoidCallback onTouchExit;

  /// Called when a pointer that has previously come into contact with the screen
  /// stops being in contact with the screen at this widget's location.
  final VoidCallback onTouchUp;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  const TouchReceiver({
    this.onTouchDown,
    this.onTouchEnter,
    this.onTouchExit,
    this.onTouchUp,
    this.child,
  });

  @override
  _TouchReceiverState createState() => _TouchReceiverState();
}

class _TouchReceiverState extends State<TouchReceiver> {
  TouchKey _key;

  @override
  void didChangeDependencies() {
    if (!_checkKey()) {
      _registerKey();
    }
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    _unregisterKey();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkKey()) {
      throw "Key unregistered!";
    }
    final cbs = _TouchCallbacks(widget.onTouchDown, widget.onTouchEnter,
        widget.onTouchExit, widget.onTouchUp);
    return _TouchReceiverCore(
      key: _key,
      child: widget.child,
      callbacks: cbs,
    );
  }

  bool _checkKey() {
    return _key != null && _getKeyRegister().isKeyRegistered(_key);
  }

  void _registerKey() {
    _key = _getKeyRegister().registerNewKey();
  }

  void _unregisterKey() {
    _getKeyRegister().unregisterKey(_key);
    _key = null;
  }

  _KeyRegister _getKeyRegister() {
    final kr = _KeyRegister.of(context);
    if (kr == null) {
      throw TouchInterceptorNotFoundError._();
    }
    return kr;
  }
}

class _TouchReceiverCore extends StatefulWidget {
  final _TouchCallbacks callbacks;
  final Widget child;

  const _TouchReceiverCore({
    TouchKey key,
    this.callbacks,
    this.child,
  }) : super(key: key);

  @override
  _TouchReceiverCoreState createState() => _TouchReceiverCoreState();
}

class _TouchReceiverCoreState extends State<_TouchReceiverCore> {
  bool _hasTouchEntered = false;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void dispatchTouch(Offset touchPosition, _TouchAction action) {
    final hit = _hitTest(touchPosition);
    if (hit) {
      switch (action) {
        case _TouchAction.down:
          if (!_hasTouchEntered) {
            setState(() {
              _hasTouchEntered = true;
            });
            widget.callbacks.down();
          }
          break;
        case _TouchAction.move:
          if (!_hasTouchEntered) {
            setState(() {
              _hasTouchEntered = true;
            });
            widget.callbacks.enter();
          }
          break;
        case _TouchAction.up:
          if (_hasTouchEntered) {
            setState(() {
              _hasTouchEntered = false;
            });
            widget.callbacks.up();
          }
          break;
      }
    } else {
      if (_hasTouchEntered) {
        setState(() {
          _hasTouchEntered = false;
        });
        widget.callbacks.exit();
      }
    }
  }

  bool _hitTest(Offset coordinates) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(coordinates);
    final result = BoxHitTestResult();
    return renderBox.hitTest(result, position: localPosition);
  }
}

class TouchKey extends GlobalKey<_TouchReceiverCoreState> {
  TouchKey() : super.constructor();

  @override
  String toString() {
    return '[TK<$hashCode>]';
  }
}

@immutable
class _TouchCallbacks {
  final VoidCallback _onTouchDown;
  final VoidCallback _onTouchEnter;
  final VoidCallback _onTouchExit;
  final VoidCallback _onTouchUp;

  _TouchCallbacks(this._onTouchDown, this._onTouchEnter, this._onTouchExit,
      this._onTouchUp);

  void down() => _safeCall(_onTouchDown);

  void enter() => _safeCall(_onTouchEnter);

  void exit() => _safeCall(_onTouchExit);

  void up() => _safeCall(_onTouchUp);

  static void _safeCall(VoidCallback cb) {
    void voidValue;
    return (cb != null) ? cb() : voidValue;
  }
}

class TouchInterceptorNotFoundError extends Error {
  TouchInterceptorNotFoundError._();

  @override
  String toString() {
    return "Error: Could not find a TouchInterceptor widget above this TouchConsumer widget.";
  }
}
