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

        BOOL callAction = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
        
        if(callAction){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"CallSuccess"];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
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
