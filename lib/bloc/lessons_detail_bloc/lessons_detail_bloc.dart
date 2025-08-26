import 'dart:convert';
import 'dart:developer';
import 'package:azan_guru_mobile/common/util.dart';
import 'package:azan_guru_mobile/graphQL/graphql_service.dart';
import 'package:azan_guru_mobile/graphQL/queries.dart';
import 'package:azan_guru_mobile/service/local_storage/local_storage_keys.dart';
import 'package:azan_guru_mobile/service/local_storage/storage_manager.dart';
import 'package:azan_guru_mobile/ui/model/ag_lesson_detail.dart';
import 'package:azan_guru_mobile/ui/model/submit_quizz_input.dart';
import 'package:azan_guru_mobile/ui/model/submitted_answers_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';

part 'lessons_detail_event.dart';
part 'lessons_detail_state.dart';

class LessonDetailBloc extends Bloc<LessonDetailEvent, LessonDetailState> {
  final graphQLService = GraphQLService();
  LessonDetailBloc() : super(LessonDetailInitial()) {
    on<GetLessonDetailEvent>(_getLessonDetail);
    on<UpdateRequestEvent>(_updateRequest);
    on<SubmitQuizEvent>(_submitQuiz);
    on<SubmitHomeworkEvent>(_submitHomework);
    on<SubmitLessonEvent>(_submitLesson);
    on<GetSubmittedQuizzAnswersByLessonIdEvent>(
        _getSubmittedQuizzAnswersByLessonId);
  }

  _getLessonDetail(GetLessonDetailEvent event, Emitter emit) async {
    emit(ShowLessonDetailLoadingState());
    final result = await graphQLService.performQuery(
      AzanGuruQueries.getLessonDetail,
      variables: {"id": event.lessonId},
    );
    emit(HideLessonDetailLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      final catData = result.data?['agCourseBy'];
      LessonDetail? data;
      if (catData != null) {
        data = LessonDetail.fromJson(catData);
      }
      emit(GetLessonDetailState(lessonDetail: data));
    }
  }

  _submitQuiz(SubmitQuizEvent event, Emitter emit) async {
    emit(ShowLessonDetailLoadingState());
    graphQLService.initClient(addToken: user != null);
    final result = await graphQLService.performMutation(
      AzanGuruQueries.submitQuizNew,
      variables: {
        "input": event.request!.toJson(),
      },
    );
    emit(HideLessonDetailLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      final resData = result.data?['submitQuiz'];
      debugPrint('graphQL Res: $resData');
      if (resData['error'] == null) {
        emit(
          SubmitQuizState(
            lessonId: event.request?.lessonId,
            lessonDbId: event.request?.lessonDbId,
          ),
        );
      } else {
        if (resData['error'].toString().toLowerCase() ==
            'Quiz already submitted'.toLowerCase()) {
          emit(
            SubmitQuizState(
              lessonId: event.request?.lessonId,
              lessonDbId: event.request?.lessonDbId,
            ),
          );
        } else {
          emit(LessonsDetailErrorState(resData['error']));
        }
      }
    }
  }

  String get token =>
      StorageManager.instance.getString(LocalStorageKeys.prefAuthToken);

  _submitHomework(SubmitHomeworkEvent event, Emitter emit) async {
    emit(ShowLessonDetailLoadingState());
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
      'query': AzanGuruQueries.submitHomeworkMutation.trim(),
      'variables': {
        "lessonId": event.lessonId,
        "studentId": event.studentId,
        "homeworkId": event.homeworkId,
        "file": event.file,
      },
    });

    request.fields['map'] = jsonEncode({
      '0': ['variables.file'],
    });

    // Determine MIME type based on the file extension
    String mimeType;
    switch (event.file?.split('.').last) {
      case 'mp3':
        mimeType = 'audio/mpeg';
        break;
      case 'wav':
        mimeType = 'audio/wav';
        break;
      case 'm4a':
        mimeType = 'audio/mp4';
        break;
      default:
        mimeType = 'application/octet-stream';
    }

    // Add the file to the request
    request.files.add(await http.MultipartFile.fromPath(
      '0',
      event.file ?? '',
      contentType: MediaType.parse(mimeType),
    ));
    // Send the request and handle the response
    try {
      final response = await http.Response.fromStream(await request.send());
      final parsedResponse = jsonDecode(response.body);
      emit(HideLessonDetailLoadingState());
      if (response.statusCode == 200) {
        var data = parsedResponse['data'];
        debugPrint('Upload response: $data');
        if (data['submitHomework']['error'] != null) {
          debugPrint('Upload error: ${data['submitHomework']['error']}');
          emit(LessonsDetailErrorState(data['submitHomework']['error']));
        } else {
          debugPrint('Upload success: ${data['submitHomework']['message']}');
          emit(SubmitHomeworkState());
        }
      } else {
        debugPrint('Upload failed: $parsedResponse');
        emit(LessonsDetailErrorState('Upload failed'));
      }
    } catch (e) {
      debugPrint('Upload failed with error: $e');
      emit(HideLessonDetailLoadingState());
      emit(LessonsDetailErrorState('Upload failed'));
    }
  }

  _submitLesson(SubmitLessonEvent event, Emitter emit) async {
    emit(ShowLessonDetailLoadingState());
    graphQLService.initClient(addToken: user != null);
    final result = await graphQLService.performMutation(
      AzanGuruQueries.submitLesson,
      variables: {
        "lesson_id": event.lessonDbId.toString(),
        "student_id": user?.databaseId.toString(),
      },
    );
    final resData = result.data?['submitCompletedLesson'];
    debugPrint('graphQL Res: $resData');
    emit(HideLessonDetailLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      emit(
        SubmitLessonState(
          type: event.type,
          lessonId: event.lessonId,
          lessonDbId: event.lessonDbId,
        ),
      );
    }
  }

  _updateRequest(UpdateRequestEvent event, Emitter emit) {
    emit(UpdateRequestState(request: event.request));
  }

  _getSubmittedQuizzAnswersByLessonId(
    GetSubmittedQuizzAnswersByLessonIdEvent event,
    Emitter emit,
  ) async {
    emit(ShowLessonDetailLoadingState());
    graphQLService.initClient(addToken: user != null);
    final result = await graphQLService.performQuery(
      AzanGuruQueries.getSubmittedQuizzAnswers,
      variables: {
        "lessonId": event.lessonDbId,
        "userId": user?.databaseId,
      },
    );
    final resData = result.data?['getQuizz'];
    debugPrint('graphQL Res: $resData');
    emit(HideLessonDetailLoadingState());
    if (result.hasException) {
      debugPrint(
          'graphQLErrors: ${result.exception?.graphqlErrors.toString()}');
    } else {
      SubmittedAnswersResponse? responce;
      if (resData != null) {
        responce = SubmittedAnswersResponse.fromJson(resData);
      }
      if (responce != null) {
        if (responce.error != null) {
          // emit(LessonsDetailErrorState(responce.error));
          debugPrint('Errors: ${responce.error}');
        } else {
          emit(
            GetSubmittedQuizzAnswersByLessonIdState(
              response: responce,
            ),
          );
        }
      } else {
        emit(LessonsDetailErrorState('Something went wrong!!!'));
      }
    }
  }
}
