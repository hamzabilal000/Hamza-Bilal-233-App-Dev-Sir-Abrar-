import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hamza Bilal 233 ',
      theme: ThemeData.dark(),
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
  String _output = "0";
  String _input = "";

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _output = "0";
        _input = "";
      } else if (value == "=") {
        try {
          _output = _evaluateExpression(_input);
          _input = _output;
        } catch (e) {
          _output = "Error";
        }
      } else {
        _input += value;
        _output = _input;
      }
    });
  }

  String _evaluateExpression(String expression) {
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      final exp = expression;
      final result = _calculate(exp);
      return result.toString();
    } catch (_) {
      return "Error";
    }
  }

  double _calculate(String exp) {
    // Placeholder: For real use, add math parser.
    return double.tryParse(exp.replaceAll(RegExp(r'[^0-9\.\+\-\*\/]'), '')) ??
        0.0;
  }

  Widget _buildButton(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: HoverAnimatedButton(
        label: text,
        color: color ?? Colors.white,
        onTap: () => _onButtonPressed(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420), // 👈 Ideal size
              child: Column(
                children: [
                  // Display
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _output,
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Buttons
                  Expanded(
                    flex: 5,
                    child: GridView.count(
                      padding: const EdgeInsets.all(12),
                      crossAxisCount: 4,
                      children: [
                        _buildButton("7"),
                        _buildButton("8"),
                        _buildButton("9"),
                        _buildButton("÷", color: Colors.orange),
                        _buildButton("4"),
                        _buildButton("5"),
                        _buildButton("6"),
                        _buildButton("×", color: Colors.orange),
                        _buildButton("1"),
                        _buildButton("2"),
                        _buildButton("3"),
                        _buildButton("-", color: Colors.orange),
                        _buildButton("0"),
                        _buildButton("C", color: Colors.red),
                        _buildButton("=", color: Colors.green),
                        _buildButton("+", color: Colors.orange),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Hover & Tap Animated Button
class HoverAnimatedButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const HoverAnimatedButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<HoverAnimatedButton> createState() => _HoverAnimatedButtonState();
}

class _HoverAnimatedButtonState extends State<HoverAnimatedButton> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(_pressed ? 0.92 : _hovering ? 1.08 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              if (_hovering)
                BoxShadow(
                  color: widget.color.withOpacity(0.7),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
