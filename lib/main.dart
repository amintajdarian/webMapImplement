import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, Widget) {
            return const MyHomePage(title: 'Flutter Demo Home Page');
          }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late LocationPermission permission;
  _CustomZoomPanBehavior _mapZoomPanBehavior = _CustomZoomPanBehavior();

  var _data = const [
    Model('Brazil', 34.7983, 48.5148),
  ];
  Position position1 = Position(
    latitude: 34.7983,
    longitude: 48.5148,
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    timestamp: DateTime.now(),
    floor: 0,
    speedAccuracy: 0.0,
  );
  @override
  void initState() {
    _mapZoomPanBehavior = _CustomZoomPanBehavior()..onTap = updateMarkerChange;
    super.initState();
  }

  void updateMarkerChange(Offset position) {
    mapController.pixelToLatLng(position);

    /// Removed [MapTileLayer.initialMarkersCount] property and updated
    /// markers only when the user taps.
    if (mapController.markersCount > 0) {
      mapController.clearMarkers();
    }
    mapController.insertMarker(0);
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    ).then((Position position) {
      MapLatLng newLatlng = MapLatLng(position.latitude, position.longitude);
      mapController.pixelToLatLng(Offset(newLatlng.latitude, newLatlng.longitude));

      if (mapController.markersCount > 0) {
        mapController.clearMarkers();
      }
      mapController.insertMarker(0);
      position1 = position;
      setState(() {});
    }).catchError((e) {});
  }

  late MapTileLayerController mapController = MapTileLayerController();

  @override
  Widget build(BuildContext context) {
    initState() {
      super.initState();
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Stack(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).

            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              MapTileLayer(
                onWillPan: (p0) {
                  // print(p0.focalLatLng);
                  return true;
                },
                onWillZoom: (p0) {
                  print(p0.focalLatLng);
                  return true;
                },
                zoomPanBehavior: _mapZoomPanBehavior,
                controller: mapController,
                initialFocalLatLng: MapLatLng(
                  position1.latitude,
                  position1.longitude,
                ),
                initialZoomLevel: 15,
                initialMarkersCount: 1,
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                markerBuilder: (BuildContext context, int index) {
                  return MapMarker(
                    latitude: position1.latitude,
                    longitude: position1.longitude,
                    size: const Size(20, 20),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red[800],
                    ),
                  );
                },
              ),
              Positioned(
                  bottom: 5.sp,
                  right: 5.sp,
                  child: Visibility(
                    visible: true,
                    child: ElevatedButton(
                        onPressed: () async {
                          permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                            if (permission == LocationPermission.deniedForever) {
                              return Future.error('Location permissions are permanently denied, we cannot request permissions.');
                            }

                            if (permission == LocationPermission.denied) {
                              return Future.error('Location permissions are denied');
                            }
                          }
                          await _getCurrentLocation();
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white, shadowColor: Colors.grey, elevation: 10, onPrimary: Colors.grey[500], fixedSize: Size(35.sp, 35.sp), shape: const CircleBorder()),
                        child: Icon(
                          Icons.my_location,
                          size: 14.sp,
                          color: Colors.red,
                        )),
                  ))
            ],
          ),
        ));
  }
}

class Model {
  const Model(this.country, this.latitude, this.longitude);

  final String country;
  final double latitude;
  final double longitude;
}

class _CustomZoomPanBehavior extends MapZoomPanBehavior {
  _CustomZoomPanBehavior();
  late MapTapCallback onTap;

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent) {
      onTap(event.localPosition);
    }
    super.handleEvent(event);
  }
}

typedef MapTapCallback = void Function(Offset position);
