//
//  ODPropertyManager.h
//  oDeskTimer
//
//  Created by Viktor on 19.06.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODPropertyManager : NSObject

@property (strong) NSString * password;
@property (strong) NSString * login;
@property (assign) int hoursPerWeek;
@property (assign) int hoursPerDay;
@property (assign) int refreshTime;
@property (assign) BOOL isAlwaysOnTop;
@property (assign) BOOL isAutoLogin;

+ (ODPropertyManager *)manager;

-(void) save;
+(void) save;

-(void) load;
+(void) load;

@end