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

#import "OGActionChooser.h"

#define ScrollViewEdgePadding 10
#define ActionButtonPaddingX 4
#define ActionButtonPaddingY 4
#define ActionButtonSizeX 84
#define ActionButtonSizeY 94
#define maxColumns 3
#define maxRows 2


typedef struct { char page; char column; char row; } ActionIndexPath;
ActionIndexPath actionIndexPathMake(char page, char column, char row) {
	ActionIndexPath aip;
	aip.page = page; aip.column = column; aip.row = row;
	return aip;
}

@interface OGCloseButton : UIButton {} @end
@interface OGAlertSheetBackground : UIView {} @end

@interface OGActionChooserButton : UIButton {}
- (id)initWithImage:(UIImage*)image andTitle:(NSString*)title;
@end


#pragma mark - Main Controller ###############################

@interface OGActionChooser ()
@property (nonatomic, retain) UILabel *lbl_Title;
@property (nonatomic, retain) UIScrollView *buttonScroll;
@property (nonatomic, retain) UIPageControl *pageControl;

- (void)actionButtonTapped:(OGActionChooserButton*)sender;
- (CGPoint)buttonCenterPoint:(ActionIndexPath)pos;
- (void)finishCloseAnimation;
@end


@implementation OGActionChooser
@synthesize delegate, lbl_Title, buttonScroll, pageControl;

- (id)init {
	self = [super init];
	if (self) {
		
		self.view.frame = CGRectMake(0,0,299,262);
		self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		
		UIView *chooserView = [[UIView alloc]initWithFrame:CGRectMake(0,0,299,262)];
		chooserView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
										UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		
		OGAlertSheetBackground *backgroundImage = [[OGAlertSheetBackground alloc]initWithFrame:CGRectMake(0,7,299,255)];
		backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		backgroundImage.backgroundColor = [UIColor clearColor];
		[chooserView addSubview:backgroundImage];
		[backgroundImage release];
		
		self.lbl_Title = [[UILabel alloc]initWithFrame:CGRectMake(24,12,252,22)];
		lbl_Title.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		lbl_Title.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
		lbl_Title.textAlignment = UITextAlignmentCenter;
		lbl_Title.lineBreakMode = UILineBreakModeTailTruncation;
		lbl_Title.textColor = [UIColor whiteColor];
		lbl_Title.backgroundColor = [UIColor clearColor];
		[chooserView addSubview:lbl_Title];
		[lbl_Title release];
		
		self.buttonScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(10,39,279,193)];
		buttonScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		buttonScroll.backgroundColor = [UIColor clearColor];
		buttonScroll.pagingEnabled = YES;
		buttonScroll.showsHorizontalScrollIndicator = NO;
		buttonScroll.delegate = self;
		[chooserView addSubview:buttonScroll];
		[buttonScroll release];
		
		self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(20,224,260,36)];
		pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
		pageControl.hidesForSinglePage = YES;
		[chooserView addSubview:pageControl];
		[pageControl release];
		
		OGCloseButton *closeButton = [[OGCloseButton alloc]initWithFrame:CGRectMake(0,0,25,25)];
		closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
		[chooserView addSubview:closeButton];
		[closeButton release];
		
		
		[self.view addSubview:chooserView];
		[chooserView release];
	}
	return self;
}

+ (id)actionChooserWithDelegate:(id<OGActionChooserDelegate>)dlg {
	OGActionChooser *ogac = [[OGActionChooser alloc]init];
	ogac.delegate = dlg;
	[ogac setButtonsWithArray:nil];
	
	return [ogac autorelease];
}

- (void)dealloc {
	[lbl_Title release];
	[buttonScroll release];
	[pageControl release];
	[super dealloc];
}

#pragma mark -

- (void)presentInView:(UIView*)parentview {
	[self retain];
	self.view.frame = parentview.bounds;
	self.view.alpha = 0.0f;
	[parentview addSubview:self.view];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15f];
	self.view.alpha = 1.0f;
	[UIView commitAnimations];
}

- (void)dismiss {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishCloseAnimation)];
	self.view.alpha = 0.0f;
	[UIView commitAnimations];
}

- (void)finishCloseAnimation {
	[self.view removeFromSuperview];
	
	if ([delegate respondsToSelector:@selector(actionChooserFinished)])
		[delegate actionChooserFinished];
	
	[self release];
}

#pragma mark - Custom Methods

- (void)setTitle:(NSString *)title { lbl_Title.text = title; }

- (NSString*)title { return lbl_Title.text; }

- (void)actionButtonTapped:(OGActionChooserButton*)sender {
	int tg = sender.tag;
	ActionIndexPath indexPath = actionIndexPathMake(tg/100, (tg%100)/10, tg%10);
	int arrayIndex = indexPath.page*(maxColumns*maxRows)+(maxColumns*indexPath.row)+indexPath.column;
	[delegate actionChooserButtonPressedWithIndex:arrayIndex];
}

