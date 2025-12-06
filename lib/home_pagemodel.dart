part of 'home_page.dart';

abstract class HomePageModel extends State<HomePage> {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];
  final ApiService _apiService = ApiService();
  SongData? _songData;
  bool _isLoading = false;

  List<Map<String, dynamic>> _getPlatformList() {
    if (_songData == null) return [];

    final platforms = <Map<String, dynamic>>[];

    if (_songData!.spotifyUrl != null) {
      platforms.add({
        'name': 'Spotify',
        'url': _songData!.spotifyUrl!,
        'icon': PhosphorIcons.spotifyLogo(),
        'color': const Color(0xFF1DB954),
      });
    }

    if (_songData!.youtubeMusicUrl != null) {
      platforms.add({
        'name': 'YT Music',
        'url': _songData!.youtubeMusicUrl!,
        'icon': Icons.play_circle_outline,
        'color': Colors.red,
      });
    }

    if (_songData!.youtubeUrl != null) {
      platforms.add({
        'name': 'YouTube',
        'url': _songData!.youtubeUrl!,
        'icon': PhosphorIcons.youtubeLogo(),
        'color': Colors.red[700]!,
      });
    }

    return platforms;
  }

  @override
  void initState() {
    super.initState();

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        setState(() {
          _sharedFiles.clear();
          _sharedFiles.addAll(value);

          log(_sharedFiles.map((f) => f.toMap()).toString());

          if (_sharedFiles.isNotEmpty) {
            _fetchSongData(_sharedFiles.first.path);
          }
        });
      },
      onError: (err) {
        log("getIntentDataStream error: $err");
      },
    );

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);
        log(_sharedFiles.map((f) => f.toMap()).toString());

        if (_sharedFiles.isNotEmpty) {
          _fetchSongData(_sharedFiles.first.path);
        }

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  Future<void> _fetchSongData(String url) async {
    setState(() {
      _isLoading = true;
      _songData = null;
    });

    final songData = await _apiService.fetchSongLinks(url);

    setState(() {
      _songData = songData;
      _isLoading = false;
    });
  }
}