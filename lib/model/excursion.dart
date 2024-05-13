import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Excursion {
  final DateTime date;
  final String description;
  final String difficulty;
  final String id;
  final String ownerName;
  final String ownerPic;
  final LatLng perimeterCenter;
  final double perimeterRadius;
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
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'difficulty': difficulty,
      'id': id,
      'ownerName': ownerName,
      'ownerPic': ownerPic,
      'perimeterCenter': GeoPoint(
        perimeterCenter.latitude,
        perimeterCenter.longitude,
      ),
      'perimeterRadius': perimeterRadius,
      'title': title,
    };
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
    return Excursion(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? '',
      id: map['id'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerPic: map['ownerPic'] ?? '',
      perimeterCenter: map['perimeterCenter'] ?? '',
      perimeterRadius: map['perimeterRadius'] ?? '',
      title: map['title'] ?? '',
    );
  }
}
