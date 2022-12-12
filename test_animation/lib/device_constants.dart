import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Flavor { development, production }

@immutable
class Constants {
  const Constants({
    required this.endpoint,
  });

  factory Constants.of() {
    if (_instance != null) return _instance!;

    final flavor = EnumToString.fromString(
      Flavor.values,
      const String.fromEnvironment('FLAVOR'),
    );

    switch (flavor) {
      case Flavor.development:
        _instance = Constants._dev();
        break;
      case Flavor.production:
      default:
        _instance = Constants._prd();
    }
    return _instance!;
  }

  factory Constants._dev() {
    return const Constants(
      endpoint: 'https://f5ssl.com/app/wecan',
    );
  }

  factory Constants._prd() {
    return const Constants(
      endpoint: 'https://f5ssl.com/app/wecan',
    );
  }

  // 画面ルーティング定数
  static const String pageNone = '';
  static const String pageSplash = '/splash';
  static const String pageInfo = '/info';
  static const String pageInfoDesc = '/info/desc';
  static const String pageHome = '/home';
  static const String pageGraph = '/graph';
  static const String pageTerms = '/terms';
  static const String pageProfile = '/profile/profile';
  static const String pageProfileEdit = '/profile/edit';
  static const String pageDocumentTerms = '/document/terms';
  static const String pageDocumentAbout = '/document/about';
  static const String pageDocumentHowToUse = '/document/how_to_use';
  static const String dialogDeviceConnect = "/device_connect";
  static const String pageDeviceTest = '/device_test';

  static Constants? _instance;
  final String endpoint;

  /// BLE情報 デバイス名
  static const bleDeviceName = "weCAN SENSOR";

  /// BLE情報 加速度係数
  static const double bleMgLSB = 0.0039;

  /// BLE情報 サービスUUID
  static const bleServiceUUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";

  /// BLE情報 送信UUID
  static const bleSendUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  /// BLE情報 通知(受信)UUID
  static const bleNotifyUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
}
