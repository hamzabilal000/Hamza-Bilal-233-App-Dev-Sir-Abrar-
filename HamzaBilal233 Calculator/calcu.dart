import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  double firstNum = 0;
  String operator = '';
  bool shouldClear = false;

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        display = '0';
        firstNum = 0;
        operator = '';
        shouldClear = false;
      } else if (value == '+' || value == '-' || value == '×' || value == '÷') {
        firstNum = double.tryParse(display) ?? 0;
        operator = value;
        shouldClear = true;
      } else if (value == '=') {
        double secondNum = double.tryParse(display) ?? 0;
        double result = 0;
        if (operator == '+') {
          result = firstNum + secondNum;
        } else if (operator == '-') {
          result = firstNum - secondNum;
        } else if (operator == '×') {
          result = firstNum * secondNum;
        } else if (operator == '÷') {
          if (secondNum != 0) {
            result = firstNum / secondNum;
          } else {
            display = 'Error';
            return;
          }
        }
        display = result.toString();
        operator = '';
      } else {
        if (display == '0' || shouldClear) {
          display = value;
          shouldClear = false;
        } else {
          display += value;
        }
      }
    });
  }

  Widget buildButton(String text, {Color color = Colors.black54}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(22.0),
            backgroundColor: Colors.grey[200],
          ),
          onPressed: () => buttonPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 22, color: color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                display,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            children: [
              buildButton('7'),
              buildButton('8'),
              buildButton('9'),
              buildButton('÷', color: Colors.blue),
            ],
          ),
          Row(
            children: [
              buildButton('4'),
              buildButton('5'),
              buildButton('6'),
              buildButton('×', color: Colors.blue),
            ],
          ),
          Row(
            children: [
              buildButton('1'),
              buildButton('2'),
              buildButton('3'),
              buildButton('-', color: Colors.blue),
            ],
          ),
          Row(
            children: [
              buildButton('C', color: Colors.red),
              buildButton('0'),
              buildButton('=', color: Colors.green),
              buildButton('+', color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}
