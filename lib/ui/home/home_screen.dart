import 'dart:math';

import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projet_cdn/constants.dart';
import 'package:projet_cdn/model/user.dart';
import 'package:projet_cdn/services/helper.dart';
import 'package:projet_cdn/ui/auth/authentication_bloc.dart';
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
                  'Sortir',
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
            'Auto Bot',
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

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });
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

