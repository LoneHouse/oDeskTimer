//
//  AppDelegate.h
//  oDeskTimer
//
//  Created by Vlad Smelov on 08.05.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "oDesk.h"
#import <WebKit/WebKit.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>
//менюшка сверху
@property (strong) IBOutlet NSMenu *appMenu;
@property(strong) NSStatusItem *timeItem;
@property(strong) NSFont * menuFont;
// основное окно
@property (nonatomic, strong) IBOutlet NSWindow *window;


//аутлеты основного окна
@property (nonatomic, strong) IBOutlet NSTextField *TextFieldLogin;
@property (nonatomic, strong) IBOutlet NSTextField *TextFieldPass;

//Свойства для основного окна
@property (unsafe_unretained, nonatomic) oDesk* oDeskTimer; // подключаем либу для работы с oDesk
@property (unsafe_unretained, nonatomic) NSTimer* timer; //Таймер ля обновления счетчика
// Поля для хранения логина и пароля
@property (unsafe_unretained, nonatomic) NSString *pass;
@property (unsafe_unretained, nonatomic) NSString *login;
@property (unsafe_unretained, nonatomic) NSString* totalTime2;
@property (unsafe_unretained, nonatomic) NSString* totalTime3;
@property (unsafe_unretained, nonatomic) NSString* totalTime4;

//методы основного окна
- (IBAction) logInMenuItem:(id)sender;
- (IBAction) statrTimer:(id)sender;
- (IBAction) forcedRefresh: (id)sender;
- (void) refreshTime;
- (IBAction)showFullTimerWindow:(id)sender;

// Черненькая клевенькая панелька
@property (nonatomic, strong) IBOutlet NSPanel *TimerPanel;

//оутлеты на панели
@property (nonatomic, strong) IBOutlet NSTextField *rwgTextField;
@property (nonatomic, strong) IBOutlet NSTextField *otherTinersTextField;
@property (nonatomic, strong) IBOutlet NSTextField *totalTime;

@property (nonatomic, strong) IBOutlet NSProgressIndicator *inProgress;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *inProgressWeek;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *inProgressMonth;

@property (nonatomic, strong) IBOutlet NSTextField *rwgTextFieldWeek;
@property (nonatomic, strong) IBOutlet NSTextField *otherTinersTextFieldWeek;
@property (nonatomic, strong) IBOutlet NSTextField *totalTimeWeek;

@property (nonatomic, strong) IBOutlet NSTextField *rwgTextFieldMounth;
@property (nonatomic, strong) IBOutlet NSTextField *otherTinersTextFieldMounth;
@property (nonatomic, strong) IBOutlet NSTextField *totalTimeMounth;


- (IBAction) showPreferences:(id)sender;

@end
