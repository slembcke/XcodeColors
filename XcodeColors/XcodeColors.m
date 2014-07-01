//
//  XcodeColors.m
//  XcodeColors
//
//  Created by Uncle MiF on 9/13/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import "XcodeColors.h"
#import <objc/runtime.h>

#define XCODE_COLORS "XcodeColors"

// How to apply color formatting to your log statements:
// 
// To set the foreground color:
// Insert the ESCAPE_SEQ into your string, followed by "fg124,12,255;" where r=124, g=12, b=255.
// 
// To set the background color:
// Insert the ESCAPE_SEQ into your string, followed by "bg12,24,36;" where r=12, g=24, b=36.
// 
// To reset the foreground color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "fg;"
// 
// To reset the background color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "bg;"
// 
// To reset the foreground and background color (to default values) in one operation:
// Insert the ESCAPE_SEQ into your string, followed by ";"
// 
// 
// Feel free to copy the define statements below into your code.
// <COPY ME>

#define XCODE_COLORS_ESCAPE @"\033["

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

// </COPY ME>

static IMP IMP_NSTextStorage_fixAttributesInRange = nil;



@implementation XcodeColors_NSTextStorage

void ApplyANSIColors(NSTextStorage *textStorage, NSRange textStorageRange, NSString *escapeSeq)
{
	NSRange range = [[textStorage string] rangeOfString:escapeSeq options:0 range:textStorageRange];
	if (range.location == NSNotFound)
	{
		// No escape sequence(s) in the string.
		return;
	}
	
	// Architecture:
	// 
	// We're going to split the string into components separated by the given escape sequence.
	// Then we're going to loop over the components, looking for color codes at the beginning of each component.
	// 
	// For example, if the input string is "Hello__fg124,12,12;World" (with __ representing the escape sequence),
	// then our components would be: (
	//   "Hello"
	//   "fg124,12,12;World"
	// )
	// 
	// We would find a color code (rgb 124, 12, 12) for the foreground color in the second component.
	// At that point, the parsed foreground color goes into an attributes dictionary (attrs),
	// and the foreground color stays in effect (for the current component & future components)
	// until it gets cleared via a different foreground color, or a clear sequence.
	// 
	// The attributes are applied to the entire range of the component, and then we move onto the next component.
	// 
	// At the very end, we go back and apply "invisible" attributes (zero font, and clear text)
	// to the escape and color sequences.
	
	
	NSString *affectedString = [[textStorage string] substringWithRange:textStorageRange];
	
	// Split the string into components separated by the given escape sequence.
	
	NSArray *components = [affectedString componentsSeparatedByString:escapeSeq];
	
	NSRange componentRange = textStorageRange;
	componentRange.length = 0;
	
	BOOL firstPass = YES;
	
	NSMutableArray *seqRanges = [NSMutableArray arrayWithCapacity:[components count]];
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithCapacity:2];
	
	for (NSString *component in components)
	{
		if (firstPass)
		{
			// The first component in the array won't need processing.
			// If there was an escape sequence at the very beginning of the string,
			// then the first component in the array will be an empty string.
			// Otherwise the first component is everything before the first escape sequence.
		}
		else
		{
			// componentSeqRange : Range of escape sequence within component, e.g. "fg124,12,12;"
			
			NSColor *color = nil;
			NSUInteger colorCodeSeqLength = 0;
			
			BOOL stop = NO;
			
			BOOL reset = !stop && (stop = [component hasPrefix:@";"]);
			BOOL fg    = !stop && (stop = [component hasPrefix:@"fg"]);
			BOOL bg    = !stop && (stop = [component hasPrefix:@"bg"]);
            BOOL ansi    = !stop;

			BOOL resetFg = fg && [component hasPrefix:@"fg;"];
			BOOL resetBg = bg && [component hasPrefix:@"bg;"];

			if (reset)
			{
                // reset sequence length (";")
                colorCodeSeqLength = 1;

                // Reset attributes
				[attrs removeObjectForKey:NSForegroundColorAttributeName];
				[attrs removeObjectForKey:NSBackgroundColorAttributeName];
			}
			else if (resetFg || resetBg)
			{
				// reset color sequence length (@"xx;")
                colorCodeSeqLength = 3;

				// Reset attributes
				if (resetFg)
					[attrs removeObjectForKey:NSForegroundColorAttributeName];
				else
					[attrs removeObjectForKey:NSBackgroundColorAttributeName];
			}
			else if (fg || bg)
			{
				// Looking for something like this: "fg124,22,12;" or "bg17,24,210;".
				// These are the rgb values for the foreground or background.
				
				NSString *str_r = nil;
				NSString *str_g = nil;
				NSString *str_b = nil;
				
				NSRange range_search = NSMakeRange(2, MIN(4, [component length] - 2));
				NSRange range_separator;
				NSRange range_value;
				
				// Search for red separator
				range_separator = [component rangeOfString:@"," options:0 range:range_search];
				if (range_separator.location != NSNotFound)
				{
					// Extract red substring
					range_value.location = range_search.location;
					range_value.length = range_separator.location - range_search.location;
					
					str_r = [component substringWithRange:range_value];
					
					// Update search range
					range_search.location = range_separator.location + range_separator.length;
					range_search.length = MIN(4, [component length] - range_search.location);
					
					// Search for green separator
					range_separator = [component rangeOfString:@"," options:0 range:range_search];
					if (range_separator.location != NSNotFound)
					{
						// Extract green substring
						range_value.location = range_search.location;
						range_value.length = range_separator.location - range_search.location;
						
						str_g = [component substringWithRange:range_value];
						
						// Update search range
						range_search.location = range_separator.location + range_separator.length;
						range_search.length = MIN(4, [component length] - range_search.location);
						
						// Search for blue separator
						range_separator = [component rangeOfString:@";" options:0 range:range_search];
						if (range_separator.location != NSNotFound)
						{
							// Extract blue substring
							range_value.location = range_search.location;
							range_value.length = range_separator.location - range_search.location;
							
							str_b = [component substringWithRange:range_value];
							
							// Mark the length of the entire color code sequence.
							colorCodeSeqLength = range_separator.location + range_separator.length;
						}
					}
				}
				
				if (str_r && str_g && str_b)
				{
					// Parse rgb values and create color
					
					int r = MAX(0, MIN(255, [str_r intValue]));
					int g = MAX(0, MIN(255, [str_g intValue]));
					int b = MAX(0, MIN(255, [str_b intValue]));
					
					color = [NSColor colorWithCalibratedRed:(r/255.0)
					                                  green:(g/255.0)
					                                   blue:(b/255.0)
					                                  alpha:1.0];
					
					if (fg)
					{
						[attrs setObject:color forKey:NSForegroundColorAttributeName];
					}
					else
					{
						[attrs setObject:color forKey:NSBackgroundColorAttributeName];
					}
                }
				else
				{
					// Wasn't able to parse a color code
                    colorCodeSeqLength = 0;

                    // Reset attributes
                    [attrs removeObjectForKey:NSForegroundColorAttributeName];
                    [attrs removeObjectForKey:NSBackgroundColorAttributeName];
				}
			}
            else if (ansi) {

                NSUInteger endIndex = [component rangeOfString:@"m"].location;

                if (endIndex == NSNotFound) {

					// Wasn't able to parse a color code
                    colorCodeSeqLength = 0;
                }

                if (endIndex == 0) {

					// empty color sequence ("m")
                    colorCodeSeqLength = 1;
                }
                else {

                    colorCodeSeqLength = endIndex + 1;

                    NSString *attrString = [component substringWithRange:NSMakeRange(0, endIndex)];

                    NSString * const kTRShellAttributesSeparator = @";";

                    NSArray *attributes = [attrString componentsSeparatedByString:kTRShellAttributesSeparator];

                    NSColor *foregroundColor = nil, *backgroundColor = nil;
                    BOOL clearForeground = NO, clearBackground = NO;

                    for (NSString *attributeStr in attributes) {

                        TRShellAttribute attribute = [attributeStr integerValue];

                        switch (attribute) {

                            /* reset cases */

                            case TRShellAttributeResetAll:
                                foregroundColor = backgroundColor = nil;
                                clearForeground = clearBackground = YES;
                                break;

                            case TRShellAttributeForegroundDefault:
                                foregroundColor = nil;
                                clearForeground = YES;
                                break;

                            case TRShellAttributeBackgroundDefault:
                                backgroundColor = nil;
                                clearBackground = YES;
                                break;

                            /* foreground color cases */

                            case TRShellAttributeForegroundBlack:
                            case TRShellAttributeForegroundRed:
                            case TRShellAttributeForegroundGreen:
                            case TRShellAttributeForegroundYellow:
                            case TRShellAttributeForegroundBlue:
                            case TRShellAttributeForegroundMagenta:
                            case TRShellAttributeForegroundCyan:
                            case TRShellAttributeForegroundLightGray:
                            {
                                TRShellColor colorCode = attribute - TRShellAttributeForegroundRegular;
                                foregroundColor = colorForShellColor(colorCode, NO);
                                break;
                            }

                            case TRShellAttributeForegroundDarkGray:
                            case TRShellAttributeForegroundLightRed:
                            case TRShellAttributeForegroundLightGreen:
                            case TRShellAttributeForegroundLightYellow:
                            case TRShellAttributeForegroundLightBlue:
                            case TRShellAttributeForegroundLightMagenta:
                            case TRShellAttributeForegroundLightCyan:
                            case TRShellAttributeForegroundWhite:
                            {
                                TRShellColor colorCode = attribute - TRShellAttributeForegroundLight;
                                foregroundColor = colorForShellColor(colorCode, YES);
                                break;
                            }

                            case TRShellAttributeBackgroundBlack:
                            case TRShellAttributeBackgroundRed:
                            case TRShellAttributeBackgroundGreen:
                            case TRShellAttributeBackgroundYellow:
                            case TRShellAttributeBackgroundBlue:
                            case TRShellAttributeBackgroundMagenta:
                            case TRShellAttributeBackgroundCyan:
                            case TRShellAttributeBackgroundLightGray:
                            {
                                TRShellColor colorCode = attribute - TRShellAttributeBackgroundRegular;
                                backgroundColor = colorForShellColor(colorCode, NO);
                                break;
                            }

                            case TRShellAttributeBackgroundDarkGray:
                            case TRShellAttributeBackgroundLightRed:
                            case TRShellAttributeBackgroundLightGreen:
                            case TRShellAttributeBackgroundLightYellow:
                            case TRShellAttributeBackgroundLightBlue:
                            case TRShellAttributeBackgroundLightMagenta:
                            case TRShellAttributeBackgroundLightCyan:
                            case TRShellAttributeBackgroundWhite:
                            {
                                TRShellColor colorCode = attribute - TRShellAttributeBackgroundLight;
                                backgroundColor = colorForShellColor(colorCode, YES);
                                break;
                            }

                            default:
                                break;
                        }
                        
                    }

                    if (clearForeground) {
                        [attrs removeObjectForKey:NSForegroundColorAttributeName];
                    }
                    if (clearBackground) {
                        [attrs removeObjectForKey:NSBackgroundColorAttributeName];
                    }
                    if (foregroundColor) {
                        [attrs setObject:foregroundColor forKey:NSForegroundColorAttributeName];
                    }
                    if (backgroundColor) {
                        [attrs setObject:backgroundColor forKey:NSBackgroundColorAttributeName];
                    }
                }
            }

            NSRange seqRange = (NSRange){
                .location = componentRange.location - [escapeSeq length],
                .length = colorCodeSeqLength + [escapeSeq length],
            };
            [seqRanges addObject:[NSValue valueWithRange:seqRange]];
		}
		
		componentRange.length = [component length];
		
		[textStorage addAttributes:attrs range:componentRange];
		
		componentRange.location += componentRange.length + [escapeSeq length];
		firstPass = NO;
		
	} // END: for (NSString *component in components)
	
	
	// Now loop over all the discovered sequences, and apply "invisible" attributes to them.
	
	if ([seqRanges count] > 0)
	{
		NSDictionary *clearAttrs =
		    [NSDictionary dictionaryWithObjectsAndKeys:
		        [NSFont systemFontOfSize:0.001], NSFontAttributeName,
		                   [NSColor clearColor], NSForegroundColorAttributeName, nil];
		
		for (NSValue *seqRangeValue in seqRanges)
		{
			NSRange seqRange = [seqRangeValue rangeValue];
			[textStorage addAttributes:clearAttrs range:seqRange];
		}
	}
}

