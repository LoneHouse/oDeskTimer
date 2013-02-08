//
//  oDesk.m
//  oDeskTimer
//
//  Created by Roman Sidorakin on 08.05.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import "oDesk.h"
#import "AppDelegate.h"

@interface oDesk()
-(NSString *) doRequest:(NSString *) params URL:(NSString* )url;
-(NSString *) loginClassicTimeAnalyze:(NSString *) counterName;
-(NSArray *) getAllCounters;
//-(CFTimeInterval) convertToTime:(NSString *) time;
-(NSString *) getTimeByDay: (NSString *) login counter:(NSString*) counter type:(NSString*) type;
-(NSString *) URLEncodedString: (NSString *) string;
@end

@implementation oDesk
@synthesize login;

-(id)init{
	if(self==[super init])
	{
	}
	return self;
}

+ (oDesk *)scharedManager
{
	static dispatch_once_t once;
	static oDesk *odesk;
	dispatch_once(&once, ^ { odesk = [[oDesk alloc] init]; });
	return odesk;
}

//make login request
-(NSString*)login:(NSString *)name password:(NSString *)password{
	self.login=[NSString stringWithString:name];
	//create data to post
	NSString* variables = [NSString stringWithFormat:@"username=%@&password=%@&action=%@",name,password,@"login"];
	return [self doRequest:variables URL:@"https://www.odesk.com/login"];
}

