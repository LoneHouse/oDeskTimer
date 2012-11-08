//
//  AppDelegate.m
//  oDeskTimer
//
//  Created by Vlad Smelov on 08.05.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import "AppDelegate.h"
#import "ODPropertyManager.h"
#import "ODPreferencesController.h"

@interface AppDelegate ()
{
	ODPreferencesController * preferencesController;	
}

@property (nonatomic, assign) BOOL isRefreshInProgress;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize oDeskTimer, isRefreshInProgress;
@synthesize timer, login, pass;
@synthesize TextFieldPass, TextFieldLogin;

@synthesize TimerPanel;
@synthesize rwgTextField, otherTinersTextField, totalTime;

@synthesize inProgress, inProgressWeek, inProgressMonth, totalTime2, totalTime3, totalTime4;
@synthesize rwgTextFieldWeek, otherTinersTextFieldWeek, totalTimeWeek;
@synthesize rwgTextFieldMounth, otherTinersTextFieldMounth, totalTimeMounth;
@synthesize timeItem,appMenu,menuFont;

- (void)activateStatusMenu

{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.timeItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    //[self.timeItem setTitle: NSLocalizedString(@"00:00",@"")];
	
	//setup attributed title
	NSMutableAttributedString *menuAttributedTitle=[[NSMutableAttributedString  alloc ] initWithString:@"00:00"];
	menuFont=[NSFont fontWithName:@"DS-Digital-Bold" size: 18];
	
	[menuAttributedTitle addAttribute:NSFontAttributeName value:self.menuFont range:NSMakeRange(0, menuAttributedTitle.string.length)];
	[self.timeItem setAttributedTitle:menuAttributedTitle];
	
	NSImage * icon = [NSImage imageNamed:@"oDeckIcon.icns"];
	NSBitmapImageRep * smallIconRep = [icon.representations objectAtIndex:1];
	NSImage *smallImg=[[NSImage alloc]initWithSize:[smallIconRep size] ];
	[smallImg addRepresentation:smallIconRep];
	[self.timeItem setImage:smallImg];
    [self.timeItem setHighlightMode:NO];
    [self.timeItem setMenu:self.appMenu];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	isRefreshInProgress = NO;
	
	[self.TimerPanel orderOut:nil];
	preferencesController = [[ODPreferencesController alloc] initWithWindowNibName:@"ODPreferencesController"];
	
	// Insert code here to initialize your application
	self.oDeskTimer = [oDesk scharedManager];
	
	//auto login
	self.TextFieldLogin.stringValue = [ODPropertyManager manager].login;
	self.TextFieldPass.stringValue  = [ODPropertyManager manager].password;
	
	if ([ODPropertyManager manager].isAutoLogin) {
		[self statrTimer:self];
	}
	
	[self activateStatusMenu];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	[ODPropertyManager save];
}

