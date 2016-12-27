//
//  AppDelegate.h
//  c3nav-ios
//
//  Created by Philipp Kirchner on 27.12.16.
//  Copyright © 2016 Philipp Kirchner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

