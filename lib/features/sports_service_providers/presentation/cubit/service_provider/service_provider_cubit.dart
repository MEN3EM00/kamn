import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:kamn/core/utils/image_picker.dart';
import 'package:kamn/features/sports_service_providers/data/model/playground_request_model.dart';
import 'package:kamn/features/sports_service_providers/data/repository/service_providers_repository.dart';
import 'package:kamn/features/sports_service_providers/presentation/cubit/service_provider/service_provider_state.dart';

import '../../../../../core/utils/location.dart';

@injectable
class ServiceProviderCubit extends Cubit<ServiceProviderState> {
  ServiceProviderCubit({required this.repository})
      : super(ServiceProviderState(state: ServiceProviderStatus.initial));

  ServiceProvidersRepository repository;
  List<File> selectedImageList = [];
  List<String> imagesUrl = [];
//TODO: add validation to the inputs /* done
//TODO: dispose controllers before navigte to another screen /* done
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController governateController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> addService(PlaygroundRequestModel playground) async {
    emit(ServiceProviderState(state: ServiceProviderStatus.loading));
    //TODO:don`t fire function into another function you must fire first function and then depend on it`s state fire the second function /* done
    var response = await repository.addServiceToFirestore(playground);
    response.fold((error) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.serviceFailed,
          erorrMessage: error.erorr));
    }, (success) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.success,
          successMessage: 'service added successfully'));
    });
  }

  //TODO: add getPhotoFromGallery to the core and make a new file name it image_picker_helper.dart /* done
  //that function must return image.path and then add it to the selectedImageList
  Future<void> getPhotoFromGallery() async {
    var image = await pickImage();
    if (image != null) {
      selectedImageList.add(image);
      emit(ServiceProviderState(
          state: ServiceProviderStatus.imagePicked,
          imagesList: selectedImageList,
          successMessage: 'image loaded sucessfully'));
    } else {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.failure,
          erorrMessage: 'cancel image pick'));
    }
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

  Future<void> deleteImagesFromStorage() async {
    emit(ServiceProviderState(state: ServiceProviderStatus.loading));
    var response = await repository.deleteImagesFromStorage(selectedImageList);

    response.fold((error) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.failure,
          erorrMessage: 'faild to upload images to firebase storage'));
    }, (success) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.imageDeleted,
          successMessage: 'images deleted successfully from firebase storage'));
    });
  }

  //TODO: add location to the core /* done
  Map<String, double> coordinates = {};
  Future<void> getLocation() async {
    emit(ServiceProviderState(state: ServiceProviderStatus.locationLoading));
    var response = await getLocationCoordinates();
    response.fold((error) {
      emit(ServiceProviderState(
          state: ServiceProviderStatus.failure, erorrMessage: error.erorr));
    }, (success) {
      coordinates = success;
      emit(ServiceProviderState(state: ServiceProviderStatus.locationDetected));
    });
  }

  void disposeControllers() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    sizeController.dispose();
    governateController.dispose();
  }

  @override
  Future<void> close() {
    disposeControllers();
    return super.close();
  }
}
