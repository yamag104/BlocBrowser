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
@end

@implementation ViewController

- (void) loadView {
    UIView *mainView = [UIView new];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    // Requesting web sites
    NSString *urlString = @"http://wikipedia.org";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    
    [mainView addSubview:self.webView];
    [mainView addSubview:self.textField];
    self.view = mainView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Prevents content to show under navigation bar & behind status bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view, typically from a nib.
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
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    // Now, assign the frames
    // CGRectMake(howFarFromTheLeft, howFarFromTheTop, howWide, howTall)
    // CGRectGetMaxY = bottom of the text field
    self.textField.frame = CGRectMake(0,0,width,itemHeight); // x=0 y=0
    self.webView.frame = CGRectMake(0,CGRectGetMaxY(self.textField.frame), width, browserHeight);
}


@end
