// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/single_tap.dart';
import '../../model/color_preference.dart';
import '../../model/message.dart';
import '../../model/message_response.dart';
import '../chat_socket.dart';

/*
Message Widget for Button MessageType
 */
class MessageButtons extends StatelessWidget {
  Message message;
  String imageUrl;
  List<MessageResponseData> data;
  final ChatSocket _socket;
  ColorPreference color;

  MessageButtons(
      this.message, this.imageUrl, this.data, this.color, this._socket,
      {super.key});

  sendMessage(String text, String title) async {
    var messageSent = await ChatSocket.sendMessage(text, title);
    _socket.controller!.sink.add(messageSent);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment:
          (!message.isUser!) ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isUser!)
              SizedBox(
                width: 30,
                height: 30,
                child: CircleAvatar(
                  onBackgroundImageError: (exception, stackTrace) {
                    if (kDebugMode) {
                      print("No Image loaded");
                    }
                  },
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Material(
                color: HexColor(color.chatBackgroundColor.toString()),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                        maxWidth: size.width * 0.8,
                        minHeight: 10,
                        maxHeight: size.height * 0.6,
                        minWidth: 10,
                      ),
                      decoration: BoxDecoration(
                          color: HexColor(color.messageBotColor.toString())
                              .withOpacity(1.0),
                          borderRadius: BorderRadius.only(
                              topRight: !message.isUser!
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0),
                              bottomLeft: message.isUser!
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0),
                              topLeft: const Radius.circular(10),
                              bottomRight: const Radius.circular(10))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: message.isUser!
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(data[0].message ?? '',
                              style: TextStyle(
                                  color: HexColor(color.messageClientColor
                                                  .toString())
                                              .computeLuminance() >
                                          0.5
                                      ? Colors.white
                                      : Colors.black)),
                          Wrap(
                            alignment: WrapAlignment.end,
                            children: data[0]
                                .buttons!
                                .map(
                                  (button) => Container(
                                      margin: const EdgeInsets.all(4),
                                      child: SingleTapEventElevatedButton(
                                          // dissapear: true,
                                          style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(50, 35),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              elevation: 0,
                                              backgroundColor: HexColor(
                                                      color.messageClientColor!)
                                                  .withOpacity(0.2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              side: BorderSide(
                                                width: 1.0,
                                                color: HexColor(
                                                    color.messageClientColor!),
                                              )),
                                          onPressed: () {
                                            if (button.type == 'link') {
                                              launchUrl(Uri.parse(button.uri!));
                                            } else {
                                              sendMessage(button.payload!,
                                                  button.text!);
                                            }
                                          },
                                          child: Text(
                                            button.text!,
                                            style: TextStyle(
                                              color: HexColor(
                                                  color.messageClientColor!),
                                            ),
                                          ))),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
