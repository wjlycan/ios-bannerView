//
//  AppDelegate.h
//  BannerView-Demo
//
//  Created by wjl on 2018/1/24.
//  Copyright © 2018年 ycan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

