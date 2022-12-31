import 'package:flutter/material.dart';
import 'package:kamilnotes/utilities/dialog/generic_dialogue.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
    context: context,
    title: 'An Error Occurred',
    content: text,
    optionBuilder: () => {'OK': null},    //this is a function that returns a map as seen in the generic dialog class
  );
}
