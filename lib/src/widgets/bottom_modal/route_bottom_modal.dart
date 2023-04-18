import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';

import '../../style/textstyle.dart';

class RouteBottomModal extends StatelessWidget {
  const RouteBottomModal({super.key, required this.route, required this.onTap});

  final RidingRoute route;
  final Function() onTap;

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
                  route.title!.replaceAll('\n', ' '),
                  style: TextStyles.modalTitleTextStyle,
                  textAlign: TextAlign.end,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(route.description!, style: TextStyles.modalSubTextStyle),
                const SizedBox(
                  height: 8,
                ),
                Text(route.route!.join(' > '),
                    style: TextStyles.modalSubTextStyle),
                const SizedBox(height: 16.0),
                const Divider(
                  color: Color.fromRGBO(233, 236, 239, 1),
                  thickness: 1.0,
                ),
                const SizedBox(height: 16.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    route.image!,
                    height: 160.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            )),
        InkWell(
            onTap: onTap,
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
