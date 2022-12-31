import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function(); //any function that would return a Map

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder(); //options here is a map function e.g {'OK', null}
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionsTitle) {
          //every keys of the map is going to be assigned to the text button child
          final value =
              options[optionsTitle]; //get the value of this particular key
          return TextButton(
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(optionsTitle), //assign the key(string) to the text
          );
        }).toList(),
      );
    },
  );
}
