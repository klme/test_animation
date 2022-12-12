/// イラストレーションキークラス
class IllustrationKeys {
  static const tofMin = [
    800,
    750,
    600,
    520,
    440,
    350,
    330,
    330,
    330,
    330,
    270,
    270,
    0
  ];
  static const tofMax = [
    8190,
    800,
    700,
    600,
    520,
    440,
    440,
    440,
    440,
    440,
    330,
    330,
    270
  ];
  static const c2c7Min = [-1, -1, -1, -1, -1, -1, 0, 25, 35, 45, 48, 0, -1];
  static const c2c7Max = [-1, -1, -1, -1, -1, -1, 25, 35, 45, -1, -1, 48, -1];
  static const type = [1, 2, 3, 3, 3, 3, 3, 3, 2, 1, 2, 1, 1];
  static const c2c7svaThreshold = [5.5, 4];
  static const message = [
    "首に負担がかかっているかもしれません。\n姿勢を確認しましょう。",
    "悪い姿勢になりはじめていませんか？\n姿勢を確認してみましょう。",
    "首に負担がかかっているかもしれません。\n姿勢を確認しましょう。",
    "悪い姿勢になりはじめていませんか？\n姿勢を確認してみましょう。",
    "よい姿勢を保っているようです。",
    "データが測定できていないようです。ご確認ください。"
  ];
}

/// ダメージゲージ閾値クラス
class DamageThreshold {
  static const sliderMin = [-10, 160, 160];
  static const sliderMax = [70, 180, 180];
  static const safeStart = [0, 170, 175];
  static const safeEnd = [0, 176, 180];
}

/// 美姿勢スコア閾値クラス
class ScoreList {
  static const rank = ["SS", "S", "A", "B ", "C", "D", "E"];
  static const partThreshold = [900, 800, 700, 500, 200, 0];
  static const totalThreshold = [2700, 2200, 2000, 1500, 500, 0];
}
