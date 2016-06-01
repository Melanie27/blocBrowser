//
//  ViewController.m
//  BlocBrowser
//
//  Created by MELANIE MCGANNEY on 5/26/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate>

//add WKWebView as a private property of ViewController.m

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;

@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UIButton *forwardButton;
@property(nonatomic, strong) UIButton *stopButton;
@property(nonatomic, strong) UIButton *reloadButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

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
    
    //Buttons!
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType: UIButtonTypeSystem];
    [self.stopButton setEnabled: NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
    [self.backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
    [self.stopButton addTarget:self.webView action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload command") forState:UIControlStateNormal];
    [self.reloadButton addTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
    //wikipedia - comment out hardcoded url
    //NSString *urlString = @"http://wikipedia.org";
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //[self.webView loadRequest:request];
    
    //refactor this repetitice view creating code
    //[mainView addSubview:self.webView];
    //[mainView addSubview: self.textField];
    //[mainView addSubview:self.backButton];
    //[mainView addSubview:self.forwardButton];
    //[mainView addSubview:self.stopButton];
    //[mainView addSubview:self.reloadButton];
    
    for (UIView *viewToAdd in @[self.webView, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
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
    
    //make the webview fill the main view
    //self.webView.frame = self.view.frame;
    
    //First calculate some dimensions
    //url bar should have a static height of 50
    static const CGFloat itemHeight = 50;
    //calculate width to be the same as the view width
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    //calculate the height of the browser view to be the height of the entire main view, minus the height of the URL bar
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    
    //Now, assign the frames
    
    self.textField.frame = CGRectMake (0,0,width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
}

#pragma mark - UITextFieldDelegate
//Implement the textFieldShouldReturn: delegate method to handle changes to the URL field

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    NSRange whiteSpace = [URLString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *replaceSpace = [URLString stringByReplacingCharactersInRange:whiteSpace withString:@"+"];
    
    NSURL *URL = [NSURL URLWithString: URLString];
    
    if (!URL.scheme) {
        //the user didn't type http: or https:
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
   
    //test if there is white space and then load google
    if (whiteSpace.location != NSNotFound) {
        NSMutableString *queryString = [@"google.com/search?q=" mutableCopy];
        //NSRange whiteSpaceRange = [queryString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        [queryString appendString:replaceSpace];
        NSLog(@"%@", queryString);
        NSLog(@"%@", replaceSpace);
        URL = [NSURL URLWithString:[NSMutableString stringWithFormat:@"http://%@", queryString]];
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
    
    //forward and back buttons
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.stopButton.enabled = self.webView.isLoading;
    self.reloadButton.enabled = !self.webView.isLoading;
}


@end
