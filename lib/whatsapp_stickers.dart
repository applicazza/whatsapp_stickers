import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'exceptions.dart';
import 'dart:io';

class WhatsappStickers {
  static const MethodChannel _channel = const MethodChannel('whatsapp_stickers');

  final Map<String, List<String>> _stickers = Map<String, List<String>>();

  final String identifier;
  final String name;
  final String publisher;
  final WhatsappStickerImage trayImageFileName;
  String? publisherWebsite;
  String? privacyPolicyWebsite;
  String? licenseAgreementWebsite;

  WhatsappStickers({
    required this.identifier,
    required this.name,
    required this.publisher,
    required this.trayImageFileName,
    this.publisherWebsite,
    this.privacyPolicyWebsite,
    this.licenseAgreementWebsite,
  });

  void addSticker(WhatsappStickerImage image, List<String> emojis) {
    emojisIsAvailable(emojis);
    _stickers[image.path] = emojis;
  }

  void emojisIsAvailable(List<String> emojis) {
    for (final emoji in emojis) {
      if (!availableEmojis.contains(emoji)) {
        throw WhatsappStickersEmojisNotAvailableException(
            'EMOJIS_NOT_AVAILABLE');
      }
    }
  }

  Future<void> checkIconPixel() async {
    final path = trayImageFileName.path.split('//')[1];
    var decodedImage = await decodeImageFromList(File(path).readAsBytesSync());
    if (decodedImage.width != 56 || decodedImage.height != 56) {
      throw WhatsappStickersIncorrectPixelIconException('INCORRECT_PIXEL_ICON');
    }
  }

  Future<void> sendToWhatsApp() async {
    try {
      await checkIconPixel();
      final payload = Map<String, dynamic>();
      payload['identifier'] = identifier;
      payload['name'] = name;
      payload['publisher'] = publisher;
      payload['trayImageFileName'] = trayImageFileName.path;
      payload['publisherWebsite'] = publisherWebsite;
      payload['privacyPolicyWebsite'] = privacyPolicyWebsite;
      payload['licenseAgreementWebsite'] = licenseAgreementWebsite;
      payload['stickers'] = _stickers;
      await _channel.invokeMethod('sendToWhatsApp', payload);
    } on PlatformException catch (e) {
      switch (e.code) {
        case WhatsappStickersFileNotFoundException.CODE:
          throw WhatsappStickersFileNotFoundException(e.message);
        case WhatsappStickersNumOutsideAllowableRangeException.CODE:
          throw WhatsappStickersNumOutsideAllowableRangeException(e.message);
        case WhatsappStickersUnsupportedImageFormatException.CODE:
          throw WhatsappStickersUnsupportedImageFormatException(e.message);
        case WhatsappStickersImageTooBigException.CODE:
          throw WhatsappStickersImageTooBigException(e.message);
        case WhatsappStickersIncorrectImageSizeException.CODE:
          throw WhatsappStickersIncorrectImageSizeException(e.message);
        case WhatsappStickersAnimatedImagesNotSupportedException.CODE:
          throw WhatsappStickersAnimatedImagesNotSupportedException(e.message);
        case WhatsappStickersTooManyEmojisException.CODE:
          throw WhatsappStickersTooManyEmojisException(e.message);
        case WhatsappStickersEmptyStringException.CODE:
          throw WhatsappStickersEmptyStringException(e.message);
        case WhatsappStickersStringTooLongException.CODE:
          throw WhatsappStickersStringTooLongException(e.message);
        case WhatsappStickersIncorrectPixelIconException.CODE:
          throw WhatsappStickersIncorrectPixelIconException(e.message);
        default:
          throw WhatsappStickersException(e.message);
      }
    }
  }
}

class WhatsappStickerImage {
  final String path;

  WhatsappStickerImage._internal(this.path);

  factory WhatsappStickerImage.fromAsset(String asset) {
    return WhatsappStickerImage._internal('assets://$asset');
  }

  factory WhatsappStickerImage.fromFile(String file) {
    return WhatsappStickerImage._internal('file://$file');
  }
}

const availableEmojis =
    '❤, 😍, 😘, 💕, 😻, 💑, 👩‍❤‍👩, 👨‍❤‍👨, 💏, 👩‍❤‍💋‍👩, 👨‍❤‍💋‍👨, 🧡, 💛, 💚, 💙, 💜, 🖤, 💔, ❣, 💞, 💓, 💗, 💖, 💘, 💝, 💟, ♥, 💌, 💋, 👩‍❤️‍💋‍👩, 👨‍❤️‍💋‍👨, 👩‍❤️‍👨, 👩‍❤️‍👩, 👨‍❤️‍👨, 👩‍❤️‍💋‍👨, 👬, 👭, 👫, 🥰, 😚, 😙, 👄, 🌹, 😽, ❣️, ❤️,😀, 😃, 😄, 😁, 😆, 😅, 😂, 🤣, 🙂, 😛, 😝, 😜, 🤪, 🤗, 😺, 😸, 😹, ☺, 😌, 😉, 🤗, 😊,☹, 😣, 😖, 😫, 😩, 😢, 😭, 😞, 😔, 😟, 😕, 😤, 😠, 😥, 😰, 😨, 😿, 😾, 😓, 🙍‍♂, 🙍‍♀, 💔, 🙁, 🥺, 🤕, ☔️, ⛈, 🌩, 🌧,😯, 😦, 😧, 😮, 😲, 🙀, 😱, 🤯, 😳, ❗, ❕, 🤬, 😡, 😠, 🙄, 👿, 😾, 😤, 💢, 👺, 🗯️, 😒, 🥵,👋,🎊, 🎉, 🎁, 🎈, 👯‍♂️, 👯, 👯‍♀️, 💃, 🕺, 🔥, ⭐️, ✨, 💫, 🎇, 🎆, 🍻, 🥂, 🍾, 🎂, 🍰';
