import 'package:json_annotation/json_annotation.dart';

part 'ota_payload.g.dart';

@JsonSerializable(nullable: true, explicitToJson: true)
class OTAPayload {

  String appKey;
  String versionCode;
  String versionName;
  String deviceInfo;

  OTAPayload({
    this.appKey,
    this.versionCode,
    this.versionName,
    this.deviceInfo
  });

  factory OTAPayload.fromJson(Map<String, dynamic> json) => _$OTAPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$OTAPayloadToJson(this);
}