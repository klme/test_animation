import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';
import 'caluculation_class.dart';

/// BLE情報 加速度係数
const double bleMgLSB = 0.0039;

String gssUuid(String code) => '0000$code-0000-1000-8000-00805f9b34fb';


/// BLE情報 サービスUUID
const bleServiceUUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";

/// BLE情報 送信UUID
const bleSendUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

/// BLE情報 通知(受信)UUID
const bleNotifyUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

//最大伝送バイト
const WOODEMI_MTU_WUART = 247;

double deviceX = 0;
double deviceY = 0;
double deviceZ = 0;
double tof = 0;

double headTilt = 0;
double c2c7 = 0;
double c7t3t8 = 0;
double t3t8t12 = 0;
double t8t12l3 = 0;
double t12l3s = 0;

double c2c7sva = 0;

/// 表示中のイラストイメージNo
int imageNo = 5;

final int additionValue = 1;

int messageType = 5;
var angle = [0, 0, 0];
var partScore = [0, 0, 0];
var partDamage = [0, 0, 0];

final Calculator _calculator = new Calculator();
final Coefficients _coefficients = new Coefficients();
enum PostureType { seijyo, nekoze ,funzori}
class DataAcquirementPage extends StatefulWidget {
  final String deviceId;

  DataAcquirementPage(this.deviceId);

  @override
  State<StatefulWidget> createState() {
    return _PeripheralDetailPageState();
  }
}

class _PeripheralDetailPageState extends State<DataAcquirementPage> {
PostureType? _character = PostureType.seijyo;

  int startId = 0;
  @override
  void initState() {
    super.initState();
    QuickBlue.setConnectionHandler(_handleConnectionChange);
    QuickBlue.setServiceHandler(_handleServiceDiscovery);
    QuickBlue.setValueHandler(_handleValueChange);
  }

  @override
  void dispose() {
    super.dispose();
    QuickBlue.setValueHandler(null);
    QuickBlue.setServiceHandler(null);
    QuickBlue.setConnectionHandler(null);
  }

  void _handleConnectionChange(String deviceId, BlueConnectionState state) {
    print('_handleConnectionChange $deviceId, $state');
  }

  void _handleServiceDiscovery(String deviceId, String serviceId, List<String> characteristicIds) {
    print('_handleServiceDiscovery $deviceId, $serviceId, $characteristicIds');
  }
  var receieveValue = [];
  var realTimeValue = [];
  var preDataToF = [];
  var preDataC2C7 = [];
  int id = 0;
  var scrollFlag = true;//スクロールの有無を決める変数
    

  void _handleValueChange(String deviceId, String characteristicId, Uint8List value) {
    setState(() {
      if(scrollFlag==true){
      _scrollController.animateTo(
             _scrollController.position.maxScrollExtent, //最後の要素の指定
            duration:Duration(seconds:1), 
            curve: Curves.easeOut,
       );
      }
      deviceX = _getValue(value[3], value[4]) * bleMgLSB*(-1);
      deviceY = _getValue(value[5], value[6]) * bleMgLSB*(-1);
      deviceZ = -_getValue(value[7], value[8]) * bleMgLSB;
      tof = _getValue(value[9], value[10]);

      if(tof>350){
        tof = 1.2637*tof-66.20;
      }

    _calculator.run(deviceX, deviceY, deviceZ, tof, _coefficients);
    preDataToF.add(tof);
    if(preDataToF.length > 4){
      preDataToF.removeAt(0);
      tof = preDataToF.reduce((value, element) => value+element)/preDataToF.length;
    }
    
    headTilt = _calculator.headTilt;
    c2c7 = _calculator.c2c7;
    preDataC2C7.add(c2c7);
    if(preDataC2C7.length > 4 ){
      preDataC2C7.removeAt(0);
      c2c7 = preDataC2C7.reduce((value, element) => value+element)/preDataC2C7.length;
    }

    c7t3t8 = _calculator.c7t3t8;
    t3t8t12 = _calculator.t3t8t12;
    t8t12l3 = _calculator.t8t12l3;
    t12l3s = _calculator.t12l3s;
    c2c7sva = _calculator.c2c7sva;
    angle[0] = _calculator.c2c7.round();
    angle[1] = _calculator.c7t3t8.round();
    angle[2] = _calculator.t12l3s.round();
    
  var now = DateTime.now();
  var logValue = [
        id.toStringAsFixed(0),
        now,
        deviceX.toStringAsFixed(2),
        deviceY.toStringAsFixed(2),
        deviceZ.toStringAsFixed(2),
        tof.toStringAsFixed(1),
        headTilt.toStringAsFixed(1),
        c2c7.toStringAsFixed(1),
        c7t3t8.toStringAsFixed(1),
        t12l3s.toStringAsFixed(1),
        c2c7sva.toStringAsFixed(1)
      ];
    id++;

    realTimeValue = logValue;
    receieveValue.add(logValue);

    });

    print('_handleValueChange $deviceId, $characteristicId, $value');

  }

