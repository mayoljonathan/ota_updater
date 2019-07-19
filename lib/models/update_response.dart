import 'package:json_annotation/json_annotation.dart';

part 'update_response.g.dart';

@JsonSerializable(nullable: true, explicitToJson: true)
class UpdateResponse {
  final AppUpdateStatus status;
  final String title;
  final String message;
  final UpdateDataResponse data;

  UpdateResponse({
    this.status,
    this.title,
    this.message,
    this.data
  });

  factory UpdateResponse.fromJson(Map<String, dynamic> json) => _$UpdateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateResponseToJson(this);
}

@JsonSerializable(nullable: true, explicitToJson: true)
class UpdateDataResponse {
  final bool isMandatory;
  final String downloadUrl;
  final String filename;

  UpdateDataResponse({
    this.isMandatory,
    this.downloadUrl,
    this.filename
  });

  factory UpdateDataResponse.fromJson(Map<String, dynamic> json) => _$UpdateDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateDataResponseToJson(this);
}

enum AppUpdateStatus {
  /// The application is up to date.
  UP_TO_DATE,

  /// There is a new update available
  UPDATE_AVAILABLE,

  /// An error has occured in communicating to the server
  ERROR
}