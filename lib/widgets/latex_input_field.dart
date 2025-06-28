import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String label;
  final String hint;
  final Function(String) onChanged;
  final String initialValue;

  const InputField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    required this.initialValue,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue == '{}' ? '' : widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      // Update the text controller only if the initialValue actually changed
      // and it's not the default empty set string.
      if (widget.initialValue == '{}' && _controller.text != '') {
        _controller.text = '';
      } else if (widget.initialValue != '{}' && _controller.text != widget.initialValue) {
        _controller.text = widget.initialValue;
      }
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            widget.onChanged(''); // Notify parent about cleared text
          },
        ),
      ),
      onChanged: widget.onChanged,
      keyboardType: TextInputType.text, // Could be text for arbitrary elements
    );
  }
}