- (void)setButtonsWithArray:(NSArray*)buttons {
	int numberOfButtons = buttons.count;
	int numberOfPages = ceilf((float)numberOfButtons/(maxColumns*maxRows));
	
	
	[buttonScroll setContentSize:CGSizeMake(buttonScroll.frame.size.width*numberOfPages, buttonScroll.frame.size.height)];
	pageControl.numberOfPages = numberOfPages;
	
	int page=-1, column=-1, row=-1;
	int i = 0;
	while (i<numberOfButtons) {
		
		column = ++column%3; // constantly run through 0,1,2,0,1,2,…
		if (column == 0) {
			row = ++row%2;
			if (row == 0) {
				page++;
			}
		}
		OGActionButton *actBtn = [buttons objectAtIndex:i];
		
		if (actBtn && [actBtn isKindOfClass:[OGActionButton class]]) {
			OGActionChooserButton *gacb = [[OGActionChooserButton alloc]initWithImage:actBtn.image andTitle:actBtn.title];
			[gacb addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
			gacb.center = [self buttonCenterPoint: actionIndexPathMake(page, column, row)];
			gacb.enabled = actBtn.enabled;
			gacb.tag = page*100 + column*10 + row;
			gacb.alpha = 0.9f;
			[buttonScroll addSubview:gacb];
			[gacb release];
		}
		
		i++;
	}
}

- (CGPoint)buttonCenterPoint:(ActionIndexPath)pos { // first = 0,0,0
	// example: 10px + ((84+4)*column) + (84/2) + (scroll-width * page)
	float xpos = ScrollViewEdgePadding + ((ActionButtonSizeX+ActionButtonPaddingX)*pos.column) + (ActionButtonSizeX/2) + buttonScroll.frame.size.width*pos.page;
	// example: ((94+4)*row) + (94/2)
	float ypos = ((ActionButtonSizeY+ActionButtonPaddingY)*pos.row) + (ActionButtonSizeY/2);
	
	return CGPointMake(xpos, ypos);
}

#pragma mark - Delegates and Page Control

- (void)pageControlChanged:(id)sender {
	if (sender == pageControl) {
		CGSize scrSize = buttonScroll.frame.size;
		CGRect scrRect = CGRectMake(pageControl.currentPage*scrSize.width, 0, scrSize.width, scrSize.height);
		[buttonScroll scrollRectToVisible:scrRect animated:YES];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (pageControl) {
		pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
	}
}

@end



#pragma mark - ##############################################



#pragma mark - ActionButton Object

@implementation OGActionButton
@synthesize title, image, enabled;
+ (id)buttonWithTitle:(NSString*)t imageName:(NSString*)n enabled:(BOOL)en {
	return [OGActionButton buttonWithTitle:t image:[UIImage imageNamed:n] enabled:en];
}
+ (id)buttonWithTitle:(NSString*)t image:(UIImage*)i enabled:(BOOL)en {
	OGActionButton *btn = [[super alloc]init];
	btn.title = t;
	btn.image = i;
	btn.enabled = en;
	return [btn autorelease];
}
@end



#pragma mark - ActionChooserButton

@implementation OGActionChooserButton
- (id)initWithImage:(UIImage*)image andTitle:(NSString*)title {
	self = [super initWithFrame:CGRectMake(0,0,ActionButtonSizeX,ActionButtonSizeY)];
	if (self) {
		[self setImage:image forState:UIControlStateNormal];
		
		UILabel *btnLabel = [[UILabel alloc]initWithFrame:CGRectMake(2,83,ActionButtonSizeX-4,12)]; // 2px padding
		btnLabel.textColor = [UIColor colorWithRed:0.0f green:0.25f blue:0.5f alpha:1.0f];
		btnLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
		btnLabel.textAlignment = UITextAlignmentCenter;
		btnLabel.backgroundColor = [UIColor clearColor];
		btnLabel.lineBreakMode = UILineBreakModeTailTruncation;
		btnLabel.highlightedTextColor = [UIColor whiteColor];
		btnLabel.text = title;
		[self addSubview:btnLabel];
		[btnLabel release];
	}
	return self;
}
@end



#pragma mark - Close-Button

@implementation OGCloseButton

- (void)drawRect:(CGRect)rect {
	float radius = MIN(rect.size.width, rect.size.height)/2;
	float hWidth = CGRectGetMidX(rect);
	float hHeight = CGRectGetMidY(rect);
	float outerLineWidth = 1.0f;
	float x = radius*0.35;
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGColorRef whiteColor = [(self.highlighted ? [UIColor lightGrayColor] : [UIColor whiteColor]) CGColor];
	CGColorRef blackColor = [[UIColor blackColor] CGColor];
	
	CGContextSetFillColorWithColor(c, whiteColor);
	CGContextSetStrokeColorWithColor(c, blackColor);
	CGContextSetLineWidth(c, outerLineWidth);
	CGContextMoveToPoint(c, hWidth + radius - outerLineWidth, hHeight);
	CGContextAddArc(c, hWidth, hHeight, radius - outerLineWidth, 0, 2*M_PI, false);
	CGContextDrawPath(c, kCGPathFillStroke);
	
	CGContextSetFillColorWithColor(c, blackColor);
	CGContextMoveToPoint(c, hWidth + (radius*0.75), hHeight);
	CGContextAddArc(c, hWidth, hHeight, radius*0.75, 0, 2*M_PI, false);
	CGContextDrawPath(c, kCGPathFill);
	
	CGContextSetStrokeColorWithColor(c, whiteColor);
	CGContextSetLineWidth(c, radius*0.2);
	CGContextMoveToPoint	(c, hWidth-x, hHeight-x); // x.
	CGContextAddLineToPoint	(c, hWidth+x, hHeight+x); // .x
	CGContextMoveToPoint	(c, hWidth+x, hHeight-x); // .x
	CGContextAddLineToPoint	(c, hWidth-x, hHeight+x); // x.	
	CGContextDrawPath(c, kCGPathStroke);
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
}

@end



#pragma mark - Alert Sheet Background

@implementation OGAlertSheetBackground

#define OGEdgeRadius 16.0f
#define OGEdgePadding 6.0f
#define OGEdgeButtomPad 9.0f
#define OGLineWidth 2.0f

- (void)drawRect:(CGRect)rect {
	float width = rect.size.width;
	float heigth = rect.size.height;
	float padEdge = OGEdgeRadius+(OGLineWidth/2);
	CGPoint p1 = CGPointMake(      OGEdgePadding+padEdge, padEdge);// p1 p2
	CGPoint p2 = CGPointMake(width-OGEdgePadding-padEdge, padEdge);// p4 p3
	CGPoint p3 = CGPointMake(width-OGEdgePadding-padEdge, heigth-OGEdgeButtomPad-padEdge);
	CGPoint p4 = CGPointMake(      OGEdgePadding+padEdge, heigth-OGEdgeButtomPad-padEdge);
	
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, p1.x, p1.y-OGEdgeRadius);
	CGPathAddArcToPoint(path, NULL, p2.x+OGEdgeRadius, p2.y-OGEdgeRadius, p2.x+OGEdgeRadius, p2.y, OGEdgeRadius);
	CGPathAddArcToPoint(path, NULL, p3.x+OGEdgeRadius, p3.y+OGEdgeRadius, p3.x, p3.y+OGEdgeRadius, OGEdgeRadius);
	CGPathAddArcToPoint(path, NULL, p4.x-OGEdgeRadius, p4.y+OGEdgeRadius, p4.x-OGEdgeRadius, p4.y, OGEdgeRadius);
	CGPathAddArcToPoint(path, NULL, p1.x-OGEdgeRadius, p1.y-OGEdgeRadius, p1.x, p1.y-OGEdgeRadius, OGEdgeRadius);
	
	CGMutablePathRef glass = CGPathCreateMutable();
	CGPathMoveToPoint(glass, NULL, 0, 0);
	CGPathAddLineToPoint(glass, NULL, width, 0);
	CGPathAddLineToPoint(glass, NULL, width, heigth/12);
	CGPathAddQuadCurveToPoint(glass, NULL, width/2, heigth/6, 0, heigth/12);
	CGPathAddLineToPoint(glass, NULL, 0, 0);
	
	
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(c);
	CGContextSetShadowWithColor(c, CGSizeMake(0, 5), 5.0, [[[UIColor blackColor] colorWithAlphaComponent:0.6]CGColor]);
	
	CGContextSetLineWidth(c, OGLineWidth);
	CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:0.8f alpha:1.0] CGColor]);
	CGContextSetFillColorWithColor(c, [[UIColor colorWithRed:17/255.0 green:25/255.0 blue:68/255.0 alpha:0.8] CGColor]);
	
	CGContextBeginTransparencyLayer (c, NULL);
	CGContextAddPath(c, path);
	CGContextDrawPath(c, kCGPathFillStroke);
	CGContextEndTransparencyLayer(c);
	CGContextRestoreGState(c);
	
	// Draw Glass-Layer
	// Clip to AlertSheet AND glass bezier
	CGContextAddPath(c, path);
	CGContextClip(c);
	CGContextAddPath(c, glass);
	CGContextClip(c);
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat colors[] ={
		1.0, 1.0, 1.0, 0.4f,
		1.0, 1.0, 1.0, 0.15f
	};
	CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, 2);
	CGColorSpaceRelease(rgb);
	
	CGContextDrawLinearGradient(c, gradient, CGPointMake(0, 0), CGPointMake(0, heigth/8), kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
	CGPathRelease(path);
	CGPathRelease(glass);
}

@end