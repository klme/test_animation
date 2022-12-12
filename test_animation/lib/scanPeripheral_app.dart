import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:quick_blue/quick_blue.dart';
import 'displayseboneDamage_app.dart';

class scanApp extends StatefulWidget {
  @override
  _scanAppState createState() => _scanAppState();
}

class _scanAppState extends State<scanApp> {
  StreamSubscription<BlueScanResult>? _subscription;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      QuickBlue.setLogger(Logger('hoge'));
    }
    _subscription = QuickBlue.scanResultStream.listen((result) {
      if (!_scanResults.any((r) => r.deviceId == result.deviceId)) {
        setState(() => _scanResults.add(result));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('スキャンモード'),
        ),
        body: Column(
          children: [
            FutureBuilder(
              future: QuickBlue.isBluetoothAvailable(),
              builder: (context, snapshot) {
                var available = snapshot.data?.toString() ?? '...';
                if(available == "true"){
                  return Text('Bluetoothが利用できる状態です。');
                }else{
                  return Text('Bluetoothが利用できない状態です。お使いのPCのBluetoothの設定を確認してください。');
                }

              },
            ),
            _buildButtons(),
            Divider(
              color: Colors.blue,
            ),
            _buildListView(),
            _buildPermissionWarning(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          child: Text('SCAN開始'),
          onPressed: () {
            QuickBlue.startScan();
          },
        ),
        ElevatedButton(
          child: Text('SCAN停止'),
          onPressed: () {
            QuickBlue.stopScan();
          },
        ),
      ],
    );
  }

  var _scanResults = <BlueScanResult>[];
  var _scrollController = ScrollController();

  Widget _buildListView() {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (context, index) => ListTile(
          title:
              Text('${_scanResults[index].name}(${_scanResults[index].rssi})'),
          subtitle: Text(_scanResults[index].deviceId),
          onTap: () {
            QuickBlue.stopScan();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DataAcquirementPage(_scanResults[index].deviceId),
                ));
          },
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount: _scanResults.length,
      ),
    );
  }

  Widget _buildPermissionWarning() {
    if (Platform.isAndroid) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Text('BLUETOOTH_SCAN/ACCESS_FINE_LOCATION needed'),
      );
    }
    return Container();
  }


}
