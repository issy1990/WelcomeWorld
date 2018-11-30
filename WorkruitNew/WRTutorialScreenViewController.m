//
//  WRTutorialScreenViewController.m
//  workruit
//
//  Created by Admin on 6/17/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "WRTutorialScreenViewController.h"
#import "HeaderFiles.h"
#import "WRACMatchScreen.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface WRTutorialScreenViewController (){
    UILabel *information;
    UIButton *skip_button;
    int numberOfItem;
    
    UIImageView *directionView;
    IBOutlet UIView * myView;

}

@end

@implementation WRTutorialScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    directionView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200 , 200)];
    directionView.image = [UIImage imageNamed:@"app_icon_image"];
    directionView.center = self.view.center;
    [self.view addSubview:directionView];
    [self.view bringSubviewToFront:directionView];
    [self startAnim];
    
    
    // Do any additional setup after loading the view.
    numberOfItem = 1;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    if(_container)
        [_container reloadCardContainer];
    else
        [self reloadTheContainerView:0];
    
    skip_button = [UIButton buttonWithType:UIButtonTypeCustom];
    skip_button.frame = CGRectMake(self.view.frame.size.width-70, 20, 50, 30);
    [skip_button setTitle:@"Skip" forState:UIControlStateNormal];
    skip_button.titleLabel.font = [UIFont fontWithName:GlobalFontRegular size:18.0f];
    [skip_button addTarget:self action:@selector(skipButtonActionClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_container addSubview:skip_button];
    
    information = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height/100)*5, self.view.frame.size.width, 50)];
    information.text = [Utility isComapany]?@"Swipe right to like a profile.":@"Swipe right to like a job.";
    information.font = [UIFont fontWithName:GlobalFontRegular size:18.0f];
    information.textColor = [UIColor whiteColor];
    information.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:information];
    
    [Utility setThescreensforiPhonex:myView];
}

-(void)viewDidDisappear:(BOOL)animated{
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedTutorial];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)skipButtonActionClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

static NSInteger count = 0;
static NSInteger maxBlind = 1000;

- (void)startAnim
{
    [self.view bringSubviewToFront:directionView];
    
    CGFloat animDuration = 1.0f;
    [UIView animateWithDuration:animDuration
                     animations:^{
                         directionView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:animDuration
                                          animations:^{
                                              directionView.alpha = 1.f;
                                          } completion:^(BOOL finished) {
                                              if (count < maxBlind){
                                                  [self startAnim];
                                                  count++;
                                              }
                                          }];
                     }];
}

/*
 Applicant:
	1.	like.png
	⁃	Swipe right to like a job.
	2.	pass.png
	⁃	Swipe left if you’re not interested.
	3.	info.png
	⁃	Tap on the card for more information.
 
 Company:
	1.	like.png
	⁃	Swipe right to like a profile.
	2.	pass.png
	⁃	Swipe left if you’re not interested.
	3.	info.png
	⁃	Tap on the card for more information.
 */

-(void)reloadTheContainerView:(int)index
{
    if(!_container)
        _container = [[YSLDraggableCardContainer alloc] init];
    
    _container.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _container.backgroundColor = [UIColor blackColor];
    _container.dataSource = self;
    _container.delegate = self;
    
    if(index == 0){
        information.text = [Utility isComapany]?@"Swipe right to like a profile.":@"Swipe right to like a job.";
        _container.canDraggableDirection =  YSLDraggableDirectionRight;
    }else if(index == 1){
        information.text = @"Swipe left if you’re not interested.";
        _container.canDraggableDirection =  YSLDraggableDirectionLeft;
    }else{
        information.text = @"Tap on the card for more information.";
        _container.canDraggableDirection =  YSLDraggableDirectionUp;
    }
    
    [self.view addSubview:_container];
    [_container reloadCardContainer];
    [_container addSubview:information];
    [_container addSubview:skip_button];
    
}
#pragma mark -- YSLDraggableCardContainer DataSource
/*
 - (UIView *)cardContainerViewNextViewWithIndex:(NSInteger)index
 {
 UIView *job_card_view = [[UIView alloc] init];
 [job_card_view setBackgroundColor:[UIColor whiteColor]];
 job_card_view.center = self.view.center;
 CGSize card_size = [Utility getCardHeight];
 job_card_view.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - card_size.width)/2, ([UIScreen mainScreen].bounds.size.height - card_size.height)/2, card_size.width, card_size.height);
 
 UIImageView *image_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, card_size.width, card_size.height)];
 if(numberOfItem == 3){
 switch (index) {
 case 0:
 image_view.image = [Utility isComapany]?[UIImage imageNamed:@"Company_Like"]:[UIImage imageNamed:@"Applicant_Like"];
 break;
 case 1:
 image_view.image = [Utility isComapany]?[UIImage imageNamed:@"Company_Pass"]:[UIImage imageNamed:@"Applicant_Pass"];
 break;
 case 2:
 image_view.image = [Utility isComapany]?[UIImage imageNamed:@"Company_Info"]:[UIImage imageNamed:@"Applicant_Info"];
 break;
 }
 }else if(numberOfItem == 2){
 switch (index) {
 case 0:
 image_view.image = [Utility isComapany]?[UIImage imageNamed:@"Company_Pass"]:[UIImage imageNamed:@"Applicant_Pass"];
 break;
 case 1:
 image_view.image = [Utility isComapany]?[UIImage imageNamed:@"Company_Info"]:[UIImage imageNamed:@"Applicant_Info"];
 break;
 }
 }else{
 image_view.image = [Utility isComapany]?[UIImage imageNamed:@"Company_Info"]:[UIImage imageNamed:@"Applicant_Info"];
 }
 [job_card_view addSubview:image_view];
 
 job_card_view.tag = index;
 job_card_view.layer.cornerRadius = 10.0f;
 job_card_view.layer.masksToBounds = YES;
 job_card_view.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15] CGColor];
 job_card_view.layer.borderWidth = 1.0f;
 return job_card_view;
 }*/
