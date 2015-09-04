//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Yoko Yamaguchi on 8/29/15.
//  Copyright (c) 2015 Yoko Yamaguchi. All rights reserved.
//

#import <UIKit/UIKit.h>

// include this line as a promise to the compiler that it will learn what this class is about below
@class AwesomeFloatingToolbar;

// clases can optionally be informed when oen of the titles is pressed
// indicates that definition of AwesomeFloatingToolBarDelegate is beginning
// this protocol inherits from the NSObject protocol
@protocol AwesomeFloatingToolbarDelegate <NSObject>

// this optional delegate method gets called once the user taps a button
@optional

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPinchWithScaleFactor:(CGFloat)scale;
-(void)floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToLongPressWithColors:(UIColor *)color;
@end

@interface AwesomeFloatingToolbar : UIView

- (instancetype) initWithFourTitles:(NSArray *)titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

@end
