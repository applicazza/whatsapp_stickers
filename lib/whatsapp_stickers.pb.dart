///
//  Generated code. Do not modify.
//  source: whatsapp_stickers.proto
///
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name

import 'dart:core' as $core show bool, Deprecated, double, int, List, Map, override, String;

import 'package:protobuf/protobuf.dart' as $pb;

class SendToWhatsAppPayload_Stickers extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SendToWhatsAppPayload.Stickers', package: const $pb.PackageName('whatsapp_stickers'))
    ..pPS(1, 'all')
    ..hasRequiredFields = false
  ;

  SendToWhatsAppPayload_Stickers() : super();
  SendToWhatsAppPayload_Stickers.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  SendToWhatsAppPayload_Stickers.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  SendToWhatsAppPayload_Stickers clone() => SendToWhatsAppPayload_Stickers()..mergeFromMessage(this);
  SendToWhatsAppPayload_Stickers copyWith(void Function(SendToWhatsAppPayload_Stickers) updates) => super.copyWith((message) => updates(message as SendToWhatsAppPayload_Stickers));
  $pb.BuilderInfo get info_ => _i;
  static SendToWhatsAppPayload_Stickers create() => SendToWhatsAppPayload_Stickers();
  SendToWhatsAppPayload_Stickers createEmptyInstance() => create();
  static $pb.PbList<SendToWhatsAppPayload_Stickers> createRepeated() => $pb.PbList<SendToWhatsAppPayload_Stickers>();
  static SendToWhatsAppPayload_Stickers getDefault() => _defaultInstance ??= create()..freeze();
  static SendToWhatsAppPayload_Stickers _defaultInstance;

  $core.List<$core.String> get all => $_getList(0);
}

class SendToWhatsAppPayload extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SendToWhatsAppPayload', package: const $pb.PackageName('whatsapp_stickers'))
    ..aOS(1, 'identifier')
    ..aOS(2, 'name')
    ..aOS(3, 'publisher')
    ..aOS(4, 'trayImageFileName')
    ..aOS(5, 'publisherWebsite')
    ..aOS(6, 'privacyPolicyWebsite')
    ..aOS(7, 'licenseAgreementWebsite')
    ..m<$core.String, SendToWhatsAppPayload_Stickers>(8, 'stickers', 'SendToWhatsAppPayload.StickersEntry',$pb.PbFieldType.OS, $pb.PbFieldType.OM, SendToWhatsAppPayload_Stickers.create, null, null , const $pb.PackageName('whatsapp_stickers'))
    ..hasRequiredFields = false
  ;

  SendToWhatsAppPayload() : super();
  SendToWhatsAppPayload.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  SendToWhatsAppPayload.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  SendToWhatsAppPayload clone() => SendToWhatsAppPayload()..mergeFromMessage(this);
  SendToWhatsAppPayload copyWith(void Function(SendToWhatsAppPayload) updates) => super.copyWith((message) => updates(message as SendToWhatsAppPayload));
  $pb.BuilderInfo get info_ => _i;
  static SendToWhatsAppPayload create() => SendToWhatsAppPayload();
  SendToWhatsAppPayload createEmptyInstance() => create();
  static $pb.PbList<SendToWhatsAppPayload> createRepeated() => $pb.PbList<SendToWhatsAppPayload>();
  static SendToWhatsAppPayload getDefault() => _defaultInstance ??= create()..freeze();
  static SendToWhatsAppPayload _defaultInstance;

  $core.String get identifier => $_getS(0, '');
  set identifier($core.String v) { $_setString(0, v); }
  $core.bool hasIdentifier() => $_has(0);
  void clearIdentifier() => clearField(1);

  $core.String get name => $_getS(1, '');
  set name($core.String v) { $_setString(1, v); }
  $core.bool hasName() => $_has(1);
  void clearName() => clearField(2);

  $core.String get publisher => $_getS(2, '');
  set publisher($core.String v) { $_setString(2, v); }
  $core.bool hasPublisher() => $_has(2);
  void clearPublisher() => clearField(3);

  $core.String get trayImageFileName => $_getS(3, '');
  set trayImageFileName($core.String v) { $_setString(3, v); }
  $core.bool hasTrayImageFileName() => $_has(3);
  void clearTrayImageFileName() => clearField(4);

  $core.String get publisherWebsite => $_getS(4, '');
  set publisherWebsite($core.String v) { $_setString(4, v); }
  $core.bool hasPublisherWebsite() => $_has(4);
  void clearPublisherWebsite() => clearField(5);

  $core.String get privacyPolicyWebsite => $_getS(5, '');
  set privacyPolicyWebsite($core.String v) { $_setString(5, v); }
  $core.bool hasPrivacyPolicyWebsite() => $_has(5);
  void clearPrivacyPolicyWebsite() => clearField(6);

  $core.String get licenseAgreementWebsite => $_getS(6, '');
  set licenseAgreementWebsite($core.String v) { $_setString(6, v); }
  $core.bool hasLicenseAgreementWebsite() => $_has(6);
  void clearLicenseAgreementWebsite() => clearField(7);

  $core.Map<$core.String, SendToWhatsAppPayload_Stickers> get stickers => $_getMap(7);
}

