//
//  UIViewController+PurchaseViewController_m.m
//  picothru_iPad
//
//  Created by 谷村元気 on 2014/09/27.
//  Copyright (c) 2014年 Genki Tanimura. All rights reserved.
//

#import "PurchaseViewController.h"
#import "ViewController.h"
#import "ListTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface PurchaseViewController ()
{
	UILabel *_thanksLabel;
	NSInteger total;
	AppDelegate *appDelegate;
}
@end

@implementation PurchaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	appDelegate = [[UIApplication sharedApplication] delegate];
	
	// テーブル定義、位置指定
	UITableView *tableView = [[UITableView alloc]initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width-20, self.view.bounds.size.height - 220) style:UITableViewStylePlain];
	tableView.tableFooterView = [[UIView alloc] init];
	[self.view addSubview:tableView];
	tableView.delegate = self;
	tableView.dataSource = self;
	[tableView registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil]forCellReuseIdentifier:@"cell"];

	
	//お買い上げありがとうございましたラベル
	_thanksLabel = [[UILabel alloc] init];
	_thanksLabel.numberOfLines = 2;
	_thanksLabel.text = @"お買い上げありがとうございました。\nまたのご来店をお待ちしております。";
	_thanksLabel.font = [UIFont fontWithName:@"Helvetica" size:40];
	_thanksLabel.frame = CGRectMake(10, self.view.bounds.size.height - 200, self.view.bounds.size.width-20, 180);
	_thanksLabel.backgroundColor = [UIColor colorWithRed:0.564 green:0.93 blue:0.564 alpha:1.0];
	//角丸ラベル
	[[_thanksLabel layer] setCornerRadius:10.0];
	[_thanksLabel setClipsToBounds:YES];
	
	NSArray *labels =  @[_thanksLabel];
	for (UILabel *label in labels) {
		label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self.view addSubview:label];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	// 合計点数計算
	total = 0;
	for(NSDictionary *product in appDelegate.products) {
		int tmp = [product[@"amount"] intValue];
		total += tmp;
	}
	
	// 合計点数表示
	UILabel *total_label = [[UILabel alloc] init];
	total_label.frame = CGRectMake(100, self.view.bounds.size.height-450 , self.view.bounds.size.width-200, 200);
	total_label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	total_label.backgroundColor = [UIColor colorWithRed:0.737 green:0.561 blue:0.561 alpha:1.0];
	total_label.textColor = [UIColor blackColor];
	total_label.textAlignment = NSTextAlignmentCenter;
	NSString *txt = [NSString stringWithFormat:@"%d", total];
	NSString *totaltxt = [NSString stringWithFormat:@"合計点数 %@点",txt];
	total_label.text = totaltxt ;
	total_label.font = [UIFont fontWithName:@"Helvetica" size:40];

	[self.view addSubview: total_label];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [appDelegate getCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = @"cell";
	ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	int i = (int)indexPath.row;
	cell.prodactname.text = appDelegate.products[i][@"name"];
	cell.prodactprice.text = appDelegate.products[i][@"price"];
	cell.prodactcount.text = appDelegate.products[i][@"amount"];
	return cell;
}








@end