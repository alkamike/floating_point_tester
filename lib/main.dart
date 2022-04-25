import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: AmountEntry(
            initialValue: 4.25,
          ),
        ),
      ),
    );
  }
}

class AmountEntry extends StatefulWidget {
  final double? initialValue;
  final intl.NumberFormat _formatter = intl.NumberFormat.simpleCurrency(
    locale: 'en_US',
    decimalDigits: 2,
  );

  AmountEntry({
    this.initialValue,
    Key? key,
  }) : super(key: key);

  @override
  _AmountEntryState createState() => _AmountEntryState();
}

class _AmountEntryState extends State<AmountEntry> {
  static const double _kMaxInputAmount = 99999999999;

  // STATE variables
  /// This value is used to track numpad entries in the bottom sheet and format into the display input field.
  ///
  /// Works in cents because it's MUCH easier to track.
  late double _editingAmount = (widget.initialValue ?? 0) * 100;

  /// Formats [_editingAmount] as currency for rendering as text in the bottom sheet display field.
  String get _formattedEditingAmount {
    return widget._formatter.format(_editingAmount / 100);
  }

  String get _jsonFormattedValue {
    return jsonEncode({'amount': _editingAmount / 100});
  }

  @override
  void didUpdateWidget(covariant AmountEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue || _editingAmount != widget.initialValue) {
      _editingAmount = (widget.initialValue ?? 0) * 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Text(
              _formattedEditingAmount,
              textDirection: TextDirection.ltr,
            ),
            Text(
              _editingAmount.toString(),
              textDirection: TextDirection.ltr,
            ),
            Text(
              _jsonFormattedValue,
              textDirection: TextDirection.ltr,
            ),
            NumberPad(
              onTap: (value) {
                late double newAmount;
                if (value == '00') {
                  newAmount = _editingAmount * 100;
                } else {
                  newAmount = _editingAmount * 10 + double.parse(value);
                }
                if (newAmount <= _kMaxInputAmount) {
                  setState(() {
                    _editingAmount = newAmount;
                  });
                }
              },
              onBackspaceTap: () {
                setState(() {
                  _editingAmount = (_editingAmount / 10).floorToDouble();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NumberPad extends StatelessWidget {
  final void Function(String value) onTap;
  final void Function() onBackspaceTap;

  const NumberPad({required this.onTap, required this.onBackspaceTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        NumberPadButton('1', onTap),
        NumberPadButton('2', onTap),
        NumberPadButton('3', onTap),
      ]),
      Row(children: [
        NumberPadButton('4', onTap),
        NumberPadButton('5', onTap),
        NumberPadButton('6', onTap),
      ]),
      Row(children: [
        NumberPadButton('7', onTap),
        NumberPadButton('8', onTap),
        NumberPadButton('9', onTap),
      ]),
      Row(children: [
        NumberPadButton('<', (_) => onBackspaceTap()),
        NumberPadButton('0', onTap),
        NumberPadButton('00', onTap),
      ]),
    ]);
  }
}

class NumberPadButton extends StatelessWidget {
  final String display;
  final void Function(String value) onPressed;

  const NumberPadButton(this.display, this.onPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(display),
      onPressed: () => onPressed(display),
    );
  }
}
