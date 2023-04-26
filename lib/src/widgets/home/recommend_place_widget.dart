import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/place.dart';
import '../../style/textstyle.dart';
import '../../utils/get_record_place.dart';
import '../bottom_modal/place_bottom_modal.dart';

final recommendPlaceProvider = FutureProvider<List<Place>>((ref) async {
  return await getRecomendPlace();
});

class RecommendPlaceWidget extends ConsumerStatefulWidget {
  const RecommendPlaceWidget({super.key});

  @override
  RecommendPlaceWidgetState createState() => RecommendPlaceWidgetState();
}

class RecommendPlaceWidgetState extends ConsumerState<RecommendPlaceWidget> {
  @override
  Widget build(BuildContext context) {
    final recommendPlace = ref.watch(recommendPlaceProvider);
    return recommendPlace.when(
      data: (data) {
        return Column(
          children: [
            recommendPlaceText(data[0].title),
            Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(children: [
                  recommendPlaceWidget(data[0]),
                  const SizedBox(
                    width: 15,
                  ),
                  recommendPlaceWidget(data[1])
                ]))
          ],
        );
      },
      loading: () {
        return const CircularProgressIndicator();
      },
      error: (error, stack) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text('추천 명소를 불러오는데 실패하였습니다')));
      },
    );
  }

  Widget recommendPlaceWidget(Place? place) {
    return Flexible(
      flex: 1,
      child: place == null
          ? Container(
              alignment: Alignment.center,
              height: 130,
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: const Text(
                "추천 명소를\n불러오고 있습니다",
                style: TextStyles.recordDescriptionTextStyle,
              ),
            )
          : Stack(
              children: [
                SizedBox(
                    height: 130,
                    child: InkWell(
                        onTap: () {
                          routeDialog(place);
                        },
                        child: Stack(children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.asset(
                                place.image!,
                                height: 130.0,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: Color.fromARGB(45, 0, 0, 0)))
                        ]))),
                Container(
                  height: 130,
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    place.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.recommendTextStyle,
                    textAlign: TextAlign.end,
                  ),
                )
              ],
            ),
    );
  }

  Widget recommendPlaceText(String title) {
    final String username =
        FirebaseAuth.instance.currentUser?.displayName ?? '파트너';

    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
        child: Text.rich(
          TextSpan(
              text: '$username님, 오늘같은 날에는\n',
              style: TextStyles.recommendPlaceTextStyle,
              children: <TextSpan>[
                TextSpan(
                    text: '\'$title\'',
                    style: TextStyles.recommendPlaceTextStyle2),
                const TextSpan(
                    text: ' 어떠세요?', style: TextStyles.recommendPlaceTextStyle)
              ]),
          textAlign: TextAlign.start,
        ));
  }

  void routeDialog(Place place) => showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (BuildContext context) => PlaceBottomModal(place: place));
}
