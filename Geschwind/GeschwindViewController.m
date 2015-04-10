//
//  GeschwindViewController.m
//  Geschwind
//
//  Created by Beni Cheni on 4/9/15.
//  Copyright (c) 2015 Princess of Darkness Factory. All rights reserved.
//

#import "GeschwindViewController.h"

@interface GeschwindViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;

@end

@implementation GeschwindViewController

#pragma mark - UIViewController

- (void)loadView {
    [self loadViewComponents:self];
}

- (void) loadViewComponents:(GeschwindViewController *)appViewController {
    appViewController.textField = [UITextField new];
    appViewController.textField.keyboardType = UIKeyboardTypeURL;
    appViewController.textField.returnKeyType = UIReturnKeyDone;
    appViewController.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    appViewController.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    appViewController.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    appViewController.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    appViewController.textField.delegate = appViewController;
    
    appViewController.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appViewController.backButton setEnabled:NO];
    appViewController.forwardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appViewController.forwardButton setEnabled:NO];
    appViewController.stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appViewController.stopButton setEnabled:NO];
    appViewController.reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appViewController.reloadButton setEnabled:NO];
    
    [@[appViewController.backButton,
       appViewController.forwardButton,
       appViewController.stopButton,
       appViewController.reloadButton] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           UIButton *button = (UIButton *) obj;
           [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
           
           switch (idx) {
               case 0:
                   [button setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
                   [button addTarget:appViewController.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
                   break;
               case 1:
                   [button setTitle:NSLocalizedString(@"Forward", @"Back command") forState:UIControlStateNormal];
                   [button addTarget:appViewController.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
                   break;
               case 2:
                   [button setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
                   [button addTarget:appViewController.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
                   break;
               case 3:
                   [button setTitle:NSLocalizedString(@"Refresh", @"Reload command") forState:UIControlStateNormal];
                   [button addTarget:appViewController.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
                   break;
               default:
                   break;
           }
      }];
    
    appViewController.webview = [UIWebView new];
    appViewController.webview.delegate = appViewController;
    UIView *mainView = [UIView new];
    
    [@[appViewController.webview,
       appViewController.textField,
       appViewController.backButton,
       appViewController.forwardButton,
       appViewController.stopButton,
       appViewController.reloadButton]
           enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               [mainView addSubview:(UIView *) obj];
     }];
    
    appViewController.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    // Make the webview fill the main view.
    self.webview.frame = self.view.frame;
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight; // top 50, bottom 50 CGFloat units
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat currentButton = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        thisButton.frame = CGRectMake(currentButton, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButton += buttonWidth;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    if (!URL.scheme) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([self.textField.text length] == 0) {
        [self popAlert:error errorMessage:NSLocalizedString(@"Empty URL", @"Empty URL")];
    } else {
        [self popAlert:error errorMessage:NSLocalizedString(@"Error", @"Error")];
    }
}


- (void)popAlert:(NSError *)error errorMessage:(NSString *)message {
    // UIAlertView is deprecated in iOS8. Use UIAlertController instead
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message
                                                                   message:[error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
