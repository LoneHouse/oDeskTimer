//
//  oDesk.h
//  oDeskTimer
//
//  Created by Roman Sidorakin on 08.05.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol oDeskDelegate <NSObject>

@optional
- (void) requestDidStart:(NSURLRequest *) request;
- (void) requestDidFinished:(NSURLRequest *) request;

@required
- (void) internetConnectionEstablished;
- (void) internetConnectionDisconnected;
@end

@interface oDesk : NSObject
@property (nonatomic, strong) NSString* login;
@property (weak) id<oDeskDelegate> delegate;

-(NSString*)login:(NSString *)name password:(NSString *)password;
-(NSString *)getUserTime:(NSString *)logn counter:(NSString *)counter type:(enum ODTimeRange)type;
-(NSDictionary *) todayTotalTime:(enum ODTimeRange) type;
+(NSString*) convertTimeToString:(CFTimeInterval) time;
+(CFTimeInterval)convertToTime:(NSString *)time;

+ (oDesk *)sharedManager;
@end
