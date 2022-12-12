import 'package:rive/rive.dart';

/// NormalMovementカスタムコントローラー
class NormalMovementController
    extends RiveAnimationController<RuntimeArtboard> {
  /// アニメーション名
  static const String _animationName = 'NormalMovement';

  /// 分割数
  static const double division = 13;

  /// 総フレーム数
  static const double frames = 7 * 60; // 7秒 x 60FPS

  /// スピード
  double speed = 3;

  /// アニメーション
  late LinearAnimationInstance _mainAnimation;

  /// 初期化処理
  @override
  bool init(RuntimeArtboard core) {
    _mainAnimation = core.animationByName(_animationName)!;
    _mainAnimation.animation.loop = Loop.oneShot;
    _mainAnimation.animation.enableWorkArea = true;
    toMove(5);
    return true;
  }

  /// アニメーション再生処理
  @override
  void apply(RuntimeArtboard core, double elapsedSeconds) {
    // 逆再生時にworkStartで停止しない問題がある為、ここで制御を入れる
    double startTime = _mainAnimation.animation.workStart / 60;
    if (_mainAnimation.time < startTime) {
      _mainAnimation.time = startTime;
    }

    _mainAnimation.animation.apply(_mainAnimation.time, coreContext: core);
    _mainAnimation.advance(elapsedSeconds);
  }

  /// 移動
  /// 現在の位置から[to]まで移動する
  toMove(int to) {
    var toFrame = frames ~/ division * to;
    var currentFrame = (_mainAnimation.time * 60).toInt();
    if (currentFrame <= toFrame) {
      // 順再生
      _mainAnimation.animation.workStart = currentFrame;
      _mainAnimation.animation.workEnd = toFrame;
      _mainAnimation.animation.speed = speed;
    } else {
      // 逆再生
      _mainAnimation.animation.workStart = toFrame;
      _mainAnimation.animation.workEnd = currentFrame;
      _mainAnimation.animation.speed = -speed;
    }
    this.isActive = true;
  }
}
