// ignore_for_file: unnecessary_new, prefer_collection_literals, unnecessary_this

class Weather {
  double? temp;
  double? tempMax;
  double? tempMin;
  String? condition;
  int? humidity;
  String? icon;

  Weather(
      {this.temp,
      this.tempMax,
      this.tempMin,
      this.condition,
      this.icon,
      this.humidity});
}

// class Weather {
//   String? skyType;
//   String? temperature;
//   String? humidity;
//   String? rainType;

//   Weather({this.skyType, this.temperature, this.humidity, this.rainType});
// }

// class WeatherData {
//   Response? response;

//   WeatherData({this.response});

//   WeatherData.fromJson(Map<String, dynamic> json) {
//     response =
//         json['response'] != null ? Response.fromJson(json['response']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.response != null) {
//       data['response'] = response!.toJson();
//     }
//     return data;
//   }
// }

// class Response {
//   Header? header;
//   Body? body;

//   Response({this.header, this.body});

//   Response.fromJson(Map<String, dynamic> json) {
//     header =
//         json['header'] != null ? new Header.fromJson(json['header']) : null;
//     body = json['body'] != null ? new Body.fromJson(json['body']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.header != null) {
//       data['header'] = this.header!.toJson();
//     }
//     if (this.body != null) {
//       data['body'] = this.body!.toJson();
//     }
//     return data;
//   }
// }

// class Header {
//   String? resultCode;
//   String? resultMsg;

//   Header({this.resultCode, this.resultMsg});

//   Header.fromJson(Map<String, dynamic> json) {
//     resultCode = json['resultCode'];
//     resultMsg = json['resultMsg'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['resultCode'] = this.resultCode;
//     data['resultMsg'] = this.resultMsg;
//     return data;
//   }
// }

// class Body {
//   String? dataType;
//   Items? items;
//   int? pageNo;
//   int? numOfRows;
//   int? totalCount;

//   Body(
//       {this.dataType,
//       this.items,
//       this.pageNo,
//       this.numOfRows,
//       this.totalCount});

//   Body.fromJson(Map<String, dynamic> json) {
//     dataType = json['dataType'];
//     items = json['items'] != null ? new Items.fromJson(json['items']) : null;
//     pageNo = json['pageNo'];
//     numOfRows = json['numOfRows'];
//     totalCount = json['totalCount'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['dataType'] = this.dataType;
//     if (this.items != null) {
//       data['items'] = this.items!.toJson();
//     }
//     data['pageNo'] = this.pageNo;
//     data['numOfRows'] = this.numOfRows;
//     data['totalCount'] = this.totalCount;
//     return data;
//   }
// }

// class Items {
//   List<Item>? item;

//   Items({this.item});

//   Items.fromJson(Map<String, dynamic> json) {
//     if (json['item'] != null) {
//       item = <Item>[];
//       json['item'].forEach((v) {
//         item!.add(new Item.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.item != null) {
//       data['item'] = this.item!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Item {
//   String? baseDate;
//   String? baseTime;
//   String? category;
//   String? fcstDate;
//   String? fcstTime;
//   String? fcstValue;
//   int? nx;
//   int? ny;

//   Item(
//       {this.baseDate,
//       this.baseTime,
//       this.category,
//       this.fcstDate,
//       this.fcstTime,
//       this.fcstValue,
//       this.nx,
//       this.ny});

//   Item.fromJson(Map<String, dynamic> json) {
//     baseDate = json['baseDate'];
//     baseTime = json['baseTime'];
//     category = json['category'];
//     fcstDate = json['fcstDate'];
//     fcstTime = json['fcstTime'];
//     fcstValue = json['fcstValue'];
//     nx = json['nx'];
//     ny = json['ny'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['baseDate'] = this.baseDate;
//     data['baseTime'] = this.baseTime;
//     data['category'] = this.category;
//     data['fcstDate'] = this.fcstDate;
//     data['fcstTime'] = this.fcstTime;
//     data['fcstValue'] = this.fcstValue;
//     data['nx'] = this.nx;
//     data['ny'] = this.ny;
//     return data;
//   }
// }
