#import <Cordova/CDVPlugin.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "CFCallNumber.h"

@implementation CFCallNumber

+ (BOOL)available {
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mnc = [carrier mobileNetworkCode];
    BOOL unavailableRightNow = ([mnc length] == 0) || ([mnc isEqualToString:@"65535"]);
    return canOpen && !unavailableRightNow;
}

- (void) callNumber:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{

        CDVPluginResult* pluginResult = nil;
        NSString* number = [command.arguments objectAtIndex:0];
        number = [number stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if( ! [number hasPrefix:@"tel:"]){
            number =  [NSString stringWithFormat:@"tel:%@", number];
        }

        if(![CFCallNumber available]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NoFeatureCallSupported"];
        }
        else if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]]) {
            // missing phone number
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }

        // return result
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }];
}

- (void) isCallSupported:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* pluginResult = [CDVPluginResult
            resultWithStatus:CDVCommandStatus_OK
            messageAsBool:[CFCallNumber available]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
