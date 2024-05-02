// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/single_tap.dart';
import '../../model/color_preference.dart';
import '../../model/message_response.dart';
import '../chat_socket.dart';

/*
Message Widget for Button MessageType
 */
class MessageButtons extends StatefulWidget {
  List<MessageResponseData> data;
  final ChatSocket _socket;
  ColorPreference color;

  MessageButtons(this.data, this.color, this._socket, {super.key});

  @override
  State<MessageButtons> createState() => _MessageButtonsState();
}

class _MessageButtonsState extends State<MessageButtons> {
  sendMessage(String text, String title) async {
    var messageSent = await ChatSocket.sendMessage(text, title);
    widget._socket.controller!.sink.add(messageSent);
  }

  bool taped = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return taped == true
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.all(5),
            child: Material(
              color: HexColor(widget.color.chatBackgroundColor.toString()),
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
                        color: HexColor(widget.color.messageBotColor.toString())
                            .withOpacity(1.0),
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(widget.data[0].message ?? '',
                            style: TextStyle(
                                color: HexColor(widget.color.messageClientColor
                                                .toString())
                                            .computeLuminance() >
                                        0.5
                                    ? Colors.white
                                    : Colors.black)),
                        Wrap(
                          alignment: WrapAlignment.end,
                          children: widget.data[0].buttons!
                              .map(
                                (e) => Container(
                                    margin: const EdgeInsets.all(4),
                                    child: SingleTapEventElevatedButton(
                                        dissapear: true,
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(50, 35),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            elevation: 0,
                                            backgroundColor: HexColor(widget
                                                    .color.messageClientColor!)
                                                .withOpacity(0.2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            side: BorderSide(
                                              width: 1.0,
                                              color: HexColor(widget
                                                  .color.messageClientColor!),
                                            )),
                                        onPressed: () {
                                          if (mounted) {
                                            setState(() {
                                              taped = true;
                                            });
                                          }
                                          sendMessage(e.payload!, e.text!);
                                        },
                                        child: Text(
                                          e.text!,
                                          style: TextStyle(
                                            color: HexColor(widget
                                                .color.messageClientColor!),
                                          ),
                                        ))),
                              )
                              .toList(),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                        //   child: Text(
                        //     data[0].message!,
                        //     style: TextStyle(
                        //         fontSize: 15,
                        //         fontWeight: FontWeight.w500,
                        //         color: HexColor(color.messageBotColor.toString())
                        //                     .computeLuminance() >
                        //                 0.5
                        //             ? Colors.black
                        //             : Colors.white),
                        //   ),
                        // ),

                        // SizedBox(
                        // width: size.width,
                        // child: Wrap(
                        //   children: widget.data[0].buttons!
                        //       .map(
                        //         (e) => Container(
                        //             margin: const EdgeInsets.all(5),
                        //             child: SingleTapEventElevatedButton(
                        //                 dissapear: true,
                        //                 style: ElevatedButton.styleFrom(
                        //                     minimumSize: const Size(40, 40),
                        //                     padding: EdgeInsets.zero,
                        //                     elevation: 0,
                        //                     backgroundColor: HexColor(
                        //                             widget.color.messageClientColor!)
                        //                         .withOpacity(0.3),
                        //                     shape: RoundedRectangleBorder(
                        //                       borderRadius:
                        //                           BorderRadius.circular(15.0),
                        //                     ),
                        //                     side: BorderSide(
                        //                       width: 1.0,
                        //                       color: HexColor(
                        //                           widget.color.messageClientColor!),
                        //                     )),
                        //                 onPressed: () {
                        //                   setState(() {
                        //                     taped = true;
                        //                   });
                        //                   sendMessage(e.payload!, e.text!);
                        //                 },
                        //                 child: Text(
                        //                   e.text!,
                        //                   style: TextStyle(
                        //                     color: HexColor(
                        //                         widget.color.messageClientColor!),
                        //                   ),
                        //                 ))),
                        //       )
                        //       .toList(),
                        // )

                        // ListView.builder(
                        //     scrollDirection: Axis.horizontal,
                        //     shrinkWrap: true,
                        //     itemCount: data[0].buttons!.length,
                        //     itemBuilder: (context, indx) {
                        //       return Wrap(
                        //         children: [
                        //           Container(
                        //               margin: const EdgeInsets.all(5),
                        //               padding: const EdgeInsets.symmetric(
                        //                   vertical: 40, horizontal: 5),
                        //               child: SingleTapEventElevatedButton(
                        //                   style: ElevatedButton.styleFrom(
                        //                       elevation: 0,
                        //                       backgroundColor:
                        //                           HexColor(color.messageClientColor!)
                        //                               .withOpacity(0.3),
                        //                       shape: RoundedRectangleBorder(
                        //                         borderRadius: BorderRadius.circular(15.0),
                        //                       ),
                        //                       side: BorderSide(
                        //                         width: 1.0,
                        //                         color: HexColor(color.messageClientColor!),
                        //                       )),
                        //                   onPressed: () {
                        //                     sendMessage(data[0].buttons![indx].payload!,
                        //                         data[0].buttons![indx].text!);
                        //                   },
                        //                   child: Text(data[0].buttons![indx].text!,
                        //                       style: TextStyle(
                        //                         color: HexColor(color.messageClientColor!),
                        //                       )))),
                        //         ],
                        //       );
                        //     })

                        //  data[0].buttons!.length > 4
                        //     ? GridView.builder(
                        //         scrollDirection: Axis.horizontal,
                        //         gridDelegate:
                        //             const SliverGridDelegateWithMaxCrossAxisExtent(
                        //                 maxCrossAxisExtent: 75,
                        //                 childAspectRatio: 3 / 2,
                        //                 crossAxisSpacing: 5,
                        //                 mainAxisSpacing: 5),
                        //         shrinkWrap: true,
                        //         itemCount: data[0].buttons!.length,
                        //         itemBuilder: (context, indx) {
                        //           return Container(
                        //               margin: const EdgeInsets.all(5),
                        //               // padding:
                        //               //     const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        //               child: SingleTapEventElevatedButton(
                        //                   style: ElevatedButton.styleFrom(
                        //                       elevation: 0,
                        //                       backgroundColor:
                        //                           HexColor(color.messageClientColor!)
                        //                               .withOpacity(0.2),
                        //                       shape: RoundedRectangleBorder(
                        //                         borderRadius: BorderRadius.circular(15.0),
                        //                       ),
                        //                       side: BorderSide(
                        //                         width: 1.0,
                        //                         color: HexColor(color.messageClientColor!)
                        //                             .withOpacity(0.8),
                        //                       )),
                        //                   onPressed: () {
                        //                     sendMessage(data[0].buttons![indx].payload!,
                        //                         data[0].buttons![indx].text!);
                        //                   },
                        //                   child: Text(data[0].buttons![indx].text!,
                        //                       style: TextStyle(
                        //                         color: HexColor(color.messageClientColor!),
                        //                       ))));
                        //         },
                        //       )
                        //     : SizedBox(
                        //         child: ListView.builder(
                        //           scrollDirection: Axis.horizontal,
                        //           shrinkWrap: true,
                        //           itemCount: data[0].buttons!.length,
                        //           itemBuilder: (context, indx) {
                        //             return Container(
                        //                 margin: const EdgeInsets.all(5),
                        //                 padding: const EdgeInsets.symmetric(
                        //                     vertical: 40, horizontal: 5),
                        //                 child: SingleTapEventElevatedButton(
                        //                     style: ElevatedButton.styleFrom(
                        //                         elevation: 0,
                        //                         backgroundColor:
                        //                             HexColor(color.messageClientColor!)
                        //                                 .withOpacity(0.3),
                        //                         shape: RoundedRectangleBorder(
                        //                           borderRadius: BorderRadius.circular(15.0),
                        //                         ),
                        //                         side: BorderSide(
                        //                           width: 1.0,
                        //                           color:
                        //                               HexColor(color.messageClientColor!),
                        //                         )),
                        //                     onPressed: () {
                        //                       sendMessage(data[0].buttons![indx].payload!,
                        //                           data[0].buttons![indx].text!);
                        //                     },
                        //                     child: Text(data[0].buttons![indx].text!,
                        //                         style: TextStyle(
                        //                           color:
                        //                               HexColor(color.messageClientColor!),
                        //                         ))));
                        //           },
                        //         ),
                        //       )

                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
