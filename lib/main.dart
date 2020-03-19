import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_oldsong/test.dart';

import 'main.dart';

void main() {
  runApp(quran());
}

class quran extends StatefulWidget {
  @override
  _quranState createState() => _quranState();
}

class _quranState extends State<quran> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Test());
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //بتضيف الاصوتيات بملف ال assets بعدين بتستدعي الاسم هنا بس كده
  final assets = <String>[
    "سورة الاخلاص.mp3",
    "سورة قريش.mp3",
    'بسم الله الذي لا يضر.mp3'

  ];
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _assetsAudioPlayer.currentPosition.listen(
          (x) {
        if (_assetsAudioPlayer.current.value != null) {
          value = (x.inSeconds).toDouble();
          setState(() {});
          if (x.inSeconds ==
              _assetsAudioPlayer.current.value.duration.inSeconds - 1 &&
              _assetsAudioPlayer.isPlaying.value == true) {
            _next();
          }
        }
      },
    );
    bannerSize = AdmobBannerSize.BANNER;

    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
      },
    );

    interstitialAd.load();
  }

  var _currentAssetPosition = -1;

  void _open(int assetIndex) {
    _currentAssetPosition = assetIndex % assets.length;
    _assetsAudioPlayer.open('assets/audios/${assets[_currentAssetPosition]}'
    );
  }



  void _playPause() {
    _assetsAudioPlayer.playOrPause();
  }

  void _next() {
    _currentAssetPosition++;
    _open(_currentAssetPosition);
  }

  void _prev() {
    _currentAssetPosition--;
    _open(_currentAssetPosition);
  }

  @override
  void dispose() {
    _assetsAudioPlayer.stop();
    interstitialAd.dispose();
    super.dispose();
  }

  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;

  @override
  Widget build(BuildContext context) {
//    _assetsAudioPlayer.seek(Duration(seconds: 1));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext ctx) => PopupMenuButton<int>(
              color: Colors.white,
              onSelected: (x) {
// to minutes هنا لتغيير الوقت
                Future.delayed(Duration(minutes: x), () {
                  _assetsAudioPlayer.stop();
                  exit(0);
                });

                Scaffold.of(ctx).showSnackBar(
                    SnackBar(content: Text('App will close after $x min')));
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text("Timer"),
              ),
//              icon: Icon(
//                Icons.close,
//                color: Colors.white,
//              ),
              itemBuilder: (BuildContext context) {
                return [
                  //  PopupMenuItem(value: 0, child: Text('now')),
                  PopupMenuItem(value: 5, child: Text('5 min')),// هنا لخمس دقايق
                  PopupMenuItem(value: 10, child: Text('10 min')),//هنا لعشره وهكذا
                  PopupMenuItem(value: 15, child: Text('15 min'))
                ];
              },
            ),
          ),
          title: const Text('القرآن الكريم',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: Stack(
          children: [
            Builder(
              builder: (BuildContext context) => Image.asset(
                //تضع الصوره في ملف ال assets img وتكتب اسمها هنا
                'assets/img/back.jpg',
                fit: BoxFit.fill,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: StreamBuilder(
                      stream: _assetsAudioPlayer.current,
                      initialData: const PlayingAudio(),
                      builder: (BuildContext context,
                          AsyncSnapshot<PlayingAudio> snapshot) {
                        final PlayingAudio currentAudio = snapshot.data;
                        //  snapshot.data.duration;
                        //assets/audios/بسم الله الذي لا يضر.mp3
                        print(assets[0]);
                        return ListView.builder(
                          reverse: false,
                          itemBuilder: (context, position) {
                            return ListTile(

                                title: Text(


                                    assets[position].substring(
                                        0, assets[position].length - 4),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        color: 'assets/audios/${assets[position]}' ==
                                            currentAudio.assetAudioPath
                                            ? Colors.green
                                            : Colors.white,
                                        fontSize: 28,
                                        fontFamily: "AssetAudioPlayer",
                                        fontWeight: FontWeight.bold)),
                                onTap: () {
                                  _open(position);
                                });
                          },
                          itemCount: assets.length,
                        );
                      },
                    ),
                    //
                  ),
                  Divider(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      StreamBuilder(
                        stream: _assetsAudioPlayer.currentPosition,
                        initialData: const Duration(),
                        builder: (BuildContext context,
                            AsyncSnapshot<Duration> snapshot) {
                          Duration duration = snapshot.data;
                          return Text(
                            durationToString(duration),
                            style: TextStyle(color: Colors.white),
                          );
                        },
                      ),
                      Text(
                        " - ",
                        style: TextStyle(color: Colors.white),
                      ),
                      StreamBuilder(
                        stream: _assetsAudioPlayer.current,
                        builder: (BuildContext context,
                            AsyncSnapshot<PlayingAudio> snapshot) {
                          Duration duration = Duration();
                          if (snapshot.hasData) {
                            //  interstitialAd.show();
                            //بتحذف الكومنت بيشغل الاعلان الكامل

                            duration = snapshot.data.duration;
                          }

                          return Text(durationToString(duration),
                              style: TextStyle(color: Colors.white));
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      IconButton(
                        onPressed: _prev,
                        icon: Icon(Icons.skip_previous, color: Colors.white),
                      ),
                      StreamBuilder(
                        stream: _assetsAudioPlayer.isPlaying,
                        initialData: false,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          return IconButton(
                            onPressed: _playPause,
                            icon: Icon(
                                snapshot.data ? Icons.pause : Icons.play_arrow,
                                color: Colors.white),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        ),
                        onPressed: _next,
                      ),
                    ],
                  ),
                  Slider(
                      activeColor: Colors.white,
                      label: 'heloo',
                      value: value,
                      max: _assetsAudioPlayer.current.value == null
                          ? 100
                          : _assetsAudioPlayer
                          .current.value.duration.inSeconds -
                          1.toDouble(),
                      min: 0,
                      onChangeStart: (x) {
                        _assetsAudioPlayer.pause();
                      },
                      onChangeEnd: (x) {
                        _assetsAudioPlayer.play();
                      },
                      onChanged: (x) {
                        value = x;
                        _assetsAudioPlayer
                            .seek(Duration(seconds: value.toInt()));

                        setState(() {});
                      }),
                  //العلانات
                  Container(

                    margin: EdgeInsets.only(bottom: 20.0),
                    child: AdmobBanner(
                      adUnitId: getBannerAdUnitId(),
                      adSize: AdmobBannerSize.BANNER,
                      listener:
                          (AdmobAdEvent event, Map<String, dynamic> args) {},
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double value = 0;
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes =
  twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  String twoDigitSeconds =
  twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));

  return "$twoDigitMinutes:$twoDigitSeconds";
}

String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544~1458002511';
  } else if (Platform.isAndroid) {
    //هنا كود  تطبيقك للاعلان
    return 'ca-app-pub-3940256099942544~3347511713';
  }
  return null;
}

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    // هنا للبانر
    return 'ca-app-pub-3940256099942544/6300978111';
  }
  return null;
}

String getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/4411468910';
  } else if (Platform.isAndroid) {
    //هنا للشاشه الكامله
    return 'ca-app-pub-3940256099942544/1033173712';
  }
  return null;
}