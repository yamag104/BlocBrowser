//
//  ViewController.m
//  BlocBrowser
//
//  Created by Yoko Yamaguchi on 8/28/15.
//  Copyright (c) 2015 Yoko Yamaguchi. All rights reserved.
//

#import "ViewController.h"
#import "AwesomeFloatingToolbar.h"
#import <WebKit/WebKit.h>

// #define lets us make up a word that is replaced with whatever follows it.
// we can use kWebBrowserStopString will automatically get replaced with NSLocalizedString(@"Stop", @"Stop command")

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, assign) NSUInteger frameCount;

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
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    
    // Use loop to add each view to the main view
    for (UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]){
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
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds)-itemHeight;
    
    // Now, assign the frames
    // CGRectMake(howFarFromTheLeft, howFarFromTheTop, howWide, howTall)
    // CGRectGetMaxY = bottom of the text field
    self.textField.frame = CGRectMake(0,0,width,itemHeight); // x=0 y=0
    self.webView.frame = CGRectMake(0,CGRectGetMaxY(self.textField.frame), width, browserHeight);
    self.awesomeToolbar.frame = CGRectMake(20,100,280,60);
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
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:![self.webView isLoading] && self.webView.URL forButtonWithTitle:kWebBrowserRefreshString];

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
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

#pragma mark - AwesomeFloatingToolbarDelegate

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:kWebBrowserBackString]) {
        [self.webView goBack];
    } else if ([title isEqual:kWebBrowserForwardString]) {
        [self.webView goForward];
    } else if ([title isEqual:kWebBrowserStopString]) {
        [self.webView stopLoading];
    } else if ([title isEqual:kWebBrowserRefreshString]) {
        [self.webView reload];
    }
}

@end
