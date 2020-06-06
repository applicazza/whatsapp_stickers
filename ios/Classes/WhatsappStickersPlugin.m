#import "WhatsappStickersPlugin.h"
#if __has_include(<whatsapp_stickers/whatsapp_stickers-Swift.h>)
#import <whatsapp_stickers/whatsapp_stickers-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "whatsapp_stickers-Swift.h"
#endif

@implementation WhatsappStickersPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWhatsappStickersPlugin registerWithRegistrar:registrar];
}
@end
