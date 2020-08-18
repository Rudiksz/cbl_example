import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'counters.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home1(),
    );
  }
}

class Home1 extends StatelessWidget {
  final counter = Counter(value: 0);

  Home1() {
    Timer.periodic(Duration(seconds: 5),
        (timer) => counter.animateToValue(Random().nextInt(1000)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Observer(builder: (_) => Text("Counter: ${counter.value}"))),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: Products({"CPU": 0, "RAM": 100})),
            Divider(height: 10),
            Divider(height: 10),
            Expanded(
              child: CustomCounterProducts({
                "CPU": Counter(
                  value: 0,
                  duration: Duration(seconds: 5),
                  curve: Curves.easeIn,
                ),
                "RAM": Counter(
                  value: 100,
                  duration: Duration(seconds: 2),
                  curve: Curves.easeOut,
                ),
                "GPU": Counter(
                  value: 314,
                  duration: Duration(seconds: 3),
                  curve: Curves.elasticInOut,
                ),
              }),
            ),
            Divider(height: 10),
            Divider(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: StockTicker(
                products: ["CPU", "RAM", "GPU", "Monitor"],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Products extends StatefulWidget {
  final Map<String, int> products;
  const Products(
    this.products, {
    Key key,
  }) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  Counters counters;

  @override
  void initState() {
    super.initState();
    counters = Counters.values(widget.products.values.toList());
  }

  @override
  void dispose() {
    counters.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _products = widget.products.keys.toList();
    return Column(children: [
      Divider(),
      Text("Default animations"),
      Observer(builder: (_) => Text("Total selected: ${counters.total}")),
      Divider(),
      Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _products.length,
          itemBuilder: (_, index) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Product: ${_products[index]}"),
              Row(
                children: [
                  Expanded(
                    child: Observer(
                      builder: (_) =>
                          Text("Quantity: ${counters[index].value}"),
                    ),
                  ),
                  IconButton(
                    onPressed: () => counters[index].remove(100),
                    icon: Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: () => counters[index].add(100),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class CustomCounterProducts extends StatefulWidget {
  final Map<String, Counter> products;
  const CustomCounterProducts(
    this.products, {
    Key key,
  }) : super(key: key);

  @override
  _CustomCounterProductsState createState() => _CustomCounterProductsState();
}

class _CustomCounterProductsState extends State<CustomCounterProducts> {
  Counters counters;
  int amount = 100;

  @override
  void initState() {
    super.initState();
    counters = Counters(counters: widget.products.values.toList());
  }

  @override
  void dispose() {
    counters.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _products = widget.products.keys.toList();
    return Column(
      children: [
        Text("Custom animations"),
        Observer(builder: (_) => Text("Total selected: ${counters.total}")),
        Divider(),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _products.length,
            itemBuilder: (_, index) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Product: ${_products[index]}"),
                Row(
                  children: [
                    Expanded(
                      child: Observer(
                        builder: (_) =>
                            Text("Quantity: ${counters[index].value}"),
                      ),
                    ),
                    IconButton(
                      onPressed: () => counters[index].remove(amount),
                      icon: Icon(Icons.remove),
                    ),
                    IconButton(
                      onPressed: () => counters[index].add(amount),
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        TextField(
          decoration: InputDecoration(
            labelText: "Amount to change: 100",
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          onChanged: (value) => amount = int.tryParse(value) ?? 100,
        ),
      ],
    );
  }
}

class StockTicker extends StatefulWidget {
  final List<String> products;
  StockTicker({Key key, this.products}) : super(key: key);

  @override
  _StockTickerState createState() => _StockTickerState();
}

class _StockTickerState extends State<StockTicker> {
  Counters counters;

  Stream<int> _ticker = (() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 5));
      yield 1;
    }
  })();

  @override
  void initState() {
    super.initState();
    // All counters animate the same way
    //counters = Counters.amount(widget.products.length);

    // or not
    counters = Counters(
      counters: widget.products
          .map(
            (e) => Counter(
                value: Random().nextInt(100),
                duration: Duration(seconds: Random().nextInt(10)),
                curve: Random().nextBool()
                    ? Curves.easeInOut
                    : Curves.bounceInOut),
          )
          .toList(),
    );

    // Set every counter by a random value
    _ticker.listen((_) => counters.foreach(
          (e) => e.animateToValue(Random().nextInt(1000)),
        ));
  }

  @override
  void dispose() {
    counters.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final _products = widget.products;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Observer(builder: (_) => Text("Total stock: ${counters.total}")),
        Divider(),
        Wrap(
          children: List.generate(_products.length, (i) => i)
              .map(
                (i) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${_products[i]}: "),
                    Observer(
                      builder: (_) => Text("Quantity: ${counters[i].value}"),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
