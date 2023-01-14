import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  late final _textEditingController;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Testing Bloc')),
        body: BlocConsumer<CounterBloc, CounterState>(
          builder: (context, state) {
            final invalidValue =
                (state is CounterStateInvalidNumber) ? state.value : '';
            return Column(
              children: [
                Text('Current Value = ${state.value}'),
                Visibility(
                  visible: state is CounterStateInvalidNumber,
                  child: Text('Invalid Input = $invalidValue'),
                ),
                TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a number here',
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          context
                              .read<CounterBloc>()
                              .add(DecrementEvent(_textEditingController.text));
                        },
                        child: const Text('-')),
                    TextButton(onPressed: () {
                      context
                              .read<CounterBloc>()
                              .add(IncrementEvent(_textEditingController.text));
                    }, child: const Text('+')),
                  ],
                )
              ],
            );
          },
          listener: (context, state) {
            _textEditingController.clear();
          },
        ),
      ),
    );
  }
}



@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalidNumber extends CounterState{
  final String invalidNumber;
  //constructor
  const CounterStateInvalidNumber(
      {required this.invalidNumber, required int previousNumber})
      : super(previousNumber);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(CounterStateInvalidNumber(
              invalidNumber: event.value, previousNumber: state.value));
        } else {
          emit(CounterStateValid(state.value + integer));
        }
      },
    );

    on<DecrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(CounterStateInvalidNumber(
              invalidNumber: event.value, previousNumber: state.value));
        } else {
          emit(CounterStateValid(state.value - integer));
        }
      },
    );
  }
}