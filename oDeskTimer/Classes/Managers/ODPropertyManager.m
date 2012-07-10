

#import "ODPropertyManager.h"

#define kIsAlwaysOnTop @"isOnTop"
#define kIsAutoLogin   @"isAutoLogin"
#define kIsFirstLaunch @"isFirstLaunch"
#define kPassword      @"password"
#define kLogin         @"login"
#define kHoursPerWeek  @"hoursPerWeek"
#define kHoursPerDay   @"hoursPerDay"
#define kRefreshTime   @"refreshTime"

@interface ODPropertyManager ()

@end

@implementation ODPropertyManager
@synthesize isAutoLogin, 
			isAlwaysOnTop, 
			password, 
			login, 
			hoursPerWeek, 
			refreshTime, 
			hoursPerDay;

+ (ODPropertyManager *)manager
{
    static dispatch_once_t once;
    static ODPropertyManager *manager;
    dispatch_once(&once, ^ { manager = [[ODPropertyManager alloc] init];
		[manager load];
	});
    return manager;
}

#pragma mark - load
-(void) load 
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	if (![defaults boolForKey:kIsFirstLaunch]) {
		[defaults setBool:YES forKey:kIsFirstLaunch];
		
		self.isAlwaysOnTop = YES;
		self.isAutoLogin   = NO ;
		self.password      = @"";
		self.login         = @"";
		self.hoursPerWeek  = 40 ;
		self.hoursPerDay   = 8 ;
		self.refreshTime   = 5  ;
		[self save];
	}
	else {
		self.isAlwaysOnTop = [defaults boolForKey:kIsAlwaysOnTop  ];
		self.isAutoLogin   = [defaults boolForKey:kIsAutoLogin    ];
		self.password      = [defaults stringForKey:kPassword     ];
		self.login         = [defaults stringForKey:kLogin        ];
		self.hoursPerWeek  = [defaults integerForKey:kHoursPerWeek];
		self.hoursPerDay   = [defaults integerForKey:kHoursPerDay ];
		self.refreshTime   = [defaults integerForKey:kRefreshTime ];
	}
}

+(void)load
{
	[[ODPropertyManager manager]load];
}

#pragma mark - save
-(void) save
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:self.isAlwaysOnTop   forKey:kIsAlwaysOnTop];
	[defaults setBool:self.isAutoLogin     forKey:kIsAutoLogin  ];
	[defaults setValue:self.password       forKey:kPassword     ];
	[defaults setValue:self.login          forKey:kLogin        ];
	[defaults setInteger:self.hoursPerWeek forKey:kHoursPerWeek ];
	[defaults setInteger:self.hoursPerDay  forKey:kHoursPerDay  ];
	[defaults setInteger:self.refreshTime  forKey:kRefreshTime  ];
	[defaults synchronize];
}

+(void)save
{
	[[ODPropertyManager manager] save];
}

@end