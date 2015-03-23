//
//  XcodeColors.h
//  XcodeColors
//
//  Created by Uncle MiF on 9/13/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_OPTIONS(NSUInteger, TRShellColor) {

    TRShellColorBlack = 0,
    TRShellColorRed,
    TRShellColorGreen,
    TRShellColorYellow,
    TRShellColorBlue,
    TRShellColorMagenta,
    TRShellColorCyan,
    TRShellColorWhite
};

typedef NS_ENUM(NSInteger, TRShellAttribute) {

    TRShellAttributeResetAll = 0,
    /*  TRShellAttributeBold = 1,
     TRShellAttributeDim = 2,
     TRShellAttributeUnderlined = 4,
     TRShellAttributeBlink = 5,
     TRShellAttributeInvert = 7,
     TRShellAttributeHidden = 8,

     TRShellAttributeResetBold = 21,
     TRShellAttributeResetDim = 22,
     TRShellAttributeResetUnderlined = 24,
     TRShellAttributeResetBlink = 25,
     TRShellAttributeResetReverse = 27,
     TRShellAttributeResetHidden = 28,
     */

    TRShellAttributeForegroundRegular       = 30,
    TRShellAttributeForegroundBlack         = TRShellAttributeForegroundRegular + TRShellColorBlack,
    TRShellAttributeForegroundRed           = TRShellAttributeForegroundRegular + TRShellColorRed,
    TRShellAttributeForegroundGreen         = TRShellAttributeForegroundRegular + TRShellColorGreen,
    TRShellAttributeForegroundYellow        = TRShellAttributeForegroundRegular + TRShellColorYellow,
    TRShellAttributeForegroundBlue          = TRShellAttributeForegroundRegular + TRShellColorBlue,
    TRShellAttributeForegroundMagenta       = TRShellAttributeForegroundRegular + TRShellColorMagenta,
    TRShellAttributeForegroundCyan          = TRShellAttributeForegroundRegular + TRShellColorCyan,
    TRShellAttributeForegroundLightGray     = TRShellAttributeForegroundRegular + TRShellColorWhite,

    TRShellAttributeForegroundDefault       = 39,

    TRShellAttributeForegroundLight         = 90,
    TRShellAttributeForegroundDarkGray      = TRShellAttributeForegroundLight + TRShellColorBlack,
    TRShellAttributeForegroundLightRed      = TRShellAttributeForegroundLight + TRShellColorRed,
    TRShellAttributeForegroundLightGreen    = TRShellAttributeForegroundLight + TRShellColorGreen,
    TRShellAttributeForegroundLightYellow   = TRShellAttributeForegroundLight + TRShellColorYellow,
    TRShellAttributeForegroundLightBlue     = TRShellAttributeForegroundLight + TRShellColorBlue,
    TRShellAttributeForegroundLightMagenta  = TRShellAttributeForegroundLight + TRShellColorMagenta,
    TRShellAttributeForegroundLightCyan     = TRShellAttributeForegroundLight + TRShellColorCyan,
    TRShellAttributeForegroundWhite         = TRShellAttributeForegroundLight + TRShellColorWhite,

    TRShellAttributeBackgroundRegular       = 40,
    TRShellAttributeBackgroundBlack         = TRShellAttributeBackgroundRegular + TRShellColorBlack,
    TRShellAttributeBackgroundRed           = TRShellAttributeBackgroundRegular + TRShellColorRed,
    TRShellAttributeBackgroundGreen         = TRShellAttributeBackgroundRegular + TRShellColorGreen,
    TRShellAttributeBackgroundYellow        = TRShellAttributeBackgroundRegular + TRShellColorYellow,
    TRShellAttributeBackgroundBlue          = TRShellAttributeBackgroundRegular + TRShellColorBlue,
    TRShellAttributeBackgroundMagenta       = TRShellAttributeBackgroundRegular + TRShellColorMagenta,
    TRShellAttributeBackgroundCyan          = TRShellAttributeBackgroundRegular + TRShellColorCyan,
    TRShellAttributeBackgroundLightGray     = TRShellAttributeBackgroundRegular + TRShellColorWhite,

    TRShellAttributeBackgroundDefault       = 49,

    TRShellAttributeBackgroundLight         = 100,
    TRShellAttributeBackgroundDarkGray      = TRShellAttributeBackgroundLight + TRShellColorBlack,
    TRShellAttributeBackgroundLightRed      = TRShellAttributeBackgroundLight + TRShellColorRed,
    TRShellAttributeBackgroundLightGreen    = TRShellAttributeBackgroundLight + TRShellColorGreen,
    TRShellAttributeBackgroundLightYellow   = TRShellAttributeBackgroundLight + TRShellColorYellow,
    TRShellAttributeBackgroundLightBlue     = TRShellAttributeBackgroundLight + TRShellColorBlue,
    TRShellAttributeBackgroundLightMagenta  = TRShellAttributeBackgroundLight + TRShellColorMagenta,
    TRShellAttributeBackgroundLightCyan     = TRShellAttributeBackgroundLight + TRShellColorCyan,
    TRShellAttributeBackgroundWhite         = TRShellAttributeBackgroundLight + TRShellColorWhite,
};

@interface NSTextStorage(XcodeColors)

- (void)xc_fixAttributesInRange:(NSRange)aRange;

@end

@interface XcodeColors : NSObject

+ (void)pluginDidLoad:(id)xcodeDirectCompatibility;
- (void)registerLaunchSystemDescriptions;

@end
