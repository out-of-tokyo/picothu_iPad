//
//  AppDelegate.m
//  picothru_iPad
//
//  Created by 谷村元気 on 2014/09/25.
//  Copyright (c) 2014年 Genki Tanimura. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// スキャンしたデータの初期化
	self.products = [[NSMutableArray alloc] init];

	// Override point for customization after application launch.
	return YES;
}

//[商品名, 価格, 個数]で商品を登録
- (void)setScanedProduct:(NSString *)name andPrice:(NSString *)price andAmount:(NSString *)amount
{
	NSMutableDictionary * product = [NSMutableDictionary dictionary];
	product[@"name"] = name;
	product[@"price"] = price;
	product[@"amount"] = amount;
	
	NSLog(@"NSMutableDictionary: %@",product);
	
	[_products addObject:product];
	NSLog(@"_products: %@",_products);
}

// 合計金額を取得
- (int)getTotalPrice
{
	int totalPrice = 0;
	for(int i=0;i<[self getCount];i++){
		totalPrice += [_products[i][@"price"] intValue];
	}
	return totalPrice;
}

// 合計個数を取得
- (int)getTotalAmount
{
	int totalAmount = 0;
	for(int i=0;i<[self getCount];i++){
		totalAmount += [_products[i][@"amount"] intValue];
	}
	return totalAmount;
}

// 商品種類数を取得
- (int)getCount;
{
	return [_products count];
}

// 全ての要素を削除
- (void)deleteAllProducts
{
	[_products removeObjectsInRange:NSMakeRange(0, [self getCount])];
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
