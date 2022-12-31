import 'package:flutter/cupertino.dart';
import 'package:kamilnotes/utilities/dialog/generic_dialogue.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Sharing',
      content: 'Cannot Share Empty Note',
      optionBuilder: () => {
        'OK' : null
      });
}
