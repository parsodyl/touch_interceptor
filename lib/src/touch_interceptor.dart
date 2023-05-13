import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that intercepts pointer events and sends them to every
/// [TouchConsumer] widget placed underneath.
///
/// ## Layout behavior
///
/// _See [BoxConstraints] for an introduction to box layout models._
///
/// If it has a child, this widget defers to the child for sizing behavior. If
/// it does not have a child, it grows to fit the parent instead.
class TouchInterceptor extends StatefulWidget {
  /// Creates a [TouchInterceptor] widget.
  const TouchInterceptor({Key? key, this.child}) : super(key: key);

  /// The [child] contained by the interceptor.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  @override
  _TouchInterceptorState createState() => _TouchInterceptorState();
}

class _TouchInterceptorState extends State<TouchInterceptor> {
  final _keySet = <TouchKey>{};

  @override
  Widget build(BuildContext context) {
    return _KeyRegister(
      keySet: _keySet,
      child: Listener(
        onPointerDown: (PointerDownEvent details) =>
            _sendAction(_TouchAction.down, details.position),
        onPointerMove: (PointerMoveEvent details) =>
            _sendAction(_TouchAction.move, details.position),
        onPointerUp: (PointerUpEvent details) =>
            _sendAction(_TouchAction.up, details.position),
        onPointerCancel: (PointerCancelEvent details) =>
            _sendAction(_TouchAction.cancel, details.position),
        child: AbsorbPointer(child: widget.child),
      ),
    );
  }

  void _sendAction(_TouchAction touchAction, Offset offset) {
    for (TouchKey key in _keySet) {
      key.currentState!.dispatchTouch(offset, touchAction);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(IterableProperty<String>(
        'keys', _keySet.map((TouchKey key) => key.toString()).toList(),
        ifEmpty: '<none>'));
  }
}

/// A widget that listens for events from the nearest [TouchInterceptor]
/// ancestor and calls callbacks in response to them.
///
/// ## Layout behavior
///
/// _See [BoxConstraints] for an introduction to box layout models._
///
/// If it has a child, this widget defers to the child for sizing behavior. If
/// it does not have a child, it grows to fit the parent instead.
class TouchConsumer extends StatefulWidget {
  // Creates a [TouchConsumer] widget.
  const TouchConsumer({
    Key? key,
    this.onTouchDown,
    this.onTouchEnter,
    this.onTouchExit,
    this.onTouchUp,
    this.child,
  }) : super(key: key);

  /// Called when a pointer comes into contact with the screen at this widget's
  /// location.
  final VoidCallback? onTouchDown;

  /// Called when a pointer that has previously come into contact with the screen
  /// changes position and reaches this widget's location.
  final VoidCallback? onTouchEnter;

  /// Called when a pointer that has previously come into contact with the screen
  /// changes position and leaves this widget's location.
  final VoidCallback? onTouchExit;

  /// Called when a pointer that has previously come into contact with the screen
  /// stops being in contact with the screen at this widget's location.
  final VoidCallback? onTouchUp;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  @override
  _TouchConsumerState createState() => _TouchConsumerState();
}

class _TouchConsumerState extends State<TouchConsumer> {
  TouchKey? _key;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isKeyRegistered) {
      _registerKey();
    }
  }

  @override
  void deactivate() {
    _unregisterKey();

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final callbacks = _TouchCallbacks(
      widget.onTouchDown,
      widget.onTouchEnter,
      widget.onTouchExit,
      widget.onTouchUp,
    );
    return _TouchConsumerCore(
      key: _key,
      child: widget.child,
      callbacks: callbacks,
    );
  }

  bool get _isKeyRegistered {
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

/// Thrown when a TouchInterceptor is not found above in the widget tree.
class TouchInterceptorNotFoundError extends Error {
  TouchInterceptorNotFoundError._();

  @override
  String toString() {
    return 'Error: Could not find a TouchInterceptor widget above this TouchConsumer widget.';
  }
}

enum _TouchAction { down, move, up, cancel }

class _KeyRegister extends InheritedWidget {
  const _KeyRegister({
    Key? key,
    required Set<TouchKey> keySet,
    required Widget child,
  })  : _keySet = keySet,
        super(key: key, child: child);

  final Set<TouchKey> _keySet;

  TouchKey? registerNewKey() {
    final newKey = TouchKey(); // keep it final!
    if (_keySet.add(newKey)) {
      return newKey;
    }
    return null;
  }

  bool isKeyRegistered(TouchKey? key) {
    return _keySet.contains(key);
  }

  void unregisterKey(TouchKey? key) {
    _keySet.remove(key);
  }

  List<TouchKey> get keys => _keySet.toList(growable: false);

  @override
  bool updateShouldNotify(_KeyRegister oldWidget) {
    return _keySet != oldWidget._keySet;
  }

  static _KeyRegister? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_KeyRegister>();
}

class _TouchConsumerCore extends StatefulWidget {
  const _TouchConsumerCore({
    TouchKey? key,
    required this.callbacks,
    required this.child,
  }) : super(key: key);

  final _TouchCallbacks callbacks;
  final Widget? child;

  @override
  _TouchConsumerCoreState createState() => _TouchConsumerCoreState();
}

class _TouchConsumerCoreState extends State<_TouchConsumerCore> {
  bool _hasTouchEntered = false;

  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
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
        case _TouchAction.cancel:
          if (_hasTouchEntered) {
            setState(() {
              _hasTouchEntered = false;
            });
            widget.callbacks.exit();
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

class TouchKey extends GlobalKey<_TouchConsumerCoreState> {
  const TouchKey() : super.constructor();

  @override
  String toString() {
    return '[TK<$hashCode>]';
  }
}

@immutable
class _TouchCallbacks {
  const _TouchCallbacks(
    this._onTouchDown,
    this._onTouchEnter,
    this._onTouchExit,
    this._onTouchUp,
  );

  final VoidCallback? _onTouchDown;
  final VoidCallback? _onTouchEnter;
  final VoidCallback? _onTouchExit;
  final VoidCallback? _onTouchUp;

  void down() => _onTouchDown?.call();

  void enter() => _onTouchEnter?.call();

  void exit() => _onTouchExit?.call();

  void up() => _onTouchUp?.call();
}
