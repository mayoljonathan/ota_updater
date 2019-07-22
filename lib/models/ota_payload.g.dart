// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ota_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OTAPayload _$OTAPayloadFromJson(Map<String, dynamic> json) {
  return OTAPayload(
      appKey: json['appKey'] as String,
      versionCode: json['versionCode'] as String,
      versionName: json['versionName'] as String,
      deviceInfo: json['deviceInfo'] as String);
}

Map<String, dynamic> _$OTAPayloadToJson(OTAPayload instance) =>
    <String, dynamic>{
      'appKey': instance.appKey,
      'versionCode': instance.versionCode,
      'versionName': instance.versionName,
      'deviceInfo': instance.deviceInfo
    };
