// Dart
import 'dart:io';
// Flutter
import 'package:flutter/material.dart';
// Others
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:media_store/media_store.dart';
import 'package:youtube_downloader/models/video_detail.dart';
import 'package:youtube_downloader/styles/progress_video.dart' as style;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ProgressVideo extends StatefulWidget {
  static const double _side = 50;

  final VideoDetail videoDetail;

  const ProgressVideo({
    required this.videoDetail,
    Key? key,
  }) : super(key: key);

  @override
  _ProgressVideoState createState() => _ProgressVideoState();
}

class _ProgressVideoState extends State<ProgressVideo> {
  bool _isFinished = false;
  bool _isThereError = false;
  int _id = 10;

  late FileSize _total;
  var _received = 0;
  double _percent = 0;

  @override
  void initState() {
    super.initState();
    _total = widget.videoDetail.streamInfo.size;
    _startDownload();
  }

  
  // FIXME: I should implement a new model where I can manipulate the download
  // and callback's, but for now, due to time, I'm going to do this
  Future<void> _startDownload() async {
    /*
    // NOTE: Only for tests
    Future.delayed(const Duration(seconds: 3)).whenComplete(() {
      _notifyDownloadDone();
    });
    */
    var downloadPath = await FileSupport().getDownloadFolderPath();
    final container = widget.videoDetail.streamInfo.container;
    final input = File('$downloadPath/input.$container');

    try {
      var streamInfo = widget.videoDetail.streamInfo;
      var stream = widget.videoDetail.yt.videos.streamsClient.get(streamInfo);
      // Delete the file if exists.
      if (input.existsSync()) {
        input.deleteSync();
      }

      // Download file
      var sink = input.openWrite();
      await for (final data in stream) {
        setState(() {
          _received += data.length;
          _percent = (_received / _total.totalBytes);
          sink.add(data);
        });
      }

      await sink.close();
      if (widget.videoDetail.type == Type.music) {
        final output = File('$downloadPath/output.mp3');
        final flutterFFmpeg = FlutterFFmpeg();
        final res = await flutterFFmpeg.execute("-i ${input.path} ${output.path}");
        if (res != 0) throw Exception('Error parse mp4 to mp3');
        await MediaStore.saveFile(output.path);
        //await MediaFileSaver.saveFile(output.path);
        if (await output.exists()) {
          await output.delete();
        }
      } else {
        // Refresh android media and generate a new file inside Rost folder
        await MediaStore.saveFile(input.path);
        //await MediaFileSaver.saveFile(input.path);
      }
      // Delete older file
      input.deleteSync();
      _notifyDownloadDone();
    } catch (e) {
      _notifyDownloadError();
      debugPrint('Error: $e');
      if (await input.exists()) {
        await input.delete();
      }
    }
  }

  void _notifyDownloadDone() {
    setState(() {
      _isFinished = true;
      _notifyUser(message: 'Download concluído');
    });
  }

  void _notifyDownloadError() {
    setState(() {
      _isThereError = true;
      _isFinished = true;
      _notifyUser(message: 'Sentimos muito :( Não foi possíve realizar o download.');
    });
  }

  void _notifyUser({required String message}) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (isAllowed) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: _id++,
            channelKey: 'basic_channel',
            title: widget.videoDetail.video.title,
            body: message,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final about = SizedBox(
      height: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              widget.videoDetail.video.title.trim(),
              style: style.ProgressVideo.title,
              maxLines: 1,
              softWrap: true,
            ),
          ),
        ],
      ),
    );

    final sizeInfo = Row(
      children: <Widget>[
        Text(
          '${FileSize(_received)} / $_total',
          style: style.ProgressVideo.size,
        ),
      ],
    );

    final progress = LinearProgressIndicator(
      minHeight: 5,
      color: Colors.blueAccent[700],
      backgroundColor: Colors.grey[350],
      value: _percent,
    );

    final information = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          about,
          sizeInfo,
          const SizedBox(height: 8),
          progress,
        ],
      ),
    );

    var icon = Container(
      width: ProgressVideo._side,
      height: ProgressVideo._side,
      decoration: BoxDecoration(
        color: style.ProgressVideo.iconBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getIcon(),
        color: style.ProgressVideo.iconColor,
        size: ProgressVideo._side - 10,
      ),
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 75,
      decoration: BoxDecoration(
        color: style.ProgressVideo.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          icon,
          const SizedBox(width: 10),
          information,
        ],
      ),
    );
  }

  IconData _getIcon() {
    var option = widget.videoDetail.type;

    if (_isThereError) {
      return Icons.report_problem;
    } else if (_isFinished) {
      return Icons.file_download_done_outlined;
    } else {
      return option == Type.video ? Icons.videocam : Icons.headset;
    }
  }
}
