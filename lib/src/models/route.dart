import 'dart:convert';

class RidingRoute {
  String? id;
  String? title;
  String? description;
  String? image;
  String? routeImage;
  List<String>? route;

  RidingRoute(
      {this.id,
      this.title,
      this.description,
      this.image,
      this.routeImage,
      this.route});

  factory RidingRoute.fromJson(Map<String, dynamic> json) => RidingRoute(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        image: json["image"],
        routeImage: json["routeImage"],
        route: List<String>.from(json['route']),
      );
  factory RidingRoute.fromDB(db) => RidingRoute(
        id: db?["id"],
        title: db?["title"],
        description: db?["description"],
        image: db?["image"],
        routeImage: db?["routeImage"],
        route: List<String>.from(json.decode(db?['route'])),
      );

  Map<String, dynamic> toDB() {
    return {
      if (id != null) "id": id,
      if (title != null) "title": title,
      if (description != null) "description": description,
      if (image != null) "image": image,
      if (routeImage != null) "routeImage": routeImage,
      if (route != null) "route": json.encode(route),
    };
  }
}

class RouteList {
  final List<RidingRoute>? routes;
  RouteList({this.routes});

  factory RouteList.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);

    List<RidingRoute> routes = <RidingRoute>[];
    routes = listFromJson.map((route) => RidingRoute.fromJson(route)).toList();
    return RouteList(routes: routes);
  }
}

class NaverRouteData {
  List<Routes>? routes;

  NaverRouteData({this.routes});

