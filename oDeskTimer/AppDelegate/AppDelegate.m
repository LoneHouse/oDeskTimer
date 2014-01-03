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
#import "ODTimerWindowController.h"
#import "Constants.h"
#import "Reachability.h"

@interface AppDelegate ()
{
	ODPreferencesController * preferencesController;
	ODTimerWindowController * timerWindowController;
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



#pragma mark - drop menu 


- (void) updateDropMenu
{
    
}



-(void) loadFonts
{

	NSString *fontFilePath = [[NSBundle mainBundle] resourcePath];
	NSURL *fontsURL = [NSURL fileURLWithPath:fontFilePath];
	NSLog(@"%@",fontFilePath);
	if(fontsURL != nil)
	{
		OSStatus status;
		FSRef fsRef;
		CFURLGetFSRef((__bridge CFURLRef)fontsURL, &fsRef);
		status = ATSFontActivateFromFileReference(&fsRef, kATSFontContextLocal, kATSFontFormatUnspecified,
												  NULL, kATSOptionFlagsDefault, NULL);
		if (status != noErr)
		{
			NSLog(@"Failed to acivate fonts!");

		}
	}
}

- (void)activateStatusMenu
{
	[self loadFonts];
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.timeItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    //[self.timeItem setTitle: NSLocalizedString(@"00:00",@"")];
	menuFont=[NSFont fontWithName:@"DS-Digital" size: 18];
	
	[self updateTimeOnMenu:@"00:00"];
	
	NSImage * icon = [NSImage imageNamed:@"oDeckIcon_menubar.tiff"];
	[self.timeItem setImage:icon];
    [self.timeItem setHighlightMode:NO];
    [self.timeItem setMenu:self.appMenu];
}

- (void) setStatusItemDayTime:(NSString*) day week:(NSString*) week mounth:(NSString*) mounth
{
	NSMenuItem * rootItem = [self.appMenu.itemArray objectAtIndex:0];
	
	NSMenuItem * itemDay = [rootItem.submenu.itemArray objectAtIndex:0];
	itemDay.title = [NSString stringWithFormat:@"Day %@",day];
	
	NSMenuItem * itemWeek = [rootItem.submenu.itemArray objectAtIndex:1];
	itemWeek.title = [NSString stringWithFormat:@"Week %@",week];
	
	NSMenuItem * itemMounth = [rootItem.submenu.itemArray objectAtIndex:2];
	itemMounth.title = [NSString stringWithFormat:@"Mounth %@",mounth];
	
}

-(void) updateTimeOnMenu:(NSString *) text
{
	[self loadFonts];
	//setup attributed title
	NSMutableAttributedString *menuAttributedTitle=[[NSMutableAttributedString  alloc ] initWithString:text];
	[menuAttributedTitle addAttribute:NSFontAttributeName value:self.menuFont range:NSMakeRange(0, menuAttributedTitle.string.length)];
	[self.timeItem setAttributedTitle:menuAttributedTitle];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	isRefreshInProgress = NO;
	
	[self.TimerPanel orderOut:nil];
	preferencesController = [[ODPreferencesController alloc] initWithWindowNibName:@"ODPreferencesController"];
	
	// Insert code here to initialize your application
	self.oDeskTimer = [oDesk sharedManager];
	
	//auto login
	self.TextFieldLogin.stringValue = [ODPropertyManager manager].login;
	self.TextFieldPass.stringValue  = [ODPropertyManager manager].password;
	
	if ([ODPropertyManager manager].isAutoLogin) {
		[self statrTimer:self];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetStatusChanged:) name:kReachabilityChangedNotification object:nil];
	
	[self activateStatusMenu];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	[ODPropertyManager save];
}

