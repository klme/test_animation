import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'model_constans.dart';



class SeboneData{
/*
  typeNum 
  0..男性正常型
  1..男性猫背型
  2..男性踏ん反り型
  3..女性正常型
  4..女性猫背型
  5..女性踏ん反り型
*/
  var C2C7_C0 = [47.61,64.00,77.03,77.81,54.28,71.70];
  var C2C7_C1 = [0.1554,0.2312,0.0364,0.4378,-0.0496,0.0646];
  var C2C7_C2 = [-0.0411,0.00018,-0.0888,	-0.1442,-0.0421,-0.1119];
  var C2C7_C3 = [0.00422,0.00018,0.00487,-0.00052,0.00743,0.00566];
  var C2C7_C4 = [1.060E-05,2.463E-05,1.868E-05,	8.068E-05,-7.656E-06,5.841E-05];
  var C7T3T8_C0 = [236.75,180.54,179.62,161.84,180.54,191.33];
  var C7T3T8_C1 = [-0.5892,-0.0297,-0.4959,-0.6064,-0.0297,-0.2960];
  var C7T3T8_C2 = [-0.0847,-0.0016,0.0355,0.0898,	-0.0016,-0.0227];
  var C7T3T8_C3 = [0.00738,0.00032,0.00744,0.01051,0.00032,0.00379];
  var C7T3T8_C4 = [1.982E-05,-6.782E-06,-5.048E-05,-9.615E-05,-6.782E-06,-1.779E-05];
  var T12L3S_C0 = [154.14,144.77,187.80,162.06,190.79,147.15];
  var T12L3S_C1 = [0.1197,0.0325,-0.0222,-0.0371,	0.2380,-0.1756];
  var T12L3S_C2 = [0.0237,0.0420,-0.0286,0.0460,-0.0939,0.0758];
  var T12L3S_C3 = [-0.00168,0.00035,0.00052,0.00076,-0.00431,	0.00227];
  var T12L3S_C4 = [-6.235E-06,-3.365E-06,1.297E-05,-3.024E-05,9.171E-05,-8.586E-05];

  var HP = 100;
  var height = 172.0;
  var damageRate = 0.7;
  var safeZoneStart = [0, 177, 170];
  var safeZoneEnd = [0, 180, 180];
  var typeNum = 0;
  var Gender = "female";
  var PostureType = "normal";

  SeboneData(){
    this.setup();
  }

  setup(){
    if(this.Gender=="male"){
      if(this.PostureType=="normal"){
        this.typeNum = 0;
      }else if(this.PostureType=="forward"){
        this.typeNum = 1;
      }else{
        this.typeNum = 2;
      }
    }else{
      if(this.PostureType=="normal"){
        this.typeNum = 3;
      }else if(this.PostureType=="forward"){
        this.typeNum = 4;
      }else{
        this.typeNum = 5;
      }
    }
  }

  int selectImage(double tof,double c2c7){
    var imageNo = 0;
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
    return imageNo;
  }

  /// 正規化
  double _normY(double x, double y, double z) {
    double vLength = sqrt(x * x + y * y + z * z);
    double Y = y / vLength;
    return Y;
  }

  /// 頭の傾きの計算
  double calcHeadTilt(double ax, double ay, double az) {
    var y = this._normY(ax, ay, az);
    var headTilt = acos(y) * (180 / pi);
    return headTilt;
  }

  /// C2C7角の計算
  double calcC2C7(double d, double headTilt) {
    var c2c7 = this.C2C7_C4[this.typeNum] * d * d +this.C2C7_C3[this.typeNum] * headTilt * headTilt + this.C2C7_C2[this.typeNum] * d + this.C2C7_C1[this.typeNum] * headTilt + C2C7_C0[this.typeNum];
    return c2c7;
  }

  /// 上位胸椎後弯角 C7T3T8角 の計算
  double calcC7T3T8(double d, double headTilt) {

    var c7t3t8 = this.C7T3T8_C4[this.typeNum] * d * d + this.C7T3T8_C3[this.typeNum] * headTilt * headTilt + this.C7T3T8_C2[this.typeNum] * d + this.C7T3T8_C1[this.typeNum] * headTilt + this.C7T3T8_C0[this.typeNum];
    while (c7t3t8 >= 360) {
      c7t3t8 = (c7t3t8 - 360);
    }
    while (c7t3t8 <= 0) {
      c7t3t8 = c7t3t8 + 180;
    }
    if (c7t3t8 >= 180) {
      c7t3t8 = -(c7t3t8 - 180);
    }
    return c7t3t8;
  }

