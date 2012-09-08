//
//  PTArticleCache.m
//  PTArticleCache
//

#import "PTArticleCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PTArticleCache
@synthesize readCahce;

static NSSet *extensions;
static BOOL gReadFromCache; // 是否是从缓存中读取

+ (void)initialize {
    // 可以进入缓存的文件类型
    extensions = [[NSSet setWithObjects:@"js", @"css",@"jpg",@"jpeg",@"gif",@"png",nil] retain];
}

- (id)init {
    self = [super init];
    if (self) {
        gReadFromCache = NO;
    }
    return self;
}

- (BOOL)valueForReadCache {
    return gReadFromCache;
}

/**
 * 根据扩展名获取MimeType
 * @param fileExtension NSString 文件扩展名
 * @return 返回扩展名对应的MimeType
 * @author 杜伟
 * @date 2012-9-5
 */
- (NSString *)fetchMimeTypeForPath:(NSString *)fileExtension
{
	if ([fileExtension isEqualToString:@"png"]) {
        return @"image/png";
    }
    else if ([fileExtension isEqualToString:@"jpeg"]) {
        return @"image/jpeg";
    }
    else if ([fileExtension isEqualToString:@"jpg"]) {
        return @"image/jpg";
    }
    else if ([fileExtension isEqualToString:@"gif"]) {
        return @"image/gif";
    }
    else if ([fileExtension isEqualToString:@"js"]) {
        return @"application/x-javascript";
    }
    else if ([fileExtension isEqualToString:@"css"]) {
        return @"text/css";
    } else {
        return @"text/html";
    }
}

/**
 * 获取字符串的MD5值
 * @param str NSString 要进行计算MD5值的字符串
 * @return 返回字符串的MD5值
 * @author 杜伟
 * @date 2012-9-5
 */
+ (NSString *)fetchMD5:(NSString *)str {
    const char *cStr = [str UTF8String];
    
    unsigned char result[16];
    
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    
    return [NSString stringWithFormat:
            
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

/**
 * 获取缓存目录
 * @return 返回缓存目录路径
 * @author 杜伟
 * @date 2012-9-5
 */
+ (NSString *)fetchCachePath {
    NSString *cachePath = NSHomeDirectory();
    cachePath = [cachePath stringByAppendingPathComponent:@"Library/Caches/ArticleCaches"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cachePath;
}

/**
 * 获取缓存数据。
 * @param url NSURL 传入URL地址，以获取此URL地址的缓存数据。
 * @return NSData。返回缓存数据。当为NULL时表示没有缓存数据。
 * @note 可以通过判断返回值是否为NULL来判断是否已缓存。
 * @author 杜伟
 * @date 2012-9-5
 */
+ (NSData *)fetchCachedData:(NSURL *)url {
    // 将整个URL地址转换为MD5值，存储时或则查询缓存文件时均使用此MD5值来判断
    NSString *url_md5 = [PTArticleCache fetchMD5:url.absoluteString];
    
    // 判断缓存中是否存在以此URL地址所对应的md5值文件名
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@",
                           [PTArticleCache fetchCachePath],
                           url_md5];
    // 存在缓存文件则读取缓存文件并返回相关数据
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
        gReadFromCache = YES;
        return [NSData dataWithContentsOfFile:cacheFile];
    }
    return nil;
}

/**
 * 保存WebView的网页页面。由于网页URLCache不会写入缓存，改由在网页载入完成后手动调用此方法写入缓存。
 * @param webview UIWebView 进行缓存的UIWebView对象
 * @author 杜伟
 * @date 2012-9-5
 */
+ (void)saveHTMLPageToCache:(UIWebView *)webview {    
    NSString *url_md5 = [self fetchMD5:webview.request.URL.absoluteString];
    NSString *path = [[PTArticleCache fetchCachePath] stringByAppendingPathComponent:url_md5];
    
    NSString *html = [webview stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    [html writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - NSURLCache类覆盖方法

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    // 获取URL地址中的扩展名
    NSString *file_extension = request.URL.pathExtension;
    // 如果不在可以缓存的文件类型列表中，则使用默认处理方式
    if (![extensions containsObject:file_extension]) {
        return [super cachedResponseForRequest:request];
    }
    
    NSData *cacheData = [PTArticleCache fetchCachedData:request.URL];
    if (cacheData) {
        gReadFromCache = YES;
        NSURLResponse *response =
        		[[[NSURLResponse alloc]
        			initWithURL:[request URL]
                  MIMEType:[self fetchMimeTypeForPath:file_extension]
        			expectedContentLength:[cacheData length]
        			textEncodingName:nil]
        		autorelease];
        	NSCachedURLResponse *cachedResponse =
        		[[[NSCachedURLResponse alloc] initWithResponse:response data:cacheData] autorelease];
        return cachedResponse;
    }
    
    return [super cachedResponseForRequest:request];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    NSString *file_extension = request.URL.pathExtension;
    // 如果不在可以缓存的文件类型列表中则不进行缓存
    if (![extensions containsObject:file_extension]) {
        return;
    }
    
    // 写入缓存
    NSString *url_md5 = [PTArticleCache fetchMD5:request.URL.absoluteString];
    NSString *path = [[PTArticleCache fetchCachePath] stringByAppendingPathComponent:url_md5];
    [cachedResponse.data writeToFile:path atomically:YES];
    //NSLog(@"storeCachedResponse:%@",path);
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    [super removeCachedResponseForRequest:request];
}

@end
