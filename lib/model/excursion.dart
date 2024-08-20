import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Excursion {
  final DateTime date;
  final String description;
  final String difficulty;
  final String id;
  final String ownerName;
  final String ownerPic;
  final LatLng? perimeterCenter;
  final double? perimeterRadius;
  final String title;

  Excursion({
    required this.date,
    required this.description,
    required this.difficulty,
    required this.id,
    required this.ownerName,
    required this.ownerPic,
    required this.perimeterCenter,
    required this.perimeterRadius,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'difficulty': difficulty,
      'id': id,
      'ownerName': ownerName,
      'ownerPic': ownerPic,
      'title': title,
    };

    if (perimeterCenter != null) {
      map['perimeterCenter'] = GeoPoint(
        perimeterCenter!.latitude,
        perimeterCenter!.longitude,
      );
    }

    if (perimeterCenter != null) {
      map['perimeterRadius'] = perimeterRadius;
    }

    return map;
  }

  Map<String, dynamic> toMapForInvitation() {
    return <String, dynamic>{
      'id': id,
      'ownerName': ownerName,
      'ownerPic': ownerPic,
      'title': title,
    };
  }

  factory Excursion.fromMap(Map<String, dynamic> map) {
    var perimeterCenter = map['perimeterCenter'];
    if (map['perimeterCenter'] is GeoPoint) {
      perimeterCenter =
          LatLng(perimeterCenter.latitude, perimeterCenter.longitude);
    }

    final excursion = Excursion(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? '',
      id: map['id'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerPic: map['ownerPic'] ?? '',
      perimeterCenter: perimeterCenter,
      perimeterRadius: map['perimeterRadius'],
      title: map['title'] ?? '',
    );

    return excursion;
  }
}
