//
//  Constants.h
//  oDeskTimer
//
//  Created by Roman Sidorakin on 13.03.13.
//  Copyright (c) 2013 Rus Wizards. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

enum ODTimeRange {
	ODTimeRangeDay = 0,
	ODTimeRangeWeek = 1,
	ODTimeRangeMonth = 2
};

extern NSString *kODDateFormat;
extern NSString *kODDateMonthFormat;

#pragma mark URLs
extern NSString *kODURLClassicTimeAnalyze;
extern NSString *kODURLReport;
extern NSString *kODURLLogin;
extern NSString *kODURLCounters;
extern NSString *kODURLGetTime;

#pragma mark Request parameters
extern NSString *kODParameterCompany;
extern NSString *kODParameterAfterLoginLoc;
extern NSString *kODParameterUsername;
extern NSString *kODParameterPassword;
extern NSString *kODParameterAction;
extern NSString *kODParameterActionLogin;


#pragma mark REQUEST PARAMS
extern NSString *kODRequestContentType;
extern NSString *kODRequestContentTypeValue;
extern NSString *kODRequestContentLength;

#pragma mark patterns
extern NSString *kODRegExpCounters;
extern NSString *kODRegExpTime;
@end
