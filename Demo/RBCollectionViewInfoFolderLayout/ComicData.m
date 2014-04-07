//
//  ComicData.m
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/4/14.
//
//

#import "ComicData.h"

@implementation ComicData

+ (NSDictionary *)data
{
	NSString * path = [[NSBundle mainBundle] pathForResource:@"civilwarData" ofType:@"json"];
	NSData * data = [NSData dataWithContentsOfFile:path];
	id civilWar = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

	path = [[NSBundle mainBundle] pathForResource:@"xmenData" ofType:@"json"];
	data = [NSData dataWithContentsOfFile:path];
	id xmen = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

	return @{ @"X-Men":xmen[@"data"], @"Civil War":civilWar[@"data"] };
}

@end
