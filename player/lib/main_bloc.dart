import 'package:just_audio/just_audio.dart';
import 'package:player/bloc/base_bloc.dart';
import 'package:player/repo/entity/song_detail.dart';
import 'package:player/repo/repo_client.dart';
import 'package:player/ui/bottom_player_page.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';

class FtMainBloc extends FtBaseBloc {
  final progressStreamCtrl = BlocStreamController<ProgressBarState>();
  final playerStateStreamCtrl = BlocStreamController<PlayerButtonState>();
  final currentSongDetailsStreamCtrl = BlocStreamController<SongDetails?>();
  final isFirstSongStreamCtrl = BlocStreamController<bool>();
  final isLastSongStreamCtrl = BlocStreamController<bool>();
  final repeatStateStreamCtrl = BlocStreamController<LoopMode>();
  final volumeStreamCtrl = BlocStreamController<double>();
  AudioPlayer? _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  final _client = DataClient();

  void initial() async {
    //TODO: desktop crash
    _audioPlayer = AudioPlayer();
    repeatStateStreamCtrl.add(LoopMode.off);
    prePlayList();
    var initProgressStatus = ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    );
    progressStreamCtrl.add(initProgressStatus);
    playerStateStreamCtrl.add(PlayerButtonState.paused);
    _listenForChangesInPlayerState();
    Rx.combineLatest3(
        _audioPlayer!.positionStream,
        _audioPlayer!.bufferedPositionStream,
        _audioPlayer!.durationStream,
        (position, bufferedPosition, duration) => ProgressBarState(
              current: position,
              buffered: bufferedPosition,
              total: duration ?? Duration.zero,
            )).listen((event) {
      progressStreamCtrl.add(event);
    });
    _listenForChangesInSequenceState();
    _listenForChangesInVolume();
    //获取播放列表
    final response = await _client.requestSongList();
  }

  void _listenForChangesInPlayerState() {
    _audioPlayer?.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        playerStateStreamCtrl.add(PlayerButtonState.loading);
      } else if (!isPlaying) {
        playerStateStreamCtrl.add(PlayerButtonState.paused);
      } else if (processingState != ProcessingState.completed) {
        playerStateStreamCtrl.add(PlayerButtonState.playing);
      } else {
        // completed
        _audioPlayer?.seek(Duration.zero);
        _audioPlayer?.pause();
      }
    });
  }

  void setVolume(double data) async {
    volumeStreamCtrl.add(data);
    _audioPlayer?.setVolume(data);
  }

  void _listenForChangesInVolume() {
    _audioPlayer?.volumeStream.listen((event) {
      volumeStreamCtrl.add(event);
    });
  }

  void _listenForChangesInSequenceState() {
    _audioPlayer?.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // update current song title
      final currentItem = sequenceState.currentSource;
      final songDetails = currentItem?.tag as SongDetails?;
      currentSongDetailsStreamCtrl.add(songDetails);
      final playlist = sequenceState.effectiveSequence;
      // update previous and next buttons
      if (playlist.isEmpty || currentItem == null) {
        isFirstSongStreamCtrl.add(true);
        isLastSongStreamCtrl.add(true);
      } else {
        isFirstSongStreamCtrl.add(playlist.first == currentItem);
        isLastSongStreamCtrl.add(playlist.last == currentItem);
      }
    });
  }

  bool isPlaying() {
    if (_audioPlayer == null) {
      return false;
    } else {
      return _audioPlayer!.playing;
    }
  }

  void play() {
    _audioPlayer?.play();
  }

  void pause() {
    _audioPlayer?.pause();
  }

  void stop() {
    _audioPlayer?.stop();
  }

  void seek(Duration position) {
    _audioPlayer?.seek(position);
  }

  void onPreviousSongButtonPressed() {
    _audioPlayer?.seekToPrevious();
  }

  void onNextSongButtonPressed() {
    _audioPlayer?.seekToNext();
  }

  void onRepeatButtonPressed() {
    switch (repeatStateStreamCtrl.value) {
      case LoopMode.off:
        repeatStateStreamCtrl.add(LoopMode.one);
        break;
      case LoopMode.one:
        repeatStateStreamCtrl.add(LoopMode.all);
        break;
      case LoopMode.all:
        repeatStateStreamCtrl.add(LoopMode.off);
        break;
      default:
        repeatStateStreamCtrl.add(LoopMode.one);
        break;
    }
  }

  void onShuffleButtonPressed() async {
    final enable = _audioPlayer?.shuffleModeEnabled == false;
    if (enable) {
      await _audioPlayer?.shuffle();
    }
    await _audioPlayer?.setShuffleModeEnabled(enable);
  }

  void prePlayList() async {
    final song0 =
        Uri.parse("http://music.163.com/song/media/outer/url?id=5238992.mp3");
    final song1 = Uri.parse(
        'https://cdn.alomerry.com/media/music/J.J.%20Abrams-Fringe%2085-%E3%80%8A%E5%8D%B1%E6%9C%BA%E8%BE%B9%E7%BC%98%20%E7%AC%AC%E4%BA%8C%E5%AD%A3%E3%80%8B%E7%94%B5%E8%A7%86%E5%89%A7%E6%8F%92%E6%9B%B2.mp3');
    final song2 = Uri.parse(
        'https://cdn.alomerry.com/media/music/Hans%20Zimmer-Cornfield%20Chase.flac');
    final song3 = Uri.parse(
        'https://cdn.alomerry.com/media/music/Hypnotized%20-%20Purple%20Disco%20Machine%2CSophie%20and%20the%20Giants.mp3');
    final song4 = Uri.parse(
        'https://cdn.alomerry.com/media/music/%E5%A4%9C%E7%9A%84%E9%92%A2%E7%90%B4%E6%9B%B2%28%E4%BA%94%29.mp3');
    final song5 = Uri.parse(
        'https://cdn.alomerry.com/media/music/%E8%B0%A2%E6%98%8E%E7%A5%A5-%E5%88%9D%E5%A4%8F%E9%9B%A8%E5%90%8E.mp3');
    final song6 = Uri.parse(
        'https://cdn.alomerry.com/media/music/%E6%A8%AA%E5%B1%B1%E5%85%8B%20-%20%E7%A7%81%E3%81%AE%E5%98%98.mp3');
    _playlist = ConcatenatingAudioSource(children: [
      AudioSource.uri(song0,
          tag: SongDetails(
            id: "1",
            name: '偏爱',
            avatar:
                'http://g.hiphotos.baidu.com/image/pic/item/6d81800a19d8bc3e770bd00d868ba61ea9d345f2.jpg',
          )),
      AudioSource.uri(song1,
          tag: SongDetails(
            id: "2",
            name: 'J.J. Abrams-Fringe 85-《危机边缘 第二季》电视剧插曲',
            avatar: 'https://cdn.alomerry.com/media/images/ddns.png',
          )),
      AudioSource.uri(song2,
          tag: SongDetails(
            id: "3",
            name: 'Hans Zimmer-Cornfield Chase',
            avatar:
                'https://cdn.alomerry.com/blog/assets/img/about/qiniu-cdn.svg',
          )),
      AudioSource.uri(song3,
          tag: SongDetails(
            id: "4",
            name: 'Hypnotized - Purple Disco Machine,Sophie and the Giants',
            avatar:
                'http://d.hiphotos.baidu.com/image/pic/item/b58f8c5494eef01f119945cbe2fe9925bc317d2a.jpg',
          )),
      AudioSource.uri(song4,
          tag: SongDetails(
            id: "5",
            name: '夜的钢琴曲(五)',
            avatar:
                'http://d.hiphotos.baidu.com/image/pic/item/b58f8c5494eef01f119945cbe2fe9925bc317d2a.jpg',
          )),
      AudioSource.uri(song5,
          tag: SongDetails(
            id: "6",
            name: '谢明祥-初夏雨后',
            avatar:
                'http://d.hiphotos.baidu.com/image/pic/item/b58f8c5494eef01f119945cbe2fe9925bc317d2a.jpg',
          )),
      AudioSource.uri(song6,
          tag: SongDetails(
            id: "7",
            name: '横山克 - 私の嘘',
            avatar:
                'http://d.hiphotos.baidu.com/image/pic/item/b58f8c5494eef01f119945cbe2fe9925bc317d2a.jpg',
          )),
    ]);
    await _audioPlayer?.setAudioSource(_playlist);
  }

  @override
  void onDispose() {
    _audioPlayer?.dispose();
    currentSongDetailsStreamCtrl.close();
    isFirstSongStreamCtrl.close();
    isLastSongStreamCtrl.close();
    playerStateStreamCtrl.close();
    progressStreamCtrl.close();
    repeatStateStreamCtrl.close();
    volumeStreamCtrl.close();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}
