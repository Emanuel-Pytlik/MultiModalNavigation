import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var selectedIndex =  0;
  var source;
  var destination;
  var car = false;
  var public = false;
  var bicycle = false;
  var walk = false;
  var distance = false;
  var duration = false;
  int stops = 0;
  
  void updateSourceDest(source, destination){
    this.source = source;
    this.destination = destination;
    notifyListeners();
  }

  void updateSelectedIndex(index){
    selectedIndex = index;
    notifyListeners();
  }

  void updatecar(car){
      this.car = car;
      notifyListeners();
  }

  void updatepublic(public){
      this.public = public;
      notifyListeners();
  }

  void updatebicycle(bicycle){
      this.bicycle = bicycle;
      notifyListeners();
  }

  void updatewalk(walk){
      this.walk = walk;
      notifyListeners();
  }

  void updatedistance(distance){
      this.distance = distance;
      this.duration = !distance;
      notifyListeners();
  }

  void updateduration(duration){
      this.duration = duration;
      this.distance = !duration;
      notifyListeners();
  }

  void updatestops(stops){
      this.stops = int.parse(stops);
      notifyListeners();
  }
  
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MapForm extends StatefulWidget {
  @override
  State<MapForm> createState() => _MapForm();
}

class CarCheckbox extends StatefulWidget {
  const CarCheckbox({Key? key}) : super(key: key);
  @override
  State<CarCheckbox> createState() => _CarCheckboxState();
}
class _CarCheckboxState extends State<CarCheckbox> {
  bool? isChecked = false; // This holds the state of the checkbox, we call setState and update this whenever a user taps the checkbox
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Checkbox(
      value: isChecked,
      onChanged: (bool? value) { // This is where we update the state when the checkbox is tapped
        setState(() {
          appState.updatecar(value);
          isChecked = value;
        });
      },
    );
  }
}

class PublicCheckbox extends StatefulWidget {
  const PublicCheckbox({Key? key}) : super(key: key);
  @override
  State<PublicCheckbox> createState() => _PublicCheckbox();
}
class _PublicCheckbox extends State<PublicCheckbox> {
  bool? isChecked = false; // This holds the state of the checkbox, we call setState and update this whenever a user taps the checkbox
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Checkbox(
      value: isChecked,
      onChanged: (bool? value) { // This is where we update the state when the checkbox is tapped
        setState(() {
          appState.updatepublic(value);
          isChecked = value;
        });
      },
    );
  }
}

class BicycleCheckbox extends StatefulWidget {
  const BicycleCheckbox({Key? key}) : super(key: key);
  @override
  State<BicycleCheckbox> createState() => _BicycleCheckbox();
}
class _BicycleCheckbox extends State<BicycleCheckbox> {
  bool? isChecked = false; // This holds the state of the checkbox, we call setState and update this whenever a user taps the checkbox
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Checkbox(
      value: isChecked,
      onChanged: (bool? value) { // This is where we update the state when the checkbox is tapped
        setState(() {
          appState.updatebicycle(value);
          isChecked = value;
        });
      },
    );
  }
}

class WalkCheckbox extends StatefulWidget {
  const WalkCheckbox({Key? key}) : super(key: key);
  @override
  State<WalkCheckbox> createState() => _WalkCheckbox();
}
class _WalkCheckbox extends State<WalkCheckbox> {
  bool? isChecked = false; // This holds the state of the checkbox, we call setState and update this whenever a user taps the checkbox
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Checkbox(
      value: isChecked,
      onChanged: (bool? value) { // This is where we update the state when the checkbox is tapped
        setState(() {
          appState.updatewalk(value);
          isChecked = value;
        });
      },
    );
  }
}

class _MapForm extends State<MapForm>{
  final _formKey = GlobalKey<FormState>();
  MapResult mapResult = MapResult();
  TextEditingController source = TextEditingController();
  TextEditingController dest = TextEditingController();
  TextEditingController stops = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  controller: source,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Depature Address',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the depature address';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  controller: dest,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Arrival Address',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the arrival address';
                    }
                    return null;
                  },
                ),
              ),
              Text("Modes of transportation:", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_bus),
                      PublicCheckbox(),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.directions_car),
                      CarCheckbox(),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.directions_bike),
                      BicycleCheckbox(),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.directions_walk),
                      WalkCheckbox(),
                    ],
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text("Optimize by:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Duration: "),
                      Checkbox(
                        value: appState.duration,
                        onChanged: (bool? value) {
                          setState(() {
                            appState.updateduration(value);
                          });
                        },
                      ),
                      Text("Distance: "),
                      Checkbox(
                        value: appState.distance,
                        onChanged: (bool? value) {
                          setState(() {
                            appState.updatedistance(value);
                          });
                        },
                      )
                    ],
                  )
                ]
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Text("Numer of stops:", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    SizedBox(
                      width: 50,
                      height: 70,
                      child: TextFormField(
                        controller: stops,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of stops';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  appState.updateSelectedIndex(1);
                  appState.updateSourceDest(source.text, dest.text);
                  appState.updatestops(stops.text);
                }
              },
              child: const Text('Find Route'),
            ),
          ),
        ],
      ),
    );
  }
}

