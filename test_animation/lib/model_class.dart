import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rive/rive.dart';
import 'rive_class.dart';


  final Calculator _calculator = new Calculator();
  final Coefficients _coefficients = new Coefficients();
  final PostureLogsRepository _postureLogsRepository;

  /// 実績ログリポジトリ
  final AchievementLogsRepository _achievementLogsRepository;

  /// 表示中のイラストイメージNo
  int imageNo = 5;

  final int additionValue = 1;

  double deviceX = 0;
  double deviceY = 0;
  double deviceZ = 0;
  double tof = 0;
  double c2c7 = 0;
  double c2c7sva = 0;
  int messageType = 5;
  var angle = [0, 0, 0];
  var partScore = [0, 0, 0];
  var partDamage = [0, 0, 0];

  /// RiveAnimation関連
  final imageMaxCount = 13;
  final riveFilePath = 'assets/rivs/shisei_0930.riv';

  /// Riveファイルがロードされたか
  late bool isRiveFileLoaded;

  late Artboard artBoard;

  /// Rive Animation 定数
  static const String StateMachine = 'State Machine Master';
  static const String NormalNeck = 'NormalNeck';
  static const String DamageNeck = 'DamageNeck';
  static const String NormalBack = 'NormalBack';
  static const String DamageBack = 'DamageBack';
  static const String NormalWaist = 'NormalWaist';
  static const String DamageWaist = 'DamageWaist';
  static const String NeckGlowOFF = 'NeckGlowOFF';
  static const String NeckGlowON = 'NeckGlowON';
  static const String BackGlowOFF = 'BackGlowOFF';
  static const String BackGlowON = 'BackGlowON';
  static const String WaistGlowOFF = 'WaistGlowOFF';
  static const String WaistGlowON = 'WaistGlowON';
  static const String NeckEffectOFF = 'NeckEffectOFF';
  static const String NeckEffectFlash = 'NeckEffectFlash';
  static const String BackEffectOFF = 'BackEffectOFF';
  static const String BackEffectFlash = 'BackEffectFlash';
  static const String WaistEffectOFF = 'WaistEffectOFF';
  static const String WaistEffectFlash = 'WaistEffectFlash';

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

  /// 開始処理
  void onStart(context) {
    _calculator.initialize(_coefficients.HP);
    partScore = [0, 0, 0];
    partDamage = [0, 0, 0];
  }

  /// レジューム処理
  void onResume(context) {
    // トレーニングモードデータを受信
    _BLEDeviceService.setTrainingReceived(onTrainingReceived);
  }

  /// バイトから数値を取得
  double _getValue(v1, v2) {
    var v = (v1 << 8) | v2;
    var bd = ByteData(2);
    bd.setUint16(0, v);
    var f = bd.getInt16(0, Endian.big);
    return f.toDouble();
  }

  /// トレーニングモードレシーバ
  void onTrainingReceived(value) {
    // トレーニングモードデータを受信
    deviceX = _getValue(value[3], value[4]) * Constants.bleMgLSB;
    deviceY = _getValue(value[5], value[6]) * Constants.bleMgLSB;
    deviceZ = -_getValue(value[7], value[8]) * Constants.bleMgLSB;
    tof = _getValue(value[9], value[10]);
    _calculator.run(deviceX, deviceY, deviceZ, tof, _coefficients);
    c2c7 = _calculator.c2c7;
    c2c7sva = _calculator.c2c7sva;
    angle[0] = _calculator.c2c7.round();
    angle[1] = _calculator.c7t3t8.round();
    angle[2] = _calculator.t12l3s.round();

    for (int ix = 0; ix < IllustrationKeys.tofMax.length; ix++) {
      var tofMin = IllustrationKeys.tofMin[ix];
      var tofMax = IllustrationKeys.tofMax[ix];
      var c2c7Min = IllustrationKeys.c2c7Min[ix];
      var c2c7Max = IllustrationKeys.c2c7Max[ix];
      var isTof = false;
      var isC2C7 = false;
      if (tof >= tofMin && tof < tofMax) {
        isTof = true;
      }
      if (c2c7Min == -1 && c2c7Max == -1) {
        isC2C7 = true;
      } else if (c2c7Min != -1 && c2c7Max != -1) {
        if (c2c7 >= c2c7Min && c2c7 < c2c7Max) {
          isC2C7 = true;
        }
      } else if (c2c7Min != -1) {
        if (c2c7 >= c2c7Min) {
          isC2C7 = true;
        }
      } else if (c2c7Max != -1) {
        if (c2c7 < c2c7Max) {
          isC2C7 = true;
        }
      }

      if (isTof == true && isC2C7 == true) {
        imageNo = ix + 1;
        break;
      }
    }

    // ダメージゲージ／スコア 加算計算
    if (c2c7sva <= 4) {
      partScore[0] += additionValue;
    } else {
      partDamage[0] += additionValue;
    }
    for (int i = 1; i < partScore.length; i++) {
      if (angle[i] >= DamageThreshold.safeStart[i] &&
          angle[i] <= DamageThreshold.safeEnd[i]) {
        partScore[i] += additionValue;
      } else {
        partDamage[i] += additionValue;
      }
    }

    for (int i = 0; i < partScore.length; i++) {
      if (partScore[i] < 0) {
        partScore[i] = 0;
      } else if (partScore[i] > 1000) {
        partScore[i] = 1000;
      }
      if (partDamage[i] < 0) {
        partDamage[i] = 0;
      } else if (partDamage[i] > 1000) {
        partDamage[i] = 1000;
      }
    }

    messageType = IllustrationKeys.type[imageNo - 1];
    if (messageType == 3) {
      /// 3の場合は出し別けなので再評価
      if (c2c7sva > IllustrationKeys.c3c7svaThreshold[0]) {
        messageType = 3;
      } else if (c2c7sva < IllustrationKeys.c3c7svaThreshold[1]) {
        messageType = 5;
      } else {
        messageType = 4;
      }
    }

    toMove(imageNo);
    drawNeckLightningEffect(messageType);
    drawLightningEffect(1, angle[1]);
    drawLightningEffect(2, angle[2]);
    drawDamageAlertEffect(_coefficients.damageRate, 0);
    drawDamageAlertEffect(_coefficients.damageRate, 1);
    drawDamageAlertEffect(_coefficients.damageRate, 2);

    notifyListeners();
  }

  /// アラート文言：メッセージテキストゲッター
  getMessageText() {
    var message = "";
    message = IllustrationKeys.message[messageType - 1];
    return message;
  }

  /// アラート文言：テキストカラーゲッター
  getMessageColor() {
    var color = Colors.black;
    if (messageType == 1) {
      color = Colors.red;
    } else if (messageType == 2) {
      color = Colors.orange;
    } else if (messageType == 3) {
      color = Colors.red;
    } else if (messageType == 4) {
      color = Colors.orange;
    } else if (messageType == 5) {
      color = Colors.blue;
    }
    return color;
  }

  /// アラート文言：背景カラーゲッター
  getMessageBackgroundColor() {
    var color = Colors.white;
    if (messageType == 1) {
      color = Color(0xFFFFDDDD).withOpacity(0.8);
    } else if (messageType == 2) {
      color = Color(0xFFFFFFDD).withOpacity(0.8);
    } else if (messageType == 3) {
      color = Color(0xFFFFDDDD).withOpacity(0.8);
    } else if (messageType == 4) {
      color = Color(0xFFFFFFDD).withOpacity(0.8);
    } else if (messageType == 5) {
      color = Color(0xFFDDDDFF).withOpacity(0.8);
    }
    return color;
  }

  /// スコアタップイベント
  onPressedScore(index) {
    print("onPressedScore:${index}");

    if (index == 1) {
      if (_timer == null) {
        startTimer();
      }
    }
  }

  /// スライダー用数値ゲッター
  int getSliderValue(int ix) {
    var value = angle[ix];
    if (value > DamageThreshold.sliderMax[ix])
      value = DamageThreshold.sliderMax[ix];
    if (value < DamageThreshold.sliderMin[ix])
      value = DamageThreshold.sliderMin[ix];
    return value;
  }

  /// セーフゾーン開始数値ゲッター
  double getSafeStart(int ix) {
    double p =
        1 / (DamageThreshold.sliderMax[ix] - DamageThreshold.sliderMin[ix]);
    double position = DamageThreshold.safeStart[ix].toDouble();
    position -= DamageThreshold.sliderMin[ix]; // 最小値を減算し座標とする。
    position *= p;
    return position;
  }

  /// セーフゾーン終了数値ゲッター
  double getSafeEnd(int ix) {
    double p =
        1 / (DamageThreshold.sliderMax[ix] - DamageThreshold.sliderMin[ix]);
    double position = DamageThreshold.safeEnd[ix].toDouble();
    if (ix == 0) {
      position = _calculator.c2c7SafeEnd; // 首セーフゾーン終点は、計算値を指定する
    }
    position -= DamageThreshold.sliderMin[ix]; // 最小値を減算し座標とする。
    position *= p;
    return position;
  }

  /// ダメージゲージ用ダメージ値取得
  double getDamage(int ix) {
    return partDamage[ix] / 1000;
  }

  /// ダメージゲージ背景色ゲッター
  Color getDamageGaugeBackgroundColor(double damage) {
    var color = Colors.black12;
    return color;
  }

  /// ダメージゲージ色ゲッター
  AlwaysStoppedAnimation<Color> getDamageGaugeColor(double damage) {
    int r = (damage * 255).toInt();
    int b = 255 - r;
    int g = (sin(damage * 180 * pi / 180) * 230).toInt();
    var color = Color.fromARGB(255, r, g, b);
    return AlwaysStoppedAnimation<Color>(color);
  }

  /// 各部位ランクゲッター
  String getPartRank(int ix) {
    var rank = ScoreList.rank.last;
    for (int i = 0; i < ScoreList.partThreshold.length; i++) {
      if (partScore[ix] >= ScoreList.partThreshold[i]) {
        rank = ScoreList.rank[i];
        break;
      }
    }
    return rank;
  }

  /// 総合ランクゲッター
  String getTotalRank() {
    var rank = ScoreList.rank.last;
    var totalHP = partScore[0] + partScore[1] + partScore[2];
    for (int i = 0; i < ScoreList.totalThreshold.length; i++) {
      if (totalHP >= ScoreList.totalThreshold[i]) {
        rank = ScoreList.rank[i];
        break;
      }
    }
    return rank;
  }

  /// 総合スコアゲッター
  int getTotalScore() {
    var score = (partScore[0] + partScore[1] + partScore[2]) / 30;
    return score.round();
  }

  Timer? _timer;

  int _add = 1;

  /// 仮アニメーション開始
  void startTimer() {
    if (_BLEDeviceService.iSConnected) {
      return;
    }
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    messageType = 5;
    _timer = Timer.periodic(
      Duration(milliseconds: 180),
      _onTimer,
    );
  }

  /// 仮アニメーション実装
  void _onTimer(Timer timer) {
    imageNo += _add;
    if (imageNo > imageMaxCount) {
      _timer!.cancel();
      _timer = null;
      _add = -1;
      messageType = 3;
    } else if (imageNo < 5) {
      _timer!.cancel();
      _timer = null;
      _add = 1;
    }
    if (imageNo > 4 && imageNo <= imageMaxCount) {
      //nextNo = imageNo;
    }
    toMove(imageNo);
    drawNeckLightningEffect(messageType);
    notifyListeners();
  }

  // Riveファイルの読み込み
  void loadRiveFile() async {
    final bytes = await rootBundle.load(riveFilePath);
    final file = RiveFile.import(bytes);
    if (file != null) {
      artBoard = file.mainArtboard;

      final effectController =
          StateMachineController.fromArtboard(artBoard, StateMachine);
      artBoard.addController(effectController!);
      _normalMovementController = NormalMovementController();
      artBoard.addController(_normalMovementController);
      isLightningEffect = [false, false, false];
      isAlertEffect = [false, false, false];
      latestFireTime = DateHelper.dateTimeToEpoch(DateTime.now());
      _damageEffectOFFTriggerList = [
        effectController.findInput<bool>(NormalNeck) as SMITrigger,
        effectController.findInput<bool>(NormalBack) as SMITrigger,
        effectController.findInput<bool>(NormalWaist) as SMITrigger
      ];
      _damageEffectONTriggerList = [
        effectController.findInput<bool>(DamageNeck) as SMITrigger,
        effectController.findInput<bool>(DamageBack) as SMITrigger,
        effectController.findInput<bool>(DamageWaist) as SMITrigger
      ];
      _glowEffectOFFTriggerList = [
        effectController.findInput<bool>(NeckGlowOFF) as SMITrigger,
        effectController.findInput<bool>(BackGlowOFF) as SMITrigger,
        effectController.findInput<bool>(WaistGlowOFF) as SMITrigger
      ];
      _glowEffectONTriggerList = [
        effectController.findInput<bool>(NeckGlowON) as SMITrigger,
        effectController.findInput<bool>(BackGlowON) as SMITrigger,
        effectController.findInput<bool>(WaistGlowON) as SMITrigger
      ];
      _lightningEffectOFFTriggerList = [
        effectController.findInput<bool>(NeckEffectOFF) as SMITrigger,
        effectController.findInput<bool>(BackEffectOFF) as SMITrigger,
        effectController.findInput<bool>(WaistEffectOFF) as SMITrigger
      ];
      _lightningEffectONTriggerList = [
        effectController.findInput<bool>(NeckEffectFlash) as SMITrigger,
        effectController.findInput<bool>(BackEffectFlash) as SMITrigger,
        effectController.findInput<bool>(WaistEffectFlash) as SMITrigger
      ];
    }
    isRiveFileLoaded = true;
    debugPrint("loadRiveFileed");
    notifyListeners();
  }

  /// 背骨ダメージエフェクト描画
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

  toMove(int index) {
    _normalMovementController.toMove(index);
  }

  /// 首稲妻エフェクト描画
  drawNeckLightningEffect(messageType) {
    if (isLightningEffect[0] == false) {
      if (messageType == 1 || messageType == 3) {
        _lightningEffectONTriggerList[0].fire();
        isLightningEffect[0] = true;
      }
    } else {
      if (messageType != 1 && messageType != 3) {
        _lightningEffectOFFTriggerList[0].fire();
        isLightningEffect[0] = false;
      }
    }
  }

  /// 背中、腰稲妻エフェクト描画
  void drawLightningEffect(int index, int angle) {
    if (isLightningEffect[index] == false) {
      if (!Calculation.isInSafeZoneRange(index, angle, _coefficients)) {
        _lightningEffectONTriggerList[index].fire();
        isLightningEffect[index] = true;
      } else {
        _lightningEffectOFFTriggerList[index].fire();
      }
    } else {
      if (Calculation.isInSafeZoneRange(index, angle, _coefficients)) {
        _lightningEffectOFFTriggerList[index].fire();
        isLightningEffect[index] = false;
      } else {
        _lightningEffectONTriggerList[index].fire();
      }
    }
  }
}
