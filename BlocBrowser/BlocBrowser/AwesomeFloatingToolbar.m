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
@property (nonatomic, strong) NSArray *labels;

@property (nonatomic, weak) UILabel *currentLabel;




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
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
    }
    
    return self;
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

//when touch begins, dim the label
-(void)touchesBegan:(NSSet *) touches withEvent: (UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    self.currentLabel = label;
    self.currentLabel.alpha = 0.5;
}


//when touch moves, check if user is still touching the same label and change alpha accordingly
-(void)touchesMoved:(NSSet *) touches withEvent: (UIEvent *) event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if(self.currentLabel != label) {
        //the label being touched is no longer the initial label
        self.currentLabel.alpha = 1;
    } else {
        //label being touched is the initial label
        self.currentLabel.alpha = .5;
    }
}


//when user lifts finger touch has ended. check if finger was lifted from initial label or not and reset variables

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel == label) {
        NSLog(@"Label tapped: %@", self.currentLabel.text);
        
        if([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle: self.currentLabel.text];
        }
    }
    
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;

}

//if touch is canceled (by a phone call or something) reset the variables

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
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
