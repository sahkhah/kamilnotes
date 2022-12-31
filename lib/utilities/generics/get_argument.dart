import 'package:flutter/cupertino.dart' show BuildContext, ModalRoute;

extension GetArguments on BuildContext {
  T? getArgument<T>() {
    final modalRoute =
        ModalRoute.of(this); //we use this bcos this is the conttext
    if (modalRoute != null) {
      final argument = modalRoute.settings.arguments;
      if (argument != null && argument is T) {
        return argument as T;
      }
    }
    return null;
  }
}
