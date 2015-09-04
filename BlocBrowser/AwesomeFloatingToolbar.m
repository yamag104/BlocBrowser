//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Yoko Yamaguchi on 8/29/15.
//  Copyright (c) 2015 Yoko Yamaguchi. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longpressGesture;
@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#define colorPurple [UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1]
#define colorRed [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1]
#define colorOrange [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1]
#define colorYellow [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisLabel forState:UIControlStateNormal];
            [button setTitle:titleForThisLabel forState:UIControlStateHighlighted];
            button.backgroundColor = colorForThisLabel;
            button.titleLabel.textColor = [UIColor whiteColor];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        // Calls tapFired: when tap is detected
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressFired:)];
        [self.longpressGesture setMinimumPressDuration:1];
        [self addGestureRecognizer:self.longpressGesture];
    }
    
    return self;
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UILabel *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) /2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) /2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust labelX and labelY for each label
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            //2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds)/2;
        }
        
        if (currentButtonIndex % 2 ==0) { // is currentLabelIndex evenly divisble by 2?
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds)/2;
        }
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

#pragma mark - Tap Gestures

- (void) buttonPressed:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:sender.titleLabel.text];
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        self.lastScale = 1.0;
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScaleFactor:)]){
            [self.delegate floatingToolbar:self didTryToPinchWithScaleFactor:[recognizer scale]];
        }
//        recognizer.scale=1;
//    }
}


- (void) longpressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        for (NSInteger i=0; i<4; ++i){
            UIColor *currentColor= ((UIButton *)[self.buttons objectAtIndex:i]).backgroundColor;
            if ([currentColor isEqual:colorPurple]){
                ((UIButton *)[self.buttons objectAtIndex:i]).backgroundColor = colorOrange;
            }
            else if ([currentColor isEqual:colorRed]){
                ((UIButton *)[self.buttons objectAtIndex:i]).backgroundColor = colorPurple;
            }
            else if ([currentColor isEqual:colorYellow]){
                ((UIButton *)[self.buttons objectAtIndex:i]).backgroundColor = colorRed;
            }
            else if ([currentColor isEqual:colorOrange]){
                ((UIButton *)[self.buttons objectAtIndex:i]).backgroundColor = colorYellow;
            }
        }
    
    }
    
}

@end
