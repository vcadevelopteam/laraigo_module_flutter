// ignore_for_file: library_private_types_in_public_api, must_be_immutable, use_key_in_widget_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/message_type.dart';
import '../../helpers/sender_type.dart';
import '../../helpers/util.dart';
import '../../model/color_preference.dart';
import '../../model/icons_preference.dart.dart';
import '../../model/message.dart';
import '../../model/message_response.dart';
import '../../model/personalization.dart';
import '../../repository/chat_socket_repository.dart';
import '../chat_socket.dart';
import '../widget/message_input.dart';
import '../widget/messages_area.dart';

class ChatPage extends StatefulWidget {
  String customMessage;
  ChatPage({required this.socket, this.customMessage = ""});

  final ChatSocket socket;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> messages = [];
  bool visible = true;
  bool isClosed = false;
  bool hasConnection = true;
  var messagesCount = [];

  final f = DateFormat('dd/mm/yyyy');
  ScrollController? scrollController;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initSocket();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => checkConnection(t));
  }

  checkConnection(Timer t) async {
    if (kDebugMode) {
      print("Checking connection");
    }
    setState(() {
      Utils.hasNetwork().then((value) async {
        hasConnection = value;
        if (hasConnection && isClosed == true) {
          widget.socket.disconnect();

          await Future.delayed(const Duration(seconds: 3));
          await initSocket();
          setState(() {
            isClosed = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    disposeSocket();
    super.dispose();
  }

  disposeSocket() async {
    widget.socket.disconnect();
  }

  initSocket() async {
    try {
      await widget.socket.connect().onError((error, stackTrace) {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('Error de conexión'),
              content: Text(
                  'Por favor verifique su conexión de internet e intentelo nuevamente'),
            );
          },
        );
      });
      await initChat();
      await fillWithChatHistory();
      await sendCustomMessage(widget.customMessage);
    } catch (exception, _) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('Error general'),
              content: Text(
                  'Por favor verifique su conexión de internet e intentelo nuevamente'),
            );
          },
        );
      }
    }
  }

  sendCustomMessage(String customMessage) async {
    var savedMessages = await ChatSocketRepository.getLocalMessages();
    if (savedMessages.isEmpty) {
      if (customMessage.isNotEmpty) {
        var response = await ChatSocketRepository.sendMessage(
            customMessage, "null", MessageType.text);

        if (response.statusCode != 500 || response.statusCode != 400) {
          List<MessageResponseData> data = [];
          data.add(MessageResponseData(
            message: customMessage,
          ));
          var messageSent = MessageResponse(
                  type: MessageType.text.name,
                  isUser: true,
                  error: false,
                  message: MessageSingleResponse(
                      createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
                      data: data,
                      type: MessageType.text.name,
                      id: const Uuid().v4().toString()),
                  receptionDate: DateTime.now().toUtc().millisecondsSinceEpoch)
              .toJson();

          setState(() {
            widget.socket.controller!.sink.add(messageSent);
          });
        }
      }
    }
  }

  fillWithChatHistory() async {
    //change state to update stream
    setState(() {});
    //Setea el estado para actualizar el stream a que responda

    var savedMessages = await ChatSocketRepository.getLocalMessages();
    //add messages list
    //Agrega una lista de mensajes
    widget.socket.controller!.sink.add(savedMessages);
  }

  initChat() async {
    try {
      widget.socket.channel!.stream.listen((event) async {
        var decodedJson = jsonDecode(event);
        decodedJson['sender'] = SenderType.chat.name;
        widget.socket.controller!.sink.add(decodedJson);
      }, onDone: () async {
        if (kDebugMode) {
          print("Socket cerrado");
        }
        if (mounted) {
          setState(() {
            hasConnection = false;
            isClosed = true;
          });
        }

        // prefs.setBool("cerradoManualmente", false);
      }, onError: (error, stacktrace) async {
        setState(() {
          hasConnection = false;
          isClosed = true;
        });
      });

      await Future.delayed(const Duration(milliseconds: 50));
      var messagesCount = await ChatSocketRepository.getLocalMessages();
      // if (messagesCount.isNotEmpty) {
      //   // scrollDown();
      // }
    } catch (exception) {
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return const AlertDialog(
      //       title: Text('Error de conexión'),
      //       content: Text(
      //           'Por favor verifique su conexión de internet e intentelo nuevamente'),
      //     );
      //   },
      // );
      setState(() {
        hasConnection = false;
        isClosed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //identify properties to customize the chat screen
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    var padding = MediaQuery.of(context).viewPadding;
    ColorPreference colorPreference =
        widget.socket.integrationResponse!.metadata!.color!;
    Color backgroundColor =
        HexColor(colorPreference.chatBackgroundColor.toString());
    IconsPreference headerIcons =
        widget.socket.integrationResponse!.metadata!.icons!;
    Personalization header =
        widget.socket.integrationResponse!.metadata!.personalization!;
    Color textColor =
        backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    double finalHeight = Platform.isAndroid
        ? screenHeight - padding.bottom - padding.top
        : screenHeight - padding.top;

    return WillPopScope(
      onWillPop: () async {
        try {
          if (widget.socket.channel != null) {
            await widget.socket.channel!.sink.close();
          }
          return true;
        } catch (ex) {
          return true;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            bottom: !hasConnection
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(30),
                    child: Container(
                        width: double.infinity,
                        height: 30,
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const Text(
                          "Sin conexión",
                          style: TextStyle(color: Colors.grey),
                        )))
                : null,
            automaticallyImplyLeading: false,
            // iconTheme:
            //     IconThemeData(color: HexColor(colorPreference.iconsColor!)),
            backgroundColor:
                HexColor(colorPreference.chatHeaderColor.toString()),
            title: Row(
              children: [
                CircleAvatar(
                  onBackgroundImageError: (exception, stackTrace) {
                    if (kDebugMode) {
                      print("No Image loaded");
                    }
                  },
                  backgroundImage: NetworkImage(headerIcons.chatHeaderImage!),
                  backgroundColor:
                      HexColor(colorPreference.chatHeaderColor.toString()),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      header.headerTitle.toString().toUpperCase(),
                      style: TextStyle(
                          fontSize: 19,
                          color: textColor,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    if (header.headerSubtitle != null &&
                        header.headerSubtitle!.length > 5)
                      Text(header.headerSubtitle.toString(),
                          style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              fontWeight: FontWeight.w400))
                  ],
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  try {
                    if (widget.socket.channel != null) {
                      await widget.socket.channel!.sink.close();
                    }

                    // ignore: use_build_context_synchronously
                    SystemNavigator.pop();
                    // Navigator.of(context).pop();
                  } catch (ex) {
                    SystemNavigator.pop();
                    // Navigator.of(context).pop();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  // decoration: BoxDecoration(
                  //   color: HexColor('#8c8c8e'),

                  //   //  HexColor(colorPreference.messageBotColor!)
                  //   //             .computeLuminance() >
                  //   //         0.5
                  //   //     ? Colors.black
                  //   //     : Colors.white,
                  //   //      // border color

                  //   shape: BoxShape.circle,
                  // ),
                  child: Icon(
                    Icons.cancel_rounded,
                    color: HexColor('#8c8c8e'),
                    size: 25,
                  ),
                ),
              ),
            ],
            elevation: 0,
            centerTitle: false,
          ),
          backgroundColor:
              HexColor(colorPreference.chatBackgroundColor.toString()),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            child: Container(
              height: finalHeight,
              decoration: BoxDecoration(color: backgroundColor),
              child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 10,
                        child: Container(
                          child: widget.socket.channel != null
                              ? MessagesArea(widget.socket)
                              : Container(),
                        ),
                      ),
                      //send socket information to MessageInput component
                      MessageInput(widget.socket)
                    ],
                  )),
            ),
          )),
    );
  }
}
