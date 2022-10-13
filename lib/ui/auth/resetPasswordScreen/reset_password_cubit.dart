import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:projet_cdn/services/authenticate.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordInitial());

  resetPassword(String email) async {
    await FireStoreUtils.resetPassword(email);
    emit(ResetPasswordDone());
  }

  checkValidField(GlobalKey<FormState> key) {
    if (key.currentState?.validate() ?? false) {
      key.currentState!.save();
      emit(ValidResetPasswordField());
    } else {
      emit(ResetPasswordFailureState(errorMessage: 'Addresse Email invalide'));
    }
  }
}
