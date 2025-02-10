import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';

class DownloaderIsolate {
  static void setupDownloaderPort({required Function(int) updateProgress}) {
    ReceivePort _port = ReceivePort();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    FlutterDownloader.registerCallback(DownloaderIsolate.downloadCallback);

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      updateProgress(progress); // Update the progress here
    });
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort sendPort = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    sendPort.send([id, status, progress]);
  }
}
