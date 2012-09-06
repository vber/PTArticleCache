//
//  PTArticleCache.h
//
//  缓存掌脉iPhone阅读APP的正文文章
//  Author:杜伟
//  Date:2012-9-5
//  ver:2.1

#import <Foundation/Foundation.h>

/**
 * @brief 正文缓存类
 * @note 用于缓存正文。目前只支持文章正文、js、css、,jpg、jpeg、gif、png文件的缓存。
 * @author 杜伟
 * @date:2012-9-5
 */

@interface PTArticleCache : NSURLCache
{

}

/**
 * 保存WebView的网页页面。由于网页URLCache不会写入缓存，改由在网页载入完成后手动调用此方法写入缓存。
 * @param webview UIWebView 进行缓存的UIWebView对象
 * @author 杜伟
 * @date 2012-9-5
 */
+ (void)saveHTMLPageToCache:(UIWebView *)webview;

/**
 * 获取缓存数据。
 * @param url NSURL 传入URL地址，以获取此URL地址的缓存数据。
 * @return NSData。返回缓存数据。当为NULL时表示没有缓存数据。
 * @note 可以通过判断返回值是否为NULL来判断是否已缓存。
 * @author 杜伟
 * @date 2012-9-5
 */
+ (NSData *)fetchCachedData:(NSURL *)url;

/**
 * 正文内容是否来自缓存
 */
@property (nonatomic, readonly) BOOL readCahce;

@end
