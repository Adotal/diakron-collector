// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waste_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WasteCollection _$WasteCollectionFromJson(Map<String, dynamic> json) =>
    _WasteCollection(
      id: (json['id'] as num).toInt(),
      idWasteType: (json['id_waste_type'] as num).toInt(),
      idSegregator: (json['id_segregator'] as num).toInt(),
      collDate: DateTime.parse(json['coll_date'] as String),
      isComplete: json['is_complete'] as bool,
    );

Map<String, dynamic> _$WasteCollectionToJson(_WasteCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_waste_type': instance.idWasteType,
      'id_segregator': instance.idSegregator,
      'coll_date': instance.collDate.toIso8601String(),
      'is_complete': instance.isComplete,
    };
