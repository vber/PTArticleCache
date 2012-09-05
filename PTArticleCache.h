//
//  PTArticleCache.h
//
//  缓存掌脉iPhone阅读APP的正文文章
//  Author:杜伟
//  Date:2012-9-5

#import <Foundation/Foundation.h>

@interface LocalSubstitutionCache : NSURLCache
{
	NSMutableDictionary *cachedResponses;
}

@end
