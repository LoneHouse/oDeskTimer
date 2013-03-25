//
//  oDesk.m
//  oDeskTimer
//
//  Created by Roman Sidorakin on 08.05.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import "oDesk.h"
#import "AppDelegate.h"
#import "NSMutableString+RequestParameters.h"
#import "Reachability.h"

@interface oDesk()
-(NSString *) doRequest:(NSString *) params URL:(NSString* )url;
-(NSString *) loginClassicTimeAnalyze:(NSString *) counterName;
-(NSArray *) getAllCounters;
-(NSString *) URLEncodedString: (NSString *) string;
@end

@implementation oDesk
@synthesize login = _login;

-(id)init{
	if(self==[super init]){
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetStatusChanged:) name:kReachabilityChangedNotification object:nil];
		Reachability *reachability = [Reachability reachabilityWithHostname:@"www.odesk.com"];
		[reachability startNotifier];
	}
	return self;
}

+ (oDesk *)sharedManager
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
	NSMutableString* variables = [NSMutableString string];
	[variables addParameter:kODParameterUsername withValue:name];
	[variables addParameter:kODParameterPassword withValue:password];
	[variables addParameter:kODParameterAction withValue:kODParameterActionLogin];
	return [self doRequest:variables URL: kODURLLogin];
}

//make some request
-(NSString *)doRequest:(NSMutableString *)params URL:(NSString *)url{
	//create request
	NSMutableURLRequest * request=[[NSMutableURLRequest alloc]init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request setValue:[params postDataLength] forHTTPHeaderField:kODRequestContentLength];
	[request setValue:kODRequestContentTypeValue forHTTPHeaderField:kODRequestContentType];
	[request setHTTPBody:[params postData]];
	if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidStart:)]) {
		[self.delegate requestDidStart:request];
	}
	
	//send request
	NSURLResponse * response=nil;
	NSError *error=nil;
	NSData *returnData =
	[NSURLConnection sendSynchronousRequest:request
						  returningResponse:&response
									  error:&error];
	
	NSString * str=[[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
	if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFinished:)]) {
		[self.delegate requestDidFinished:request];
	}
	return str;
}

//calcule total time
-(NSDictionary *) todayTotalTime:(enum ODTimeRange) type{
	NSMutableDictionary * timesByCounter=[[NSMutableDictionary alloc] init];
	//get all counters in account
	NSArray *counterNames=[self getAllCounters];
	
	CFTimeInterval totalInterval=0;
	//get time by every counter and summ it
	for (int i=0; i<[counterNames count]; i++) {
		//GET TIME
		NSString * time=[self getUserTime: self.login counter:[counterNames objectAtIndex:i] type:type];
		//add counter time to dictionary
		[timesByCounter setValue:time forKey:[counterNames objectAtIndex:i]];
		
		totalInterval+=[oDesk convertToTime:time];
	}
	
	//return totalTime
	AppDelegate *app = [[NSApplication sharedApplication] delegate];
	switch (type) {
		case ODTimeRangeDay:{
			app.totalTime2 = [oDesk convertTimeToString:totalInterval];
		}
			break;
			
		case ODTimeRangeWeek:{
			app.totalTime3 = [oDesk convertTimeToString:totalInterval];
		}
			break;
			
		case ODTimeRangeMonth:{
			app.totalTime4 = [oDesk convertTimeToString:totalInterval];
		}
			break;
			
		default:
			break;
	}
	//return dictionary with counters and times
	return timesByCounter;
}

//method get all counters from account
-(NSArray *) getAllCounters{
	NSMutableArray * resultCounters= [[NSMutableArray alloc] init];
	
	//get page with counters
	NSString * content= [self doRequest:@"" URL:kODURLCounters];
	
	//create regular expression
	NSError *error;
	NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:kODRegExpCounters
																				options:NSRegularExpressionCaseInsensitive
																				  error:&error];
	//find matches
	const NSUInteger startSearch = 6000; // number of symbols before tab <select> (for best performance)
	NSArray * matchesArray=[expression matchesInString:content options:0 range:NSMakeRange(startSearch, [content length] - startSearch)];
	
	//create array with counters
	for (NSTextCheckingResult* result in matchesArray){
		const NSUInteger optionLenght = 15;
		//15 is length of text "<option value=""
		NSRange range=NSMakeRange(result.range.location + optionLenght, result.range.length - optionLenght);
		
		NSString * counterName=[content substringWithRange:range];
		[resultCounters addObject:counterName];
	}
	return resultCounters;
}

