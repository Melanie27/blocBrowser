//
//  ViewController.m
//  BlocBrowser
//
//  Created by MELANIE MCGANNEY on 5/26/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "AwesomeFloatingToolbar.h"


//define directives let us make up a word that is replaced with whatever word follows
#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")


//in interface need to declare that we conform to the new "awesome" protocol
@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

//add WKWebView as a private property of ViewController.m

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;

@end

@implementation ViewController

#pragma mark - UIViewController 

//a main container view in which we will place all of our subviews. Create one by overriding the loadView method

-(void)loadView {
    UIView *mainView = [UIView new];
    
    //add WKWebView as a subview to main view
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    //build the text field and add it as a subview of the main view
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    //replace the buttons with the toolbar in an array of views to add
    for (UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //opt out of the behavior where apps scroll content under the nav bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //spinner
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
}

//give new webview a size
-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
    
    //First calculate some dimensions
    //url bar should have a static height of 50
    static const CGFloat itemHeight = 50;
    //calculate width to be the same as the view width
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    //Now, assign the frames
    
    self.textField.frame = CGRectMake (0,0,width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
}

#pragma mark - AweseomFloatingToolbarDelegate
-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    
    if ([title isEqual:NSLocalizedString(@"Back", @"Back command")]) {
        [self.webView goBack];
    } else if ([title isEqual:NSLocalizedString(@"Forward", @"Forward command")]) {
        [self.webView goForward];
    } else if ([title isEqual:NSLocalizedString(@"Stop", @"Stop command")]) {
        [self.webView stopLoading];
    } else if ([title isEqual:NSLocalizedString(@"Refresh", @"Reload command")]) {
        [self.webView reload];
    }
    
}

#pragma mark - UITextFieldDelegate
//Implement the textFieldShouldReturn: delegate method to handle changes to the URL field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString: URLString];
    
    if (!URL.scheme) {
        //the user didn't type http: or https:
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    if(URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
    return NO;
    
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}


//call these if the page fails to load
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *) navigation withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (error.code != NSURLErrorCancelled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self updateButtonsAndTitle];
}


#pragma mark - Misc

-(void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webView.title copy];
    if ([webpageTitle length]) {
        self.title = webpageTitle;
    } else {
        self.title = self.webView.URL.absoluteString;
    }
    
    //spinner
    if(self.webView.isLoading) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:![self.webView isLoading] && self.webView.URL forButtonWithTitle:kWebBrowserRefreshString];
}

-(void) resetWebView {
    [self.webView removeFromSuperview];
    
    WKWebView *newWebView = [[WKWebView alloc] init];
    newWebView.navigationDelegate = self;
    self.webView = newWebView;
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    //get top-left corner of where the toolbar is currently located
    CGPoint startingPoint = toolbar.frame.origin;
    //store the future top-left corner by adding difference in x and difference in y to original top-left
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    //create a potential new CGRect - must make sure it is inside the bounds of the screen
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didPinchWithScale:(CGFloat)scale {
    //get the original scale
    CGRect frame = [self.view frame];
    frame.size.width = frame.size.width * scale;
    [self.view setFrame:frame];
    
    NSLog(@"Scale is %f", scale);
    
}


@end
