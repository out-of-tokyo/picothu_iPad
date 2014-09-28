//
//  AppDelegate.h
//  picothru_iPad
//
//  Created by 谷村元気 on 2014/09/25.
//  Copyright (c) 2014年 Genki Tanimura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *products;

- (void)setScanedProduct:(NSString *)name andPrice:(NSString *)price andAmount:(NSString *)amount;
- (int)getTotalPrice;
- (int)getTotalAmount;
- (int)getCount;

@end

