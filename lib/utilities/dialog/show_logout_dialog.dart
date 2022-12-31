import 'package:flutter/material.dart';
import 'package:kamilnotes/utilities/dialog/generic_dialogue.dart';

Future<bool> showLogoutDialog(BuildContext context, String text) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Are you sure?',
    content: text,
    optionBuilder: () => {'Yes': true, 'No': false},    //this is a function that returns a map as seen in the generic dialog class
  ).then((value) => value ?? false);
}
