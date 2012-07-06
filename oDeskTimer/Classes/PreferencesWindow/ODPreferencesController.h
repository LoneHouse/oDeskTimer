//
//  ODPreferencesController.h
//  oDeskTimer
//
//  Created by Viktor on 22.06.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ODPreferencesController : NSWindowController <NSControlTextEditingDelegate,NSWindowDelegate>

- (IBAction)done:(NSButton *)sender;

- (IBAction)autoLogin:(NSButton *)sender;

- (IBAction)onTop:(NSButton *)sender;

@property (strong) IBOutlet NSTextField *loginTF;
@property (strong) IBOutlet NSSecureTextField *passwordSTF;
@property (strong) IBOutlet NSButton *autoLogin;
@property (strong) IBOutlet NSButton *onTop;
@property (strong) IBOutlet NSTextField *hoursPerWeek;
@property (strong) IBOutlet NSTextField *hoursPerDay;
@property (strong) IBOutlet NSTextField *refreshTime;
@end
