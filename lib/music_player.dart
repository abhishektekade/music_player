import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo, this.changeTrack, this.key}) : super(key: key);
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double minvalue = 0.0, maxvalue = 0.0, currentvalue = 0.0;
  String currentTime = "", endtime = "";
  bool isPlaying = false;

  final AudioPlayer player = AudioPlayer();
  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  void dispose() {
    super.dispose();
    player?.dispose();
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentvalue = minvalue;
    maxvalue = player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime = getDuration(currentvalue);
      endtime = getDuration(currentvalue);
    });
    isPlaying = false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentvalue = duration.inMilliseconds.toDouble();
      setState(() {
        currentTime = getDuration(currentvalue);
      });
    });
  }

  void changeStatus() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(":");
  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              // get back
            },
            icon: Icon(Icons.arrow_back, color: Colors.black)),
        title: Text('Now Playing', style: TextStyle(color: Colors.black)),
      ),
      body: Container(
          margin: EdgeInsets.fromLTRB(5, 40, 5, 0),
          child: Column(
            children: <Widget>[
              // this is song album background image
              CircleAvatar(
                backgroundImage: widget.songInfo.albumArtwork == null
                    ? AssetImage('assets/images/music_gradient.jpg')
                    : FileImage(File(widget.songInfo.albumArtwork)),
                radius: 95,
              ),
              // below is song title info
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 7),
                child: Text(
                  widget.songInfo.title,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              // below is artist name
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Text(
                  widget.songInfo.artist,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500),
                ),
              ),
              // Track Slider music Progresss
              Slider(
                inactiveColor: Colors.black12,
                activeColor: Colors.black,
                min: minvalue,
                max: maxvalue,
                value: currentvalue,
                onChanged: (value) {
                  currentvalue = value;
                  player.seek(Duration(milliseconds: currentvalue.round()));
                },
              ),
              Container(
                  transform: Matrix4.translationValues(0, -5, 0),
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentTime,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        endtime,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),

              // Buttons to Move to next or to Previous
              Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // previous button
                      GestureDetector(
                        child: Icon(Icons.skip_previous,
                            color: Colors.black, size: 55),
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          widget.changeTrack(false);
                        },
                      ),
                      // Play/Pause Button
                      GestureDetector(
                        child: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: Colors.black,
                            size: 75),
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          changeStatus();
                        },
                      ),
                      // next Track Button
                      GestureDetector(
                        child: Icon(Icons.skip_next,
                            color: Colors.black, size: 55),
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          widget.changeTrack(true);
                        },
                      ),
                    ],
                  ))
            ],
          )),
    );
  }
}
