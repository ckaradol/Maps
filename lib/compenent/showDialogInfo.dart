import 'package:flutter/material.dart';

class ShowDialogInfo extends StatelessWidget {
  const ShowDialogInfo({Key? key, required this.title, this.content})
      : super(key: key);
  final String title;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Tamam"),
        ),
      ],
    );
  }
}
