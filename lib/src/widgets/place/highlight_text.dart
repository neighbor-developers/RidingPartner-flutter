import 'package:flutter/cupertino.dart';

import '../../style/textstyle.dart';

Widget highlightedText(String text, String highlight, String type) {
  highlight = highlight.replaceAll(" ", "");
  final List<String> splitText = text.split(highlight);
  final List<TextSpan> children = [];
  if (type == "title") {
    for (int i = 0; i < splitText.length; i++) {
      children.add(
          TextSpan(text: splitText[i], style: TextStyles.searchBoxTextStyle));
      if (i != splitText.length - 1) {
        children.add(TextSpan(
          text: highlight,
          style: TextStyles.searchBoxHighlightStyle,
        ));
      }
    }
  }
  if (type == "subtitle") {
    for (int i = 0; i < splitText.length; i++) {
      children
          .add(TextSpan(text: splitText[i], style: TextStyles.subTextStyle));
      if (i != splitText.length - 1) {
        children.add(TextSpan(
          text: highlight,
          style: TextStyles.subHighlightStyle,
        ));
      }
    }
  }
  return Text.rich(TextSpan(children: children), textAlign: TextAlign.start);
}
