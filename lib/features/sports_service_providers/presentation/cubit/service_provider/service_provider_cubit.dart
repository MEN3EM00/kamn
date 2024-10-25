import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kamn/core/utils/image_picker.dart';
import 'package:kamn/features/sports_service_providers/data/model/playground_model.dart';
import 'package:kamn/features/sports_service_providers/data/repository/service_providers_repository.dart';
import 'package:kamn/features/sports_service_providers/presentation/cubit/service_provider/service_provider_state.dart';

import '../../../../../core/utils/location.dart';

class ServiceProviderCubit extends Cubit<ServiceProviderState> {
  ServiceProviderCubit({required this.repository})
      : super(ServiceProviderState(state: ServiceProviderStatus.initial));

  ServiceProvidersRepository repository;
  List<File> selectedImageList = [];
  List<String> imagesUrl = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController governateController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> addService(PlaygroundModel playground) async {
    emit(ServiceProviderState(state: ServiceProviderStatus.loading));
    var response = await repository.addServiceToFirestore(playground);
    response.fold((error) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.failure, erorrMessage: error.erorr));
    }, (success) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.success,
          successMessage: 'service added successfully'));
    });
  }

  //that function must return image.path and then add it to the selectedImageList
  Future<void> getPhotoFromGallery() async {
    var images = await pickImage();
    if (images != null) {
      selectedImageList = images;
      emit(ServiceProviderState(
          state: ServiceProviderStatus.imagePicked,
          imagesList: images,
          successMessage: 'image loaded sucessfully'));
    } else {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.failure,
          erorrMessage: 'cancel image pick'));
    }
  }

  //TODO: i want to compress the images when pick it to avoid this function
  Future<void> compressImage() async {
    emit(ServiceProviderState(state: ServiceProviderStatus.loading));
    selectedImageList = await compressImages();
    emit(ServiceProviderState(state: ServiceProviderStatus.imageCompressed));
  }

  void removeImageFromList(File image) {
    selectedImageList.remove(image);
    emit(ServiceProviderState(
        state: ServiceProviderStatus.imageDeleted,
        imagesList: selectedImageList));
  }

  Future<void> addImagesToStorage() async {
    emit(ServiceProviderState(state: ServiceProviderStatus.loading));
    var response = await repository.addFImagesToStorage(selectedImageList);

    response.fold((error) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.failure,
          erorrMessage: 'faild to upload images to firebase storage'));
    }, (success) {
      imagesUrl = success;

      emit(ServiceProviderState(
          state: ServiceProviderStatus.imageUploaded,
          successMessage: 'images added successfully to firebase storage'));
    });
  }

  Map<String, double> coordinates = {};
  Future<void> getLocation() async {
    emit(ServiceProviderState(state: ServiceProviderStatus.locationLoading));
    var response = await getLocationCoordinates();
    response.fold((error) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.failure, erorrMessage: error.erorr));
    }, (success) {
      emit(ServiceProviderState(state: ServiceProviderStatus.locationDetected));
    });
  }
}
