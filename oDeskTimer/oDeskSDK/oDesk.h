//
//  oDesk.h
//  oDeskTimer
//
//  Created by Roman Sidorakin on 08.05.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface oDesk : NSObject
@property (nonatomic, strong) NSString* login;

-(NSString *) login:(NSString*) name password:(NSString*) password;
-(NSDictionary *) todayTotalTime:(enum ODTimeRange) type;
+(NSString*) convertTimeToString:(CFTimeInterval) time;
+(CFTimeInterval)convertToTime:(NSString *)time;

+ (oDesk *)scharedManager;
@end
