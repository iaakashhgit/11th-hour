import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';







class VisionText {
  
  final Map<dynamic, dynamic> _data;

  String get text => _data['text'];
  final Rect rect;
  final List<Point<num>> cornerPoints;

  VisionText._(this._data)
      : rect = Rect.fromLTRB(_data['rect_left'], _data['rect_top'],
            _data['rect_right'], _data['rect_bottom']),
        cornerPoints = _data['points'] == null
            ? null
            : _data['points']
                .map<Point<num>>(
                    (dynamic item) => Point<num>(item['x'], item['y']))
                .toList();
}

class VisionTextBlock extends VisionText {
  final List<VisionTextLine> lines;

  VisionTextBlock._(Map<dynamic, dynamic> data)
      : lines = data['lines'] == null
            ? null
            : data['lines']
                .map<VisionTextLine>((dynamic item) => VisionTextLine._(item))
                .toList(),
        super._(data);
}

class VisionTextLine extends VisionText {
  final List<VisionTextElement> elements;

  VisionTextLine._(Map<dynamic, dynamic> data)
      : elements = data['elements'] == null
            ? null
            : data['elements']
                .map<VisionTextElement>(
                    (dynamic item) => VisionTextElement._(item))
                .toList(),
        super._(data);
}

class VisionTextElement extends VisionText {
  VisionTextElement._(Map<dynamic, dynamic> data) : super._(data);
}

class FirebaseMlkit {
  // ignore: unused_field
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/mlkit');

  static FirebaseMlkit instance = new FirebaseMlkit._();

  FirebaseMlkit._();

  FirebaseVisionTextDetector getVisionTextDetector() {
    return FirebaseVisionTextDetector.instance;
  }
}

class FirebaseVisionTextDetector {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/mlkit');

  static FirebaseVisionTextDetector instance =
      new FirebaseVisionTextDetector._();

  FirebaseVisionTextDetector._();

  Future<List<VisionText>> detectFromBinary(Uint8List binary) async {
    List<dynamic> texts = await _channel.invokeMethod(
        "FirebaseVisionTextDetector#detectFromBinary", {'binary': binary});
    List<VisionText> ret = [];
    texts?.forEach((dynamic item) {
      final VisionTextBlock text = new VisionTextBlock._(item);
      ret.add(text);
    });
    return ret;
  }

  Future<List<VisionText>> detectFromPath(String filepath) async {
    List<dynamic> texts = await _channel
        .invokeMethod("FirebaseVisionTextDetector#detectFromPath", {
      '/Users/its...ShiVam_Raj/Desktop/Data/catch_lens/catchlens/assets/Model.tflite':
          filepath
    });
    List<VisionText> ret = [];
    texts?.forEach((dynamic item) {
      final VisionTextBlock text = new VisionTextBlock._(item);
      ret.add(text);
    });
    return ret;
  }
}

class FirebaseModelInterpreter {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/mlkit');

  static FirebaseModelInterpreter instance = new FirebaseModelInterpreter._();

  FirebaseModelInterpreter._();

  Future<List<dynamic>> run(
      {String remoteModelName,
      String localModelName,
      FirebaseModelInputOutputOptions inputOutputOptions,
      Uint8List inputBytes}) async {
    assert(remoteModelName != null || localModelName != null);
    try {
      dynamic results =
          await _channel.invokeMethod("FirebaseModelInterpreter#run", {
        'remoteModelName': remoteModelName,
        'localModelName': localModelName,
        'inputOutputOptions': inputOutputOptions.asDictionary(),
        'inputBytes': inputBytes
      });
      return results;
    } catch (e) {
      print("Error on FirebaseModelInterpreter#run : ${e.toString()}");
    }
    return null;
  }
}

class FirebaseModelIOOption {
  final FirebaseModelDataType dataType;
  final List<int> dims;

  const FirebaseModelIOOption(this.dataType, this.dims);
  Map<String, dynamic> asDictionary() {
    return {
      "dataType": dataType.value,
      "dims": dims,
    };
  }
}

class FirebaseModelInputOutputOptions {
  final List<FirebaseModelIOOption> inputOptions;
  final List<FirebaseModelIOOption> outputOptions;

  const FirebaseModelInputOutputOptions(this.inputOptions, this.outputOptions);

  Map<String, dynamic> asDictionary() {
    List<Map<String, dynamic>> inputs = [];
    List<Map<String, dynamic>> outputs = [];
    inputOptions.forEach((o) {
      inputs.add(o.asDictionary());
    });
    outputOptions.forEach((o) {
      outputs.add(o.asDictionary());
    });
    return {
      "inputOptions": inputs,
      "outputOptions": outputs,
    };
  }
}

class FirebaseModelDataType {
  final int value;
  const FirebaseModelDataType._(int value) : value = value;

  static const FLOAT32 = const FirebaseModelDataType._(1);
  static const INT32 = const FirebaseModelDataType._(2);
  static const BYTE = const FirebaseModelDataType._(3);
  static const LONG = const FirebaseModelDataType._(4);
}

class FirebaseModelManager {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/mlkit');

  static FirebaseModelManager instance = FirebaseModelManager._();

  FirebaseModelManager._();

  Future<void> registerRemoteModelSource(
      FirebaseRemoteModelSource cloudSource) async {
    try {
      await _channel.invokeMethod(
          "FirebaseModelManager#registerRemoteModelSource",
          {'source': cloudSource.asDictionary()});
    } catch (e) {
      print(
          "Error on FirebaseModelManager#registerRemoteModelSource : ${e.toString()}");
    }
    return null;
  }

  Future<void> registerLocalModelSource(
      FirebaseLocalModelSource localSource) async {
    try {
      await _channel.invokeMethod(
          "FirebaseModelManager#registerLocalModelSource",
          {'source': localSource.asDictionary()});
    } catch (e) {
      print(
          "Error on FirebaseModelManager#registerLocalModelSource : ${e.toString()}");
    }
    return null;
  }
}

class FirebaseLocalModelSource {
  final String modelName;
  final String assetFilePath;

  FirebaseLocalModelSource({
    @required this.modelName,
    @required this.assetFilePath,
  });

  Map<String, dynamic> asDictionary() {
    return {
      "Model": modelName,
      "/Users/its...ShiVam_Raj/Desktop/Data/catch_lens/catchlens/assets/Model.tflite":
          assetFilePath
    };
  }
}

class FirebaseRemoteModelSource {
  final String modelName;
  final bool enableModelUpdates;
  final FirebaseModelDownloadConditions initialDownloadConditions;
  final FirebaseModelDownloadConditions updatesDownloadConditions;

  static const _defaultCondition = FirebaseModelDownloadConditions();

  FirebaseRemoteModelSource(
      {@required this.modelName,
      this.enableModelUpdates: false,
      this.initialDownloadConditions: _defaultCondition,
      this.updatesDownloadConditions: _defaultCondition});

  Map<String, dynamic> asDictionary() {
    return {
      "enableModelUpdates": enableModelUpdates,
      "initialDownloadConditions": initialDownloadConditions.asDictionary(),
      "updatesDownloadConditions": updatesDownloadConditions.asDictionary(),
    };
  }
}

class FirebaseModelDownloadConditions {
  final bool requireWifi;
  final bool requireDeviceIdle;
  final bool requireCharging;

  const FirebaseModelDownloadConditions(
      {this.requireCharging: false,
      this.requireDeviceIdle: false,
      this.requireWifi: false});

  Map<String, dynamic> asDictionary() {
    return {
      "requireWifi": requireWifi,
      "requireDeviceIdle": requireDeviceIdle,
      "requireCharging": requireCharging
    };
  }
}
