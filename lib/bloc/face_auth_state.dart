import 'package:equatable/equatable.dart';

abstract class FaceAuthState extends Equatable {
  const FaceAuthState();

  @override
  List<Object?> get props => [];
}

class FaceInitial extends FaceAuthState {}

class FaceLoading extends FaceAuthState {}

class FaceDetecting extends FaceAuthState {}

class FaceDetected extends FaceAuthState {
  final String file;

  const FaceDetected(
    this.file,
  ) : super();

  @override
  List<Object> get props => [file, super.props];
}
