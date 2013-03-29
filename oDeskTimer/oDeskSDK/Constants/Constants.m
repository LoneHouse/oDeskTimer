//
//  Constants.m
//  oDeskTimer
//
//  Created by Roman Sidorakin on 13.03.13.
//  Copyright (c) 2013 Rus Wizards. All rights reserved.
//

#import "Constants.h"

@implementation Constants

const NSString *kODDateFormat = @"MM/dd/YYYY";
const NSString *kODDateMonthFormat = @"MM/01/YYYY";

#pragma mark URLs
const NSString *kODURLClassicTimeAnalyze = @"https://www.odesk.com/team/scripts/login?initial=1&after_login_location=http%3A%2F%2Fwww.odesk.com%2Fteam%2Fscripts%2Freport";
const NSString *kODURLReport = @"http://www.odesk.com/team/scripts/report";
const NSString *kODURLLogin = @"https://www.odesk.com/login";
const NSString *kODURLCounters = @"https://www.odesk.com/team/scripts/login?initial=1";
const NSString *kODURLGetTime = @"https://www.odesk.com/team/scripts/report?company_id=%@&type=Chart&range=custom&user_id=%@&action=choose_custom_range&vs_users=&actually=1&start_date=%@&end_date=%@";

#pragma mark Request parameters
const NSString *kODParameterCompany = @"selected_company";
const NSString *kODParameterAfterLoginLoc = @"after_login_location";
const NSString *kODParameterUsername = @"username";
const NSString *kODParameterPassword = @"password";
const NSString *kODParameterAction = @"action";
const NSString *kODParameterActionLogin = @"login";


#pragma mark REQUEST PARAMS
const NSString *kODRequestContentType = @"Content-Type";
const NSString *kODRequestContentTypeValue = @"application/x-www-form-urlencoded";
const NSString *kODRequestContentLength =@"Content-Length";

#pragma mark patterns
const NSString *kODRegExpCounters = @"<option value=\"[\\w \\: \\- \\! \\* \\' \\( \\) \\; \\@ \\& \\= \\+ \\$ \\, \\/ \\? \\% \\#]{1,}";
const NSString *kODRegExpTime = @"<b>\\d{2,}:\\d{2}</b>";

@end
