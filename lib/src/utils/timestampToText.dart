String timestampToText(int timestamp) {
  String hour = "00";
  String minute = "00";
  String second = "00";

  if (timestamp ~/ 3600 < 10) {
    hour = "0${timestamp ~/ 3600}";
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

  return '$hour:$minute:$second';
}
