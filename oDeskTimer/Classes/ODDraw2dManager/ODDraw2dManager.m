//
//  draw2dTXT.m
//  oDeskTimer
//
//  Created by Vlad Smelov on 30.06.12.
//  Copyright (c) 2012 Rus Wizards. All rights reserved.
//

#import "ODDraw2dManager.h"
#import "ODPropertyManager.h"

@implementation ODDraw2dManager

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:self.frame];
    // Drawing code here.
	NSGraphicsContext* context1 = [NSGraphicsContext currentContext];
	[context1 saveGraphicsState];
	
	// Set the drawing attributes
	CGContextRef context = [context1 graphicsPort]; //определяем контекст
	CGContextSetLineWidth(context, 2.0f);//толщина линии
	//цвет границы круга
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.5f, 0.5f, 0.5f, 1.0f};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
	//квадрат в котором рисется круг
    CGRect rectangle = CGRectMake(53.0f, 6.0f, 10.30f, 10.0f);
	//добавляем круг на вью
    CGContextAddEllipseInRect(context, rectangle);
    CGContextStrokePath(context);
	//цвет заливки
	CGColorSpaceRef colorspace1 = CGColorSpaceCreateDeviceRGB();
	
	NSString *str = [NSString stringWithString:[self rgb]];
	NSArray  *strSeparated = [str componentsSeparatedByString:@"/"];
    CGFloat components1[] = {[[strSeparated objectAtIndex:0] floatValue], 
							 [[strSeparated objectAtIndex:1] floatValue], 
							 [[strSeparated objectAtIndex:2] floatValue], 1};
	CGColorRef color1 = CGColorCreate(colorspace1, components1);
	
	//заливаем
	CGContextSetFillColorWithColor(context, color1);
    CGContextFillEllipseInRect(context, rectangle);
	
	[context1 restoreGraphicsState];
}

- (NSString *) rgb
{	
	if (self.stringValue) {
		
		float hoursMustWork = 1;
		if (self.tag == 1) {
			hoursMustWork = [ODPropertyManager manager].hoursPerWeek;
		}
		else if (self.tag == 0)
		{
			hoursMustWork = [ODPropertyManager manager].hoursPerDay;
		}
		
		NSString *text = self.stringValue;
		NSArray  *components = [text componentsSeparatedByString:@":"];
		float hours = [[components objectAtIndex:0] integerValue] + [[components objectAtIndex:0] integerValue] / 60;
		
		float percentOfHours = [self percentOfNumber:hours divideValue:hoursMustWork];
//		NSLog(@"%f %f %f", hours, hoursInWeek, percentOfHours);
		
		if(percentOfHours < 0.5)
		{
			float percentOfColor = [self percentOfNumber:percentOfHours divideValue:50.0f] * 100;
			NSLog(@"RGB (1, %f, 0)", percentOfColor);
			return [NSString stringWithFormat:@"1/%f/0", percentOfColor];
		}
		else if (percentOfHours == 0.5)
		{
			NSLog(@"RGB (1, 1, 0)");
			return [NSString stringWithFormat:@"1/1/0"];
		}
		else if (percentOfHours > 0.5 && percentOfHours < 1) {
			float percentOfColor = [self percentOfNumber:percentOfHours divideValue:50.0f]  * 100;
			NSLog(@"RGB (%f, 1, 0)", 2 - percentOfColor); //-2 потому что уменьшаем значение Red
			return [NSString stringWithFormat:@"%f/1/0", 2 - percentOfColor];
		}
		else if (percentOfHours == 1) {
			NSLog(@"RGB (0, 1, 0)");
			return [NSString stringWithFormat:@"0/1/0"];
		}
		else if (percentOfHours > 1 && percentOfHours < 1.5){
			float percentOfColor = [self percentOfNumber:percentOfHours divideValue:50.0f] * 100;
			NSLog(@"RGB (0, 1, %f)", percentOfColor - 2);
			return [NSString stringWithFormat:@"0/1/%f", percentOfColor - 2];
		}
		else if (percentOfHours >= 1.5 && percentOfHours <=2){
			float percentOfColor = [self percentOfNumber:percentOfHours divideValue:50.0f] * 100;
			NSLog(@"RGB (0, %f, 1)", 4 - percentOfColor); // -1 потому что значение уже больше единицы.
			return [NSString stringWithFormat:@"0/%f/1", 4 - percentOfColor];
		}
		else {
			NSLog(@"RGB (0, 0, 1)");
			return [NSString stringWithFormat:@"0/0/1"];
		}
	}
	return [NSString stringWithFormat:@"0/0/0"];
}

- (float) percentOfNumber:(float)upValue divideValue:(float) downValue
{
	return upValue / downValue;
}

@end