import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  var audios = [
    'assets/audios/سورة قريش.mp3',
    'assets/audios/سورة الاخلاص.mp3'
  ];
  @override
  Widget build(BuildContext context) {
    var assetAudio = AssetsAudioPlayer();
    assetAudio.openPlaylist(Playlist(assetAudioPaths: audios));

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: audios.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(audios[index]),
                onTap: () {
                  assetAudio.playlistPlayAtIndex(index);
                },
              ),
            ),
          ),
          Slider(
              value: value,
              onChanged: (x) {
                this.value = x;
                setState(() {});
              }),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.navigate_before),
                    onPressed: () {
                      

                      assetAudio.playlistPrevious();
                    }),
                IconButton(icon: Icon(Icons.pause), onPressed: () {}),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () {
                      assetAudio.playlistNext();
                    })
              ],
            ),
          )
        ],
      ),
    );
  }

  double value = 0;
}
