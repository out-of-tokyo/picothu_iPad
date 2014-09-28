//
//  ViewController.m
//  picothru_iPad
//
//  Created by 谷村元気 on 2014/09/25.
//  Copyright (c) 2014年 Genki Tanimura. All rights reserved.
//

#import "ViewController.h"
#import "PurchaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
	AVCaptureSession *_session;
	AVCaptureDevice *_device;
	AVCaptureDeviceInput *_input;
	AVCaptureMetadataOutput *_output;
	AVCaptureVideoPreviewLayer *_prevLayer;
	UIView *_highlightView;
	int flag;
	AppDelegate *appDelegate;
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	appDelegate = [[UIApplication sharedApplication] delegate];

	flag = 0;
	//カメラを起動
	[self launchCamera];
	
}

// カメラを起動する
- (void)launchCamera
{
	_highlightView = [[UIView alloc] init];
	_highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
	_highlightView.layer.borderColor = [UIColor greenColor].CGColor;
	_highlightView.layer.borderWidth = 3;
	[self.view addSubview:_highlightView];
	
	_session = [[AVCaptureSession alloc] init];
	NSLog(@"_session: %@",_session);
//	_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	_device = [self cameraWithPosition:AVCaptureDevicePositionFront];
	NSError *error = nil;
	NSLog(@"_device: %@",_device);
	NSLog(@"frontcamera: %@",[self cameraWithPosition:AVCaptureDevicePositionFront]);
	
	_input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
	NSLog(@"_input: %@",_input);
	if (_input) {
		[_session addInput:_input];
		NSLog(@"_session: %@",_session);
	} else {
		NSLog(@"Error: %@", error);
	}
	
	_output = [[AVCaptureMetadataOutput alloc] init];
	[_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
	[_session addOutput:_output];
	
	_output.metadataObjectTypes = [_output availableMetadataObjectTypes];
	
	_prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	_prevLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	_prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer:_prevLayer];
	
	[_session startRunning];
	
	[self.view bringSubviewToFront:_highlightView];
}
		  
// ポジションでカメラを返す
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
		NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
		for (AVCaptureDevice *device in devices) {
			if ([device position] == position) {
				return device;
			}
		}
		return nil;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	CGRect highlightViewRect = CGRectZero;
	AVMetadataMachineReadableCodeObject *barCodeObject;
	NSString *qrCode = nil;
	NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
							  AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
							  AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
	for (AVMetadataObject *metadata in metadataObjects) {
		for (NSString *type in barCodeTypes) {
			if ([metadata.type isEqualToString:type])
			{
				barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
				highlightViewRect = barCodeObject.bounds;
				qrCode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
				break;
			}
		}
		//バーコードスキャン成功したらQRコード値をtokenとしてPOST
		if (qrCode != nil && flag == 0){
			NSLog(@"QRCode: %@",qrCode);
			[self postQRCode:qrCode];
			qrCode = nil;
			flag = 1;
			[self gotoPurchase];
			break;
		}
	}
	_highlightView.frame = highlightViewRect;
}

//QRコードの中身をサーバーにPOSTする
- (void)postQRCode:(NSString *)qrCode
{
	NSURL *url;
	NSMutableURLRequest *request;
	
	//パラメータの組み立て
	NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
	//★APIの形式に合わせて組み立てる
	[mutableDic setValue:qrCode forKey:@"encrypted_purchase"];
	NSData *body = [NSJSONSerialization dataWithJSONObject:mutableDic options:NSJSONWritingPrettyPrinted error:nil];
	
	//リクエスト作成
	url     = [NSURL URLWithString:@"http://54.64.69.224/api/v0/purchase"];
	request = [[NSMutableURLRequest alloc]init];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:body];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSLog(@"request: %@",request);
	
	//HTTPリクエスト送信
	NSHTTPURLResponse *response = nil;
	NSError *error = nil;
	NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	NSString *contentsString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	NSLog(@"contents:\n%@", contentsString);
	NSLog(@"response: %@",response);
	NSLog(@"result: %@",result);
	NSLog(@"error: %@",error);
	
	int statusCode = response.statusCode;
	if(statusCode == 201){
		[self response2products:result];
	}else{
		[self viewDidLoad];
	}
}

-(void)response2products:(NSData *)response
{
	NSError *error;
	// jsonをパースしてArrayに入れる
	NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response
													 options:NSJSONReadingAllowFragments
													   error:&error];
	NSLog(@"[array count]: %u",[dic count]);
	NSLog(@"dic[purchased_products]: %@",dic[@"purchased_products"]);
	
	// appDelegateのproductsに保存
	for (NSDictionary *obj in dic[@"purchased_products"])
	{
		NSLog(@"%@",obj);
		//　名前、価格、個数をproductsに保存
		NSString *name = [obj objectForKey:@"name"];
		NSString *price = [NSString stringWithFormat:@"%@",[obj objectForKey:@"price"]];
		NSString *amount = [NSString stringWithFormat:@"%@",[obj objectForKey:@"amount"]];
//		NSString *amount = [NSString stringWithFormat:@"%@",[obj objectForKey:@"id"]];
		NSLog(@"name: %@, price: %@, amount: %@",name,price,amount);
		[appDelegate setScanedProduct:name andPrice:price andAmount:amount];
	}
}

-(void)errormessage{
	UIAlertView *alert =
	[[UIAlertView alloc] initWithTitle:@"PicoNothru" message:@"エラー" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
	[alert show];
}

//購入完了画面へ移動
-(void)gotoPurchase{	
	PurchaseViewController *purchaseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"purchase"];
	[self presentViewController:purchaseViewController animated:YES completion:nil];
}

//スキャン画面を再読み込み
-(void)gotoScan{
	ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"scan"];
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
