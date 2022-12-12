import 'package:flutter/material.dart';
import 'util/date_helper.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'calculation_class.dart';
import 'model_constans.dart';  
import 'rive_class.dart';
import 'util/display_helper.dart';

/// BLE情報 加速度係数
const double bleMgLSB = 0.0039;

String gssUuid(String code) => '0000$code-0000-1000-8000-00805f9b34fb';

/// BLE情報 サービスUUID
const bleServiceUUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";

/// BLE情報 送信UUID
const bleSendUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

/// BLE情報 通知(受信)UUID
const bleNotifyUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";


double deviceX = 0;
double deviceY = 0;
double deviceZ = 0;
double tof = 0;

double headTilt = 0;
double c2c7 = 0;
double c7t3t8 = 0;
double t12l3s = 0;
double c2c7sva = 0;

/// 表示中のイラストイメージNo
int imageNo = 1;
final int additionValue = 1;

int messageType = 1;
var angle = [0, 0, 0];
var partScore = [0, 0, 0];
var partDamage = [0, 0, 0];

/// RiveAnimation関連
final imageMaxCount = 13;
final riveFilePath = 'assets/rivs/shisei.riv';

/// Riveファイルがロードされたか
late bool isRiveFileLoaded = false;

late Artboard artBoard;


/// Rive Animation 定数
const String StateMachine = 'State Machine Master';
const String NormalNeck = 'NormalNeck';
const String DamageNeck = 'DamageNeck';
const String NormalBack = 'NormalBack';
const String DamageBack = 'DamageBack';
const String NormalWaist = 'NormalWaist';
const String DamageWaist = 'DamageWaist';
const String NeckGlowOFF = 'NeckGlowOFF';
const String NeckGlowON = 'NeckGlowON';
const String BackGlowOFF = 'BackGlowOFF';
const String BackGlowON = 'BackGlowON';
const String WaistGlowOFF = 'WaistGlowOFF';
const String WaistGlowON = 'WaistGlowON';
const String NeckEffectOFF = 'NeckEffectOFF';
const String NeckEffectFlash = 'NeckEffectFlash';
const String BackEffectOFF = 'BackEffectOFF';
const String BackEffectFlash = 'BackEffectFlash';
const String WaistEffectOFF = 'WaistEffectOFF';
const String WaistEffectFlash = 'WaistEffectFlash';

  /// NormalMovementカスタムコントローラー
late NormalMovementController _normalMovementController;

  /// ダメージ色変更エフェクトOFFトリガー
List<SMITrigger> _damageEffectOFFTriggerList = <SMITrigger>[];

/// ダメージ色変更エフェクトONトリガー
List<SMITrigger> _damageEffectONTriggerList = <SMITrigger>[];

/// グローエフェクトONトリガー
List<SMITrigger> _glowEffectONTriggerList = <SMITrigger>[];

/// グローエフェクトOFFトリガー
List<SMITrigger> _glowEffectOFFTriggerList = <SMITrigger>[];

/// 稲妻エフェクトOFFトリガー
List<SMITrigger> _lightningEffectOFFTriggerList = <SMITrigger>[];

/// 稲妻エフェクトONトリガー
List<SMITrigger> _lightningEffectONTriggerList = <SMITrigger>[];

/// 稲妻エフェクトフラグ
List<bool> isLightningEffect = [];

/// 背骨ダメージアラートフラグ
List<bool> isAlertEffect = [];

/// 背骨ダメージエフェクトの直筋の発火時間
late int latestFireTime;

/// アニメーションを発火させるインターバル
final int animationInterval = 2;

final SeboneData _seboneData = new SeboneData();


class DataAcquirementPage extends StatefulWidget {
  final String deviceId;

  DataAcquirementPage(this.deviceId);

  @override
  State<StatefulWidget> createState() {
    return _DataAcquirementPageState();
  }
}

class _DataAcquirementPageState extends State<DataAcquirementPage> {

  bool pressOn = false;
  @override
  void initState() {
    loadRiveFile();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

  }
    messageType = 2;
    drawNeckLightningEffect(messageType);
    drawLightningEffect(1, angle[1]);
    drawLightningEffect(2, angle[2]);
    drawDamageAlertEffect(100, 0);
    drawDamageAlertEffect(100, 1);
    drawDamageAlertEffect(100, 2);
    
  }

  toMove(int index) {
    _normalMovementController.toMove(index);
  }
