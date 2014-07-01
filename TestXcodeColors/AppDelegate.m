#import "AppDelegate.h"
#import "XcodeColors.h"

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

#define XCODE_COLORS_ESCAPE_MAC @"\033["
#define XCODE_COLORS_ESCAPE_IOS @"\xC2\xA0["

#if TARGET_OS_IPHONE
  #define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_IOS
#else
  #define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
#endif

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

#define LogBlue(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,0,255;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"After building the XcodeColors plugin for the first time, you MUST RESTART XCODE.");
	NSLog(@"If you still don't see colors below, please consult the README.");
	
	NSLog(XCODE_COLORS_ESCAPE @"fg0,0,255;" @"Blue text" XCODE_COLORS_RESET);
	
	NSLog(XCODE_COLORS_ESCAPE @"bg220,0,0;" @"Red background" XCODE_COLORS_RESET);
	
	NSLog(XCODE_COLORS_ESCAPE @"fg0,0,255;"
		  XCODE_COLORS_ESCAPE @"bg220,0,0;"
		  @"Blue text on red background"
		  XCODE_COLORS_RESET);
	
	NSLog(XCODE_COLORS_ESCAPE @"fg209,57,168;" @"You can supply your own RGB values!" XCODE_COLORS_RESET);
	
	LogBlue(@"Blue text via macro");

  //  [self testANSIColors];
}

- (void)testANSIColors {

    NSLog(@"\n=======Testing ANSI colors=======");

    //These correspond to the TRShellColor values
    NSArray *colorNames = @[@"Black", @"Red", @"Green", @"Yellow", @"Blue", @"Magenta", @"Cyan", @"White"];

    TRShellAttribute baseAttributes[] = {TRShellAttributeForegroundRegular, TRShellAttributeForegroundLight, TRShellAttributeBackgroundRegular, TRShellAttributeBackgroundLight};

    TRShellColor colorCode;
    for (NSInteger i = 0; i < 4; i++) {

        TRShellAttribute baseAttribute = baseAttributes[i];

        // Test without reset
        colorCode = TRShellColorBlack;
        for (NSString *colorName in colorNames) {

            NSLog(@"%@%lum%@", XCODE_COLORS_ESCAPE, baseAttribute + colorCode++, colorName);
        }

        NSLog(@"No Attribute");


        //Test with reset
        colorCode = TRShellColorBlack;
        for (NSString *colorName in colorNames) {

            NSLog(@"%@%lum%@%@", XCODE_COLORS_ESCAPE, baseAttribute + colorCode++, colorName, XCODE_COLORS_RESET);
        }

        NSLog(@"No Attribute");
    }

    // Test setting both background and foreground
    colorCode = TRShellColorBlack;
    NSInteger count = 0;

    for (NSString *colorName in colorNames) {

        TRShellColor bgColorCode = [colorNames count] - (1 + count++);
        NSString *bgColorName = colorNames[bgColorCode];
        NSLog(@"%@%lu;%lum%@-bg%@%@", XCODE_COLORS_ESCAPE, TRShellAttributeForegroundRegular + colorCode, TRShellAttributeBackgroundRegular + bgColorCode, colorName, bgColorName,XCODE_COLORS_RESET);
        colorCode++;
    }
    
    NSLog(@"No Attribute");
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}
@end
