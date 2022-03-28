import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

abstract class DetectState extends Equatable {
  const DetectState();

  @override
  List<Object?> get props => [];
}

class DetectNoFound extends DetectState {}

class Detected extends DetectState {
  final Face face;

  const Detected(
    this.face,
  ) : super();

  @override
  List<Object> get props => [face, super.props];
}

class Authenticated extends DetectState {
  final Face face;

  const Authenticated(
    this.face,
  ) : super();

  @override
  List<Object> get props => [face, super.props];
}

class DetectBloc extends Cubit<DetectState> {
  DetectBloc() : super(DetectNoFound());

  void detected(Face? face) {
    if (face == null) {
      emit(DetectNoFound());
      return;
    }
    emit(Detected(face));
  }

  void authenticate(Face face) {
    emit(Authenticated(face));
  }
}
