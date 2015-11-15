//
//  AppDelegate.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//


#import <Realm/Realm.h>
#import <Realm/RLMRealmConfiguration.h>
#import <objc/runtime.h>
#import <MFSideMenu/MFSideMenu.h>
#import "JKMinesweeperHomeViewController.h"
#import "JKiPhoneSettingsViewController.h"
#import "SaveGameModel.h"
#import "AppDelegate.h"

// Crashlytics Dependencies.
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"currentLevel"]) {
        [self setInitialDefaults];
    }
    [self performDatabaseMigration];
    
    if (IPAD) {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    } else {
        UIStoryboard* mainiPhoneStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        JKMinesweeperHomeViewController* homeViewController = [mainiPhoneStoryboard instantiateInitialViewController];
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        JKiPhoneSettingsViewController* leftViewController = [mainiPhoneStoryboard instantiateViewControllerWithIdentifier:@"leftMenu"];
        leftViewController.minesweeperHomeViewController = homeViewController;
        
        UINavigationController* leftMenuNavController = [[UINavigationController alloc] initWithRootViewController:leftViewController];
        
        MFSideMenuContainerViewController* container =
        [MFSideMenuContainerViewController containerWithCenterViewController:navController
                                                      leftMenuViewController:leftMenuNavController
                                                     rightMenuViewController:nil];
        container.panMode = MFSideMenuPanModeNone;
        container.leftMenuWidth = homeViewController.view.frame.size.width - 60.0;
        container.rightMenuWidth = homeViewController.view.frame.size.width - 60.0;
        self.window.rootViewController = container;
    }
    self.window.frame = [UIScreen mainScreen].bounds;
    [self.window makeKeyAndVisible];
    [[Fabric sharedSDK] setDebug: YES];
    [Fabric with:@[[Crashlytics class]]];
    
    return YES;
}



-(void) performDatabaseMigration {
    RLMRealmConfiguration* config = [RLMRealmConfiguration defaultConfiguration];
    [config setSchemaVersion:2];
    [config setMigrationBlock:^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 1) {
            [migration enumerateObjects: SaveGameModel.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
                                      newObject[@"score"] = @(0);
                                  }];
        } else if (oldSchemaVersion < 2) {
            [migration enumerateObjects:SaveGameModel.className block:^(RLMObject* oldObject, RLMObject* newObject) {
                newObject[@"successiveTilesDistanceIncrement"] = @(0);
            }];
        }
    }];
    [RLMRealmConfiguration setDefaultConfiguration:config];
    [RLMRealm defaultRealm];
}

-(void)setInitialDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"currentLevel"];
    [[NSUserDefaults standardUserDefaults] setObject:@"50" forKey:@"tileWidth"];
    [[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"gutterSpacing"];
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"sound"];
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"timer"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end













