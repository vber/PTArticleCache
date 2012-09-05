//
//  ViewController.m
//  PTArticleCache
//
//  Created by Du Wei on 12-9-5.
//  Copyright (c) 2012年 Du Wei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize web;

- (void)viewDidLoad
{
    NSURL *url = [NSURL URLWithString:@"http://kls.cms.palmtrends.com/api_v2.php?action=article&uid=2763189&id=419&mobile=iphone4&e=dd35ca6c8bdd1f4f033ff19645c53f91"];
    
    PTArticleCache *ac = [[PTArticleCache alloc] init];
    
    [NSURLCache setSharedURLCache:ac];
    
    NSData *cachedData = [PTArticleCache fetchCachedData:url];
    if (cachedData) {
        [web loadData:cachedData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@"http://kls.cms.palmtrends/"]];
    } else {
        [web loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    [ac release];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"web:%@",webView.request.URL);
    
    [PTArticleCache saveHTMLPageToCache:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [web release];
    [super dealloc];
}
@end
