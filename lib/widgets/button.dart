import 'package:flutter/material.dart';
import 'package:task_management/theme.dart';

class MyButton extends StatelessWidget {
  final void Function() onTap;
  final String label;
  const MyButton({Key? key, required this.onTap, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 130,
        decoration: BoxDecoration(
          color: primaryClr,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
