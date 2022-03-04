import 'package:bloc_flutter/bloc/image_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/data_layer.dart';
import '../services/services_layer.dart';

abstract class TextRecognizedState extends Equatable {
  const TextRecognizedState();

  @override
  List<Object?> get props => [];
}

class TextRecognizedInitial extends TextRecognizedState {}

class TextRecognizedLoading extends TextRecognizedState {}

class TextRecognizedLoaded extends TextRecognizedState {
  final List<RecognizedText>? processedTexts;

  const TextRecognizedLoaded(
    this.processedTexts,
  ) : super();

  @override
  List<Object> get props =>
      processedTexts == null ? [super.props] : [processedTexts!, super.props];
}

class TextRecognizedError extends TextRecognizedState {
  final String? errorMessage;

  const TextRecognizedError({
    this.errorMessage,
  });

  @override
  List<Object> get props =>
      errorMessage == null ? [super.props] : [errorMessage!, super.props];
}

class TextRecognizedCubit extends Cubit<TextRecognizedState> {
  TextRecognizedCubit() : super(TextRecognizedInitial());

  late ImageCubit imageCubit;

  List<RecognizedText>? _processedTexts;

  List<RecognizedText>? get processedTexts => _processedTexts;

  void getText() async {
    if (imageCubit.image == null) return;
    emit(TextRecognizedLoading());
    try {
      final _mlService = MlService();
      final ImageModel _image = imageCubit.image!;
      final String _imagePath = _image.imagePath!;
      _processedTexts = await _mlService.getText(_imagePath);
      emit(TextRecognizedLoaded(processedTexts));
    } catch (e) {
      emit(
        const TextRecognizedError(errorMessage: "Error occur"),
      );
    }
  }

  void emptyList() {
    _processedTexts = [];
  }
}
