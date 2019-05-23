import Flutter
import SwiftProtobuf
import UIKit

public class SwiftWhatsappStickersPlugin: NSObject, FlutterPlugin {
    private var registrar: FlutterPluginRegistrar?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "whatsapp_stickers", binaryMessenger: registrar.messenger())
        let instance = SwiftWhatsappStickersPlugin()
        instance.registrar = registrar;
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method != "sendToWhatsApp") {
            result(FlutterError(code: "INVALID_METHOD", message: "Invalid method", details: nil));
            return;
        }

        let arguments = call.arguments as? FlutterStandardTypedData;

        if (arguments == nil) {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil));
            return;
        }
        
        var message: WhatsappStickers_SendToWhatsAppPayload?

        do {
            message = try WhatsappStickers_SendToWhatsAppPayload.init(serializedData: arguments!.data)
            
            let stickerPack = try StickerPack(identifier: message!.identifier,
                                          name: message!.name,
                                          publisher: message!.publisher,
                                          trayImageFileName: registrar!.lookupKey(forAsset: message!.trayImageFileName),
                                          publisherWebsite: message!.publisherWebsite,
                                          privacyPolicyWebsite: message!.privacyPolicyWebsite,
                                          licenseAgreementWebsite: message!.licenseAgreementWebsite)
            
            for sticker in message!.stickers {
                do {
                    try stickerPack.addSticker(contentsOfFile: registrar!.lookupKey(forAsset: sticker.key), emojis: sticker.value.all)
                } catch StickerPackError.fileNotFound {
                    result(FlutterError(code: "FILE_NOT_FOUND", message: "\(sticker.key) not found.", details: nil));
                    return;
                } catch StickerPackError.stickersNumOutsideAllowableRange {
                    result(FlutterError(code: "OUTSIDE_ALLOWABLE_RANGE", message: "Sticker count outside the allowable limit (\(Limits.MaxStickersPerPack) stickers per pack).", details: nil))
                    return;
                } catch StickerPackError.unsupportedImageFormat(let imageFormat) {
                    result(FlutterError(code: "UNSUPPORTED_IMAGE_FORMAT", message: "\(sticker.key): \(imageFormat) is not a supported format.", details: nil))
                    return;
                } catch StickerPackError.imageTooBig(let imageFileSize) {
                    let roundedSize = round((Double(imageFileSize) / 1024) * 100) / 100;
                    result(FlutterError(code: "IMAGE_TOO_BIG", message: "\(sticker.key): \(roundedSize) KB is bigger than the max file size (\(Limits.MaxStickerFileSize / 1024) KB).", details: nil))
                    return;
                } catch StickerPackError.incorrectImageSize(let imageDimensions) {
                    result(FlutterError(code: "INCORRECT_IMAGE_SIZE", message: "\(sticker.key): \(imageDimensions) is not compliant with sticker images dimensions, \(Limits.ImageDimensions).", details: nil))
                    return;
                } catch StickerPackError.animatedImagesNotSupported {
                    result(FlutterError(code: "ANIMATED_IMAGES_NOT_SUPPORTED", message: "\(sticker.key) is an animated image. Animated images are not supported.", details: nil))
                    return;
                } catch StickerPackError.tooManyEmojis {
                    result(FlutterError(code: "TOO_MANY_EMOJIS", message: "\(sticker.key) has too many emojis. \(Limits.MaxEmojisCount) is the maximum number.", details: nil))
                    return;
                }
            }
            
            stickerPack.sendToWhatsApp {
                completed in
                result(true)
            }
            
        }
        catch BinaryDecodingError.internalExtensionError {
            result(FlutterError(code: "PROTOBUF_INTERNAL_EXTENSION_ERROR", message: "ProtoBuf internal extension error", details: nil));
        } catch BinaryDecodingError.invalidUTF8 {
            result(FlutterError(code: "PROTOBUF_INVALID_UTF8", message: "Protobuf invalid UTF8", details: nil));
        } catch BinaryDecodingError.malformedProtobuf {
            result(FlutterError(code: "PROTOBUF_MALFORMED", message: "Malformed ProtoBuf", details: nil));
        } catch BinaryDecodingError.messageDepthLimit {
            result(FlutterError(code: "PROTOBUF_MESSAGE_DEPTH_LIMIT", message: "ProtoBuf message depth limit", details: nil));
        } catch BinaryDecodingError.missingRequiredFields {
            result(FlutterError(code: "PROTOBUF_MISSING_REQUIRED_FIELDS", message: "ProtoBuf missing required fields", details: nil));
        } catch BinaryDecodingError.trailingGarbage {
            result(FlutterError(code: "PROTOBUF_TRAILING_GARBAGE", message: "ProtoBuf trailing garbage", details: nil));
        } catch BinaryDecodingError.truncated {
            result(FlutterError(code: "PROTOBUF_TRUNCATED", message: "ProtoBuf truncated", details: nil));
        } catch StickerPackError.fileNotFound {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "\(message!.trayImageFileName) not found.", details: nil));
        } catch StickerPackError.emptyString {
            result(FlutterError(code: "EMPTY_STRING", message: "The name, identifier, and publisher strings can't be empty.", details: nil))
        } catch StickerPackError.unsupportedImageFormat(let imageFormat) {
            result(FlutterError(code: "UNSUPPORTED_IMAGE_FORMAT", message: "\(message!.trayImageFileName): \(imageFormat) is not a supported format.", details: nil))
        } catch StickerPackError.imageTooBig(let imageFileSize) {
            let roundedSize = round((Double(imageFileSize) / 1024) * 100) / 100;
            result(FlutterError(code: "IMAGE_TOO_BIG", message: "\(message!.trayImageFileName): \(roundedSize) KB is bigger than the max file size (\(Limits.MaxStickerFileSize / 1024) KB).", details: nil))
        } catch StickerPackError.incorrectImageSize(let imageDimensions) {
            result(FlutterError(code: "INCORRECT_IMAGE_SIZE", message: "\(message!.trayImageFileName): \(imageDimensions) is not compliant with sticker images dimensions, \(Limits.ImageDimensions).", details: nil))
        } catch StickerPackError.animatedImagesNotSupported {
            result(FlutterError(code: "ANIMATED_IMAGES_NOT_SUPPORTED", message: "\(message!.trayImageFileName) is an animated image. Animated images are not supported.", details: nil))
        } catch StickerPackError.stringTooLong {
            result(FlutterError(code: "STRING_TOO_LONG", message: "Name, identifier, and publisher of sticker pack must be less than \(Limits.MaxCharLimit128) characters.", details: nil))
        } catch {
            result(FlutterError(code: "GENERAL_ERROR", message: error.localizedDescription, details: nil));
        }
        
    }
}
