import 'dart:convert';

import 'package:flutter_naver_map/flutter_naver_map.dart';

class Place {
  String id;
  String title;
  LatLng location;

  String jibunAddress;
  String? roadAddress;
  String? description;
  String? image;
  String? marker;
  String? type;

  Place(
      {required this.id,
      required this.title,
      required this.location,
      required this.jibunAddress,
      this.roadAddress,
      this.description,
      this.image,
      this.marker,
      this.type});

  factory Place.fromJson(Map<String, dynamic> json) => Place(
      id: json["id"],
      title: json["title"],
      location: LatLng(
          double.parse(json["latitude"]), double.parse(json["longitude"])),
      jibunAddress: json["jibunAddress"],
      roadAddress: json["roadAddress"],
      description: json["description"],
      image: json["image"],
      marker: json["marker"],
      type: json["type"]);

  factory Place.fromDB(db) => Place(
      id: db?["id"],
      title: db?["title"],
      location:
          LatLng(double.parse(db["latitude"]), double.parse(db["longitude"])),
      jibunAddress: db?["jibunAddress"],
      roadAddress: db?["roadAddress"],
      description: db?["description"],
      image: db?["image"],
      marker: db?["marker"],
      type: db?["type"]);
}

class PlaceList {
  final List<Place>? places;
  PlaceList({this.places});

  factory PlaceList.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);
    List<Place> places = <Place>[];

    places = listFromJson.map((place) => Place.fromJson(place)).toList();
    return PlaceList(places: places);
  }
}

class NaverPlaceData {
  Meta? meta;
  List<NaverPlace>? place;
  List<All>? all;
  List<Address>? address;

  NaverPlaceData({this.meta, this.place, this.all, this.address});

  NaverPlaceData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['place'] != null) {
      place = <NaverPlace>[];
      json['place'].forEach((v) {
        place!.add(NaverPlace.fromJson(v));
      });
    }
    if (json['address'] != null) {
      address = <Address>[];
      json['address'].forEach((v) {
        address!.add(Address.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (place != null) {
      data['place'] = place!.map((v) => v.toJson()).toList();
    }
    if (all != null) {
      data['all'] = all!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Address {
  String? type;
  String id;
  String title;
  String x;
  String y;
  double? dist;
  double? totalScore;
  String? fullAddress;
  String? shortAddress;

  Address(
      {this.type,
      required this.id,
      required this.title,
      required this.x,
      required this.y,
      this.dist,
      this.totalScore,
      this.fullAddress,
      this.shortAddress});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
      type: json["type"],
      id: json["id"],
      title: json["title"],
      x: json["x"],
      y: json["y"],
      dist: json["dist"],
      totalScore: json["totalScore"],
      fullAddress: json["fullAddress"],
      shortAddress: json["shortAddress"][0]);
}

class Meta {
  String? model;
  String? query;
  String? requestId;

  Meta({this.model, this.query, this.requestId});

  Meta.fromJson(Map<String, dynamic> json) {
    model = json['model'];
    query = json['query'];
    requestId = json['requestId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['model'] = model;
    data['query'] = query;
    data['requestId'] = requestId;
    return data;
  }
}

class NaverPlace {
  String? type;
  String? id;
  String? title;
  String? x;
  String? y;
  double? dist;
  double? totalScore;
  String? sid;
  String? ctg;
  String? cid;
  String? jibunAddress;
  String? roadAddress;
  Review? review;

  NaverPlace(
      {this.type,
      this.id,
      this.title,
      this.x,
      this.y,
      this.dist,
      this.totalScore,
      this.sid,
      this.ctg,
      this.cid,
      this.jibunAddress,
      this.roadAddress,
      this.review});

  NaverPlace.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    title = json['title'];
    x = json['x'];
    y = json['y'];
    dist = json['dist'];
    totalScore = json['totalScore'];
    sid = json['sid'];
    ctg = json['ctg'];
    cid = json['cid'];
    jibunAddress = json['jibunAddress'];
    roadAddress = json['roadAddress'];
    review = json['review'] != null ? Review.fromJson(json['review']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['id'] = id;
    data['title'] = title;
    data['x'] = x;
    data['y'] = y;
    data['dist'] = dist;
    data['totalScore'] = totalScore;
    data['sid'] = sid;
    data['ctg'] = ctg;
    data['cid'] = cid;
    data['jibunAddress'] = jibunAddress;
    data['roadAddress'] = roadAddress;
    if (review != null) {
      data['review'] = review!.toJson();
    }
    return data;
  }
}

class Review {
  String? count;

  Review({this.count});

  Review.fromJson(Map<String, dynamic> json) {
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    return data;
  }
}

class All {
  NaverPlace? place;
  dynamic address;
  dynamic bus;

  All({this.place, this.address, this.bus});

  All.fromJson(Map<String, dynamic> json) {
    place = json['place'] != null ? NaverPlace.fromJson(json['place']) : null;
    address = json['address'];
    bus = json['bus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (place != null) {
      data['place'] = place!.toJson();
    }
    data['address'] = address;
    data['bus'] = bus;
    return data;
  }
}
