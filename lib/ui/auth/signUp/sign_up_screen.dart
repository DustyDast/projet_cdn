import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projet_cdn/constants.dart';
import 'package:projet_cdn/services/helper.dart';
import 'package:projet_cdn/ui/auth/authentication_bloc.dart';
import 'package:projet_cdn/ui/auth/signUp/sign_up_bloc.dart';
import 'package:projet_cdn/ui/home/home_screen.dart';
import 'package:projet_cdn/ui/loading_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  File? _image;
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  String? firstName, lastName, email, password, confirmPassword;
  AutovalidateMode _validate = AutovalidateMode.disabled;
  bool acceptEULA = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpBloc>(
      create: (context) => SignUpBloc(),
      child: Builder(
        builder: (context) {
          if (Platform.isAndroid) {
            context.read<SignUpBloc>().add(RetrieveLostDataEvent());
          }
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  context.read<LoadingCubit>().hideLoading();
                  if (state.authState == AuthState.authenticated) {
                    pushAndRemoveUntil(
                        context, HomeScreen(user: state.user!), false);
                  } else {
                    showSnackBar(
                        context,
                        state.message ??
                            'Impossible de s\'inscrire, veuillez réessayer.');
                  }
                },
              ),
              BlocListener<SignUpBloc, SignUpState>(
                listener: (context, state) {
                  if (state is ValidFields) {
                    context.read<LoadingCubit>().showLoading(
                        context,
                        'Création d\'un nouveau compte, veuillez patienter...',
                        true);
                    context.read<AuthenticationBloc>().add(
                        SignupWithEmailAndPasswordEvent(
                            emailAddress: email!,
                            password: password!,
                            image: _image,
                            lastName: lastName,
                            firstName: firstName));
                  } else if (state is SignUpFailureState) {
                    showSnackBar(context, state.errorMessage);
                  }
                },
              ),
            ],
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                    color: isDarkMode(context) ? Colors.white : Colors.black),
              ),
              body: SingleChildScrollView(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                child: BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (old, current) =>
                      current is SignUpFailureState && old != current,
                  builder: (context, state) {
                    if (state is SignUpFailureState) {
                      _validate = AutovalidateMode.onUserInteraction;
                    }
                    return Form(
                      key: _key,
                      autovalidateMode: _validate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Créer un nouveau compte',
                            style: TextStyle(
                                color: bot,
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, top: 32, right: 8, bottom: 8),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                BlocBuilder<SignUpBloc, SignUpState>(
                                  buildWhen: (old, current) =>
                                      current is PictureSelectedState &&
                                      old != current,
                                  builder: (context, state) {
                                    if (state is PictureSelectedState) {
                                      _image = state.imageFile;
                                    }
                                    return state is PictureSelectedState
                                        ? SizedBox(
                                            height: 130,
                                            width: 130,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(65),
                                              child: state.imageFile == null
                                                  ? Image.asset(
                                                      'assets/images/placeholder.jpg',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.file(
                                                      state.imageFile!,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 130,
                                            width: 130,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(65),
                                              child: Image.asset(
                                                'assets/images/placeholder.jpg',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                  },
                                ),
                                Positioned(
                                  right: 110,
                                  child: FloatingActionButton(
                                    backgroundColor: bot,
                                    mini: true,
                                    onPressed: () => _onCameraClick(context),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: isDarkMode(context)
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              validator: validateName,
                              onSaved: (String? val) {
                                firstName = val;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: getInputDecoration(
                                  hint: 'Prénom',
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).errorColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              validator: validateName,
                              onSaved: (String? val) {
                                lastName = val;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: getInputDecoration(
                                  hint: 'Nom',
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).errorColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: validateEmail,
                              onSaved: (String? val) {
                                email = val;
                              },
                              decoration: getInputDecoration(
                                  hint: 'E-mail',
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).errorColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              controller: _passwordController,
                              validator: validatePassword,
                              onSaved: (String? val) {
                                password = val;
                              },
                              style:
                                  const TextStyle(height: 0.8, fontSize: 18.0),
                              cursorColor: bot,
                              decoration: getInputDecoration(
                                  hint: 'Mot de passe',
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).errorColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  context.read<SignUpBloc>().add(
                                        ValidateFieldsEvent(_key,
                                            acceptEula: acceptEULA),
                                      ),
                              obscureText: true,
                              validator: (val) => validateConfirmPassword(
                                  _passwordController.text, val),
                              onSaved: (String? val) {
                                confirmPassword = val;
                              },
                              style:
                                  const TextStyle(height: 0.8, fontSize: 18.0),
                              cursorColor: bot,
                              decoration: getInputDecoration(
                                  hint: 'Confirmez le mot de passe',
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).errorColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 40.0, left: 40.0, top: 40.0),
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
                                'S\'inscrire',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () => context.read<SignUpBloc>().add(
                                    ValidateFieldsEvent(_key,
                                        acceptEula: acceptEULA),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ListTile(
                            trailing: BlocBuilder<SignUpBloc, SignUpState>(
                              buildWhen: (old, current) =>
                                  current is EulaToggleState && old != current,
                              builder: (context, state) {
                                if (state is EulaToggleState) {
                                  acceptEULA = state.eulaAccepted;
                                }
                                return Checkbox(
                                  onChanged: (value) =>
                                      context.read<SignUpBloc>().add(
                                            ToggleEulaCheckboxEvent(
                                              eulaAccepted: value!,
                                            ),
                                          ),
                                  activeColor: bot,
                                  value: acceptEULA,
                                );
                              },
                            ),
                            title: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text:
                                        'En créant un compte, vous acceptez nos\n',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                    text: 'Conditions d\'utilisation',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (await canLaunchUrl(
                                            Uri.parse(EULA))) {
                                          await launchUrl(
                                            Uri.parse(EULA),
                                          );
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _onCameraClick(BuildContext context) {
    final action = CupertinoActionSheet(
      title: const Text(
        'Ajouter une photo de profil',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            context.read<SignUpBloc>().add(ChooseImageFromGalleryEvent());
          },
          child: const Text('Choisir depuis la galerie'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            context.read<SignUpBloc>().add(CaptureImageByCameraEvent());
          },
          child: const Text('Prendre une photo'),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
          child: const Text('Annuler'),
          onPressed: () => Navigator.pop(context)),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _image = null;
    super.dispose();
  }
}
