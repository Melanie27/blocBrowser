//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by MELANIE MCGANNEY on 5/31/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

//create properties to store lables, colors, titles
@interface AwesomeFloatingToolbar()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray<UILabel*> *labels;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) NSArray<UIButton*> *buttons;
//@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end


@implementation AwesomeFloatingToolbar
//next - write an initializer to create 4 lables and assign colors and text to each. then, all all that to the view

-(instancetype) initWithFourTitles:(NSArray *)titles {
    //First, call the superclass UIView's initializer
    
    self = [super init];
    
    if (self) {
        
        //save the titles and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]
                        ];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        self.colorOffset = 0;

        //Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
           
            //property that indicates whether a UIView (or subclass) receives touch events
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];// 0 through 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
             NSLog(@"Setting color for %@",titleForThisButton);
            [self setEnabled:YES forButtonWithTitle:titleForThisButton];
            
           
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            [button setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
            
            
            //class that represents color and sometimes opacity
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            [button setBackgroundColor:colorForThisButton];
            
            
           
            
            //button.textAlignment = NSTextAlignmentCenter;
            //button.font = [UIFont systemFontOfSize:10];

            
            [buttonsArray addObject:button];
        }
        
        
        self.buttons = buttonsArray;

        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
        
      
        [self setColorsFromOffset];
        
        
        //create and initialize pan gesture
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        //create and initialize pinch gesture
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        //create and initialize longpress gesture
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}

-(IBAction)buttonTouchUpInside:(id)sender {
    
    NSLog(@"Button Touch Up Inside Event Fired.");
    //[self setEnabled:YES forButtonWithTitle:titleForThisButton];
}

-(void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}


-(void)setColorsFromOffset {
    for (NSInteger i = 0; i<self.buttons.count; i++) {
        UIColor *colorForThisButton = self.colors[(i+self.colorOffset)%self.colors.count];
        
        self.buttons[i].backgroundColor = colorForThisButton;
        NSLog(@"Setting color for %ld",i);
    }
}

//implement panFired method

-(void) panFired:(UIPanGestureRecognizer *) recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        //NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

//implement pinch

-(void) pinchFired:(UIPinchGestureRecognizer *) recognizer {
    CGFloat scale = recognizer.scale;
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didPinchWithScale:scale];
        }
        
        recognizer.scale = 1;
        
    }
}

//implement longpress gesture recognizer that rotates the background colors when fired

-(void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Long Press Began");
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbarDidLongPress:)]) {
            [self.delegate floatingToolbarDidLongPress:self];
        }
    }
    
}


//layout the 4 labels in a 2x2 grid
//layout subview will get called any time a view's frame changes
//code loops though the array of labels and sets the correct origin point and size


//subview for buttons
-(void) layoutSubviews {
    //set frames
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex =[self.buttons indexOfObject:thisButton];
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        //adjust labelX and labelY for each label
        if (currentButtonIndex < 2 ) {
            //0 or 1 so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0) {
            buttonX = 0;
        } else {
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
        
    }
}


#pragma mark - Button Enabling







#pragma mark - Touch Handling


-(UIButton *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *) event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UIButton class]]) {
        return (UIButton *)subview;
    } else {
        return nil;
    }
    
}


-(void) rotateColors {
    
    NSArray *colors = @[@"red",@"blue",@"green",@"yellow"];
    for (NSInteger offset = 0; offset <= 10; offset++) {
    
    NSLog(@"1: %@  2: %@  3: %@  4: %@",
          colors[(0+offset)%4],
          colors[(1+offset)%4],
          colors[(2+offset)%4],
          colors[(3+offset)%4]);
    }
     
    self.colorOffset++;
    [self setColorsFromOffset];
}

-(void)scaleBy:(CGFloat)scale {
    self.transform = CGAffineTransformScale(self.transform, scale, scale);
}



@end
