import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spork/theme.dart';

class DetailsHeader extends StatelessWidget {
  const DetailsHeader({required this.url, Key? key}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    double imgWidth = MediaQuery.of(context).size.width / 1;

    return Material(
      color: CustomColors.white,
      borderRadius:
      const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      elevation: 3,
      child: Stack(
        children: [
          url != '' ? CachedNetworkImage(
            imageUrl: url,
            imageBuilder: (context, imageProvider) => SizedBox(
              height: imgWidth,
              width: imgWidth,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
                child: Image(
                  image: imageProvider,
                ),
              ),
            ),
            placeholder: (context, url) => Container(
              height: imgWidth,
              width: imgWidth,
              decoration: const BoxDecoration(
                  color: CustomColors.grey2,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: CustomColors.grey4,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: imgWidth,
              width: imgWidth,
              decoration: const BoxDecoration(
                  color: CustomColors.grey2,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: CustomColors.grey4,
              ),
            ),
          ) : Container(
            height: imgWidth,
            width: imgWidth,
            decoration: const BoxDecoration(
                color: CustomColors.grey2,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: CustomColors.grey4,
            ),
          ),
          Positioned(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Platform.isAndroid ? Material(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: CustomColors.white,
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(Icons.arrow_back),
                ),
              ) : Stack(
                children: [
                  Material(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: CustomColors.white,
                    child: const SizedBox(height: 38, width: 38,)
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6.5, left: 11),
                    child: Icon(Icons.arrow_back_ios),
                  ),
                ],
              ),
            ),
            top: 10,
            left: 10,
          ),
        ],
      )
      );
  }
}