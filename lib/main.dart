// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home: MyHomePage(title: "dafsdf"),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

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
  String dataShared = 'No data';
  ChatSocket? socket;
  bool isInitialized = false;
  ColorPreference colorPreference = ColorPreference();

  @override
  void initState() {
    super.initState();
    getSharedText();
  }

  initSocketForAndroid() async {
    var pref = await SharedPreferences.getInstance();
    if (pref.getString("integrationId") != null) {
      await _initchatSocket(pref.getString("integrationId"));
    }
  }

  _initchatSocket(integrationId) async {
    socket = await ChatSocket.getInstance(integrationId);
    colorPreference = socket!.integrationResponse!.metadata!.color!;
    setState(() {
      isInitialized = true;
    });
  }

  Future<void> getSharedText() async {
    var sharedData = await platform.invokeMapMethod('testingSendData');
    if (sharedData != null) {
      var pref = await SharedPreferences.getInstance();
      pref.setString("integrationId", sharedData["integrationId"]);

      await _initchatSocket(pref.getString("integrationId"));
      final connection = await ChatSocketRepository.hasNetwork();
      print("incializando");
      if (socket != null && connection) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                      socket: socket!,
                    ))).then((value) async {
          var prefs = await SharedPreferences.getInstance();
          if (prefs.getBool("cerradoManualmente")! == false) {
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
