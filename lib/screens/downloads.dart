import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_downloader/components/progress_video.dart';
import 'package:youtube_downloader/models/videos_for_download.dart';
import 'package:youtube_downloader/styles/downloads.dart' as style;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Downloading extends StatefulWidget {
  static const double _radius = 35;

  @override
  _DownloadingState createState() => _DownloadingState();
}

class _DownloadingState extends State<Downloading> {

  void removeFromStackDownloads(Video video) {
    setState(() {
      var videos = VideosForDownload.fetchVideos;
      for (var i = 0; i < videos.length; i++) {
        if (videos[i] == video) {
          videos.removeAt(i);
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final aboutPage = Row(
      children: const <Widget>[
        Icon(Icons.download_for_offline_rounded, size: 40, color: Colors.white),
        SizedBox(width: 20),
        Text('Seus downloads', style: style.Downloading.title),
      ],
    );

    final topSection = Container(
      width: width,
      height: 0.22 * height,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topCenter,
          colors: [
            Color.fromRGBO(49, 77, 201, 1),
            Color.fromRGBO(23, 42, 125, 1),
          ],
        ),
      ),
      child: aboutPage,
    );

    final listSection = Container(
      height: 0.75 * height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Downloading._radius),
          topRight: Radius.circular(Downloading._radius),
        ),
      ),
      child: ListView.separated(
        itemCount: VideosForDownload.fetchVideos.length,
        separatorBuilder: (_, i) => const SizedBox(height: 15),
        itemBuilder: (_, i) => ProgressVideo(
          video: VideosForDownload.fetchVideos[i],
          onClickedClose: () {
            removeFromStackDownloads(VideosForDownload.fetchVideos[i]);
          },
        ),
      ),
    );

    final body = Container(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          topSection,
          Align(alignment: Alignment.bottomCenter, child: listSection),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: body,
    );
  }
}
