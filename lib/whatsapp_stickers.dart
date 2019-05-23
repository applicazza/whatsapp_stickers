import 'dart:async';

import 'package:flutter/services.dart';

import 'whatsapp_stickers.pb.dart';
import 'exceptions.dart';

class WhatsappStickers {
  static const MethodChannel _channel =
      const MethodChannel('whatsapp_stickers');

  final Map<String, List<String>> _stickers = Map<String, List<String>>();

  final String _identifier;
  final String _name;
  final String _publisher;
  final String _trayImageFileName;
  final String _publisherWebsite;
  final String _privacyPolicyWebsite;
  final String _licenseAgreementWebsite;

  WhatsappStickers(
      this._identifier,
      this._name,
      this._publisher,
      this._trayImageFileName,
      this._publisherWebsite,
      this._privacyPolicyWebsite,
      this._licenseAgreementWebsite);

  void addSticker(String contentsOfFile, List<String> emojis) {
    _stickers[contentsOfFile] = emojis;
  }

  Future<void> sendToWhatsApp() async {
    var message = SendToWhatsAppPayload()
      ..identifier = _identifier
      ..name = _name
      ..publisher = _publisher
      ..trayImageFileName = _trayImageFileName
      ..publisherWebsite = _publisherWebsite
      ..privacyPolicyWebsite = _privacyPolicyWebsite
      ..licenseAgreementWebsite = _licenseAgreementWebsite;

    _stickers.forEach((sticker, emojis) => message.stickers[sticker] =
        SendToWhatsAppPayload_Stickers.create()..all.addAll(emojis));

    try {
      await _channel.invokeMethod(
          "sendToWhatsApp", message.writeToBuffer());
    } on PlatformException catch (e) {
      switch (e.code) {
        case "FILE_NOT_FOUND":
          throw WhatsappStickersFileNotFoundException(e.message);
        case "OUTSIDE_ALLOWABLE_RANGE":
          throw WhatsappStickersNumOutsideAllowableRangeException(e.message);
        case "UNSUPPORTED_IMAGE_FORMAT":
          throw WhatsappStickersUnsupportedImageFormatException(e.message);
        case "IMAGE_TOO_BIG":
          throw WhatsappStickersImageTooBigException(e.message);
        case "INCORRECT_IMAGE_SIZE":
          throw WhatsappStickersIncorrectImageSizeException(e.message);
        case "ANIMATED_IMAGES_NOT_SUPPORTED":
          throw WhatsappStickersAnimatedImagesNotSupportedException(e.message);
        case "TOO_MANY_EMOJIS":
          throw WhatsappStickersTooManyEmojisException(e.message);
        case "EMPTY_STRING":
          throw WhatsappStickersEmptyStringException(e.message);
        case "STRING_TOO_LONG":
          throw WhatsappStickersStringTooLongException(e.message);
        default:
          throw WhatsappStickersException(e.message);
      }
    }
  }
}
