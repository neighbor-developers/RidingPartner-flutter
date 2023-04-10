
import 'package:flutter/material.dart';

import '../../models/place.dart';

class RouteBottomModal extends StatelessWidget {
  const RouteBottomModal({super.key, required this.place});

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
                Text(
                  place.title!,
                  style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 8,
                ),
                if (place.roadAddress == null || place.roadAddress == "") ...[
                  Text(
                    place.jibunAddress!,
                    style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(51, 51, 51, 0.5)),
                  )
                ] else ...[
                  Text(
                    place.roadAddress!,
                    style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(51, 51, 51, 0.5)),
                  )
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
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => MultiProvider(
              //               providers: [
              //                 ChangeNotifierProvider(
              //                     create: (context) =>
              //                         NavigationProvider([place])),
              //                 ChangeNotifierProvider(
              //                     create: (context) => RidingProvider())
              //               ],
              //               child: const NavigationPage(),
              //             )));
            },
            child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 60,
                color: const Color.fromRGBO(240, 120, 5, 1),
                child: const Text('안내 시작',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700))))
      ],
    );
  }
}
