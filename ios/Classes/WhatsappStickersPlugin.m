#import "WhatsappStickersPlugin.h"
#import <whatsapp_stickers/whatsapp_stickers-Swift.h>

@implementation WhatsappStickersPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWhatsappStickersPlugin registerWithRegistrar:registrar];
}
@end
