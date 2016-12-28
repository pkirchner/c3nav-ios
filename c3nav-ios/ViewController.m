//
//  ViewController.m
//  c3nav-ios
//
//  Created by Philipp Kirchner on 27.12.16.
//  Copyright © 2016 Philipp Kirchner. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if(self.isWiFiEnabled){
        NSLog(@"Enabled!");
    }
    NSLog(@"BSSID: %@, SSID: %@", self.BSSID, self.SSID);
    self.webviewConfig = [[WKWebViewConfiguration alloc] init];
    
    self.userContentController = [[WKUserContentController alloc] init];
    self.webviewConfig.userContentController = self.userContentController;
    self.webviewConfig.applicationNameForUserAgent = @"c3navClient/iOS/0.9";
    
    NSURL *jsURL = [[NSBundle mainBundle] URLForResource:@"userscript" withExtension:@"js"];
    NSString *jsString = [NSString stringWithContentsOfURL:jsURL encoding:NSUTF8StringEncoding error:nil];
    
    
    
    //WKUserScript *userscript = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    //[self.userContentController addUserScript:userscript];
    
    self.webview=[[WKWebView alloc] initWithFrame:self.view.bounds configuration:self.webviewConfig];
    
    [self.view addSubview:self.webview];
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://c3nav.de"]]];

    [self.webview evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error);
        }else{
            NSLog(@"%@", result);
        }
    }];

    
    void __block (^wifipush)() = ^{
        NSDictionary *wifidetails = [self wifiDetails];
        NSMutableDictionary *jsonwifi = [[NSMutableDictionary alloc] init];
        //example: '[{"bssid":"94:b4:0f:84:88:50","ssid":"33C3","level":-59,"frequency":5220,"last":44},{"bssid":"94:b4:0f:84:88:51","ssid":"spacenet","level":-63,"frequency":5220,"last":44}]'
        jsonwifi[@"ssid"] = wifidetails[@"SSID"];
        NSString *bssid = wifidetails[@"BSSID"];
        if([[bssid componentsSeparatedByString:@":"] objectAtIndex:0].length==1){
            jsonwifi[@"bssid"] = [NSString stringWithFormat:@"0%@",wifidetails[@"BSSID"]];
        }else{
            jsonwifi[@"bssid"] = wifidetails[@"BSSID"];
        }
        
        jsonwifi[@"level"] = @-50;
        jsonwifi[@"frequency"] = @5220;
        jsonwifi[@"last"] = [NSNumber numberWithInt:[NSDate timeIntervalSinceReferenceDate]];
        NSArray *jsonArray = [NSArray arrayWithObject:jsonwifi];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:NULL];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
        [self.webview evaluateJavaScript:[NSString stringWithFormat:@"mobileclient.setNearbyStations('%@')", jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if(error){
                NSLog(@"%@", error);
            }else{
                NSLog(@"%@", result);
            }
        }];

        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"javascript:nearby_stations_available();"]]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), wifipush); //retain cycle is fully ok here...
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), wifipush);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//! das ist alles nur geklaut, eo, eo. Nein, wirklich. <a href="http://www.enigmaticape.com/blog/determine-wifi-enabled-ios-one-weird-trick">Von hier.</a>
- (NSDictionary *) wifiDetails
{
    NSDictionary *d = (__bridge NSDictionary *) CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex( CNCopySupportedInterfaces(), 0));
    return d;
}

- (BOOL) isWiFiEnabled
{
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}


//! das ist alles nur geklaut, eo, eo. Nein, wirklich. <a href="http://www.enigmaticape.com/blog/determine-wifi-enabled-ios-one-weird-trick">Von hier.</a>
- (BOOL) isWiFiConnected
{
    return [self wifiDetails] == nil ? NO : YES;
}

//! das ist alles nur geklaut, eo, eo. Nein, wirklich. <a href="http://www.enigmaticape.com/blog/determine-wifi-enabled-ios-one-weird-trick">Von hier.</a>
- (NSString *) BSSID
{
    return [self wifiDetails][@"BSSID"];
}

//! das ist alles nur geklaut, eo, eo. Nein, wirklich. <a href="http://www.enigmaticape.com/blog/determine-wifi-enabled-ios-one-weird-trick">Von hier.</a>
- (NSString *) SSID
{
    return [self wifiDetails][@"SSID"];
}


@end
