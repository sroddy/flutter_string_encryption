#import "FlutterStringEncryptionPlugin.h"
#import <flutter_string_encryption/flutter_string_encryption-Swift.h>

@implementation FlutterStringEncryptionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterStringEncryptionPlugin registerWithRegistrar:registrar];
}
@end