//login to classic time analyzing
-(NSString *) loginClassicTimeAnalyze: (NSString*) counterName{
	NSMutableString *variables = [NSMutableString string];
	[variables addParameter:kODParameterCompany withValue:counterName];
	[variables addParameter:kODParameterAfterLoginLoc withValue:kODURLReport];
	return [self doRequest:variables URL:kODURLClassicTimeAnalyze];
}

-(NSString *) formattedStringFromDate{
	NSDate *date = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:kODDateFormat];
	NSString *currentDate = [formatter stringFromDate:date];
	return currentDate;
}

-(NSString *)getUserTime:(NSString *)logn counter:(NSString *)counter type:(enum ODTimeRange)type
{
	NSString * url;
	switch (type) {
		case ODTimeRangeDay:{
			NSString *currentDate = [self formattedStringFromDate];
			url=[NSString stringWithFormat:kODURLGetTime,[self URLEncodedString:counter],logn,currentDate,currentDate];
		}
			break;
			
		case ODTimeRangeWeek:{

			NSString *dateString = [self formattedStringFromDate];
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
			[components setDay:([components day]-([components weekday]-2))];
			NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
			NSDateFormatter *dateFormat_first = [[NSDateFormatter alloc] init];
			[dateFormat_first setDateFormat:kODDateFormat];
			NSString *dateString_first = [dateFormat_first stringFromDate:beginningOfWeek];
			
			url=[NSString stringWithFormat: kODURLGetTime,[self URLEncodedString:counter],logn,dateString_first,dateString];
		}
			break;
			
		case ODTimeRangeMonth:{

			NSString *currentDate = [self formattedStringFromDate];
			
			NSDate *dateOld = [NSDate date];
			NSDateFormatter *formatterOld = [[NSDateFormatter alloc] init];
			[formatterOld setDateFormat:kODDateMonthFormat];
			NSString *stringOldDate = [formatterOld stringFromDate:dateOld];
			url=[NSString stringWithFormat: kODURLGetTime, [self URLEncodedString:counter], logn,stringOldDate, currentDate];
		}
			break;
			
		default:
			break;
	}

	//do request
	NSMutableString *request=[NSMutableString string];
	[request addParameter:kODParameterCompany withValue:counter];
	NSString* requestResult= [self doRequest:request URL:url];
	
	NSLog(@"%@",url);
	
	//create regular expression
	NSError *error;
	NSRegularExpression* expression =[NSRegularExpression regularExpressionWithPattern:kODRegExpTime
																			   options:NSRegularExpressionCaseInsensitive
																				 error:&error];
	//find matches
	NSRange rangeOfFirstMatch = [expression rangeOfFirstMatchInString:requestResult options:0 range:NSMakeRange(0, [requestResult length])];
	
	//if bad request
	if(rangeOfFirstMatch.length < 5 || rangeOfFirstMatch.location>[requestResult length]){
		NSString *time=[self getUserTime: logn counter: counter type: type];
		return time;
	}
	
	//cut <b> and </b>
#define cut_len 3
	rangeOfFirstMatch=NSMakeRange(rangeOfFirstMatch.location + cut_len, rangeOfFirstMatch.length - (cut_len * 2) - 1);
	//get result string with time
	NSString *time=[requestResult substringWithRange: rangeOfFirstMatch];
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
	float hours=floor(time / 60.0);
	float minutes=time-hours * 60.0;
	
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
	return result;
}

-(void)dealloc{
	Reachability *reachability = [Reachability reachabilityWithHostname:@"www.odesk.com"];
	[reachability stopNotifier];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark Reachability
- (void) internetStatusChanged:(NSNotification*)note{
	Reachability* reachability = [note object];
	NetworkStatus networkStatus = reachability.currentReachabilityStatus;
	
	if (networkStatus == NotReachable)
	{
		if (self.delegate && [self.delegate respondsToSelector:@selector(internetConnectionDisconnected)]) {
			[self.delegate internetConnectionDisconnected];
		}
	}
	else{
		if (self.delegate && [self.delegate respondsToSelector:@selector(internetConnectionEstablished)]) {
			[self.delegate internetConnectionEstablished];
		}
	}
}

@end
