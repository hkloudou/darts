import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import './simple_banner_model.dart';
import 'package:flutter/material.dart';

class SimpleBannerWidget extends StatelessWidget {
  final SimpleBannerModel? model;
  final EdgeInsetsGeometry margin;
  const SimpleBannerWidget({
    Key? key,
    this.model,
    this.margin = const EdgeInsets.fromLTRB(
      0,
      0,
      16,
      0,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (model == null) return Container();
    var a = model!;
    if (a.items.isEmpty || !a.enable) return Container();
    var banners = a.items;
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: a.width / a.height,
        autoPlay: banners.length > 1,
        enlargeCenterPage: true,
        enableInfiniteScroll: banners.length > 1,
        viewportFraction: banners.length > 1 ? 0.93 : 1.0,
      ),
      items: banners.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.fromLTRB(
                banners.length > 1 ? 4 : 16,
                0,
                banners.length > 1 ? 4 : 16,
                0,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: Stack(children: <Widget>[
                  (i.blur.isEmpty
                      ? Image.network(
                          i.img,
                          fit: BoxFit.fill,
                        )
                      : BlurHash(
                          imageFit: BoxFit.fill,
                          hash: i.blur,
                          image: i.img,
                        )),
                ]),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
