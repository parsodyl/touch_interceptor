# touch_interceptor

A widget that intercepts touch events and sends them to other widgets underneath.

![Schema](https://raw.githubusercontent.com/parsodyl/touch_interceptor/master/touch_interceptor.png?sanitize=true)


### Useful when:

- there is an opaque layer over a widget, and you want to make it transparent to touch events 
- you want seamlessly transfer a touch event from one widget to another

### Syntax:

```dart
// interceptor
TouchInterceptor(
  // other component(s)
  child: OtherWidget(
    // consumer
    child: TouchConsumer(
      onTouchDown: () {
        // do something
      },
      onTouchUp: () {
        // do something
      },
      onTouchEnter: () {
        // do something
      },
      onTouchExit: () {
        // do something
      },
    ),
  ),
),
```

### See the examples:
- [Basic example](https://github.com/parsodyl/touch_interceptor/tree/master/example)
- TBD: frozen layer
- TBD: colorful pads
