//
//  NSString+RequestParameters.m
//  oDeskTimer
//
//  Created by Roman Sidorakin on 13.03.13.
//  Copyright (c) 2013 Rus Wizards. All rights reserved.
//

#import "NSMutableString+RequestParameters.h"

@implementation NSMutableString (RequestParameters)

-(void)addParameter:(NSString *)parameter withValue:(NSString *)value{
	if (self.length == 0) {
		[self appendFormat:@"%@=%@",parameter,value];
	}
	else{
		[self appendFormat:@"&%@=%@",parameter,value];
	}
}

-(NSString *)postDataLength{
	return [NSString stringWithFormat:@"%ld", [self length]];
}

-(NSData *)postData{
	return [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
}
@end
