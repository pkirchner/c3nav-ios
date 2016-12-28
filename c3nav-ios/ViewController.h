//
//  ViewController.h
//  c3nav-ios
//
//  Created by Philipp Kirchner on 27.12.16.
//  Copyright © 2016 Philipp Kirchner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <sys/sysctl.h>

@interface ViewController : UIViewController

@property (strong) WKWebView *webview;
@property (strong) WKUserContentController *userContentController;
@property (strong) WKWebViewConfiguration *webviewConfig;


- (BOOL) isWiFiEnabled;
- (NSDictionary *) wifiDetails;
- (BOOL) isWiFiConnected;
- (NSString *) BSSID;
- (NSString *) SSID;

@end

