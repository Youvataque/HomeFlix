import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter/material.dart';
import 'package:homeflix/Components/ViewComponents/PlayerPages/PlayerOverlay.dart';

class VlcVideoPlayer extends StatefulWidget {
	final String videoUrl;

	const VlcVideoPlayer({
		super.key,
		required this.videoUrl,
	});

	@override
	_VlcVideoPlayerState createState() => _VlcVideoPlayerState();
}

class _VlcVideoPlayerState extends State<VlcVideoPlayer> {
	late VlcPlayerController _vlcPlayerController;
	bool _show = false;
	bool _isInitialized = false;
	Map<int, String> _audioTracks = {};
	Map<int, String> _subtitleTracks = {};

	@override
	void initState() {
		super.initState();
		_initializePlayer();
	}

	void _initializePlayer() {
		_vlcPlayerController = VlcPlayerController.network(
			widget.videoUrl,
			hwAcc: HwAcc.full,
			autoPlay: true,
			options: VlcPlayerOptions(),
		);

		_vlcPlayerController.addListener(() {
			if (_vlcPlayerController.value.isInitialized && !_isInitialized) {
				setState(() {
					_isInitialized = true;
				});
				Future.delayed(const Duration(seconds: 2), () {
					_fetchTracks();
				});
			}
		});
	}

	void _fetchTracks() async {
		try {
		final audioTracks = await _vlcPlayerController.getAudioTracks();
		final subtitleTracks = await _vlcPlayerController.getSpuTracks();
		setState(() {
			_audioTracks = audioTracks;
			_subtitleTracks = subtitleTracks;
		});
		} catch (e) {
			print('Erreur lors de la récupération des pistes: $e');
		}
	}

	@override
	void dispose() {
		_vlcPlayerController.stop();
		_vlcPlayerController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return body();
	}

	Widget body() {
		return Scaffold(
			backgroundColor: Colors.black,
			body: Align(
				alignment: Alignment.center,
				child: Stack(
					children: [
						RotatedBox(
							quarterTurns: 1,
							child: SizedBox(
								width: MediaQuery.sizeOf(context).height,
								height: MediaQuery.sizeOf(context).width,
								child: ElevatedButton(
									onPressed: () {
										setState(() {
											_show = !_show;
										});
									},
									style: ElevatedButton.styleFrom(
										shadowColor: Colors.transparent,
										backgroundColor: Colors.transparent,
										foregroundColor: Colors.transparent,
									),
									child: player(),
								)
							)
						),
						PlayerOverlay(
							show: _show,
							controller: _vlcPlayerController,
							audioTracks: _audioTracks,
							subtitleTracks: _subtitleTracks,
						),
					],
				),
			),
		);
	}

	Widget player() {
		return VlcPlayer(
			controller: _vlcPlayerController,
			aspectRatio: 16 / 9,
			placeholder: const Center(
				child: CircularProgressIndicator(),
			),
		);
	}
}