- (UIView *)cardContainerViewNextViewWithIndex:(NSInteger)index
{
    NSDictionary *tutorial_data = [[NSUserDefaults standardUserDefaults] valueForKey:@"tutorial_data"];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:APPLICANTCARDVIEW owner:self options:nil];
    ApplicantCardView *job_card_view = (ApplicantCardView *)[topLevelObjects objectAtIndex:0];
    job_card_view.center = self.view.center;
    CGSize card_size = [Utility getCardHeight];
    job_card_view.profile_dictionary = [[tutorial_data valueForKey:@"cards"] objectAtIndex:0];
    job_card_view.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - card_size.width)/2, ([UIScreen mainScreen].bounds.size.height - card_size.height)/2, card_size.width, card_size.height);
    job_card_view.layer.cornerRadius = 10.0f;
    job_card_view.layer.masksToBounds = YES;
    job_card_view.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15] CGColor];
    job_card_view.layer.borderWidth = 1.0f;
    job_card_view.tag = index;
    [job_card_view.table_view reloadData];
    return job_card_view;
}


- (NSInteger)cardContainerViewNumberOfViewInIndex:(NSInteger)index
{
    return numberOfItem;
}


#pragma mark -- YSLDraggableCardContainer Delegate
- (void)cardContainerView:(YSLDraggableCardContainer *)cardContainerView didEndDraggingAtIndex:(NSInteger)index draggableView:(UIView *)draggableView draggableDirection:(YSLDraggableDirection)draggableDirection
{
    if (draggableDirection == YSLDraggableDirectionLeft) {
        [cardContainerView movePositionWithDirection:draggableDirection
                                         isAutomatic:NO];
        numberOfItem = numberOfItem-1;
        //        [self reloadTheContainerView:2];
    }
    if (draggableDirection == YSLDraggableDirectionRight) {
        [cardContainerView movePositionWithDirection:draggableDirection
                                         isAutomatic:NO];
        numberOfItem = numberOfItem-1;
        //     [self reloadTheContainerView:1];
    }
    NSDictionary *tutorial_data = [[NSUserDefaults standardUserDefaults] valueForKey:@"tutorial_data"];
    [self showMatchWindowWithObject:[[tutorial_data valueForKey:@"cards"] objectAtIndex:0]];
}

-(void)showMatchWindowWithObject:(NSDictionary *)dictionary
{
    UIViewController *presentingController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    WRACMatchScreen *controller = [mystoryboard instantiateViewControllerWithIdentifier:@"WRACMatchScreenIdentifier"];
    controller.notification_payload = dictionary;
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [presentingController presentViewController:controller animated:YES completion:nil];
}

- (void)cardContainerViewDidCompleteAll:(YSLDraggableCardContainer *)container;
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [container reloadCardContainer];
    });
}

- (void)cardContainerView:(YSLDraggableCardContainer *)cardContainerView didSelectAtIndex:(NSInteger)index draggableView:(UIView *)draggableView
{
    if(numberOfItem == 1)
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cardContainderView:(YSLDraggableCardContainer *)cardContainderView updatePositionWithDraggableView:(UIView *)draggableView draggableDirection:(YSLDraggableDirection)draggableDirection widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio
{
    //NSLog(@"%f ----------------------- %f",widthRatio,heightRatio);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
