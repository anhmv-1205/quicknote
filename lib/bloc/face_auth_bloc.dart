import 'package:flutter_bloc/flutter_bloc.dart';

import 'face_auth_state.dart';

class FaceAuthBloc extends Cubit<FaceAuthState> {
  FaceAuthBloc() : super(FaceInitial());

  void loading() {
    emit(FaceLoading());
  }

  void detecting() {
    emit(FaceDetecting());
  }

  void detected(String file) {
    emit(FaceDetected(file));
  }
}
