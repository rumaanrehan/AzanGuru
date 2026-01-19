import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/mixin/validation_mixin.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/model/user.dart';
import 'package:azan_guru_mobile/ui/model/user_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cross_file/cross_file.dart';

import '../../../ui/model/media_node.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> with ValidationMixin {
  // Access the singleton instance:
  final graphQLService = GraphQLService();
  final ImagePicker _picker;

  String get token => StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);

  ProfileBloc()
      : _picker = ImagePicker(),
        super(ProfileInitialState()) {
    on<PickImage>(_onPickImage);
    on<UpdateProfileEvent>(
          (event, emit) async {
        if (isFieldEmpty(event.displayName)) {
          emit(ProfileErrorState(errorMessage: "Please enter display name."));
        } else if (isFieldEmpty(event.gender)) {
          emit(ProfileErrorState(errorMessage: "Please select gender."));
        } else {
          emit(ProfileLoadingState());
          String userId = user?.id ?? '';
          graphQLService.initClient();
          final result = await graphQLService.performMutation(
            AzanGuruQueries.updateUser,
            variables: {
              "id": userId,
              "firstName": event.displayName,
              "lastName": event.lastName,
              "email": event.email,
              "gender": event.gender,
              "phone": event.phone,
            },
          );
          if (result.hasException) {
            debugPrint('graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
            String errorMessgae = result.exception!.graphqlErrors.map((e) => e.message).join(',');
            emit(ProfileErrorState(errorMessage: errorMessgae));
          } else {
            UserData userData = UserData.fromJson(result.data?["updateUser"]);
            debugPrint('------ user - ${userData.user?.email}');
            StorageManager.instance.setUserSession(userDataToJson(userData));
            // final loginData = result.data?['login'];
            // UserData userData = UserData.fromJson(loginData);
            // debugPrint('------ user - ${userData.user?.email}');
            emit(ProfileSuccessState());
          }
        }
      },
    );

    on<GetProfileEvent>(
          (event, emit) async {
        emit(ProfileLoadingState());
        graphQLService.initClient();
        String? userId = user?.id;
        debugPrint('userId===> $userId');
        final result = await graphQLService.performQuery(
          AzanGuruQueries.getUser,
          variables: {"id": userId},
        );
        debugPrint('result===> ${result.toString()}');
        emit(ProfileLoadingState());
        if (result.hasException) {
          debugPrint('graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
          String errorMessage = result.exception!.graphqlErrors.map((e) => e.message).join(',');
          emit(ProfileErrorState(errorMessage: errorMessage));
        } else {
          UserData? userData = StorageManager.instance.getLoginUser();
          debugPrint("result.data===> ${result.data?['user']}");
          User? user = User.fromJson(result.data?['user']);
          userData?.user = user;
          debugPrint("user ====> $user");
          debugPrint("userData ====> ${userData?.user?.toJson()}");
          StorageManager.instance.setUserSession(userDataToJson(userData!));
          emit(GetProfileState(user));
        }
      },
    );

    on<ResetUserPasswordEvent>(
          (event, emit) async {
        if (isFieldEmpty(event.username)) {
          emit(
            ProfileErrorState(errorMessage: "Please enter username."),
          );
        } else {
          emit(ProfileLoadingState());
          final result = await graphQLService.performMutation(
            AzanGuruQueries.resetPasswordEmail,
            variables: {"username": event.username},
          );
          if (result.hasException) {
            debugPrint('graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
            String errorMessgae = result.exception!.graphqlErrors.map((e) => e.message).join(',');
            emit(ProfileErrorState(errorMessage: errorMessgae));
          } else {
            emit(ResetPasswordSuccessState());
          }
        }
      },
    );
  }

  _onPickImage(PickImage event, Emitter emit) async {
    try {
      if (event.fromCamera) {
        await _requestCameraPermission(emit);
      } else {
        await _requestStoragePermission(emit);
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile != null) {
        final compressedImage = await _compressImage(File(pickedFile.path));
        emit(ProfileLoadingState());
        var headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        };
        // Create a MultipartRequest
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(graphQLService.apiUrl),
        );
        // Add the headers
        request.headers.addAll(headers);
        // Add the fields
        request.fields['operations'] = jsonEncode({
          'query': AzanGuruQueries.uploadImage.trim(),
          'variables': {
            "studentId": user?.databaseId,
            "file": compressedImage.path,
          },
        });

        request.fields['map'] = jsonEncode({
          '0': ['variables.file'],
        });

        request.files.add(await http.MultipartFile.fromPath(
          '0',
          compressedImage.path,
        ));
        try {
          final response = await http.Response.fromStream(await request.send());
          final parsedResponse = jsonDecode(response.body);
          if (response.statusCode == 200) {
            var data = parsedResponse['data'];
            debugPrint('Upload response: $data');
            if (data['updateUserPicture']['error'] != null) {
              debugPrint('Upload error: ${data['updateUserPicture']['error']}');
              emit(ProfileErrorState(errorMessage: data['updateUserPicture']['error']));
            } else {
              String imageUrl = data['updateUserPicture']['message'];
              debugPrint('Upload success: $imageUrl');
              UserData? userData = StorageManager.instance.getLoginUser();
              User? user = userData?.user;
              if (user?.studentsOptions != null) {
                user?.studentsOptions?.studentPicture?.node?.mediaItemUrl = imageUrl;
              } else {
                user?.studentsOptions = StudentsOptions(
                  studentPicture: StudentPicture(
                    node: MediaNode(
                      mediaItemUrl: imageUrl,
                    ),
                  ),
                );
              }
              StorageManager.instance.setUserSession(userDataToJson(userData!));
              emit(ImagePickerLoaded(imagePath: imageUrl));
            }
          } else {
            emit(ProfileErrorState(errorMessage: 'Upload failed'));
          }
        } catch (e) {
          emit(ProfileErrorState(errorMessage: 'Upload failed'));
        }
      } else {
        debugPrint('No Image Selected.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _requestCameraPermission(Emitter emit) async {
    try {
      var status = await Permission.camera.status;
      debugPrint('Initial camera permission status: $status');

      // Check if the permission is already granted
      if (status.isGranted) {
        debugPrint('Camera permission already granted');
        return; // Permission is granted, no further action is needed.
      }

      // If the permission is permanently denied, guide the user to app settings
      if (status.isPermanentlyDenied) {
        debugPrint('Camera permission permanently denied - directing user to app settings');
        emit(ProfileErrorState(
          errorMessage: 'Camera permission is permanently denied. You need to enable it in the app settings.',
          isOpenSetting: true, // Prompt user to open app settings
        ));
        return; // Stop further execution
      }

      // If permission is denied, limited, or restricted, request permission
      if (status.isDenied || status.isLimited || status.isRestricted) {
        debugPrint('Requesting camera permission...');
        PermissionStatus permissionStatus = await Permission.camera.request();
        debugPrint('After camera request: $permissionStatus');

        // After the request, check if permission is granted
        if (permissionStatus.isGranted) {
          debugPrint('Camera permission granted after request');
          return; // Permission granted after request, proceed as needed
        }

        // Handle different denial cases
        if (permissionStatus.isDenied) {
          emit(ProfileErrorState(
            errorMessage: 'Camera permission is required to take photos. You can enable it in the app settings.',
            isOpenSetting: true,
          ));
        } else if (permissionStatus.isLimited) {
          emit(ProfileErrorState(
            errorMessage: 'Limited access is not sufficient. Please grant full access in the app settings.',
            isOpenSetting: true,
          ));
        } else if (permissionStatus.isRestricted) {
          emit(ProfileErrorState(
            errorMessage: 'Camera permission is restricted. Please check your settings.',
            isOpenSetting: true,
          ));
        } else if (permissionStatus.isPermanentlyDenied) {
          emit(ProfileErrorState(
            errorMessage: 'Camera permission is permanently denied. You need to enable it in the app settings.',
            isOpenSetting: true,
          ));
        }
      }
    } on PlatformException catch (e) {
      // Handle the PlatformException
      debugPrint('PlatformException (camera): ${e.message}');
      emit(ProfileErrorState(
        errorMessage:
        'An error occurred while requesting camera permission: ${e.message}. Please enable the permission from settings.',
        isOpenSetting: true,
      ));
    }
  }

  Future<void> _requestStoragePermission(Emitter emit) async {
    try {
      var status = await Permission.photos.status;
      debugPrint('Initial status: $status');

      // Check if the permission is already granted
      if (status.isGranted) {
        debugPrint('Permission already granted');
        return; // Permission is granted, no further action is needed.
      }

      // If the permission is permanently denied, guide the user to app settings
      if (status.isPermanentlyDenied) {
        debugPrint('Permanently Denied - Directing user to app settings');
        emit(ProfileErrorState(
          errorMessage: 'Storage permission is permanently denied. You need to enable it in the app settings.',
          isOpenSetting: true, // Prompt user to open app settings
        ));
        return; // Stop further execution
      }

      // If permission is denied, limited, or restricted, request permission
      if (status.isDenied || status.isLimited || status.isRestricted) {
        debugPrint('Requesting permission...');
        PermissionStatus permissionStatus = await Permission.photos.request();
        debugPrint('After request: $permissionStatus');

        // After the request, check if permission is granted
        if (permissionStatus.isGranted) {
          debugPrint('Permission granted after request');
          return; // Permission granted after request, proceed as needed
        }

        // Handle different denial cases
        if (permissionStatus.isDenied) {
          emit(ProfileErrorState(
            errorMessage: 'Storage permission is required to select photos. You can enable it in the app settings.',
            isOpenSetting: true,
          ));
        } else if (permissionStatus.isLimited) {
          emit(ProfileErrorState(
            errorMessage: 'Limited access is not sufficient. Please grant full access in the app settings.',
            isOpenSetting: true,
          ));
        } else if (permissionStatus.isRestricted) {
          emit(ProfileErrorState(
            errorMessage: 'Storage permission is restricted. Please check your settings.',
            isOpenSetting: true,
          ));
        } else if (permissionStatus.isPermanentlyDenied) {
          emit(ProfileErrorState(
            errorMessage: 'Storage permission is permanently denied. You need to enable it in the app settings.',
            isOpenSetting: true,
          ));
        }
      }
    } on PlatformException catch (e) {
      // Handle the PlatformException
      debugPrint('PlatformException: ${e.message}');
      emit(ProfileErrorState(
        errorMessage:
        'An error occurred while requesting storage permission: ${e.message}. Please enable the permission from settings.',
        isOpenSetting: true,
      ));
    }
  }

  Future<File> _compressImage(File file) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final String targetPath = '$tempPath/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile? xfile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
    );

    return xfile != null ? File(xfile.path) : throw Exception('Image compression failed');
  }
}
