//
//  UIView+BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Larry Lynn on 3/3/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

//#import "UIView+BLCAwesomeFloatingToolbar.h"

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UIButton *currentButton;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;


//@property (nonatomic) CGFloat scale;

//@property (nonatomic, readonly) CGFloat velocity;

@end

@implementation BLCAwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    
    self = [super init];
    
    if (self) {
        
        // Save the titles and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
                        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
                        
        //make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];  //0 thru 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            [button.titleLabel setTextAlignment: NSTextAlignmentCenter];
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle: titleForThisButton forState:UIControlStateNormal];
            button.backgroundColor = colorForThisButton;
            button.tintColor = [UIColor whiteColor];
            
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
        //self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        //[self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longFired:)];
        [self addGestureRecognizer:self.longGesture];
        
        
    }
    
    return self;
    
}

//- (void) tapFired:(UITapGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//        CGPoint location = [recognizer locationInView:self];
//        UIView *tappedView = [self hitTest:location withEvent:nil];
//        
//        if ([self.buttons containsObject:tappedView]) {
//            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
//            }
//        }
//    }
//}


- (void) layoutSubviews {
    //set the frames for the 4 labels
    
    for (UIButton *thisLabel in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        //adjust lableX and labelY for each label
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        }  else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        if (currentButtonIndex % 2 == 0) {  //is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
            
        }  else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark - Gesture Recognizers

- (void) buttonPressed:(UIButton *) button {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:button.titleLabel.text];
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
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = recognizer.scale;
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:scale];
        }
        
        
    }
}

- (void) longFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        self.colors = @[self.colors[3],
                        self.colors[0],
                        self.colors[1],
                        self.colors[2]];
        
        for (int i = 0; i < self.colors.count; i ++) {
            UILabel *buttons = self.buttons[i];
            UIColor *color = self.colors[i];
            buttons.backgroundColor = color;
            
        }
    }
}




#pragma mark - Touch Handling

//- (UILabel *) labelFromTouches:(NSSet *)touches withEvent: (UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self];
//    UIView *subView = [self hitTest:location withEvent:event];
//    return (UILabel *)subView;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
//    UILabel *label  = [self labelFromTouches:touches withEvent:event];
//    
//    self.currentLabel = label;
//    self.currentLabel.alpha = 0.5;
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    UILabel *label = [self labelFromTouches:touches withEvent:event];
//    
//    if (self.currentLabel != label) {
//        // the label being touched is no longer the initial label
//        self.currentLabel.alpha = 1;
//        
//    } else {
//        //the label being touched is the initial label
//        self.currentLabel.alpha = 0.5;
//        
//    }
//}
//
//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UILabel *label = [self labelFromTouches:touches withEvent:event];
//    
//    if (self.currentLabel == label)  {
//        NSLog(@"Label tapped: %@", self.currentLabel.text);
//        
//        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//            [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text];
//        }
//    }
//    
//    self.currentLabel.alpha = 1;
//    self.currentLabel = nil;
//}
//
//- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.currentLabel.alpha = 1;
//    self.currentLabel = nil;
//    
//}

# pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