// アラート文言：メッセージテキストゲッター
  getMessageText() {
    var message = "";
    message = IllustrationKeys.message[messageType - 1];
    return message;
  }

double getDamage(int ix) {
    return partDamage[ix] / 1000;
  }



  drawDamageAlertEffect(double damageRate, int index) {
    if (isAlertEffect[index] == false) {
      if (getDamage(index) > damageRate) {
        var now = DateTime.now();
        if (DateHelper.dateTimeToEpoch(now) >
            (latestFireTime + animationInterval)) {
          isAlertEffect[index] = true;
          latestFireTime = DateHelper.dateTimeToEpoch(now);
          _damageEffectONTriggerList[index].fire();
          _glowEffectONTriggerList[index].fire();
        }
      }
    }
  }

  int eCnt = 1000;
/// 首稲妻エフェクト描画
  drawNeckLightningEffect(messageType) {
    if (isLightningEffect[0] == false) {
      if (messageType == 1) {
        eCnt++;
        if(eCnt>60){
        _lightningEffectONTriggerList[0].fire();
        _damageEffectONTriggerList[0].fire();
        _glowEffectONTriggerList[0].fire();
        isLightningEffect[0] = true;
        }else{
          _lightningEffectOFFTriggerList[0].fire();
          _damageEffectOFFTriggerList[0].fire();
          _glowEffectOFFTriggerList[0].fire();
          isLightningEffect[0] = false;
        }
      }
    } else {
      if (messageType != 1) {
        _lightningEffectOFFTriggerList[0].fire();
        _damageEffectOFFTriggerList[0].fire();
        _glowEffectOFFTriggerList[0].fire();
        isLightningEffect[0] = false;
        eCnt = eCnt -10;
      }
    }
  }

 //ここを変更
  var wcnt = [50,50,50];

  /// 背中、腰稲妻エフェクト描画
  void drawLightningEffect(int index, int angle) {
    if (isLightningEffect[index] == false) {
      if (!_seboneData.isInSafeZoneRange(index, angle)) {
        wcnt[index]++;
        if(wcnt[index]>30){
        _lightningEffectONTriggerList[index].fire();
        _damageEffectONTriggerList[index].fire();
        _glowEffectONTriggerList[index].fire();
        isLightningEffect[index] = true;
        }
      } else {
        if(wcnt[index]>0){
          wcnt[index]= wcnt[index] - 10;
        }
        
        _lightningEffectOFFTriggerList[index].fire();
        _damageEffectOFFTriggerList[index].fire();
        _glowEffectOFFTriggerList[index].fire();
      }
    } else {
      if (_seboneData.isInSafeZoneRange(index, angle)) {
        _lightningEffectOFFTriggerList[index].fire();
        _damageEffectOFFTriggerList[index].fire();
        _glowEffectOFFTriggerList[index].fire();
        isLightningEffect[index] = false;
        wcnt[index] = 0;
      } else {
        _lightningEffectONTriggerList[index].fire();
        _damageEffectONTriggerList[index].fire();
        _glowEffectONTriggerList[index].fire();
        
      }
    }
  }



  void loadRiveFile() async {
    final bytes = await rootBundle.load(riveFilePath);
    final file = RiveFisle.import(bytes);
    print("loadRive!");
    if (file != null) {
      artBoard = file.mainArtboard;
      _normalMovementController = NormalMovementController();
      artBoard.addController(_normalMovementController);
    }
    isRiveFileLoaded = true;
    debugPrint("loadRiveFileed");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文字列'),
      ),
      body:SizedBox(
                width: 700, //横幅
                height: 400, //高さ
                child: Container(
                  height: Display.getOptimizedSize(context, 280),
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Container(
                        width: Display.getOptimizedSize(context, 280),
                        height: Display.getOptimizedSize(context, 280),
                        child: isRiveFileLoaded == true
                            ? Rive(
                                artboard: artBoard,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
          ),      
      ),
  }
  
}
