import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:ridingpartner_flutter/src/models/route.dart';

class RouteBottomModal extends StatelessWidget {
  const RouteBottomModal({super.key, required this.route, required this.onTap});

  final RidingRoute route;
  final onTap;

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
                  style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.end,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  route.description!,
                  style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  route.route!.join(' > '),
                  style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(51, 51, 51, 0.5)),
                ),
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
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700))))
      ],
    );
  }
}
