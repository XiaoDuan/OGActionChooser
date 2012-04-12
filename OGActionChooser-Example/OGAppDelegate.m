//
//  Copyright (c) 2011 Oleg Geier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "OGAppDelegate.h"

@implementation OGAppDelegate
@synthesize window = _window;
@synthesize acSheet;

- (void)dealloc
{
	[_window release];
	[acSheet release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Test Button
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(50, 100, 200, 50);
	[btn setTitle:@"show it to me" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
	
	// usual stuff
    self.window = [[[UIWindow alloc] initWithFrame:
					[[UIScreen mainScreen] bounds]] autorelease];
	UIView *theView = [[UIView alloc]initWithFrame:self.window.frame];
	[theView addSubview:btn];
	[self.window addSubview:theView];
	[theView release];
	
    [self.window makeKeyAndVisible];
    return YES;
}

//  ---------------------------------------------------------------
// |
// |  start OGActionChooser configuration
// |
//  ---------------------------------------------------------------

- (void)showActionSheet:(UIButton*)sender
{
	acSheet = [OGActionChooser actionChooserWithDelegate:self];
	
	OGActionButton *fst = [OGActionButton buttonWithTitle:@"First Button" 
												imageName:@"actionChooser_Button" 
												  enabled:YES];
	OGActionButton *snd = [OGActionButton buttonWithTitle:@"Second" 
												imageName:@"actionChooser_Button" 
												  enabled:NO];
	OGActionButton *trd = [OGActionButton buttonWithTitle:@"Next Page" 
												imageName:@"actionChooser_Button.png" 
												  enabled:YES];
	
	// you can use 'buttonWithTitle:image:enabled:' for example if you like to draw it with Quartz. Or you want to copy from another image etc.
	
	[acSheet setButtonsWithArray:[NSArray arrayWithObjects:
								  fst, @"", snd, // always three in a row
								  @"", @"", @"",
								  trd, nil]]; // next page
	[acSheet presentInView: sender.superview];
}

//  ---------------------------------------------------------------
// |
// |  Event handling OGActionChooser
// |
//  ---------------------------------------------------------------

- (void)actionChooserButtonPressedWithIndex:(NSInteger)index
{
	// you can create an array of buttons to identify them by index
	NSLog(@"clicked button with index: %i", index);
	if (index == 6) {
		NSLog(@"first button on the second page clicked");
	}
	[acSheet dismiss]; // dismiss if you like to close it right afterwards
}

- (void)actionChooserFinished
{
	NSLog(@"cancel button clicked or dismissed programatically");
}

@end
