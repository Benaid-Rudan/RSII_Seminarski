// TODO Implement this library.
import 'package:json_annotation/json_annotation.dart';

part 'grad.g.dart';

@JsonSerializable()
class Grad {
  int? gradId;
  String? naziv;

  Grad({this.gradId, this.naziv});

  // factory Grad.fromJson(Map<String, dynamic> json) {
  //   return Grad(
  //     gradId: json['gradId'],
  //     naziv: json['naziv'],
  //   );
  factory Grad.fromJson(Map<String, dynamic> json) => _$GradFromJson(json);
  Map<String, dynamic> toJson() => _$GradToJson(this);
}
