
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:excursiona/shared/constants.dart';

class PerimeterPage extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationSelected;
  final double perimeterRadius;

  const PerimeterPage({
    super.key,
    required this.initialLocation,
    required this.onLocationSelected,
    required this.perimeterRadius,
  });

  @override
  State<PerimeterPage> createState() => _PerimeterPageState();
}

class _PerimeterPageState extends State<PerimeterPage> {
  GoogleMapController? _mapController;
  late LatLng _selectedLocation;

  @override
  void initState() {
    _selectedLocation = widget.initialLocation;

    super.initState();
  }

  _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });

    widget.onLocationSelected(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecciona un punto", style: GoogleFonts.inter()),
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFFFAFAFA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: GoogleMap(
        circles: {
          Circle(
            circleId: const CircleId('selected_circle'),
            center: _selectedLocation,
            radius: widget.perimeterRadius,
            fillColor: Constants.steelBlue.withOpacity(0.3),
            strokeColor: Constants.steelBlue,
            strokeWidth: 2,
          ),
        },
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation,
          ),
        },
      ),
    );
  }
}