class MapResult extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
        body: Container(
          child: FutureBuilder<List<Segment>>(
            future: bestSegments(
              appState
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
            itemCount: snapshot.data!.length,
         itemBuilder: (context, index) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          snapshotContent(snapshot, index),
          Divider()
        ]
      );
    }
  );
              } else if (snapshot.hasError) {
                print("ERROR");
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner
              return CircularProgressIndicator();
            },
          ),
        ),
      );
  }

  Container snapshotContent(AsyncSnapshot<List<Segment>> snapshot, int index) {
    var data = snapshot.data![index];
    return Container(
      constraints: BoxConstraints(minWidth: 100),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 158, 49, 15)),
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              rowGenerator("Start", data.start),
              rowGenerator("End", data.end),
              rowGenerator("Duration", data.duration + " seconds"),
              rowGenerator("Distance", data.distance.toString() + "meters"),
              rowGenerator("Mode", data.mode)
            ]
        ),
      ),
    );
  }

  Row rowGenerator(String label, var data) {
    return Row(
      children: [
        Text(label + ":", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 5),
        Text(data)
      ],
    );
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
    var apiKey = '&key=' + 'AIzaSyCinpZUOSmMbDLM0RNQWIFhquY94XR-9nc';

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

  Future computeRoute(originLat, originLng, destinationLat, destinationLng,
      mode) async {
    var headers = {
      "X-Goog-API-Key": "AIzaSyCinpZUOSmMbDLM0RNQWIFhquY94XR-9nc",
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

  Future<List<Segment>> bestSegments(MyAppState appState) async {

    // print("source");
    // print(appState.source);
    // print("destination");
    // print(appState.destination);
    // print("public");
    // print(appState.public);
    // print("car");
    // print(appState.car);
    // print("bicycle");
    // print(appState.bicycle);
    // print("walk");
    // print(appState.walk);
    // print("duration");
    // print(appState.duration);
    // print("distance");
    // print(appState.distance);
    // print("stops");
    // print(appState.stops.toString());

    // var tmp = await encodeAddress(appState.source);
    // var decode = await decodeCoordinates(tmp[0], tmp[1]);
    // print(decode.toString());
    // tmp = await encodeAddress(appState.destination);
    // decode = await decodeCoordinates(tmp[0], tmp[1]);
    // print(decode.toString());

    // var src = await encodeAddress(appState.source);
    // var dest = await encodeAddress(appState.destination);
    
    // var res = await computeRoute(src[0], src[1], dest[0], dest[1], RouteTravelMode.values[0]);
    // print(res.toString());

    // var res = computeWaypoints([src, dest], 3);
    // res = await computeRouteSegments(res, modes);
    // res = optimizeSegments(res, "duration");
    // print(res.toString());

    var paths = await multiModalPaths(
        appState.source,
        appState.destination,
        appState.stops,
        appState.public,
        appState.car,
        appState.bicycle,
        appState.walk,
        appState.duration,
        appState.distance
    );

    List apiSegments = [];
    for (int i = 0; i < paths.length; i++){
        var path = paths[i];
        apiSegments.add(
          {
            "start" : path["origin"],
            "end" : path["destination"],
            "distance" : path["distanceMeters"],
            "mode" : path["mode"],
            "duration" : path["duration"]
          }
        );
    }
    
    // List apiSegments = [
    //   {
    //     "start" : "1310 La Loma Ave, Berkeley, CA, 94708",
    //     "end" : "Soda Hall, Berkeley, CA 94709",
    //     "distance" : 5,
    //     "mode" : "Drive",
    //     "duration" : "181s"
    //   },
    //   {
    //     "start" : "1310 La Loma Ave, Berkeley, CA, 94708",
    //     "end" : "Soda Hall, Berkeley, CA 94709",
    //     "distance" : 5,
    //     "mode" : "Drive",
    //     "duration" : "181s"
    //   },
    //   {
    //     "start" : "1310 La Loma Ave, Berkeley, CA, 94708",
    //     "end" : "Soda Hall, Berkeley, CA 94709",
    //     "distance" : 5,
    //     "mode" : "Drive",
    //     "duration" : "181s"
    //   }
    // ];
    List<Segment> segmentList = createSegmentList(apiSegments);
    return segmentList;
  }
}

class FavoritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('You have '
                '${appState.favorites.length} favorites:'),
          ),
          for (var favorite in favorites)
            ListTile(
              leading: Icon(Icons.favorite),
              title : Text(favorite.asLowerCase)
            ),
        ],
      )
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var selectedIndex = appState.selectedIndex;
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MapForm();
        break;
      case 1:
        page = MapResult();
        break;
      case 2:
        page = GeneratorPage();
        break;
      case 3:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget selected');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 500,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.maps_ugc),
                      label: Text('Map'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map),
                      label: Text('Map'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: appState.selectedIndex,
                  onDestinationSelected: (value) {
                    appState.updateSelectedIndex(value);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class Segment {
  String start;
  String end;
  String duration;
  String mode;
  int distance;

  Segment(
    {
      required this.start,
      required this.end,
      required this.duration,
      required this.mode,
      required this.distance
    }
  );
}

List<Segment> createSegmentList(List apiSegments){
  List<Segment> segments = <Segment>[];

  for (int i = 0; i < apiSegments.length; i++) {

    var apiSegment = apiSegments[i];

    // This drops the "s" from the seconds.
    String duration = apiSegment["duration"];
    if (duration != null && duration.length > 0) {
      duration = duration.substring(0, duration.length - 1);
    }
    
    Segment segment = Segment(
      end: apiSegment["end"],
      start: apiSegment["start"],
      duration: duration,
      mode: apiSegment["mode"],
      distance: apiSegment["distance"],
    );
    
    segments.add(segment);
  }
  return segments;
}

