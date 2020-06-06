import Flutter
import UIKit

public class SwiftWhatsappStickersPlugin: NSObject, FlutterPlugin {
    private var registrar: FlutterPluginRegistrar?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "whatsapp_stickers", binaryMessenger: registrar.messenger())
        let instance = SwiftWhatsappStickersPlugin()
        instance.registrar = registrar
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method != "sendToWhatsApp") {
            result(FlutterError(code: "INVALID_METHOD", message: "Invalid method", details: nil))
            return
        }
        
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let identifier = arguments["identifier"] as? String else {
            result(FlutterError(code: "INVALID_IDENTIFIER", message: "Invalid identifier", details: nil))
            return
        }
        
        guard let name = arguments["name"] as? String else {
            result(FlutterError(code: "INVALID_NAME", message: "Invalid name", details: nil))
            return
        }
        
        guard let publisher = arguments["publisher"] as? String else {
            result(FlutterError(code: "INVALID_PUBLISHER", message: "Invalid publisher", details: nil))
            return
        }
        
        guard let trayImageFileName = arguments["trayImageFileName"] as? String else {
            result(FlutterError(code: "INVALID_TRAY_IMAGE_FILE_NAME", message: "Invalid tray image file name", details: nil))
            return
        }
        
        guard let stickers = arguments["stickers"] as? [String: [String]] else {
            result(FlutterError(code: "INVALID_STICKERS", message: "Invalid stickers", details: nil))
            return
        }
        
        let publisherWebsite = arguments["publisherWebsite"] as? String
        let privacyPolicyWebsite = arguments["privacyPolicyWebsite"] as? String
        let licenseAgreementWebsite = arguments["licenseAgreementWebsite"] as? String
        
        var stickerPack: StickerPack?
        
        do {
            stickerPack = try StickerPack(identifier: identifier,
                                          name: name,
                                          publisher: publisher,
                                          trayImageFileName: locateFile(atPath: trayImageFileName),
                                          publisherWebsite: publisherWebsite,
                                          privacyPolicyWebsite: privacyPolicyWebsite,
                                          licenseAgreementWebsite: licenseAgreementWebsite)
            
        } catch StickerPackError.fileNotFound {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "\(trayImageFileName) not found.", details: nil))
            return
        } catch StickerPackError.emptyString {
            result(FlutterError(code: "EMPTY_STRING", message: "The name, identifier, and publisher strings can't be empty.", details: nil))
            return
        } catch StickerPackError.unsupportedImageFormat(let imageFormat) {
            result(FlutterError(code: "UNSUPPORTED_IMAGE_FORMAT", message: "\(trayImageFileName): \(imageFormat) is not a supported format.", details: nil))
            return
        } catch StickerPackError.imageTooBig(let imageFileSize) {
            let roundedSize = round((Double(imageFileSize) / 1024) * 100) / 100
            result(FlutterError(code: "IMAGE_TOO_BIG", message: "\(trayImageFileName): \(roundedSize) KB is bigger than the max file size (\(Limits.MaxStickerFileSize / 1024) KB).", details: nil))
            return
        } catch StickerPackError.incorrectImageSize(let imageDimensions) {
            result(FlutterError(code: "INCORRECT_IMAGE_SIZE", message: "\(trayImageFileName): \(imageDimensions) is not compliant with sticker images dimensions, \(Limits.ImageDimensions).", details: nil))
            return
        } catch StickerPackError.animatedImagesNotSupported {
            result(FlutterError(code: "ANIMATED_IMAGES_NOT_SUPPORTED", message: "\(trayImageFileName) is an animated image. Animated images are not supported.", details: nil))
            return
        } catch StickerPackError.stringTooLong {
            result(FlutterError(code: "STRING_TOO_LONG", message: "Name, identifier, and publisher of sticker pack must be less than \(Limits.MaxCharLimit128) characters.", details: nil))
        } catch {
            result(FlutterError(code: "GENERAL_ERROR", message: error.localizedDescription, details: nil))
            return
        }
        
        for sticker in stickers {
            let emojis: [String]? = sticker.value
            
            let filename = sticker.key
            
            do {
                try stickerPack!.addSticker(contentsOfFile: locateFile(atPath: filename), emojis: emojis)
            } catch StickerPackError.stickersNumOutsideAllowableRange {
                result(FlutterError(code: "OUTSIDE_ALLOWABLE_RANGE", message: "Sticker count outside the allowable limit (\(Limits.MaxStickersPerPack) stickers per pack).", details: nil))
                return
            } catch StickerPackError.fileNotFound {
                result(FlutterError(code: "FILE_NOT_FOUND", message: "\(filename) not found.", details: nil))
                return
            } catch StickerPackError.unsupportedImageFormat(let imageFormat) {
                result(FlutterError(code: "UNSUPPORTED_IMAGE_FORMAT", message: "\(filename): \(imageFormat) is not a supported format.", details: nil))
                return
            } catch StickerPackError.imageTooBig(let imageFileSize) {
                let roundedSize = round((Double(imageFileSize) / 1024) * 100) / 100;
                result(FlutterError(code: "IMAGE_TOO_BIG", message: "\(filename): \(roundedSize) KB is bigger than the max file size (\(Limits.MaxStickerFileSize / 1024) KB).", details: nil))
                return
            } catch StickerPackError.incorrectImageSize(let imageDimensions) {
                result(FlutterError(code: "INCORRECT_IMAGE_SIZE", message: "\(filename): \(imageDimensions) is not compliant with sticker images dimensions, \(Limits.ImageDimensions).", details: nil))
                return
            } catch StickerPackError.animatedImagesNotSupported {
                result(FlutterError(code: "ANIMATED_IMAGES_NOT_SUPPORTED", message: "\(filename) is an animated image. Animated images are not supported.", details: nil))
                return
            } catch StickerPackError.tooManyEmojis {
                result(FlutterError(code: "TOO_MANY_EMOJIS", message: "\(filename) has too many emojis. \(Limits.MaxEmojisCount) is the maximum number.", details: nil))
                return
            } catch {
                result(FlutterError(code: "GENERAL_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            stickerPack!.sendToWhatsApp {
                completed in
                result(true)
            }
        }
    }
    
    fileprivate func locateFile(atPath: String) throws -> String {
        if atPath.hasPrefix("assets://") {
            let asset = String(atPath.dropFirst(9))
            
            guard let fileUrl = Bundle.main.url(forResource: registrar!.lookupKey(forAsset:asset), withExtension: "") else {
                throw StickerPackError.fileNotFound
            }
            
            return fileUrl.path
        }
        
        if atPath.hasPrefix("file://") {
            let path = String(atPath.dropFirst(7))
            
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        throw StickerPackError.fileNotFound
    }
    
}
