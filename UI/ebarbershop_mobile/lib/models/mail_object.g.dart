// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MailObject _$MailObjectFromJson(Map<String, dynamic> json) => MailObject(
  json['mailAdresa'] as String?,
  json['subject'] as String?,
  json['poruka'] as String?,
);

Map<String, dynamic> _$MailObjectToJson(MailObject instance) =>
    <String, dynamic>{
      'mailAdresa': instance.mailAdresa,
      'subject': instance.subject,
      'poruka': instance.poruka,
    };
