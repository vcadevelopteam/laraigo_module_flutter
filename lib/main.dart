// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:laraigo_chat_module/core/widget/socket_elevated_button.dart';
import 'package:laraigo_chat_module/repository/chat_socket_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/chat_socket.dart';
import 'core/pages/chat_page.dart';
import 'helpers/utils.dart';
import 'model/color_preference.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const MyHomePage(title: "dafsdf"),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('laraigo_chat_communication_channel');
  static const _basicMessageChannel = BasicMessageChannel<dynamic>(
    'laraigo_chat_communication_channel',
    StandardMessageCodec(),
  );
  String? integrationId;
  String? customMessage;
  String dataShared = 'No data';
  ChatSocket? socket;
  bool isInitialized = false;
  ColorPreference colorPreference = ColorPreference();

  @override
  void initState() {
    super.initState();
    executeChannelByDevice();
    // _listenBasicMessageChannel();
    // getSharedText();
  }

  Future<void> executeChannelByDevice() async {
    if (Platform.isAndroid) _listenPlatformChannel();
    if (Platform.isIOS) _listenBasicMessageChannel();
  }

  // Method to access the platform channel - Android
  Future<void> _listenPlatformChannel() async {
    final sharedData =
        await platform.invokeMapMethod<String, String>('testingSendData');
    print('PlatformChannel init: $sharedData');

    if (sharedData != null) {
      setState(() {
        integrationId = sharedData['integrationId'];
        customMessage = sharedData['customMessage'];
      });

      final Map<String, String> customMap = {
        "integrationId": integrationId!,
        "customMessage": customMessage ?? '',
      };

      getSharedText(customMap);
    } else {
      print('ERROR-Android Execution');
      throw PlatformException(
          code: 'Error', message: 'Fallo de carga de datos', details: null);
    }
  }

  // Method to access the basic message channel - iOS
  Future<void> _listenBasicMessageChannel() async {
    _basicMessageChannel.setMessageHandler((message) async {
      print('BasicMessageChannel init: $message');
      if (message != null) {
        setState(() {
          integrationId = message['integrationId'] as String;
          customMessage = message['customMessage'] as String;
        });

        final Map<String, String> customMap = {
          "integrationId": integrationId!,
          "customMessage": customMessage ?? '',
        };
        print('BasicMessageChannel final: $customMap');

        getSharedText(customMap);
      } else {
        print('ERROR-iOS Execution');
        throw PlatformException(
            code: 'Error', message: 'Fallo de carga de datos', details: null);
      }
    });
  }

  _initchatSocket(integrationId) async {
    socket = await ChatSocket.getInstance(integrationId);
    colorPreference = socket!.integrationResponse!.metadata!.color!;
    setState(() {
      isInitialized = true;
    });
  }

  Future<void> getSharedText(Map<String, String>? sharedData) async {
    if (sharedData != null) {
      var pref = await SharedPreferences.getInstance();
      pref.setString("integrationId", sharedData["integrationId"]!);
      pref.setString("customMessage", sharedData["customMessage"] ?? '');

      print('Antes del socket...');
      await _initchatSocket(pref.getString("integrationId"));
      final connection = await ChatSocketRepository.hasNetwork();
      print("incializando... | connection-state: $connection");
      if (socket != null && connection) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                      socket: socket!,
                      customMessage: pref.getString("customMessage") ?? '',
                    ))).then((value) async {
          var prefs = await SharedPreferences.getInstance();
          if (prefs.getBool("cerradoManualmente") != null) {
            if (prefs.getBool("cerradoManualmente") == false) {
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
            }
          }
          SystemNavigator.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
