//
//  OGActionChooser.h
//  ActionChooser
//
//  Created by Oleg Geier on 13.07.11.
//  Copyright 2011 Oleg Geier. All rights reserved.
//
//  Weiterverwendung in anderen Projekten (außerhalb des GPS-Explorer mobil)
//  nur durch vorherige Zustimmung des Autors.
//


@interface OGActionButton : NSObject {}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) BOOL enabled;
+ (id)buttonWithTitle:(NSString*)t image:(UIImage*)i enabled:(BOOL)en;
+ (id)buttonWithTitle:(NSString*)t imageName:(NSString*)n enabled:(BOOL)en;
@end



@protocol OGActionChooserDelegate <NSObject>
- (void)actionChooserButtonPressedWithIndex:(NSInteger)index;
- (void)actionChooserFinished;
@end


@interface OGActionChooser : UIViewController <UIScrollViewDelegate> {}
@property (nonatomic, assign) id<OGActionChooserDelegate> delegate;

+ (id)actionChooserWithDelegate:(id<OGActionChooserDelegate>)dlg;
- (void)setButtonsWithArray:(NSArray*)buttons;
- (void)presentInView:(UIView*)parentview;
- (void)dismiss;
@end