  final serviceUUID = TextEditingController(text: bleServiceUUID);
  final characteristicUUID =
      TextEditingController(text: bleNotifyUUID);
  final binaryCode = TextEditingController(
      text: hex.encode([0x01, 0x0A, 0x00, 0x00, 0x00, 0x01]));
 
 var _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('測定モード'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                child: Text('1.接続'),
                onPressed: () {
                  QuickBlue.connect(widget.deviceId);
                },
              ),
              ElevatedButton(
                child: Text('接続解除'),
                onPressed: () {
                  QuickBlue.disconnect(widget.deviceId);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                child: Text('2.サービスを探す'),
                onPressed: () {
                  QuickBlue.discoverServices(widget.deviceId);
                },
              ),
            ],
          ),
          ElevatedButton(
            child: Text('3.データを受信開始'),
            onPressed: (){
              var notify  =  QuickBlue.setNotifiable(widget.deviceId, bleServiceUUID, bleNotifyUUID,BleInputProperty.indication);
              var value = Uint8List.fromList([0x91,0x35]);//コマンド
              QuickBlue.writeValue(widget.deviceId, bleServiceUUID, bleSendUUID,value, BleOutputProperty.withResponse);

            },
          ),
      Column(
      children: <Widget>[
        ListTile(
          title: const Text('正常型'),
          leading: Radio<PostureType>(
            value: PostureType.seijyo,
            groupValue: _character,
            onChanged: (PostureType? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('猫背型'),
          leading: Radio<PostureType>(
            value: PostureType.nekoze,
            groupValue: _character,
            onChanged: (PostureType? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
         ListTile(
          title: const Text('ふん反り返り型'),
          leading: Radio<PostureType>(
            value: PostureType.funzori,
            groupValue: _character,
            onChanged: (PostureType? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
      ],
    ),
          SwitchListTile(
      title: const Text('自動スクロール'),
      value: scrollFlag,
      onChanged:(bool value) {
       if(scrollFlag==false){
        scrollFlag = true;
       }else{
        scrollFlag = false;
      }
       },),
        _buildListView2(),
        Container(height:50),
         _buildViewRealTimeData(),
        ],
      ),
    );
  }

 Widget _buildViewRealTimeData(){
   return Text(realTimeValue.toString(),
   style: TextStyle(
     fontWeight: FontWeight.bold,
     fontSize: 20,
     ));
 }

 Widget _buildListView2() {
    return Expanded(
      child: ListView.separated(
        controller: _scrollController,
        itemBuilder: (context, index) => ListTile(
          title:
              Text(receieveValue[index].toString()),
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount:receieveValue.length,
      ),
    );
  }
  double _getValue(v1, v2) {
    var v = (v1 << 8) | v2;
    var bd = ByteData(2);
    bd.setUint16(0, v);
    var f = bd.getInt16(0, Endian.big);
    return f.toDouble();
  }
  /*_onRadioSelected(value) {
    setState(() {
      _gValue = value;
    });*/
}