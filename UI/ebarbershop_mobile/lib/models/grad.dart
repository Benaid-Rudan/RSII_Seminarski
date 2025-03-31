// TODO Implement this library.
import 'package:json_annotation/json_annotation.dart' show JsonSerializable;

part 'grad.g.dart';

@JsonSerializable()
class Grad {
  int? gradId;
  String? naziv;

  Grad({this.gradId, this.naziv});
 
  factory Grad.fromJson(Map<String, dynamic> json) => _$GradFromJson(json);
  Map<String, dynamic> toJson() => _$GradToJson(this);
}