  /// T12L3S角の計算
  double calcT12L3S(double d, double headTilt) {
    var t12l3s =  this.T12L3S_C4[this.typeNum] * d * d +this.T12L3S_C3[this.typeNum] * headTilt * headTilt + this.T12L3S_C2[this.typeNum] * d + T12L3S_C1[this.typeNum] * headTilt + this.T12L3S_C0[this.typeNum];
    while (t12l3s >= 360) {
      t12l3s = (t12l3s - 360);
    }
    while (t12l3s <= 0) {
      t12l3s = t12l3s + 180;
    }
    if (t12l3s >= 180) {
      t12l3s = -(t12l3s - 180);
    }
    return t12l3s;
  }

  /// neckLengthの計算
  double calcNeckLength(double height) {
    // double neckLength = 8 + (height - 150) * (1 / 10);
    // TODO 8.5cm固定値を指定
    double neckLength = 8.5;
    return neckLength;
  }

  /// c2c7svaの計算
  double calcC2C7SVA(c2c7,double height,) {
    var c2c7sva = this.calcNeckLength(height) * sin(c2c7 * pi / 180);
    return c2c7sva;
  }

  /// 首（c2c7）セーフゾーン終点値のの計算
  double calcC2C7SafeEnd(double height) {
    double value = asin(4 / this.calcNeckLength(height)) * 180 / pi;
    return value;
  }

  /// HP値計算
  int calcHP(int HP, double c2c7sva) {
    if (c2c7sva >= 4.0) {
      HP--;
    }
    return HP;
  }

  // セーフゾーン内か判定
  bool isInSafeZoneRange(
      int index, int angle) {
    var result;
    if (angle >= this.safeZoneStart[index] &&
        angle <= this.safeZoneEnd[index]) {
      result = true;
    } else {
      result = false;
    }
    return result;
  }


  double headTilt = 0;
  double c2c7 = 0;
  double c7t3t8 = 0;
  double t3t8t12 = 0;
  double t8t12l3 = 0;
  double t12l3s = 0;
  double tof_latest = 0;

  double c2c7sva = 0;
  double c2c7SafeEnd = 0;

  /// 初期化処理
  void initialize(int hp) {
    HP = hp;
    print(HP);
  }

  /// 実行
  void runCalc(x, y, z, tof) {
    try {
      if (tof >= 8190) {
        tof = tof_latest;
      } else {
        tof_latest = tof;
      }

      headTilt = this.calcHeadTilt(x, y, z);

      c2c7 = this.calcC2C7(this.headTilt,tof);

      c7t3t8 = this.calcC7T3T8(this.headTilt,tof);

      t12l3s = this.calcT12L3S(this.headTilt,tof,);

      c2c7sva = this.calcC2C7SVA(this.c2c7,this.height);
      c2c7SafeEnd = this.calcC2C7SafeEnd(this.height);

      HP = this.calcHP(this.HP,this.c2c7sva);
    } catch (e) {
      print(e);
    }
  }
}


class CSVmodule {
  int startId = 0;
  int stopId = 0;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return  directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    var now = DateTime.now();
    final fileName = "sebone " + DateFormat('yy-MM-dd H-mm-ss').format(now)+".csv";
    return File('$path/$fileName');
  }

  Future<int> readData() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeData(List<dynamic>outputDatas ) async {
    final file = await _localFile;
    var str = "";
    for(int i=this.startId;i<this.stopId;i++){
      for(int j=0;j<11;j++){
        str += outputDatas[i][j].toString()+",";
      }
      str += "\n";
    }

    // Write the file
    return file.writeAsString('$str');
  }

    Future<File> writeAllData(List<dynamic>outputDatas ) async {
    final file = await _localFile;
    var str = "";
    for(int i=0;i<outputDatas.length;i++){
      for(int j=0;j<11;j++){
        str += outputDatas[i][j].toString()+",";
      }
      str += "\n";
    }
    // Write the file
    return file.writeAsString('$str');
  }


}