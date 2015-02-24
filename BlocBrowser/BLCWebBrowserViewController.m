//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Larry Lynn on 2/16/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCWebBrowserViewController.h"



//  @interface BLCWebBrowserViewController
//  @interface BLCWebBrowserViewController () <UIWebViewDelegate>

@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


//  @property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) NSUInteger frameCount;


@end

@implementation BLCWebBrowserViewController

#pragma mark - UIViewController

- (void)loadView {
    UIView *mainView = [UIView new];
    
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL or Google Search", @"Placeholder text for web browser URL field");
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
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload command") forState:UIControlStateNormal];
    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
    
    
//    NSString *urlString = @"http://wikipedia.org";
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webview loadRequest:request];

    
//    [mainView addSubview:self.webview];
//    [mainView addSubview:self.textField];
//    [mainView addSubview:self.backButton];
//    [mainView addSubview:self.forwardButton];
//    [mainView addSubview:self.stopButton];
//    [mainView addSubview:self.reloadButton];
//
    for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [mainView addSubview:viewToAdd];
    }
    
    
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    //  [self.activityIndicator startAnimating];
    
}

    
    - (void)viewWillLayoutSubviews {
        [super viewWillLayoutSubviews];
        
        //make the webview fill the main view
        
        //self.webview.frame = self.view.frame;
        
        //First calculate some dimensions
        static const CGFloat itemHeight = 50;
        CGFloat width = CGRectGetWidth(self.view.bounds);
        //CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
        
        CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
        CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
        // Now assign the frames
        self.textField.frame = CGRectMake(0, 0, width, itemHeight);
        self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
        
        CGFloat currentButtonX = 0;
        
        for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
            thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
            currentButtonX += buttonWidth;
        }
    }
    
# pragma mark - UITextFieldDelegate
    
    - (BOOL)textFieldShouldReturn:(UITextField *)textField {
        [textField resignFirstResponder];
        
        NSString *URLString = textField.text;
        
        NSURL *URL = [NSURL URLWithString:URLString];
        
        if (!URL.scheme) {
            
            NSRange urlSpace = [URLString rangeOfString:@" "];
            NSString *urlNoSpace = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            if (urlSpace.location != NSNotFound) {
                // the user typed a space so it is a search entry
                URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@",urlNoSpace]];
                
                
            }  else {
                
            // the user didn't type in http: or https:
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
            }
            
        }
        
        if (URL) {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [self.webview loadRequest:request];
        }
        
        return NO;
        
        }
    
# pragma mark - UIWebViewDelegate
    
    - (void)webViewDidStartLoad:(UIWebView *)webView  {
        //  self.isLoading = YES;
         self.frameCount++;
        [self updateButtonsAndTitle];
        
    }
    
    - (void)webViewDidFinishLoad:(UIWebView *)webView {
        //  self.isLoading = NO;
        self.frameCount --;
        [self updateButtonsAndTitle];
        
    }
    
    - (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        
        [alert show];
    
    
    [self updateButtonsAndTitle];

    self.frameCount --;
    
    }

# pragma mark - Miscellaneous

- (void) updateButtonsAndTitle {
    
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;

    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    //if (self.isLoading) {
    if (self.frameCount > 0) {

        [self.activityIndicator startAnimating];

    }  else {
        
        [self.activityIndicator stopAnimating];
    }
    
    
    self.backButton.enabled = [self.webview canGoBack];
    self.forwardButton.enabled = [self.webview canGoForward];
//    self.stopButton.enabled = self.isLoading;
//    self.reloadButton.enabled = !self.isLoading;
    
    self.stopButton.enabled = self.frameCount > 0;
    self.reloadButton.enabled = self.frameCount ==0;
    
}
    

@end