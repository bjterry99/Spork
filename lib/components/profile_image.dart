import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage(
    this.url,
    this.size,
    this.iconSize, {
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    Key? key,
  }) : super(key: key);
  final String url;
  final double size;
  final double iconSize;
  final EdgeInsets padding;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        margin: margin,
        padding: padding,
        child: url != ''
            ? CachedNetworkImage(
                imageUrl: url,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CustomColors.grey1,
                  ),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  backgroundColor: CustomColors.grey1,
                  child: Icon(
                    Icons.error,
                    size: iconSize,
                    color: CustomColors.grey3,
                  ),
                ),
              )
            : CircleAvatar(
                backgroundColor: CustomColors.grey1,
                child: Icon(
                  Icons.person,
                  size: iconSize,
                  color: CustomColors.grey3,
                ),
              ),
      ),
    );
  }
}
