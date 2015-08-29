//
//  ViewController.m
//  BlocBrowser
//
//  Created by Yoko Yamaguchi on 8/28/15.
//  Copyright (c) 2015 Yoko Yamaguchi. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void) loadView {
    UIView *mainView = [UIView new];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Search or enter website name", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];

    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload command") forState:UIControlStateNormal];
    [self addButtonTargets];
    
    // Use loop to add each view to the main view
    for (UIView *viewToAdd in @[self.webView, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]){
        [mainView addSubview:viewToAdd];
    }
    self.view = mainView;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Prevents content to show under navigation bar & behind status bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view, typically from a nib.
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Welcome!", @"Welcome Message") message:@"Enjoy!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // First, calculate some dimensions.
    
    // static keeps the value the same btwn invocations of the method
    // const tells the compiler that this value won't change
    static const CGFloat itemHeight = 50; // URL Bar Height
    // Make URL Bar width the same as view width
    CGFloat width = CGRectGetWidth(self.view.bounds);
    // Make the Browser height the asme height as the entire main view - URL bar height
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight-itemHeight;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds)/4;
    
    // Now, assign the frames
    // CGRectMake(howFarFromTheLeft, howFarFromTheTop, howWide, howTall)
    // CGRectGetMaxY = bottom of the text field
    self.textField.frame = CGRectMake(0,0,width,itemHeight); // x=0 y=0
    self.webView.frame = CGRectMake(0,CGRectGetMaxY(self.textField.frame), width, browserHeight);
    CGFloat currentButtonX = 0;
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton,self.reloadButton]) {
        thisButton.frame=CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    NSString *URLString = textField.text;
    NSURL *URL = [NSURL URLWithString:URLString];
    
    // Search Query
    if ([URLString containsString:@" "]) {
        // Get rid of space and insert '+'
        NSString *newString = [[URLString componentsSeparatedByString:@" "] componentsJoinedByString:@"+"];
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://google.com/search?q=%@", newString]];
    }
    if (!URL.scheme) {
        // The user didn't type http: or https:
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    if (URL) {
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

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    // When URL loading request is cancelled
    // i.e. when user goes to another web site before the first one is finished loading
    if (error.code != NSURLErrorCancelled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self updateButtonsAndTitle];
}

#pragma mark - Miscellaneous

- (void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webView.title copy];
    if ([webpageTitle length]) self.title = webpageTitle;
    else    self.title = self.webView.URL.absoluteString;
    
    if (self.webView.isLoading)     [self.activityIndicator startAnimating];
    else    [self.activityIndicator stopAnimating];
    
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.stopButton.enabled = self.webView.isLoading;
    // Webview has an NSURLRequest with accompanying NSURL
    self.reloadButton.enabled = !self.webView.isLoading && self.webView.URL;
}

- (void) resetWebView {
    // removes the old web view from the view hierarchy
    // creates a new, empty web view and adds it back in
    // clears the URL field
    // calls addButtonTargets to point the buttons to the new web view
    // updates the buttons and navigation title to their proper state
    [self.webView removeFromSuperview];
    
    WKWebView *newWebView = [[WKWebView alloc]init];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    [self addButtonTargets];
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

-(void) addButtonTargets {
    // Remove reference to the old web view
    for (UIButton *button in@[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    // Add web view as target to each button
    [self.backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self.webView action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
}

@end
