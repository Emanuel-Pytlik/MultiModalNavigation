import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fetch Data Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text('API Testing'),
            ),
            body: Text(multiModalPaths("Berkeley", "Oakland", 3, true, true,
                    false, false, false, true)
                .toString())));
  }

  Future encodeAddress(address) async {
    var url = 'https://maps.googleapis.com/maps/api/geocode/';
    var outputFormat = 'json' + '?';
    var parameters = 'address=' + Uri.encodeComponent(address);
    var apiKey = '&key=' + '<INSERT_API_KEY>';

    final response =
        await http.get(Uri.parse(url + outputFormat + parameters + apiKey));
    List responseJson = json.decode("[" + response.body.toString() + "]");
    var lat = responseJson[0]['results'][0]['geometry']['location']['lat'];
    var lng = responseJson[0]['results'][0]['geometry']['location']['lng'];

    //print([lat, lng]);
    return [lat, lng];
  }

  Future decodeCoordinates(lat, lng) async {
    var url = 'https://maps.googleapis.com/maps/api/geocode/';
    var outputFormat = 'json?';
    var parameters = 'latlng=' + lat.toString() + ',' + lng.toString();
    var apiKey = '&key=' + '<INSERT_API_KEY>';

    final response =
        await http.get(Uri.parse(url + outputFormat + parameters + apiKey));
    var responseJson = json.decode("[" + response.body.toString() + "]");

    //print(responseJson);
    return responseJson;
  }

  List computeWaypoints(coordinates, numberWaypoints) {
    List waypoints = [coordinates[0]]; // Add origin

    for (var point = 0; point < numberWaypoints; point++) {
      var tmpPointLat = waypoints[point][0] +
          (coordinates[1][0] - coordinates[0][0]) / (numberWaypoints + 1);
      var tmpPointLng = waypoints[point][1] +
          (coordinates[1][1] - coordinates[0][1]) / (numberWaypoints + 1);
      waypoints.add([tmpPointLat, tmpPointLng]);
    }
    waypoints.add(coordinates[1]); // Add destination
    //print(waypoints);
    return waypoints;
  }

  Future computeRoute(
      originLat, originLng, destinationLat, destinationLng, mode) async {
    var headers = {
      "X-Goog-API-Key": "<INSERT_API_KEY>",
      "X-Goog-FieldMask":
          "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline",
      "Content-Type": "application/json"
    };
    var body = {
      "origin": {
        "location": {
          "latLng": {"latitude": originLat, "longitude": originLng}
        }
      },
      "destination": {
        "location": {
          "latLng": {"latitude": destinationLat, "longitude": destinationLng}
        }
      },
      "travelMode": mode,
      //"routingPreference": "TRAFFIC_AWARE",
      //"departureTime": departureTime,
      "computeAlternativeRoutes": false,
      "routeModifiers": {
        "avoidTolls": false,
        "avoidHighways": false,
        "avoidFerries": false
      },
      "languageCode": "en-US",
      "units": "IMPERIAL"
    };
    final response = await http.post(
        Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes'),
        headers: headers,
        body: jsonEncode(body));
    List responseJson = json.decode("[" + response.body.toString() + "]");
    if (responseJson[0].containsKey('error')) {
      print('Error: ${responseJson[0]["error"]["message"]}');
      return {};
    } else {
      //print(responseJson[0]['routes'][0]);
      return responseJson[0]['routes'][0];
    }
  }

  Future computeRouteSegments(waypoints, modes) async {
    var numberSegments = waypoints.length - 1;
    var numberModes = modes.length;
    List routeSegments = [];
    List routeModes = [];

    for (var waypoint = 0; waypoint < numberSegments; waypoint++) {
      routeModes = [];
      for (var mode = 0; mode < numberModes; mode++) {
        var tmp = await computeRoute(
            waypoints[waypoint][0],
            waypoints[waypoint][1],
            waypoints[waypoint + 1][0],
            waypoints[waypoint + 1][1],
            modes[mode]);
        var origin = await decodeCoordinates(
            waypoints[waypoint][0], waypoints[waypoint][1]);
        var destination = await decodeCoordinates(
            waypoints[waypoint + 1][0], waypoints[waypoint + 1][1]);
        tmp['origin'] =
            origin[0]['results'][0]['address_components'][1]['short_name'];
        tmp['destination'] =
            destination[0]['results'][0]['address_components'][1]['short_name'];
        tmp['mode'] = modes[mode];
        routeModes.add(tmp);
      }
      routeSegments.add(routeModes);
    }
    //print(routeSegments);
    return routeSegments;
  }

  List optimizeSegments(routeSegments, optimizer) {
    var numberSegments = routeSegments.length;
    var numberModes = routeSegments[0].length;
    double minValue = double.maxFinite;
    var minMode = 0;
    List optimizedSegments = [];

    for (var segment = 0; segment < numberSegments; segment++) {
      minMode = 0;
      for (var mode = 0; mode < numberModes; mode++) {
        var value = routeSegments[segment][mode][optimizer];
        if (optimizer == 'duration') {
          value = double.parse(value.toString().replaceAll('s', ''));
        }
        if (value.toDouble() < minValue) {
          minValue = value.toDouble();
          minMode = mode;
        }
      }
      optimizedSegments.add(routeSegments[segment][minMode]);
    }
    //print(optimizedSegments);
    return optimizedSegments;
  }

  Future multiModalPaths(
      String origin,
      String destination,
      int numberStops,
      bool public,
      bool car,
      bool bicicle,
      bool walk,
      bool duration,
      bool distance) async {
    // Build the list of travel modes
    List modes = [];
    if (public) {
      modes.add("TRANSIT");
    }
    if (car) {
      modes.add("DRIVE");
    }
    if (bicicle) {
      modes.add("BICYCLE");
    }
    if (walk) {
      modes.add("WALK");
    }
    // Create the optimizer variable
    String optimizer = "distanceMeters";
    if (duration) {
      optimizer = "duration";
    }
    var coordinatesOrigin = await encodeAddress(origin);
    var coordinatesDestination = await encodeAddress(destination);
    var waypoints = computeWaypoints(
        [coordinatesOrigin, coordinatesDestination], numberStops);
    var routeSegments = await computeRouteSegments(waypoints, modes);
    var optimizedSegments = optimizeSegments(routeSegments, optimizer);

    print(optimizedSegments);
    return optimizedSegments;
  }
}
