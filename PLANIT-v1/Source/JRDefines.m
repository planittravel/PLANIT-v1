//
//  Defines.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRDefines.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>
#import "SLLocalization.h"
#import <UIKit/UIKit.h>
#import "Config.h"
#import "PLANIT_v1-Swift.h"


NSString * const kHotelsStringsTable = @"HotelsLocalizable";

//------------------------
// DEFINES
//------------------------

NSUserDefaults *JRUserDefaults() {
    return [NSUserDefaults standardUserDefaults];
}

CGFloat JRPixel() {
    return 1.0f / [UIScreen mainScreen].scale;
}

//------------------------
// TARGETS & CONFIGURATIONS
//------------------------

BOOL Simulator() {
    return [[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"];
}

BOOL iPhone() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

BOOL iPhoneWithHeight(CGFloat height) {
    CGSize screneSize = [[ UIScreen mainScreen ] bounds ].size;
    return iPhone() && (fabs( ( double ) MAX(screneSize.width, screneSize.height) - ( double )height ) < DBL_EPSILON );
}

BOOL iPhone4Inch() {
    return iPhoneWithHeight(568);
}
BOOL iPhone35Inch() {
    return iPhoneWithHeight(480);
}
BOOL iPhone47Inch() {
    return iPhoneWithHeight(667);
}
BOOL iPhone55Inch() {
    return iPhoneWithHeight(736);
}

BOOL iPad() {
    return (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad);
}

DeviceSizeType __attribute__((const))  CurrentDeviceSizeType() {
    static BOOL wasTypeDefined = NO;
    static DeviceSizeType res;
    if (wasTypeDefined) {
        return res;
    } else {
        res = iPad()    ?   DeviceSizeTypeIPad :
        iPhone55Inch()  ?   DeviceSizeTypeIPhone55Inch:
        iPhone47Inch()  ?   DeviceSizeTypeIPhone47Inch:
        iPhone4Inch()   ?   DeviceSizeTypeIPhone4Inch:
        /* otherwise */     DeviceSizeTypeIPhone35Inch;
        
        wasTypeDefined = YES;
        return res;
    }
}

BOOL iOSVersionEqualTo(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame);
}

BOOL iOSVersionGreaterThan(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending);
}

BOOL iOSVersionGreaterThanOrEqualTo(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending);
}

BOOL iOSVersionLessThan(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending);
}
BOOL iOSVersionLessThanOrEqualTo(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending);
}

CGFloat iPhoneSizeValue(CGFloat defaultValue, CGFloat iPhone6Value, CGFloat iPhone6PlusValue) {
    switch (CurrentDeviceSizeType()) {
        case DeviceSizeTypeIPad:
        case DeviceSizeTypeIPhone55Inch:
            return iPhone6PlusValue;
        case DeviceSizeTypeIPhone47Inch:
            return iPhone6Value;
        default:
            return defaultValue;
    }
}

CGFloat deviceSizeTypeValue(CGFloat deviceSizeTypeIPhone35Inch, CGFloat deviceSizeTypeIPhone4Inch, CGFloat deviceSizeTypeIPhone47Inch, CGFloat deviceSizeTypeIPhone55Inch, CGFloat deviceSizeTypeIPad) {
    switch (CurrentDeviceSizeType()) {
        case DeviceSizeTypeIPhone35Inch:
            return deviceSizeTypeIPhone35Inch;
        case DeviceSizeTypeIPhone4Inch:
            return deviceSizeTypeIPhone4Inch;
        case DeviceSizeTypeIPhone47Inch:
            return deviceSizeTypeIPhone47Inch;
        case DeviceSizeTypeIPhone55Inch:
            return deviceSizeTypeIPhone55Inch;
        case DeviceSizeTypeIPad:
            return deviceSizeTypeIPad;
    }
}

CGFloat minScreenDimension(void)
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return MIN(screenSize.width, screenSize.height);
}

CGFloat maxScreenDimension(void)
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return MAX(screenSize.width, screenSize.height);
}

BOOL Debug() {
#if DEBUG
    return YES;
#else
    return NO;
#endif
}

BOOL AppStore() {
#if APPSTORE
    return YES;
#else
    return NO;
#endif
}

BOOL ticketsEnabled() {
#if TICKETS_ENABLED
    return YES;
#else
    return NO;
#endif
}

BOOL hotelsEnabled() {
#if HOTELS_ENABLED
    return YES;
#else
    return NO;
#endif
}

UIView *loadViewFromNibNamed(NSString *nibNamed)
{
    return [[[NSBundle mainBundle] loadNibNamed:nibNamed owner:nil options:nil] objectAtIndex:0];
}

UIView *loadViewFromNib(NSString *nibNamed, id owner)
{
    return [[[NSBundle mainBundle] loadNibNamed:nibNamed owner:owner options:nil] objectAtIndex:0];
}

NSString *platformName()
{
    return iPhone() ? @"iphone" : @"ipad";
}

//------------------------
// LOCALIZATION
//------------------------

NSString *NSLS(NSString *key) {

    NSString *result = [AVIASALES_BUNDLE localizedStringForKey:key value:@"" table:@"AviasalesTemplateLocalizable"];
    if (![result isEqualToString:key]) {
        return result;
    } else {
        return NSLocalizedStringFromTable(key, kHotelsStringsTable, @"");
    }
}

NSString *NSLSP(NSString *key, float pluralValue) {
    NSString *result = [AVIASALES_BUNDLE pluralizedStringWithKey:key defaultValue:@"" table:@"AviasalesTemplateLocalizable" pluralValue:SL_FLOATVALUE(pluralValue)];
    if (![result isEqualToString:key]) {
        return result;
    } else {
        return [[NSBundle mainBundle] pluralizedStringWithKey:key defaultValue:@"" table:kHotelsStringsTable pluralValue:SL_FLOATVALUE(pluralValue)];
    }

}

//------------------------
// DISPATCH
//------------------------

void hl_dispatch_main_sync_safe(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void hl_dispatch_main_async_safe(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

//------------------------
// CONFIG
//------------------------

BOOL ShowAppodealAds() {
    return kShowAppodealAds;
}

BOOL ShowAviasalesAds() {
    return kShowAviasalesAds;
}
