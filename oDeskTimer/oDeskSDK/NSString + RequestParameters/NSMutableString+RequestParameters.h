//
//  NSString+RequestParameters.h
//  oDeskTimer
//
//  Created by Roman Sidorakin on 13.03.13.
//  Copyright (c) 2013 Rus Wizards. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (RequestParameters)

- (void) addParameter:(NSString *) parameter withValue:(NSString *) value;
- (NSString *) postDataLength;
- (NSData *) postData;
@end