NSColor *colorForShellColor(TRShellColor colorCode, BOOL light) {

    // These colors are taken from the Terminal.app default preferences.

    switch (colorCode) {

        case TRShellColorBlack:

            if (!light) {
                return [NSColor blackColor];
            }
            else {
                return [NSColor colorWithCalibratedRed:0.326 green:0.326 blue:0.326 alpha:1.000];
            }
            break;

        case TRShellColorRed:

            if (!light) {
                return [NSColor colorWithDeviceRed:0.522 green:0.000 blue:0.009 alpha:1.000];
            }
            else {
                return [NSColor colorWithDeviceRed:0.863 green:0.000 blue:0.021 alpha:1.000];
            }
            break;

        case TRShellColorGreen:

            if (!light) {
                return [NSColor colorWithCalibratedRed:0.079 green:0.602 blue:0.009 alpha:1.000];
            }
            else {
                return [NSColor colorWithCalibratedRed:0.110 green:0.839 blue:0.017 alpha:1.000];
            }
            break;

        case TRShellColorYellow:

            if (!light) {
                return [NSColor colorWithCalibratedRed:0.530 green:0.540 blue:0.017 alpha:1.000];
            }
            else {
                return [NSColor colorWithCalibratedRed:0.877 green:0.892 blue:0.036 alpha:1.000];
            }
            break;

        case TRShellColorBlue:

            if (!light) {
                return [NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.639 alpha:1.000];
            }
            else {
                return [NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.998 alpha:1.000];
            }
            break;

        case TRShellColorMagenta:

            if (!light) {
                return [NSColor colorWithCalibratedRed:0.630 green:0.000 blue:0.640 alpha:1.000];
            }
            else {
                return [NSColor colorWithCalibratedRed:0.862 green:0.000 blue:0.875 alpha:1.000];
            }
            break;

        case TRShellColorCyan:

            if (!light) {
                return [NSColor colorWithCalibratedRed:0.075 green:0.589 blue:0.639 alpha:1.000];
            }
            else {
                return [NSColor colorWithCalibratedRed:0.113 green:0.885 blue:0.875 alpha:1.000];
            }
            break;

        case TRShellColorWhite:

            if (!light) {
                return [NSColor colorWithCalibratedRed:0.697 green:0.697 blue:0.697 alpha:1.000];
            }
            else {
                return [NSColor colorWithCalibratedRed:0.876 green:0.876 blue:0.876 alpha:1.000];
            }
            break;
    }
}

