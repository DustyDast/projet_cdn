import 'dart:io';
import 'dart:math';

import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projet_cdn/constants.dart';
import 'package:projet_cdn/model/user.dart';
import 'package:projet_cdn/services/helper.dart';
import 'package:projet_cdn/ui/auth/authentication_bloc.dart';
import 'package:projet_cdn/ui/auth/signUp/sign_up_bloc.dart';
import 'package:projet_cdn/ui/auth/welcome/welcome_screen.dart';
import 'package:projet_cdn/ui/home/app_body.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late User user;
  late DialogFlowtter dialogFlowtter;
  late DialogAuthCredentials credentials;
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    DialogFlowtter.fromFile(
            path: "assets/dialog_flow_auth.json", sessionId: user.userID)
        .then((instance) => dialogFlowtter = instance);
  }

//test
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const WelcomeScreen(), false);
        }
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(COLOR_PRIMARY),
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.black),
                ),
                leading: Transform.rotate(
                    angle: pi / 1,
                    child: const Icon(Icons.exit_to_app, color: Colors.black)),
                onTap: () {
                  context.read<AuthenticationBloc>().add(LogoutEvent());
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text(
            'Home',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(child: AppBody(messages: messages)),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              color: Colors.blue,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      addMessage(
        Message(text: DialogText(text: [text])),
        true,
      );
    });

    //dialogFlowtter.projectId = "projet-integrateur-37b6f";

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text, languageCode: 'fr')),
    );

    if (response.message == null) return;
    setState(() {
      addMessage(response.message!);
    });
  }

  void addMessage(Message message, [bool isUserMessage = false]) async {
    if (message.text.toString() == 'DialogText([**UPLOAD USER IMAGE**])') {
      message.text!.text![0] = await uploadImage();
      messages.add({
        'message': message,
        'isUserMessage': true,
      });
    } else {
      messages.add({
        'message': message,
        'isUserMessage': isUserMessage,
      });
    }
  }

  Future<String> uploadImage() async {
    Reference storage = FirebaseStorage.instance.ref();
    ImagePicker imagePicker = ImagePicker();
    XFile? xImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xImage != null) {
      File image = File(xImage.path);
      Reference upload = storage.child("images/cars/${user.userID}.jpeg");
      UploadTask uploadTask = upload.putFile(image);
      var downloadUrl =
          await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
      return downloadUrl.toString();
    }
    String defaultUrl =
        'https://firebasestorage.googleapis.com/v0/b/projetintegrateurv2.appspot.com/o/images%2Fpexels-mike-b-112460.jpg?alt=media&token=55503f6c-f77b-4591-9ca2-33c4cd58be8a';
    return defaultUrl;
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }
}

//     body: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.max,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           user.profilePictureURL == ''
//               ? CircleAvatar(
//                   radius: 35,
//                   backgroundColor: Colors.grey.shade400,
//                   child: ClipOval(
//                     child: SizedBox(
//                       width: 70,
//                       height: 70,
//                       child: Image.asset(
//                         'assets/images/placeholder.jpg',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 )
//               : displayCircleImage(user.profilePictureURL, 80, false),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(user.fullName()),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(user.email),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(user.userID),
//           ),
//         ],
//       ),
//     ),
//   ),
// );
