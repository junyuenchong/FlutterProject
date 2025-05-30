import 'package:flutter/material.dart';

class ItemCount1 extends StatefulWidget {
  final Color color;
  final double buttonSizeHeight;
  final double buttonSizeWidth;
    final double TextSizeHeight;
  final double TextSizeWidth;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final int decimalPlaces;
  final ValueChanged<int> onChanged;

  const ItemCount1({
    super.key,
    required this.color,
    required this.buttonSizeHeight,
    required this.buttonSizeWidth,
        required this.TextSizeHeight,
        required this.TextSizeWidth,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.decimalPlaces,
    required this.onChanged,
  });

  @override
  _ItemCountState createState() => _ItemCountState();
}

class _ItemCountState extends State<ItemCount1> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  void _increment() {
    if (_currentValue < widget.maxValue) {
      setState(() {
        _currentValue++;
      });
      widget.onChanged(_currentValue);
    }
  }

  void _decrement() {
    if (_currentValue > widget.minValue) {
      setState(() {
        _currentValue--;
      });
      widget.onChanged(_currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decrement button
          SizedBox(
            height: widget.buttonSizeHeight,
            width: widget.buttonSizeWidth,
            child: ElevatedButton(
              onPressed: _decrement,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
              ),
              child: const Icon(Icons.remove, color: Colors.white),
            ),
          ),
          // Display value
          Container(
            width: widget.TextSizeWidth,
            height: widget.TextSizeHeight,
            alignment: Alignment.center,
            child: Text(
              _currentValue.toStringAsFixed(widget.decimalPlaces),
              style: TextStyle(
                fontSize: 20,
                color: widget.color,
              ),
            ),
          ),
          // Increment button
          SizedBox(
            height: widget.buttonSizeHeight,
            width: widget.buttonSizeWidth,

            child: ElevatedButton(
              onPressed: _increment,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
