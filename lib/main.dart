import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as directions;
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASKTU',
      theme: ThemeData(
        primarySwatch: Colors.green, // Renk temasını yeşil olarak değiştir
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Location location = Location();
  LatLng? currentLocation;
  Set<Marker> markers = {};
  Set<Polyline> _polylines = {};

  String? originName;
  String? destinationName;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation =
            LatLng(userLocation.latitude ?? 0.0, userLocation.longitude ?? 0.0);
        markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: currentLocation!,
            infoWindow: InfoWindow(title: 'Şu anki konumunuz'),
          ),
        );
      });
    } catch (e) {
      print("Konum bilgisi alınamadı: $e");
    }
  }

  Future<void> _calculateRoute(String origin, String destination) async {
    final directions.GoogleMapsDirections directionsApi =
        directions.GoogleMapsDirections(
            apiKey: 'AIzaSyDfUGbHVeJLxyiDzo_xruCG5acEFzf3VEw');

    final directions.DirectionsResponse response =
        await directionsApi.directions(
      origin,
      destination,
      travelMode: directions.TravelMode.walking,
    );

    List<LatLng> points = [];

    if (response.status == 'OK') {
      for (final step in response.routes!.first!.legs!.first!.steps!) {
        points.add(LatLng(step.startLocation.lat, step.startLocation.lng));
      }
    }
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('route'),
        color: Colors.green, // Yürüyüş rotası rengini yeşil olarak değiştir
        points: points,
        width: 5,
      );
      markers.clear();
      _polylines.clear();
      _polylines.add(polyline);
    });
  }

  void _showRouteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rota Oluştur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Başlangıç'),
                onChanged: (value) {
                  setState(() {
                    originName = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Bitiş'),
                onChanged: (value) {
                  setState(() {
                    destinationName = value;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (originName != null && destinationName != null) {
                  // Rota hesapla
                  _calculateRoute(originName!, destinationName!);
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Hata'),
                        content: Text(
                            'Lütfen başlangıç ve bitiş noktalarını belirtin.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Tamam'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ASKTU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: currentLocation != null
          ? Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation!,
                    zoom: 15.0,
                  ),
                  markers: markers,
                  polylines: _polylines,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: _showRouteDialog,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white,
                      ),
                      elevation: MaterialStateProperty.all<double>(5),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors
                                .green, // Buton rengini yeşil olarak değiştir
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      'Rota Oluştur',
                      style: TextStyle(
                        color: Colors
                            .green, // Buton yazı rengini yeşil olarak değiştir
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
