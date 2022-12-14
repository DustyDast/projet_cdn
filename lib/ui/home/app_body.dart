import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:projet_cdn/ui/home/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../colors.dart';

class AppBody extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final Function sendMessage;

  const AppBody({Key? key, this.messages = const [], required this.sendMessage})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, i) {
        var obj = messages[messages.length - 1 - i];
        Message message = obj['message'];
        bool isUserMessage = obj['isUserMessage'] ?? false;
        return Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MessageContainer(
              message: message,
              isUserMessage: isUserMessage,
              sendMessage: sendMessage,
            ),
          ],
        );
      },
      separatorBuilder: (_, i) => Container(height: 10),
      itemCount: messages.length,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
    );
  }
}

class _MessageContainer extends StatelessWidget {
  final Message message;
  final bool isUserMessage;
  final Function sendMessage;

  const _MessageContainer(
      {Key? key,
      required this.message,
      this.isUserMessage = false,
      required this.sendMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: LayoutBuilder(
        builder: (context, constrains) {
          switch (message.type) {
            case MessageType.quickReply:
              return _QuickRepliesContainer(
                qReplies: message.quickReplies!,
                sendMessage: sendMessage,
              );
            case MessageType.card:
              return _CardContainer(
                  card: message.card!, sendMessage: sendMessage);
            case MessageType.text:
            default:
              return Container(
                decoration: BoxDecoration(
                  color: isUserMessage ? Colors.blue : bot,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Text(
                  message.text?.text?[0] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _QuickRepliesContainer extends StatelessWidget {
  final QuickReplies qReplies;
  final Function sendMessage;

  const _QuickRepliesContainer(
      {Key? key, required this.qReplies, required this.sendMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bot,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  qReplies.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Divider(
                  height: 15,
                ),
                if (qReplies.quickReplies?.isNotEmpty ?? false)
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 40,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      // padding: const EdgeInsets.symmetric(vertical: 5),
                      itemBuilder: (context, i) {
                        //CardButton button = quickReplies.quickReplies![i];
                        return TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(qReplies.quickReplies![i]),
                          onPressed: () {
                            sendMessage(qReplies.quickReplies![i]);
                          },
                        );
                      },
                      separatorBuilder: (_, i) => Container(width: 10),
                      itemCount: qReplies.quickReplies!.length,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final DialogCard card;
  final Function sendMessage;

  const _CardContainer(
      {Key? key, required this.card, required this.sendMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.title! == "Toyota Corolla 2018") {
      const String separateur = "=-=";
      var elements = [];
      var lePrix = '';
      var leKm = '';
      var laDescription = '';
      var leNumero = [' '];
      var lEmail = '';
      var leMessage =
          "Bonjour,\nJe suis int??ress?? par votre annonce pour\n${card.title!}";
      elements = card.subtitle!.split(separateur);
      lePrix = elements[0];
      leKm = elements[1];
      laDescription = elements[2];
      leNumero = [elements[3]];
      lEmail = elements[4];

      return Card(
        color: bot,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.imageUri != null)
              Container(
                constraints: const BoxConstraints.expand(height: 150),
                child: Image.network(
                  card.imageUri!,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.title ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (card.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Prix: $lePrix CAD',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Kilom??trage: ${leKm}km',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Description: $laDescription',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (card.buttons?.isNotEmpty ?? false)
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 40,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        // padding: const EdgeInsets.symmetric(vertical: 5),
                        itemBuilder: (context, i) {
                          CardButton button = card.buttons![i];

                          return TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(button.text ?? ''),
                            onPressed: () {
                              void contact = i == 0
                                  ? launchEmail(
                                      toEmail: lEmail,
                                      subject: card.title!,
                                      message: leMessage)
                                  : envoiSMS(leMessage, leNumero);
                              contact;
                            },
                          );
                        },
                        separatorBuilder: (_, i) => Container(width: 10),
                        itemCount: card.buttons!.length,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      print(card);
      return Card(
        color: bot,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.imageUri != null)
              Container(
                constraints: const BoxConstraints.expand(height: 150),
                child: Image.network(
                  card.imageUri!,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                constraints: const BoxConstraints.expand(height: 150),
                child: Image.network(
                  'https://www.seekpng.com/png/detail/89-896670_old-classic-cars-silhouette-classic-car-silhouette-png.png',
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.title ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (card.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        card.subtitle!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  if (card.buttons?.isNotEmpty ?? false)
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 40,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        // padding: const EdgeInsets.symmetric(vertical: 5),
                        itemBuilder: (context, i) {
                          CardButton button = card.buttons![i];
                          return TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(button.text ?? ''),
                            onPressed: () {
                              sendMessage(button.postback);
                            },
                          );
                        },
                        separatorBuilder: (_, i) => Container(width: 10),
                        itemCount: card.buttons!.length,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  void envoiSMS(String msg, List<String> list_receipents) async {
    String send_result =
        await sendSMS(message: msg, recipients: list_receipents)
            .catchError((err) {
      print(err);
    });
    print(send_result);
  }

  Future launchEmail({
    required String toEmail,
    required String subject,
    required String message,
  }) async {
    final Uri url = Uri.parse(
        'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('error');
    }
  }
}
