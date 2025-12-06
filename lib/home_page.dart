import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'api_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

part 'home_pagemodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends HomePageModel {
  static const Color primaryColor = Color(0xFFFDFDEF);
  static const Color shareButtonColor = Color(0xFFE2DECF);
  static const Color shareIconButtonColor = Color(0xFF60594C);
  static const Color brownColor = Color(0xFF7B6050);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          'Song Link',
          style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _songData == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text(
                  'Şarkı \n      paylaşın!',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    songInformation(context),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: sendButton(),
                        ),
                        platformsList(),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Column songInformation(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _songData!.thumbnailUrl,
            width: MediaQuery.of(context).size.width - 32,
            height: MediaQuery.of(context).size.width - 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: MediaQuery.of(context).size.width - 32,
                height: MediaQuery.of(context).size.width - 32,
                color: Colors.grey[300],
                child: const Icon(Icons.music_note, size: 100),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                _songData!.title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Artist Name
              Text(
                _songData!.artistName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget platformsList() {
    return Center(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: _getPlatformList().length,
          itemBuilder: (context, index) {
            final platform = _getPlatformList()[index];
            return Padding(
              padding: EdgeInsets.only(
                right: index < _getPlatformList().length - 1 ? 12.0 : 0,
              ),
              child: IconButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(text: platform['url'] as String),
                  );
                },
                icon: Icon(platform['icon'] as IconData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: shareButtonColor,
                  foregroundColor: shareIconButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconButton sendButton() {
    return IconButton(
      onPressed: () {
        final shareText =
            '''
Şarkı Adı: ${_songData!.title}
Sanatçı: ${_songData!.artistName}
${_songData!.youtubeMusicUrl != null ? 'YouTube Music: ${_songData!.youtubeMusicUrl}' : ''}
${_songData!.spotifyUrl != null ? 'Spotify: ${_songData!.spotifyUrl}' : ''}''';
        SharePlus.instance.share(ShareParams(text: shareText));
      },
      icon: Icon(PhosphorIcons.shareFat()),
      iconSize: 46,
      padding: const EdgeInsets.all(30),
      style: IconButton.styleFrom(
        backgroundColor: brownColor,
        foregroundColor: primaryColor,
      ),
    );
  }
}
