//
//  AppDelegate.m
//  HandSlider
//
//  Created by Jinwoo Kim on 6/7/24.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    if (connectingSceneSession.configuration.role == UISceneSessionRoleImmersiveSpaceApplication) {
        return connectingSceneSession.configuration;
    } else {
        UISceneConfiguration *configuration = [connectingSceneSession.configuration copy];
        configuration.delegateClass = SceneDelegate.class;
        return [configuration autorelease];
    }
}

@end
