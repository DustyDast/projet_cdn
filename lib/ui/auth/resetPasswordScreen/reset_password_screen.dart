import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projet_cdn/constants.dart';
import 'package:projet_cdn/services/helper.dart';
import 'package:projet_cdn/ui/auth/resetPasswordScreen/reset_password_cubit.dart';
import 'package:projet_cdn/ui/loading_cubit.dart';
import '../../../colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String _emailAddress = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResetPasswordCubit>(
      create: (context) => ResetPasswordCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                  color: isDarkMode(context) ? Colors.white : Colors.black),
              elevation: 0.0,
            ),
            body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
              listenWhen: (old, current) => old != current,
              listener: (context, state) {
                if (state is ResetPasswordDone) {
                  context.read<LoadingCubit>().hideLoading();
                  showSnackBar(context, 'Email envoyé');
                  Navigator.pop(context);
                } else if (state is ValidResetPasswordField) {
                  context
                      .read<LoadingCubit>()
                      .showLoading(context, 'Envoi...', false);
                  context
                      .read<ResetPasswordCubit>()
                      .resetPassword(_emailAddress);
                } else if (state is ResetPasswordFailureState) {
                  showSnackBar(context, state.errorMessage);
                }
              },
              buildWhen: (old, current) =>
                  current is ResetPasswordFailureState && old != current,
              builder: (context, state) {
                if (state is ResetPasswordFailureState) {
                  _validate = AutovalidateMode.onUserInteraction;
                }
                return Form(
                  autovalidateMode: _validate,
                  key: _key,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 32.0, right: 16.0, left: 16.0),
                          child: Text(
                            'Resetter le mot de passe',
                            style: TextStyle(
                                color: bot,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 32.0, right: 24.0, left: 24.0),
                          child: TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.done,
                            validator: validateEmail,
                            onFieldSubmitted: (_) => context
                                .read<ResetPasswordCubit>()
                                .checkValidField(_key),
                            onSaved: (val) => _emailAddress = val!,
                            style: const TextStyle(fontSize: 18.0),
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: bot,
                            decoration: getInputDecoration(
                                hint: 'E-mail',
                                darkMode: isDarkMode(context),
                                errorColor: Theme.of(context).errorColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 40.0, left: 40.0, top: 40),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bot,
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: const BorderSide(
                                  color: bot,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Envoyer Email',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () => context
                                .read<ResetPasswordCubit>()
                                .checkValidField(_key),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