  NaverRouteData.fromJson(Map<String, dynamic> json) {
    if (json['routes'] != null) {
      routes = <Routes>[];
      json['routes'].forEach((v) {
        routes!.add(Routes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (routes != null) {
      data['routes'] = routes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Routes {
  RouteSummary? summary;
  String? routeFullpath;
  List<Legs>? legs;

  Routes({this.summary, this.routeFullpath, this.legs});

  Routes.fromJson(Map<String, dynamic> json) {
    summary =
        json['summary'] != null ? RouteSummary.fromJson(json['summary']) : null;
    routeFullpath = json['route_fullpath'];
    if (json['legs'] != null) {
      legs = <Legs>[];
      json['legs'].forEach((v) {
        legs!.add(Legs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    data['route_fullpath'] = routeFullpath;
    if (legs != null) {
      data['legs'] = legs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RouteSummary {
  int? distance;
  int? duration;
  Bounds? bounds;
  int? routeOption;
  String? toll;
  int? taxiFare;
  Start? start;
  Start? end;
  List<End>? waypoints;
  List<RoadSummary>? roadSummary;
  FacilityCount? facilityCount;
  int? destinationDir;
  String? engineVersion;
  String? resultVersion;
  String? coordType;

  RouteSummary(
      {this.distance,
      this.duration,
      this.bounds,
      this.routeOption,
      this.toll,
      this.taxiFare,
      this.start,
      this.end,
      this.waypoints,
      this.roadSummary,
      this.facilityCount,
      this.destinationDir,
      this.engineVersion,
      this.resultVersion,
      this.coordType});

  RouteSummary.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    duration = json['duration'];
    bounds = json['bounds'] != null ? Bounds.fromJson(json['bounds']) : null;
    routeOption = json['route_option'];
    toll = json['toll'];
    taxiFare = json['taxi_fare'];
    start = json['start'] != null ? Start.fromJson(json['start']) : null;
    end = json['end'] != null ? Start.fromJson(json['end']) : null;
    if (json['waypoints'] != null) {
      waypoints = <End>[];
      json['waypoints'].forEach((v) {
        waypoints!.add(End.fromJson(v));
      });
    }
    if (json['road_summary'] != null) {
      roadSummary = <RoadSummary>[];
      json['road_summary'].forEach((v) {
        roadSummary!.add(RoadSummary.fromJson(v));
      });
    }
    facilityCount = json['facility_count'] != null
        ? FacilityCount.fromJson(json['facility_count'])
        : null;
    destinationDir = json['destination_dir'];
    engineVersion = json['engine_version'];
    resultVersion = json['result_version'];
    coordType = json['coord_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    if (bounds != null) {
      data['bounds'] = bounds!.toJson();
    }
    data['route_option'] = routeOption;
    data['toll'] = toll;
    data['taxi_fare'] = taxiFare;
    if (start != null) {
      data['start'] = start!.toJson();
    }
    if (end != null) {
      data['end'] = end!.toJson();
    }
    if (waypoints != null) {
      data['waypoints'] = waypoints!.map((v) => v.toJson()).toList();
    }
    if (roadSummary != null) {
      data['road_summary'] = roadSummary!.map((v) => v.toJson()).toList();
    }
    if (facilityCount != null) {
      data['facility_count'] = facilityCount!.toJson();
    }
    data['destination_dir'] = destinationDir;
    data['engine_version'] = engineVersion;
    data['result_version'] = resultVersion;
    data['coord_type'] = coordType;
    return data;
  }
}

class Bounds {
  String? leftTop;
  String? rightBottom;

  Bounds({this.leftTop, this.rightBottom});

  Bounds.fromJson(Map<String, dynamic> json) {
    leftTop = json['left_top'];
    rightBottom = json['right_bottom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['left_top'] = leftTop;
    data['right_bottom'] = rightBottom;
    return data;
  }
}

class Start {
  String? address;
  String? location;

  Start({this.address, this.location});

  Start.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['location'] = location;
    return data;
  }
}

class End {
  String? address;
  String? location;
  int? distance;
  int? duration;

  End({this.address, this.location, this.distance, this.duration});

  End.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    location = json['location'];
    distance = json['distance'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['location'] = location;
    data['distance'] = distance;
    data['duration'] = duration;
    return data;
  }
}

class RoadSummary {
  String? location;
  String? roadName;
  int? distance;
  int? congestion;
  int? speed;

  RoadSummary(
      {this.location,
      this.roadName,
      this.distance,
      this.congestion,
      this.speed});

  RoadSummary.fromJson(Map<String, dynamic> json) {
    location = json['location'];
    roadName = json['road_name'];
    distance = json['distance'];
    congestion = json['congestion'];
    speed = json['speed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['road_name'] = roadName;
    data['distance'] = distance;
    data['congestion'] = congestion;
    data['speed'] = speed;
    return data;
  }
}

class FacilityCount {
  int? crosswalk;

  FacilityCount({this.crosswalk});

  FacilityCount.fromJson(Map<String, dynamic> json) {
    crosswalk = json['crosswalk'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['crosswalk'] = crosswalk;
    return data;
  }
}

class Legs {
  LegSummary? summary;
  List<Steps>? steps;

  Legs({this.summary, this.steps});

  Legs.fromJson(Map<String, dynamic> json) {
    summary =
        json['summary'] != null ? LegSummary.fromJson(json['summary']) : null;
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps!.add(Steps.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LegSummary {
  int? distance;
  int? duration;
  Start? start;
  Start? end;

  LegSummary({this.distance, this.duration, this.start, this.end});

  LegSummary.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    duration = json['duration'];
    start = json['start'] != null ? Start.fromJson(json['start']) : null;
    end = json['end'] != null ? Start.fromJson(json['end']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    if (start != null) {
      data['start'] = start!.toJson();
    }
    if (end != null) {
      data['end'] = end!.toJson();
    }
    return data;
  }
}

class Steps {
  String? path;
  StepSummary? summary;
  Road? road;
  Panorama? panorama;
  Guide? guide;
  Traffic? traffic;

  Steps(
      {this.path,
      this.summary,
      this.road,
      this.panorama,
      this.guide,
      this.traffic});

  Steps.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    summary =
        json['summary'] != null ? StepSummary.fromJson(json['summary']) : null;
    road = json['road'] != null ? Road.fromJson(json['road']) : null;
    panorama =
        json['panorama'] != null ? Panorama.fromJson(json['panorama']) : null;
    guide = json['guide'] != null ? Guide.fromJson(json['guide']) : null;
    traffic =
        json['traffic'] != null ? Traffic.fromJson(json['traffic']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (road != null) {
      data['road'] = road!.toJson();
    }
    if (panorama != null) {
      data['panorama'] = panorama!.toJson();
    }
    if (guide != null) {
      data['guide'] = guide!.toJson();
    }
    if (traffic != null) {
      data['traffic'] = traffic!.toJson();
    }
    return data;
  }
}

class StepSummary {
  int? distance;
  int? duration;
  String? stepSummary;

  StepSummary({this.distance, this.duration, this.stepSummary});

  StepSummary.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    duration = json['duration'];
    stepSummary = json['step_summary'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    data['step_summary'] = stepSummary;
    return data;
  }
}

class Road {
  int? roadType;
  String? roadName;
  int? roadNo;
  int? laneNum;
  int? roadStructure;

  Road(
      {this.roadType,
      this.roadName,
      this.roadNo,
      this.laneNum,
      this.roadStructure});

  Road.fromJson(Map<String, dynamic> json) {
    roadType = json['road_type'];
    roadName = json['road_name'];
    roadNo = json['road_no'];
    laneNum = json['lane_num'];
    roadStructure = json['road_structure'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['road_type'] = roadType;
    data['road_name'] = roadName;
    data['road_no'] = roadNo;
    data['lane_num'] = laneNum;
    data['road_structure'] = roadStructure;
    return data;
  }
}

class Panorama {
  String? id;
  String? location;
  int? pan;
  int? tilt;

  Panorama({this.id, this.location, this.pan, this.tilt});

  Panorama.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    location = json['location'];
    pan = json['pan'];
    tilt = json['tilt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['location'] = location;
    data['pan'] = pan;
    data['tilt'] = tilt;
    return data;
  }
}

class Guide {
  String? turnPoint;
  String? direction;
  int? turn;
  int? entranceType;
  String? point;
  String? content;
  String? instructions;

  Guide(
      {this.turnPoint,
      this.direction,
      this.turn,
      this.entranceType,
      this.point,
      this.content,
      this.instructions});

  Guide.fromJson(Map<String, dynamic> json) {
    turnPoint = json['turn_point'];
    direction = json['direction'];
    turn = json['turn'];
    entranceType = json['entrance_type'];
    point = json['point'];
    content = json['content'];
    instructions = json['instructions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['turn_point'] = turnPoint;
    data['direction'] = direction;
    data['turn'] = turn;
    data['entrance_type'] = entranceType;
    data['point'] = point;
    data['content'] = content;
    data['instructions'] = instructions;
    return data;
  }
}

class Traffic {
  int? congestion;
  int? speed;

  Traffic({this.congestion, this.speed});

  Traffic.fromJson(Map<String, dynamic> json) {
    congestion = json['congestion'];
    speed = json['speed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['congestion'] = congestion;
    data['speed'] = speed;
    return data;
  }
}
