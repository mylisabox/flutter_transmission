import 'package:flutter/material.dart';
import 'package:flutter_transmission/flutter_transmission.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return TransmissionScope(
      baseUrl: 'http://192.168.1.35:9091/transmission/rpc',
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TransmissionScreen(),//or directly TransmissionScreen(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transmission'),
        actions: <Widget>[
          RealTimeActionButton(),
        ],
      ),
      body: TorrentList(),
      bottomNavigationBar: Container(
        child: TransmissionStatusBar(),
        color: Theme.of(context).primaryColor,
      ),
      floatingActionButton: AddTorrentActionButton(
        isFloatingButton: true,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
