import 'package:flutter/material.dart';

enum MarkerType {
  choice,
  numeric
}

class Marker {
  final String id;
  final String name;
  final MarkerType type;
  final List<String> possibleValues;
  final double? minValue;
  final double? maxValue;
  bool isUpdatedToday;
  final Color color;

  Marker({
    required this.id,
    required this.name,
    required this.type,
    this.possibleValues = const [],
    this.minValue,
    this.maxValue,
    this.isUpdatedToday = false,
    required this.color,
  });

  factory Marker.fromJson(Map<String, dynamic> json) {
    return Marker(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MarkerType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MarkerType.choice,
      ),
      possibleValues: List<String>.from(json['possibleValues'] ?? []),
      minValue: json['minValue']?.toDouble(),
      maxValue: json['maxValue']?.toDouble(),
      isUpdatedToday: json['isUpdatedToday'] ?? false,
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'possibleValues': possibleValues,
      'minValue': minValue,
      'maxValue': maxValue,
      'isUpdatedToday': isUpdatedToday,
      'color': color.value,
    };
  }

  Marker copyWith({
    String? id,
    String? name,
    MarkerType? type,
    List<String>? possibleValues,
    double? minValue,
    double? maxValue,
    bool? isUpdatedToday,
    Color? color,
  }) {
    return Marker(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      possibleValues: possibleValues ?? this.possibleValues,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      isUpdatedToday: isUpdatedToday ?? this.isUpdatedToday,
      color: color ?? this.color,
    );
  }
}

class MarkerValue {
  final String id;
  final String markerId;
  final DateTime date;
  final String value;

  MarkerValue({
    required this.id,
    required this.markerId,
    required this.date,
    required this.value,
  });

  factory MarkerValue.fromJson(Map<String, dynamic> json) {
    return MarkerValue(
      id: json['id'] as String,
      markerId: json['markerId'] as String,
      date: DateTime.parse(json['date'] as String),
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'markerId': markerId,
      'date': date.toIso8601String(),
      'value': value,
    };
  }
}
