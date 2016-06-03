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

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
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
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        self.colorOffset = 0;

        //Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init];
            
            //property that indicates whether a UIView (or subclass) receives touch events
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];// 0 through 3
            NSLog(@"%lu", currentTitleIndex);
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            
            //class that represents color and sometimes opacity
            /*
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            label.backgroundColor = colorForThisLabel;
             */
            
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
        
        [self setColorsFromOffset];
        
        // #1 - tells gesture recognizer which method to call when the tap is detected
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        
        // #2 tells the view (self) to route touch events through this gesture recognizer
        [self addGestureRecognizer:self.tapGesture];
        
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


-(void)setColorsFromOffset {
    for (NSInteger i = 0; i<self.labels.count; i++) {
        UIColor *colorForThisLabel = self.colors[(i+self.colorOffset)%self.colors.count];
        
        self.labels[i].backgroundColor = colorForThisLabel;
        NSLog(@"Setting color for %ld",i);
    }
}

//implement tapFired method

//3 checks for the proper state
//4 calculates and stores an x-y coordinate of the gesture's location with respect to self's bounds - tap in top left will register (0,0)
//5 invokes hitTest:withEvent to determine which view received the tap
//6 check if the view that was tapped was one of the toolbar labels, if so verify delegate for compatibility before the method call

//we care where the gesture occurred

-(void) tapFired:(UITapGestureRecognizer *) recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {  //#3
        CGPoint location = [recognizer locationInView:self]; //#4
        UIView *tappedView = [self hitTest:location withEvent:nil]; //5
        
        if([self.labels containsObject:tappedView]) { //#6
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
            }
        }
    }
}

// we care what direction the gesture is going in
//translation is how far the user's finger has moved in each direction since touch event began
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
    
    
    /*if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didPinchWithScale:scale];
        }
        
        recognizer.scale = 1;
        NSLog(@"%f", recognizer.scale);
    }*/
    
    
    
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didPinchWithScale:scale];
        }
        
        //can we talk about setScale?
        //[recognizer setScale:scale];
        recognizer.scale = 1;
        NSLog(@" test, %f", recognizer.scale);
        
    }
}

//implement longpress gesture recognizer that rotates the background colors when fired

-(void) longPressFired:(UILongPressGestureRecognizer *)recognizer
{
    
   
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Long Press Began");
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbarDidLongPress:)]) {
            [self.delegate floatingToolbarDidLongPress:self];
        }
        
        //[longPressTimer fire];
    }
    
    /*if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        NSLog(@"Long Press Ended");
        longPressTimer = nil;
        
    }*/
}




//layout the 4 lables in a 2x2 grid
//layout subview will get called any time a view's frame changes
//code loops though the array of labels and sets the correct origin point and size


-(void) layoutSubviews {
    //set the frames for the 4 lables
    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex =[self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        //adjust labelX and labelY for each label
        if (currentLabelIndex < 2 ) {
            //0 or 1 so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) {
            labelX = 0;
        } else {
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        
    }
}


#pragma mark - Touch Handling

//method to determine which of the labels was touched

-(UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *) event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UILabel *)subview;
    } else {
        return nil;
    }

}

-(void) rotateColors {
    /*
    NSArray *colors = @[@"red",@"blue",@"green",@"yellow"];
    for (NSInteger offset = 0; offset <= 10; offset++) {
    
    NSLog(@"1: %@  2: %@  3: %@  4: %@",
          colors[(0+offset)%4],
          colors[(1+offset)%4],
          colors[(2+offset)%4],
          colors[(3+offset)%4]);
    }
     */
    self.colorOffset++;
    [self setColorsFromOffset];
}


#pragma mark -- Button Enabling

-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled? 1.0 : .25;
    }
}

@end
