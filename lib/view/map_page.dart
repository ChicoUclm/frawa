import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:excursiona/controllers/excursion_controller.dart';

import 'package:excursiona/model/marker_model.dart';

import 'package:excursiona/shared/assets.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';

import 'package:excursiona/view/widgets/change_map_type_button.dart';
import 'package:excursiona/view/widgets/loader.dart';
import 'package:excursiona/view/widgets/marker_info_sheet.dart';

const _minimumDistanceForUpdate = 5;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(38.9842, -3.9275), zoom: 5);

  late LocationSettings locationSettings;

  Set<Marker> markers = {};

  StreamSubscription<Position>? positionStream;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const double _zoom = 19;

  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;

  MapType _mapType = MapType.satellite;
  Position? _currentPosition;
  var _finishedLocation = false;
  var _isDragging = false;

  @override
  void dispose() {
    super.dispose();

    if (positionStream != null) {
      positionStream!.cancel();
    }
  }

  @override
  void initState() {
    _initLocation();

    super.initState();

    _setInterestingPointsMarkers();

    _setCustomMarkerIcon();
    _setPositionData();
  }

  _setInterestingPointsMarkers() async {
    List<MarkerModel> markersData = await ExcursionController().getAllMarkers();

    List<Marker> interestingPointsMarkers = [];
    for (MarkerModel markerModel in markersData) {
      interestingPointsMarkers.add(
        Marker(
          markerId: MarkerId(markerModel.id),
          onTap: () => _showMarkerInfo(markerModel),
          position: LatLng(
            markerModel.position.latitude,
            markerModel.position.longitude,
          ),
        ),
      );
    }

    setState(() {
      markers.addAll(interestingPointsMarkers);
    });
  }

  _initLocation() {
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "",
          notificationTitle: "",
          enableWakeLock: true,
        ),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        allowBackgroundLocationUpdates: true,
        distanceFilter: _minimumDistanceForUpdate,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _minimumDistanceForUpdate,
      );
    }
  }

  _setPositionData() {
    getCurrentPosition().then((value) async {
      setState(() {
        _currentPosition = value;
      });
      _generateLocationMarker();

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: _zoom);

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      _finishedLocation = true;
    }).catchError((error) {
      showSnackBar(context, Theme.of(context).primaryColor, error.toString());
      _finishedLocation = true;
    });
  }

  _setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, Assets.resourceImagesMylocationicon)
        .then((value) {
      setState(() {
        _currentLocationIcon = value;
      });
    });
  }

  _showMarkerInfo(MarkerModel markerModel) {
    _isDragging = true;

    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.2),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      elevation: 1,
      context: context,
      builder: (context) {
        return MarkerInfoSheet(markerModel: markerModel);
      },
    );
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    Geolocator.getServiceStatusStream().listen(
      (status) {
        if (status == ServiceStatus.disabled) {
          showSnackBar(context, Theme.of(context).primaryColor,
              'La ubicación no está activada');
        } else {
          _setPositionData();
        }
      },
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null && _currentPosition != null) {
        if (Geolocator.distanceBetween(position.latitude, position.longitude,
                _currentPosition!.latitude, _currentPosition!.longitude) <
            _minimumDistanceForUpdate) {
          return;
        }
      }

      setState(() {
        _currentPosition = position;
      });
      if (!_isDragging) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position!.latitude, position.longitude),
                zoom: _zoom),
          ),
        );
      }
      _generateLocationMarker();
    });
  }

  _generateLocationMarker() {
    const markerId = MarkerId('currentPos');
    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      icon: _currentLocationIcon,
    );

    setState(() {
      markers.add(marker);
    });
  }

  void _changeMapType(MapType mapType) {
    setState(
      () {
        _mapType = mapType;
      },
    );

    Navigator.pop(context);
  }

  _buildBottomSheet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Tipo de mapa",
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MapTypeButton(
                  selectedMapType: _mapType,
                  onTap: _changeMapType,
                  mapType: MapType.satellite,
                  icon: Icons.satellite_alt,
                  label: "Satélite"),
              MapTypeButton(
                  selectedMapType: _mapType,
                  onTap: _changeMapType,
                  mapType: MapType.normal,
                  icon: Icons.map,
                  label: "Normal"),
              MapTypeButton(
                  selectedMapType: _mapType,
                  onTap: _changeMapType,
                  mapType: MapType.terrain,
                  icon: Icons.terrain,
                  label: "Terreno")
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            mapType: _mapType,
            onMapCreated: (GoogleMapController controller) =>
                _onMapCreated(controller),
            onTap: (LatLng? latLng) {
              _isDragging = true;
            },
            zoomControlsEnabled: false,
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.small(
                        heroTag: 'mapType',
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        tooltip: "Cambiar tipo de mapa",
                        child: const Icon(
                          Icons.layers_rounded,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            backgroundColor: Constants.darkWhite,
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.20),
                            builder: (context) {
                              return _buildBottomSheet();
                            },
                          );
                        }),
                    FloatingActionButton.small(
                      heroTag: 'centerPosition',
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      tooltip: "Centrar en mi ubicación",
                      child: const Icon(
                        Icons.gps_fixed,
                      ),
                      onPressed: () async {
                        setState(() {
                          _isDragging = false;
                        });
                        final GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target: LatLng(_currentPosition!.latitude,
                                    _currentPosition!.longitude),
                                zoom: _zoom),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )),
          if (!_finishedLocation) const Geolocating(),
        ],
      ),
    );
  }
}

class Geolocating extends StatelessWidget {
  const Geolocating({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 55),
        child: Container(
            height: 50,
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.55),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(76, 130, 130, 130),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(1, 1), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(30)),
            child: const Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Loader(),
                  SizedBox(width: 15),
                  Text("Geolocalizando...", style: TextStyle(fontSize: 16))
                ],
              ),
            )),
      ),
    );
  }
}
