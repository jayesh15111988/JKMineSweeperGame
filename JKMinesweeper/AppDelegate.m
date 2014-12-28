//
//  AppDelegate.m
//  JKMinesweeper
//
//  Created by Jayesh Kawli on 9/28/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//


#import <RLMMigration.h>
#import <RLMRealm.h>
#import "SaveGameModel.h"
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"currentLevel"]) {
        [self setInitialDefaults];
    }
    
    [self performDatabaseMigration];
    
    //Test code
    /*Sample* sam1 = [Sample new];
    sam1.p1 = @"jayesh";
    sam1.p2 = CGPointMake(100, 200);
    sam1.p3 = 26;
    sam1.p4 = YES;
    
    Sample* sam2 = [Sample new];
    sam2.p1 = @"archana";
    sam2.p2 = CGPointMake(36, 28);
    sam2.p3 = 26;
    sam2.p4 = NO;
    
    NSData *data1=[NSKeyedArchiver archivedDataWithRootObject:sam1];
    NSData *data2=[NSKeyedArchiver archivedDataWithRootObject:sam2];
    
    
    Sample *s1=[NSKeyedUnarchiver unarchiveObjectWithData:data1];
    Sample *s2=[NSKeyedUnarchiver unarchiveObjectWithData:data2];
    
    DLog(@"%@ and %@",s1,s2);
*/
    
    return YES;
}

-(void) performDatabaseMigration {
    
    [RLMRealm setSchemaVersion:1 withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
        
        if (oldSchemaVersion < 1) {
            
            [migration enumerateObjects: SaveGameModel.className
                                  block:^(RLMObject *oldObject, RLMObject *newObject) {
                                      newObject[@"score"] = @(0);
                                  }];
        }
    }];
    
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