- (void)refreshTime {
#define RWG @"kudos_soft"
	Reachability *reachability = [Reachability reachabilityWithHostname:@"www.odesk.com"];
	[reachability startNotifier];
	NetworkStatus networkStatus = reachability.currentReachabilityStatus;
	
	if (login && !isRefreshInProgress && networkStatus != NotReachable) {
		isRefreshInProgress = YES;
		[self.inProgress startAnimation:self];
		[self.inProgressWeek startAnimation:self];
		[self.inProgressMonth startAnimation:self];
		
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		    //111111111111111111111111111111111111
		    NSDictionary *times = [self.oDeskTimer todayTotalTime:ODTimeRangeDay];
		    //get ruswizards counter
		    NSString *rwgTime = [times objectForKey:RWG];
			
		    if (!rwgTime) {
		        rwgTime = @"00:00";
			}
			
		    NSString *otherTime = [oDesk convertTimeToString:([oDesk convertToTime:totalTime2] - [oDesk convertToTime:rwgTime])];
			
			
		    //2222222222222222222222222222222322222222
		    NSDictionary *times2 = [self.oDeskTimer todayTotalTime:ODTimeRangeWeek];
		    //get ruswizards counter
		    NSString *rwgTime2 = [times2 objectForKey:RWG];
			
		    if (!rwgTime2) {
		        rwgTime2 = @"00:00";
			}
			
		    NSString *otherTime2 = [oDesk convertTimeToString:([oDesk convertToTime:totalTime3] - [oDesk convertToTime:rwgTime2])];
			
			
		    //333333333333333333333333333333
		    NSDictionary *times3 = [self.oDeskTimer todayTotalTime:ODTimeRangeMonth];
		    //get ruswizards counter
		    NSString *rwgTime3 = [times3 objectForKey:RWG];
			
		    if (!rwgTime3) {
		        rwgTime3 = @"00:00";
			}
			
		    NSString *otherTime3 = [oDesk convertTimeToString:([oDesk convertToTime:totalTime4] - [oDesk convertToTime:rwgTime3])];
			
			
			
		    dispatch_sync(dispatch_get_main_queue(), ^{
		        [self.totalTime setStringValue:[NSString stringWithFormat:@"%@", totalTime2]];
		        [self.rwgTextField setStringValue:[NSString stringWithFormat:@"%@", rwgTime]];
		        [self.otherTinersTextField setStringValue:otherTime];
		        [self.inProgress stopAnimation:self];
		        [self.timeItem setTitle:self.totalTime2];
		        //set time to menu
		        [self updateTimeOnMenu:totalTime2];
				
				
		        [self.totalTimeWeek setStringValue:[NSString stringWithFormat:@"%@", totalTime3]];
		        [self.rwgTextFieldWeek setStringValue:[NSString stringWithFormat:@"%@", rwgTime2]];
		        [self.otherTinersTextFieldWeek setStringValue:otherTime2];
		        [self.inProgressWeek stopAnimation:self];
				
				
		        [self.totalTimeMounth setStringValue:[NSString stringWithFormat:@"%@", totalTime4]];
		        [self.rwgTextFieldMounth setStringValue:[NSString stringWithFormat:@"%@", rwgTime3]];
		        [self.otherTinersTextFieldMounth setStringValue:otherTime3];
		        [self.inProgressMonth stopAnimation:self];
		        [self updateView];
		        [self setStatusItemDayTime:rwgTime week:rwgTime2 mounth:rwgTime3];
			});
		});
	}
}

- (IBAction)showFullTimerWindow:(id)sender {
    timerWindowController = [[ODTimerWindowController alloc] initWithWindowNibName:@"ODTimerWindowController"];
    [timerWindowController showWindow:nil];
    
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

-(void) updateView
{
	isRefreshInProgress = NO;
	
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

#pragma mark Reachability
- (void) internetStatusChanged:(NSNotification*)note{
	Reachability* reachability = [note object];
	NetworkStatus networkStatus = reachability.currentReachabilityStatus;
	
	if (networkStatus == NotReachable)
	{
		NSImage * icon = [NSImage imageNamed:@"oDeckIcon_menubar_red.tiff"];
		[self.timeItem setImage:icon];
		[[NSAlert alertWithMessageText:@"Internet connection disappears! Time will be refreshed automatically when internet connection appers." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
	}
	else{
		NSImage * icon = [NSImage imageNamed:@"oDeckIcon_menubar.tiff"];
		[self.timeItem setImage:icon];
	}
}

@end