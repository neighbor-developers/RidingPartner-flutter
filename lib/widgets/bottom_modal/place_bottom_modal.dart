import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/screen/navigation_screen.dart';
import 'package:ridingpartner_flutter/style/textstyle.dart';

import '../../models/place.dart';

class PlaceBottomModal extends StatelessWidget {
  const PlaceBottomModal({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.fromLTRB(24, 38, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(place.title, style: TextStyles.modalTitleTextStyle),
                const SizedBox(
                  height: 8,
                ),
                if (place.roadAddress == null || place.roadAddress == "") ...[
                  Text(place.jibunAddress, style: TextStyles.modalSubTextStyle)
                ] else ...[
                  Text(place.roadAddress!, style: TextStyles.modalSubTextStyle)
                ],
                const SizedBox(height: 16.0),
                const Divider(
                  color: Color.fromRGBO(233, 236, 239, 1),
                  thickness: 1.0,
                ),
                const SizedBox(height: 16.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    place.image!,
                    height: 180.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            )),
        InkWell(
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NavigationScreen(places: [place])));
            },
            child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 60,
                color: const Color.fromRGBO(240, 120, 5, 1),
                child: const Text('안내 시작',
                    style: TextStyles.modalButtonTextStyle)))
      ],
    );
  }
}