-(void)refreshTime{
#define RWG @"kudos_soft"
	if(login && !isRefreshInProgress)
	{
		isRefreshInProgress = YES;
		[self.inProgress      startAnimation:self];
		[self.inProgressWeek  startAnimation:self];
		[self.inProgressMonth startAnimation:self];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			dispatch_async(dispatch_get_current_queue(), ^{
				
				NSDictionary* times = [self.oDeskTimer todayTotalTime:@"day"];
				
				[self.totalTime setStringValue:[NSString stringWithFormat:@"%@", totalTime2]];
				
				//get ruswizards counter
				NSString * rwgTime=[times objectForKey:RWG];
				if (!rwgTime) {
					rwgTime=@"00:00";
				}
				[self.rwgTextField setStringValue:[NSString stringWithFormat:@"%@", rwgTime]];
				
				NSString *otherTime = [oDesk convertTimeToString:([oDesk convertToTime:totalTime2] - [oDesk convertToTime:rwgTime])];
				[self.otherTinersTextField setStringValue:otherTime];
				
				[self.inProgress stopAnimation:self];
				
				[self.timeItem setTitle:self.totalTime2];
				//set time to menu
//				NSMutableAttributedString *menuAttributedTitle=[[NSMutableAttributedString  alloc ] initWithString:totalTime2];
//				[menuAttributedTitle addAttribute:NSFontAttributeName value:self.menuFont range:NSMakeRange(0, menuAttributedTitle.string.length)];
//				[self.timeItem setAttributedTitle:menuAttributedTitle];
				
				[self updateView];         
			});
		});	
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			dispatch_async(dispatch_get_current_queue(), ^{
				NSDictionary* times = [self.oDeskTimer todayTotalTime:@"week"];
				
				[self.totalTimeWeek setStringValue:[NSString stringWithFormat:@"%@", totalTime3]];
				
				//get ruswizards counter
				NSString * rwgTime=[times objectForKey:RWG];
				if (!rwgTime) {
					rwgTime=@"00:00";
				}
				[self.rwgTextFieldWeek setStringValue:[NSString stringWithFormat:@"%@", rwgTime]];
				
				NSString *otherTime = [oDesk convertTimeToString:([oDesk convertToTime:totalTime3] - [oDesk convertToTime:rwgTime])];
				[self.otherTinersTextFieldWeek setStringValue:otherTime];
				[self.inProgressWeek stopAnimation:self];
				[self updateView];         
			});
		});
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			dispatch_async(dispatch_get_current_queue(), ^{
				NSDictionary* times = [self.oDeskTimer todayTotalTime:@"mounth"];
				
				[self.totalTimeMounth setStringValue:[NSString stringWithFormat:@"%@", totalTime4]];
				
				//get ruswizards counter
				NSString * rwgTime=[times objectForKey:RWG];
				if (!rwgTime) {
					rwgTime=@"00:00";
				}
				[self.rwgTextFieldMounth setStringValue:[NSString stringWithFormat:@"%@", rwgTime]];
				
				NSString *otherTime = [oDesk convertTimeToString:([oDesk convertToTime:totalTime4] - [oDesk convertToTime:rwgTime])];
				[self.otherTinersTextFieldMounth setStringValue:otherTime];
				[self.inProgressMonth stopAnimation:self];
				[self updateView];         
			});
		});
		
	}
}

//принудительно обновляем таймеры
- (void)forcedRefresh:(id)sender
{
	[self refreshTime];
}

- (void)statrTimer:(id)sender
{
	[self.TimerPanel makeKeyAndOrderFront:nil];
	[self.TimerPanel setAlphaValue:0.75f];
	[self.window setAlphaValue:0.0f];
	
	//запоминаем данные
	self.login = [self.TextFieldLogin stringValue];
	self.pass = [self.TextFieldPass stringValue];
    [ODPropertyManager manager].login = self.login;
    [ODPropertyManager manager].password = self.pass;
	NSLog(@"%@ %@", self.login, self.pass);
	[self.oDeskTimer login:self.login password:self.pass];
	
	//запускаем таймер на авто рефреш
	self.timer = [NSTimer scheduledTimerWithTimeInterval:[ODPropertyManager manager].refreshTime*60 target:self selector:@selector(refreshTime) userInfo:nil repeats:YES];
	[self refreshTime];
}

-(void) updateView{
	//Ограничение на повторный вызов рефреша во время самого рефреша
	static int i = 0;
	i++;
	
	if (i == 3) 
	{
		i = 0;
		isRefreshInProgress = NO;
	}
	
	NSRect panelRect = self.TimerPanel.frame;
	[self.TimerPanel setFrame:panelRect display:YES animate:NO];
}

- (IBAction)logInMenuItem:(id)sender
{
	[self.window setAlphaValue:1.0f];
	[self.TimerPanel orderOut:nil];
}

- (void)showPreferences:(id)sender
{
	[preferencesController showWindow:self];
}

@end