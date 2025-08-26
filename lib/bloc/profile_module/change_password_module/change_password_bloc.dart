import 'package:azan_guru_mobile/mixin/validation_mixin.dart';
import 'package:azan_guru_mobile/ui/model/mdl_login_param.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'change_password_event.dart';

part 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState>
    with ValidationMixin {
  ChangePasswordBloc() : super(ChangePasswordInitialState()) {
    on<PasswordChangeEvent>((event, emit) {
      if (isFieldEmpty(event.mdlChangePasswordParam.currentPassword ?? "")) {
        emit(ChangePasswordErrorState(
            errorMessage: "Please enter your current password."));
      } else if (isFieldEmpty(event.mdlChangePasswordParam.newPassword ?? "")) {
        emit(ChangePasswordErrorState(
            errorMessage: "Please enter your new password."));
      } else if (!passwordValidation(
          event.mdlChangePasswordParam.newPassword ?? "")) {
        emit(ChangePasswordErrorState(
            errorMessage: "Please enter minimum 8 character password."));
      } else if (isFieldEmpty(
          event.mdlChangePasswordParam.confirmPassword ?? "")) {
        emit(ChangePasswordErrorState(
            errorMessage: "Please enter your confirm password."));
      } else if (confirmPasswordValidation(
          event.mdlChangePasswordParam.newPassword ?? "",
          event.mdlChangePasswordParam.confirmPassword ?? "")) {
        emit(ChangePasswordErrorState(
            errorMessage:
                "Please enter password and confirm password are same."));
      } else {
        emit(ChangePasswordSuccessState());
      }
    });
  }
}
