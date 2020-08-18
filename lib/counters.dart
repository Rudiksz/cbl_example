import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobx/mobx.dart';

part 'counters.g.dart';

class Counters = _Counters with _$Counters;

abstract class _Counters with Store {
  /// counters: list of inital values of the counters to be created
  /// Defaults to creating one counter with initial value 0
  _Counters({List<Counter> counters}) {
    this.counters = counters ?? [Counter(value: 0)];
  }

  _Counters.amount(int amount) {
    counters = List.generate(amount, (_) => Counter(value: 0));
  }

  _Counters.values(List<int> values) {
    counters = values.map((e) => Counter(value: e)).toList();
  }

  @observable
  List<Counter> counters = [];

  @computed
  get total {
    var sum = 0;
    counters.forEach((counter) => sum += counter.value);
    return sum;
  }

  dispose() => counters.forEach((e) => e.dispose());

  foreach(void Function(Counter) f) => counters?.forEach(f);

  /// Subscript access to the counters
  Counter operator [](int key) => key < counters.length ? counters[key] : null;
}

class TickerProviderImpl extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class Counter = _Counter with _$Counter;

abstract class _Counter with Store {
  _Counter({
    this.value,
    this.duration = const Duration(seconds: 2),
    this.curve = Curves.linear,
    this.animated = true,
  }) {
    tween = IntTween(begin: value, end: value);
    controller = AnimationController(
      duration: duration,
      animationBehavior: AnimationBehavior.normal,
      vsync: TickerProviderImpl(),
    );

    animation = controller.drive(CurveTween(curve: curve));

    animation.addListener(() => value = tween.evaluate(animation));
  }

  @observable
  int value = 0;

  @observable
  bool animated = true;

  Duration duration = Duration(seconds: 2);
  Curve curve = Curves.linear;

  IntTween tween;
  AnimationController controller;
  Animation animation;

  @action
  animateToValue(int newValue) {
    if (!animated) {
      value = newValue;
      return;
    }

    tween.begin = value;
    tween.end = newValue;
    controller
      ..reset()
      ..forward();

    tween.animate(CurvedAnimation(curve: curve, parent: animation));
  }

  add(int amount) => animateToValue(value + amount);
  remove(int amount) => animateToValue(value - amount);

  @action
  toggleAnimation() => animated = !animated;

  dispose() => controller.dispose();
}