- (void)fixAttributesInRange:(NSRange)aRange
{
	// This method "overrides" the method within NSTextStorage.
	
	// First we invoke the actual NSTextStorage method.
	// This allows it to do any normal processing.
	
	IMP_NSTextStorage_fixAttributesInRange(self, _cmd, aRange);
	
	// Then we scan for our special escape sequences, and apply desired color attributes.
	
	char *xcode_colors = getenv(XCODE_COLORS);
	if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
	{
		ApplyANSIColors(self, aRange, XCODE_COLORS_ESCAPE);
	}
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XcodeColors

IMP ReplaceInstanceMethod(Class sourceClass, SEL sourceSel, Class destinationClass, SEL destinationSel)
{
	if (!sourceSel || !sourceClass || !destinationClass)
	{
		NSLog(@"XcodeColors: Missing parameter to ReplaceInstanceMethod");
		return nil;
	}
	
	if (!destinationSel)
		destinationSel = sourceSel;
	
	Method sourceMethod = class_getInstanceMethod(sourceClass, sourceSel);
	if (!sourceMethod)
	{
		NSLog(@"XcodeColors: Unable to get sourceMethod");
		return nil;
	}
	
	IMP prevImplementation = method_getImplementation(sourceMethod);
	
	Method destinationMethod = class_getInstanceMethod(destinationClass, destinationSel);
	if (!destinationMethod)
	{
		NSLog(@"XcodeColors: Unable to get destinationMethod");
		return nil;
	}
	
	IMP newImplementation = method_getImplementation(destinationMethod);
	if (!newImplementation)
	{
		NSLog(@"XcodeColors: Unable to get newImplementation");
		return nil;
	}
	
	method_setImplementation(sourceMethod, newImplementation);
	
	return prevImplementation;
}

+ (void)load
{
	NSLog(@"XcodeColors: %@ (v10.1)", NSStringFromSelector(_cmd));
	
	char *xcode_colors = getenv(XCODE_COLORS);
	if (xcode_colors && (strcmp(xcode_colors, "YES") != 0))
		return;
	
	IMP_NSTextStorage_fixAttributesInRange =
	    ReplaceInstanceMethod([NSTextStorage class], @selector(fixAttributesInRange:),
							  [XcodeColors_NSTextStorage class], @selector(fixAttributesInRange:));
	
	setenv(XCODE_COLORS, "YES", 0);
}

+ (void)pluginDidLoad:(id)xcodeDirectCompatibility
{
	NSLog(@"XcodeColors: %@", NSStringFromSelector(_cmd));
}

- (void)registerLaunchSystemDescriptions
{
	NSLog(@"XcodeColors: %@", NSStringFromSelector(_cmd));
}

@end
