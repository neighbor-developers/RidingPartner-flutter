// 검색 결과 리스트 위젯
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/place.dart';
import '../../screen/map_search_screen.dart';
import '../../style/palette.dart';
import '../place/highlight_text.dart';

class SearchListWidget extends ConsumerStatefulWidget {
  const SearchListWidget(
      {super.key,
      required this.list,
      required this.textController,
      required this.type,
      required this.onPlaceItemTab});

  final List<Place> list;
  final TextEditingController textController;
  final SearchType type;
  final Function(TextEditingController, Place, SearchType) onPlaceItemTab;

  @override
  SearchListWidgetState createState() => SearchListWidgetState();
}

class SearchListWidgetState extends ConsumerState<SearchListWidget> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              borderOnForeground: true,
              margin: const EdgeInsets.symmetric(vertical: 0.3),
              child: ListTile(
                  title: Row(
                    children: [
                      const ImageIcon(
                          AssetImage('assets/icons/search_marker.png'),
                          size: 18),
                      highlightedText("  ${widget.list[index].title}",
                          widget.textController.text, "title"),
                    ],
                  ),
                  subtitle: highlightedText(widget.list[index].jibunAddress,
                      widget.textController.text, "subtitle"),
                  textColor: Colors.black,
                  tileColor: Palette.searchBoxColor,
                  onTap: () => widget.onPlaceItemTab(
                      widget.textController, widget.list[index], widget.type)));
        },
      ),
    );
  }
}
