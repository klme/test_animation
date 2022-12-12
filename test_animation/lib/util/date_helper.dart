import 'package:intl/intl.dart';

/// 日付関連ヘルパークラス
///
class DateHelper {
  /// 現在日付を返す（時間は0:00)
  ///
  static DateTime getNowDate() {
    return DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
  }

  ///DateTime型からエポックタイムへ変換
  ///
  static int dateTimeToEpoch(value) {
    return (value.millisecondsSinceEpoch / 1000).floor();
  }

  /// 文字列日付(YYYYMMDD)からエポックタイムへ変換
  ///
  static int dateStringToEpoch(value) {
    return (DateTime.parse(value).millisecondsSinceEpoch / 1000).floor();
  }

  /// エポックタイムから文字列日付(YYYYMMDD)へ変換
  ///
  static String dateEpochToString(value) {
    return DateFormat('yyyy/MM/dd HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(value * 1000));
  }

  /// エポックタイムからDateTime型へ変換
  ///
  static DateTime dateEpochToDateTime(value) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
}
