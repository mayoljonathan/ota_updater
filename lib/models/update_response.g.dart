// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateResponse _$UpdateResponseFromJson(Map<String, dynamic> json) {
  return UpdateResponse(
      status: _$enumDecodeNullable(_$AppUpdateStatusEnumMap, json['status']),
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : UpdateDataResponse.fromJson(json['data'] as Map<String, dynamic>));
}

Map<String, dynamic> _$UpdateResponseToJson(UpdateResponse instance) =>
    <String, dynamic>{
      'status': _$AppUpdateStatusEnumMap[instance.status],
      'title': instance.title,
      'message': instance.message,
      'data': instance.data?.toJson()
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$AppUpdateStatusEnumMap = <AppUpdateStatus, dynamic>{
  AppUpdateStatus.UP_TO_DATE: 'UP_TO_DATE',
  AppUpdateStatus.UPDATE_AVAILABLE: 'UPDATE_AVAILABLE',
  AppUpdateStatus.ERROR: 'ERROR'
};

UpdateDataResponse _$UpdateDataResponseFromJson(Map<String, dynamic> json) {
  return UpdateDataResponse(
      isMandatory: json['isMandatory'] as bool,
      downloadUrl: json['downloadUrl'] as String,
      filename: json['filename'] as String);
}

Map<String, dynamic> _$UpdateDataResponseToJson(UpdateDataResponse instance) =>
    <String, dynamic>{
      'isMandatory': instance.isMandatory,
      'downloadUrl': instance.downloadUrl,
      'filename': instance.filename
    };
