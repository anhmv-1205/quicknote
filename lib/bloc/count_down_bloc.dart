import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CountDownState extends Equatable {
  const CountDownState();

  @override
  List<Object?> get props => [];
}

class CountDownInitial extends CountDownState {}

class Counting extends CountDownState {
  final int count;

  const Counting(
    this.count,
  ) : super();

  @override
  List<Object> get props => [count, super.props];
}

class Finish extends CountDownState {
  const Finish() : super();
}

class CountDownBloc extends Cubit<CountDownState> {
  CountDownBloc() : super(const Counting(_start));

  static const _start = 10;

  get start => _start;

  void startTimer() {
    var time = _start;
    const oneSec = Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) {
        if (time == 0) {
          finish();
          timer.cancel();
        } else {
          counting(--time);
        }
      },
    );
  }

  void counting(int count) {
    emit(Counting(count));
  }

  void finish() {
    emit(const Finish());
  }
}
