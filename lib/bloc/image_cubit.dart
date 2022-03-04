import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/data_layer.dart';
import '../services/services_layer.dart';

// enum ImageState { idle, loading, loaded, error }

abstract class ImageState extends Equatable {
  const ImageState();

  @override
  List<Object?> get props => [];
}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageLoaded extends ImageState {
  final ImageModel? image;

  const ImageLoaded(
    this.image,
  ) : super();

  @override
  List<Object> get props =>
      image == null ? [super.props] : [image!, super.props];
}

class ImageError extends ImageState {
  final String? errorMessage;

  const ImageError({
    this.errorMessage,
  });

  @override
  List<Object> get props =>
      errorMessage == null ? [super.props] : [errorMessage!, super.props];
}

class ImageCubit extends Cubit<ImageState> {
  ImageCubit() : super(ImageInitial());

  ImageModel? _image;

  ImageModel? get image => _image;

  void getImage() async {
    if (_image != null) {
      _image = null;
    }
    emit(ImageLoading());
    try {
      final _mediaService = MediaService();
      _image = await _mediaService.pickImageFromGallery();
      emit(ImageLoaded(image));
    } on Exception catch (e) {
      emit(ImageError(errorMessage: e.toString()));
    }
  }
}
