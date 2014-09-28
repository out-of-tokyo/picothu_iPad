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

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
AVCaptureSession *_session;
AVCaptureDevice *_device;
AVCaptureDeviceInput *_input;
AVCaptureMetadataOutput *_output;
AVCaptureVideoPreviewLayer *_prevLayer;
UIView *_highlightView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
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
	_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSError *error = nil;
	
	_input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
	if (_input) {
		[_session addInput:_input];
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

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	CGRect highlightViewRect = CGRectZero;
	AVMetadataMachineReadableCodeObject *barCodeObject;
	NSString *qrCode = nil;
	NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
							  AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
							  AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
	int flag = 0;
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
		if (qrCode != nil && flag == 0);
		{
			NSLog(@"QRCode: %@",qrCode);
			[self postQRCode:qrCode];
			qrCode = nil;
			flag = 1;
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
	NSData *body = [NSJSONSerialization dataWithJSONObject:mutableDic options:NSJSONWritingPrettyPrinted error:Nil];
	
	//リクエスト作成
	url     = [NSURL URLWithString:@"http://54.64.69.224/api/v0/purchase"];
	request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:body];
	
	NSLog(@"request: %@",request);
	
	//HTTPリクエスト送信
	NSHTTPURLResponse *response = nil;
	NSError *error          = nil;
	NSData *result          = [NSURLConnection sendSynchronousRequest:request
													returningResponse:&response
																error:&error];
	
	NSLog(@"response: %@",response);
	NSLog(@"result: %@",result);
	
	
	//	// HTTP requestの作成
//	NSURL *url = [NSURL fileURLWithPath:@"http://54.64.69.224/api/v0/purchase"];
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//	[request setHTTPMethod:@"POST"];
//	[request setHTTPBody:[qrCode dataUsingEncoding:NSUTF8StringEncoding]];
//
//	NSLog(@"qrCode: %@",qrCode);
//	NSLog(@"request: %@",[request allHTTPHeaderFields]);
//
//	// 送信処理
//	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//	NSLog(@"response: %@",response);
//	if(response){
//		NSArray *array = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
//		NSLog(@"array: %@",array);
//		BOOL loginResult = [array valueForKey:@"status"];
//		NSLog(@"loginResult: ",loginResult);
//		if (loginResult){
//			UIAlertView *alert =
//			[[UIAlertView alloc] initWithTitle:@"Picoした" message:@"完了しました" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
//			[alert show];
//			[self gotoPurchase];
//
//		}else{
//			[self errormessage];
//		}
//	}else{
//		[self errormessage];
//	}
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

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
