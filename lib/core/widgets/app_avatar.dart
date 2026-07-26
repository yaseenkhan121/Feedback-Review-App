import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String photoUrl;
  final String initial;
  final double radius;
  final Color backgroundColor;

  const AppAvatar({
    super.key,
    required this.photoUrl,
    required this.initial,
    this.radius = 24,
    this.backgroundColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl.isNotEmpty;
    final isLocalFile = hasPhoto && !photoUrl.startsWith('http');
    final localFileExists = isLocalFile && File(photoUrl).existsSync();

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: hasPhoto
          ? (isLocalFile
              ? (localFileExists
                  ? ClipOval(
                      child: Image.file(
                        File(photoUrl),
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      initial,
                      style: TextStyle(
                        fontSize: radius * 0.8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ))
              : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    errorWidget: (context, url, error) => Text(
                      initial,
                      style: TextStyle(
                        fontSize: radius * 0.8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ))
          : Text(
              initial,
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
    );
  }
}
