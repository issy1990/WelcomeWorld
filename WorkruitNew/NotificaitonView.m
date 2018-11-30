//
//  NotificaitonView.m
//  workruit
//
//  Created by Admin on 12/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NotificaitonView.h"
#import "HeaderFiles.h"

@implementation NotificaitonView

- (void)awakeFromNib
{
    [super awakeFromNib];
   self.app_icon_img.layer.cornerRadius = self.app_icon_img.frame.size.width/2;
   self.app_icon_img.layer.masksToBounds = YES;
        self.app_icon_img.contentMode = UIViewContentModeScaleAspectFit;
   self.bgView.layer.cornerRadius = 10.0f;
    self.bgView.layer.masksToBounds = YES;
    
    UISwipeGestureRecognizer *upRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [upRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self addGestureRecognizer:upRecognizer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fireScrollRectToVisible:)]; // this is the current problem like a lot of people out there...
    [self addGestureRecognizer:tap];
    
} 

- (void) fireScrollRectToVisible: (UIGestureRecognizer *) gesture
{
    [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION_ON_CLICK object:nil userInfo:self.payload];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName: DISMISSNOTIFICATIONFROMVIEW object:nil userInfo:self.payload];
    
    
}

-(IBAction)notificationDidClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: DIDRECIVE_REMOTE_NOTIFICATION_ON_CLICK object:nil userInfo:self.payload];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
