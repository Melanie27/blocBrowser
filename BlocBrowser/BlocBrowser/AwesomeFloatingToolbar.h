//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by MELANIE MCGANNEY on 5/31/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

//include this line as a promise to the compiler that it will learn what an awesomefloating toolbar is later
@class AwesomeFloatingToolbar;

//this line indicates that the definition to AwesomeFloatingToolbarDelegate is beginning. indicates that the protocol inherits from NSOBject protocol
@protocol AwesomeFloatingToolbarDelegate <NSObject>


//if the delegate implements this optional method it will be used when a button is tapped
@optional

-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

//new delegate method to protocol that indicates the toolbar wants to move around
-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;

//new delegate method protocol that inidcates the toolbar is being pinched
-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didPinchWithScale:(CGFloat)scale;

@end

//ends definition of the delegate protocol


//interface for the toolbar itself
@interface AwesomeFloatingToolbar : UIView

//a custom initializer that takes an array of 4 titles
-(instancetype) initWithFourTitles:(NSArray *)titles;

//a method that enables or disables a button based on the title passed in
-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

//a delegate property to use if a delegate is desired
@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

@end
