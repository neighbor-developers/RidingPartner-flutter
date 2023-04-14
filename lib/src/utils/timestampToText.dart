String timestampToText(int timestamp, int type) {
  String hour = "00";
  String minute = "00";
  String second = "00";

  if (timestamp ~/ 3600 < 10) {
    hour = "${timestamp ~/ 3600}";
  } else {
    hour = "${timestamp ~/ 3600}";
  }

  if (timestamp ~/ 60 < 10) {
    minute = "0${timestamp ~/ 60}";
  } else {
    minute = "${timestamp ~/ 60}";
  }
  if (timestamp % 60 < 10) {
    second = "0${timestamp % 60}";
  } else {
    second = "${timestamp % 60}";
  }
  if (type == 0) {
    return '$hour:$minute:$second';
  } else {
    if (hour == '0') {
      return '$minute:$second';
    } else {
      return '$hour:$minute:$second';
    }
  }
}
