//
//  Copyright (c) 2012 Oleg Geier
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

#import "SampleController.h"
#import "OGActionChooser.h"

@interface SampleController ()<OGActionChooserDelegate, UIApplicationDelegate> {
	UIWindow *_window;
} @end

@implementation SampleController

- (void)dealloc {
	[_window release];
	[super dealloc];
}

-(void)applicationDidFinishLaunching:(UIApplication *)application
{
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[_window addSubview:self.view];
	[_window makeKeyAndVisible];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{ return YES; }

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	// Test Button
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn setTitle: @"show OGActionChooser" forState:UIControlStateNormal];
	[btn setFrame: CGRectMake(40, 80, 240, 50)];
	[btn addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn];
}


//  ---------------------------------------------------------------
// |
// |  start OGActionChooser configuration
// |
//  ---------------------------------------------------------------

- (void)showActionSheet:(UIButton*)sender
{
	OGActionChooser *acSheet = [OGActionChooser actionChooserWithDelegate:self];
	acSheet.title = @"Chooser title";
	
	OGActionButton *fst = [OGActionButton buttonWithTitle:@"Toggle Shadow" 
												imageName:@"actionChooser_Button" 
												  enabled:YES];
	OGActionButton *snd = [OGActionButton buttonWithTitle:@"Change Color" 
												imageName:@"actionChooser_Button" 
												  enabled:YES];
	OGActionButton *trd = [OGActionButton buttonWithTitle:@"Next Page" 
												imageName:@"actionChooser_Button.png" 
												  enabled:YES];
	
	// you can use 'buttonWithTitle:image:enabled:' for example if you like to draw it with Quartz. Or you want to copy from another image etc.
	
	[acSheet setButtonsWithArray:[NSArray arrayWithObjects:
								  fst, @"", snd, // always three in a row (currently)
								  @"", @"", @"",
								  trd, nil]]; // next page
	[acSheet presentInView: sender.superview];
}

//  ---------------------------------------------------------------
// |
// |  Event handling OGActionChooser
// |
//  ---------------------------------------------------------------

- (void)actionChooser:(OGActionChooser *)ac buttonPressedWithIndex:(NSInteger)index
{
	// you can create an array of buttons to identify them by index
	switch (index) {
		case 0:
			ac.shouldDrawShadow = !ac.shouldDrawShadow; break;
		case 2:
			ac.backgroundColor = [UIColor colorWithRed:rand()%255/255.0 
												 green:rand()%255/255.0 
												  blue:rand()%255/255.0 alpha:0.8f];
			break;
		case 6:
			NSLog(@"first button on the second page clicked"); break;
		default:
			NSLog(@"clicked button with index: %i", index);
	}
	
	//[ac dismiss]; // if you like to close it right afterwards
}

- (void)actionChooserFinished:(OGActionChooser *)ac
{
	NSLog(@"cancel button clicked or dismissed programatically");
}

@end