//make some request
-(NSString *)doRequest:(NSString *)params URL:(NSString *)url{
	//create data to post
	NSData* postVariables =
	[params dataUsingEncoding:NSASCIIStringEncoding
			allowLossyConversion:YES];
	NSString* postLength =
	[NSString stringWithFormat:@"%ld", [postVariables length]];
	//create request
	NSMutableURLRequest * request=[[NSMutableURLRequest alloc]init];
	[request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postVariables];
	//send request
	NSURLResponse * response=nil;
	NSError *error=nil;
	NSData *returnData =
	[NSURLConnection sendSynchronousRequest:request
						  returningResponse:&response
									  error:&error];
	
	NSString * str=[[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
	
	return str;
}

//calcule total time
-(NSDictionary *)todayTotalTime:type{
	NSMutableDictionary * timesByCounter=[[NSMutableDictionary alloc] init];
	//get today date
	NSDate *today=[NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
	[dateFormat setDateFormat:@"MM/dd/YYYY"];
	NSString *dateString = [dateFormat stringFromDate:today];
	NSLog(@"%@",dateString);

	//get all counters in account
	NSArray *counterNames=[self getAllCounters];
	
	CFTimeInterval totalInterval=0;
	//get time by every counter and summ it
	for (int i=0; i<[counterNames count]; i++) {
		//get page with time
//		NSString * str=[self loginClassicTimeAnalyze:[self URLEncodedString:[counterNames objectAtIndex:i]]];
//		NSLog(@"%@",str);
		//GET TIME
		NSString * time=[self getTimeByDay: self.login counter:[counterNames objectAtIndex:i] type:type];
		//add counter time to dictionary
		[timesByCounter setValue:time forKey:[counterNames objectAtIndex:i]];
		
		totalInterval+=[oDesk convertToTime:time];
	}

	//return totalTime
	AppDelegate *app = [[NSApplication sharedApplication] delegate];
    if([type isEqualToString:@"day"])
        app.totalTime2 = [oDesk convertTimeToString:totalInterval];
    else {
        if([type isEqualToString:@"week"])
            app.totalTime3 = [oDesk convertTimeToString:totalInterval];
        else
            app.totalTime4 = [oDesk convertTimeToString:totalInterval];
    }
	//return dictionary with counters and times
	return timesByCounter;
}

//method get all counters from account
-(NSArray *) getAllCounters{
	NSMutableArray * resultCounters= [[NSMutableArray alloc] init];
	
	//get page with counters
	NSString * content= [self doRequest:@"" URL:@"https://www.odesk.com/team/scripts/login?initial=1"];
	
	//create regular expression
	NSError *error;
	NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:@"<option value=\"[\\w \\: \\- \\! \\* \\' \\( \\) \\; \\@ \\& \\= \\+ \\$ \\, \\/ \\? \\% \\#]{1,}" 
																			    options:NSRegularExpressionCaseInsensitive
																				  error:&error];
	//find matches
	NSArray * array=[expression matchesInString:content options:0 range:NSMakeRange(0, [content length])];
	 
	//create array with counters
	for (NSTextCheckingResult* result in array){
		NSRange range=NSMakeRange(result.range.location+15, result.range.length-15);
		
		NSString * counterName=[content substringWithRange:range];
		[resultCounters addObject:counterName];
//		NSLog(@"%@",counterName);
	}
	return resultCounters;
}

//login to classic time analyzing
-(NSString *) loginClassicTimeAnalyze: (NSString*) counterName{
	NSString* variables = [NSString stringWithFormat:@"selected_company=%@&after_login_location=%@",counterName,@"http://www.odesk.com/team/scripts/report"];
	return [self doRequest:variables URL:@"https://www.odesk.com/team/scripts/login?initial=1&after_login_location=http%3A%2F%2Fwww.odesk.com%2Fteam%2Fscripts%2Freport"];
}

-(NSString *)getTimeByDay:(NSString *)logn counter:(NSString *)counter type:(NSString *)type
{	
    NSString * url;
    if([type isEqualToString:@"day"])
    {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
        NSString *currentDate = [formatter stringFromDate:date];
        url=[NSString stringWithFormat:@"https://www.odesk.com/team/scripts/report?company_id=%@&type=Chart&range=custom&user_id=%@&action=choose_custom_range&vs_users=&actually=1&start_date=%@&end_date=%@",[self URLEncodedString:counter],logn,currentDate,currentDate];
    }
    else 
    {
        if([type isEqualToString:@"week"])
        {
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/YYYY"];
            NSString *dateString = [dateFormat stringFromDate:today];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:today];
            [components setDay:([components day]-([components weekday]-2))];
            NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
            NSDateFormatter *dateFormat_first = [[NSDateFormatter alloc] init];
            [dateFormat_first setDateFormat:@"MM/dd/YYYY"];
            NSString *dateString_first = [dateFormat_first stringFromDate:beginningOfWeek];
            url=[NSString stringWithFormat:@"https://www.odesk.com/team/scripts/report?company_id=%@&type=Chart&range=custom&user_id=%@&action=choose_custom_range&vs_users=&actually=1&start_date=%@&end_date=%@",[self URLEncodedString:counter],logn,dateString_first,dateString];
        }
        else 
        {
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/YYYY"];
            NSString *currentDate = [formatter stringFromDate:date];
            
            NSDate *dateOld = [NSDate date];
            NSDateFormatter *formatterOld = [[NSDateFormatter alloc] init];
            [formatterOld setDateFormat:@"MM/01/YYYY"];
            NSString *stringOldDate = [formatterOld stringFromDate:dateOld];
//			NSLog(@"%@",currentDate);
            url=[NSString stringWithFormat:@"https://www.odesk.com/team/scripts/report?company_id=%@&type=Chart&range=custom&user_id=%@&action=choose_custom_range&vs_users=&actually=1&start_date=%@&end_date=%@", [self URLEncodedString:counter], logn,stringOldDate, currentDate];
//			NSLog(@"%@", url);
            
        }
    }
	NSString* variables = [NSString stringWithFormat:@"selected_company=%@",counter];
	NSString* strResult= [self doRequest:variables URL:url];
	
//	NSLog(@"%@",strResult);
	//create regular expression
	NSError *error;
	NSRegularExpression* expression =[NSRegularExpression regularExpressionWithPattern:@"<b>\\d{2,}:\\d{2}</b>" 
																			   options:NSRegularExpressionCaseInsensitive
																				 error:&error];
	//find matches
	NSRange rangeOfFirstMatch =[expression rangeOfFirstMatchInString:strResult options:0 range:NSMakeRange(0, [strResult length])];
	
	//if bad request
	if(rangeOfFirstMatch.length<5 || rangeOfFirstMatch.location>[strResult length]){
		NSString* time=[self getTimeByDay:logn counter:counter type:type];
		return time;
	}
	//cut <b> and </b>
    #define cut_len 3 /*длина тегов*/
	rangeOfFirstMatch=NSMakeRange(rangeOfFirstMatch.location+cut_len, rangeOfFirstMatch.length-(cut_len*2)-1);
	//get result string with time
	NSString* time=[strResult substringWithRange:rangeOfFirstMatch];
	return time;
}

+(CFTimeInterval)convertToTime:(NSString *)time{
	NSArray* components= [time componentsSeparatedByString:@":"];
	//add hours
	CFTimeInterval converted=[[components objectAtIndex:0] intValue]*60;
	//add minutes 
	converted+=[[components objectAtIndex:1] intValue];
	return converted;
}

+(NSString*) convertTimeToString:(CFTimeInterval) time{
	float hours=floor(time/60);
	float minutes=time-hours*60;
	
	NSMutableString * total=[NSMutableString stringWithFormat:@"%.0f:%.0f", hours,minutes];
	
	if([[NSString stringWithFormat:@"%.0f",hours] length]==1)
	{
		[total insertString:@"0" atIndex:0];
	}
	
	if([[NSString stringWithFormat:@"%.0f",minutes] length]==1)
	{
		[total insertString:@"0" atIndex:4];
	}
	
	return total;
}

- (NSString *) URLEncodedString: (NSString *) string {
	CFStringRef preprocessedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef) string, CFSTR(""), kCFStringEncodingUTF8);
	NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																			   preprocessedString,
																			   NULL,
																			   CFSTR("!*'();:@&=+$,/?%#[]-"),
																			   kCFStringEncodingUTF8);
	//CFRelease(preprocessedString);
	return result;
}

@end
