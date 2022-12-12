import 'package:flutter/cupertino.dart';

/// 画面出力関連ヘルパークラス
class Display {
  /// 基準高
  static const double _width = 1080;

  /// 最新の比率
  /// ※どうしてもcontextが利用できない場面で利用する
  static double latestOptimizedRate = 0;

  /// 最適化サイズを返す
  static double getOptimizedSize(context, double size) {
    latestOptimizedRate = MediaQuery.of(context).size.width / _width;
    return size * latestOptimizedRate;
  }

  /// 最適化サイズ（テキスト）を返す
  static double getOptimizedTextScaleFactor(context) {
    var rate = MediaQuery.of(context).size.width / _width;
    return rate;
  }
}
