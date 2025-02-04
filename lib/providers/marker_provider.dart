import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/marker.dart';

class MarkerProvider with ChangeNotifier {
  static const String _markersKey = 'markers';
  static const String _valuesKey = 'marker_values';
  
  final SharedPreferences _prefs;
  List<Marker> _markers = [];
  Map<String, List<MarkerValue>> _markerValues = {};

  MarkerProvider(this._prefs) {
    _loadMarkers();
    _loadMarkerValues();
    _initializeDefaultMarkers();
  }

  List<Marker> get markers => _markers;
  List<Marker> get updatedMarkers => _markers.where((m) => m.isUpdatedToday).toList();
  List<Marker> get pendingMarkers => _markers.where((m) => !m.isUpdatedToday).toList();

  void _initializeDefaultMarkers() {
    if (_markers.isEmpty) {
      final defaultMarkers = [
        Marker(
          id: 'mood',
          name: 'Mood',
          type: MarkerType.choice,
          possibleValues: ['bad', 'neutral', 'good'],
          color: const Color(0xFFFF6B6B),
        ),
        Marker(
          id: 'study',
          name: 'Hours Studied',
          type: MarkerType.numeric,
          minValue: 1,
          maxValue: 5,
          color: const Color(0xFF4ECDC4),
        ),
        Marker(
          id: 'social',
          name: 'Social Contacts',
          type: MarkerType.numeric,
          minValue: 0,
          maxValue: 3,
          color: const Color(0xFF45B7D1),
        ),
      ];

      for (var marker in defaultMarkers) {
        addMarker(marker);
      }
    }
  }

  void _loadMarkers() {
    final markersJson = _prefs.getStringList(_markersKey) ?? [];
    _markers = markersJson
        .map((json) => Marker.fromJson(jsonDecode(json)))
        .toList();
  }

  void _loadMarkerValues() {
    final valuesJson = _prefs.getStringList(_valuesKey) ?? [];
    final allValues = valuesJson
        .map((json) => MarkerValue.fromJson(jsonDecode(json)))
        .toList();

    _markerValues.clear();
    for (var value in allValues) {
      _markerValues.putIfAbsent(value.markerId, () => []).add(value);
    }
  }

  Future<void> _saveMarkers() async {
    final markersJson = _markers
        .map((marker) => jsonEncode(marker.toJson()))
        .toList();
    await _prefs.setStringList(_markersKey, markersJson);
    notifyListeners();
  }

  Future<void> _saveMarkerValues() async {
    final allValues = _markerValues.values.expand((values) => values).toList();
    final valuesJson = allValues
        .map((value) => jsonEncode(value.toJson()))
        .toList();
    await _prefs.setStringList(_valuesKey, valuesJson);
    notifyListeners();
  }

  Future<void> addMarker(Marker marker) async {
    _markers.insert(0, marker); // Add new markers at the beginning
    await _saveMarkers();
  }

  Future<void> removeMarker(String markerId) async {
    _markers.removeWhere((m) => m.id == markerId);
    _markerValues.remove(markerId);
    await _saveMarkers();
    await _saveMarkerValues();
  }

  Future<void> updateMarkerValue(String markerId, String value) async {
    final marker = _markers.firstWhere((m) => m.id == markerId);
    final markerValue = MarkerValue(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      markerId: markerId,
      date: DateTime.now(),
      value: value,
    );

    _markerValues.putIfAbsent(markerId, () => []).add(markerValue);
    marker.isUpdatedToday = true;
    
    await _saveMarkers();
    await _saveMarkerValues();
  }

  List<MarkerValue> getValuesForMarker(String markerId) {
    return _markerValues[markerId] ?? [];
  }

  List<MarkerValue> getValuesForDate(String markerId, DateTime date) {
    final values = _markerValues[markerId] ?? [];
    return values.where((value) => 
      value.date.year == date.year && 
      value.date.month == date.month && 
      value.date.day == date.day
    ).toList();
  }

  void resetDailyStatus() {
    for (var marker in _markers) {
      marker.isUpdatedToday = false;
    }
    _saveMarkers();
  }
}
