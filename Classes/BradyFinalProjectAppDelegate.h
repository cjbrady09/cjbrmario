//
//  BradyFinalProjectAppDelegate.h
//  BradyFinalProject
//
//  Created by Clayton Brady on 4/29/11.
//  Copyright Drake University 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface BradyFinalProjectAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
