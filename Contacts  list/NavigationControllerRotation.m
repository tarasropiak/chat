//
//  NavigationControllerRotation.m
//  SIPPhone
//
//  Created by Administrator on 7/16/13.
//  Copyright (c) 2013 Andriy Mykhaylyshyn. All rights reserved.
//

#import "NavigationControllerRotation.h"

@implementation UINavigationController (Rotation)


- (NSUInteger)supportedInterfaceOrientations
{
    UITabBarController *currVC = (UITabBarController *)[self topViewController];
    if ([currVC respondsToSelector:@selector(selectedViewController)]){
        UIViewController *visible = currVC.selectedViewController;
        if ([visible respondsToSelector:@selector(visibleViewController)]){
            visible = [((UINavigationController*)visible) visibleViewController];
            return [visible supportedInterfaceOrientations];
        }
    }
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL) shouldAutorotate {
    return YES;
}

@end


