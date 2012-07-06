//
//  ODPreferencesController.m
//  oDeskTimer
//
//  Created by Viktor on 22.06.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import "ODPreferencesController.h"
#import "ODPropertyManager.h"

@interface ODPreferencesController ()

-(void) getValues;

@end

@implementation ODPreferencesController
@synthesize loginTF;
@synthesize passwordSTF;
@synthesize autoLogin;
@synthesize onTop;
@synthesize hoursPerWeek;
@synthesize hoursPerDay;
@synthesize refreshTime;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	switch (control.tag) {
		case 1:
			[ODPropertyManager manager].login        = fieldEditor.string;
			break;
			
		case 2:
			[ODPropertyManager manager].password     = fieldEditor.string;
			break;
			
		case 3:
			[ODPropertyManager manager].hoursPerWeek = [fieldEditor.string intValue];
			break;
			
		case 4:
			[ODPropertyManager manager].refreshTime  = [fieldEditor.string intValue];
			break;
			
		case 5:
			[ODPropertyManager manager].hoursPerDay  = [fieldEditor.string intValue];
			break;
	}
	return YES;
}

- (void)getValues
{
	[ODPropertyManager manager].login         = self.loginTF.stringValue;
	[ODPropertyManager manager].password      = self.passwordSTF.stringValue;
	[ODPropertyManager manager].hoursPerWeek  = self.hoursPerWeek.intValue;
	[ODPropertyManager manager].hoursPerDay   = self.hoursPerDay.intValue;
	[ODPropertyManager manager].refreshTime   = self.refreshTime.intValue;
	[ODPropertyManager manager].isAlwaysOnTop = self.onTop.state     == NSOnState;
	[ODPropertyManager manager].isAutoLogin   = self.autoLogin.state == NSOnState; 
	
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.loginTF.stringValue     = [ODPropertyManager manager].login;
	self.passwordSTF.stringValue = [ODPropertyManager manager].password;
	self.hoursPerWeek.intValue   = [ODPropertyManager manager].hoursPerWeek;
	self.hoursPerDay.intValue    = [ODPropertyManager manager].hoursPerDay;
	self.refreshTime.intValue    = [ODPropertyManager manager].refreshTime;
	self.onTop.state             = [ODPropertyManager manager].isAlwaysOnTop ? NSOnState: NSOffState; 
	self.autoLogin.state         = [ODPropertyManager manager].isAutoLogin   ? NSOnState: NSOffState; 
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self getValues];
}

- (IBAction)done:(NSButton *)sender 
{
	
	[self getValues];
	[self close];
	[ODPropertyManager save];
}

- (IBAction)autoLogin:(NSButton *)sender {
	[ODPropertyManager manager].isAutoLogin = sender.state == NSOnState;
}

- (IBAction)onTop:(NSButton *)sender {
	[ODPropertyManager manager].isAlwaysOnTop = sender.state == NSOnState;
}
@end
