import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screen/map_search_screen.dart';
import '../../style/palette.dart';
import '../../style/textstyle.dart';

class SearchBoxWidget extends ConsumerStatefulWidget {
  const SearchBoxWidget(
      {super.key,
      required this.textControllerForStart,
      required this.textControllerForEnd,
      required this.onClickClear});

  final TextEditingController textControllerForStart;
  final TextEditingController textControllerForEnd;
  final Function(SearchType) onClickClear;

  @override
  SearchBoxWidgetState createState() => SearchBoxWidgetState();
}

class SearchBoxWidgetState extends ConsumerState<SearchBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 35),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      child: Column(
        children: <Widget>[
          searchBox(SearchType.start, widget.textControllerForStart),
          searchBox(SearchType.destination, widget.textControllerForEnd),
        ],
      ),
    );
  }

  // 검색창 위젯
  Widget searchBox(SearchType type, TextEditingController textController) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(boxShadow: [
        BoxShadow(
            spreadRadius: 5,
            blurRadius: 10,
            color: Color.fromRGBO(0, 0, 0, 0.07))
      ]),
      width: MediaQuery.of(context).size.width - 60,
      height: 60,
      child: TextField(
        style: TextStyles.searchBoxTextStyle,
        onChanged: (value) {
          if (value != "") {
            if (type == SearchType.start) {
              // 출발지 검색
              ref.read(searchStartPlaceProvider.notifier).getPlaces(value);
            } else {
              // 도착지 검색
              ref
                  .read(searchDestinationPlaceProvider.notifier)
                  .getPlaces(value);
            }
          }
        },
        controller: textController,
        decoration: InputDecoration(
          hintStyle: TextStyles.hintTextStyle,
          hintText: type == SearchType.start ? "출발지를 입력해주세요" : "도착지를 입력해주세요",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
              icon: Image.asset(
                'assets/icons/xmark.png',
                scale: 3.5,
              ),
              onPressed: () {
                textController.clear();
                widget.onClickClear(type);
              }),
          filled: true,
          fillColor: Palette.searchBoxColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
