// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counters.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Counters on _Counters, Store {
  Computed<dynamic> _$totalComputed;

  @override
  dynamic get total => (_$totalComputed ??=
          Computed<dynamic>(() => super.total, name: '_Counters.total'))
      .value;

  final _$countersAtom = Atom(name: '_Counters.counters');

  @override
  List<Counter> get counters {
    _$countersAtom.reportRead();
    return super.counters;
  }

  @override
  set counters(List<Counter> value) {
    _$countersAtom.reportWrite(value, super.counters, () {
      super.counters = value;
    });
  }

  @override
  String toString() {
    return '''
counters: ${counters},
total: ${total}
    ''';
  }
}

mixin _$Counter on _Counter, Store {
  final _$valueAtom = Atom(name: '_Counter.value');

  @override
  int get value {
    _$valueAtom.reportRead();
    return super.value;
  }

  @override
  set value(int value) {
    _$valueAtom.reportWrite(value, super.value, () {
      super.value = value;
    });
  }

  final _$animatedAtom = Atom(name: '_Counter.animated');

  @override
  bool get animated {
    _$animatedAtom.reportRead();
    return super.animated;
  }

  @override
  set animated(bool value) {
    _$animatedAtom.reportWrite(value, super.animated, () {
      super.animated = value;
    });
  }

  final _$_CounterActionController = ActionController(name: '_Counter');

  @override
  dynamic animateToValue(int newValue) {
    final _$actionInfo =
        _$_CounterActionController.startAction(name: '_Counter.animateToValue');
    try {
      return super.animateToValue(newValue);
    } finally {
      _$_CounterActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic toggleAnimation() {
    final _$actionInfo = _$_CounterActionController.startAction(
        name: '_Counter.toggleAnimation');
    try {
      return super.toggleAnimation();
    } finally {
      _$_CounterActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
value: ${value},
animated: ${animated}
    ''';
  }
}
