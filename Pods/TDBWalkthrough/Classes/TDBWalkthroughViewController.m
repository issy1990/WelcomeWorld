//
//  TDBWalkThroughViewController.m
//  TDBWalkthrough
//
//  Created by Titouan Van Belle on 24/04/14.
//  Copyright (c) 2014 3dB. All rights reserved.
//

#import "TDBWalkthrough.h"
#import "TDBWalkThroughViewController.h"
#import "TDBInterface.h"

@interface TDBWalkthroughViewController ()

@property (strong, nonatomic) NSMutableArray *viewControllers;

@end

@implementation TDBWalkthroughViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width , self.view.frame.size.height)];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor colorWithRed:62/255.0f green:187/255.0f blue:100/255.0f alpha:1.0f];
        [self.view addSubview:self.scrollView];
        [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-100)];
        self.scrollView.showsVerticalScrollIndicator = NO;
        
       self.get_strated_button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.get_strated_button setBackgroundColor:[UIColor colorWithRed:51/255.0f green:122/255.0f blue:183/255.0f alpha:1.0f]];
        
        int screenHeight =[UIScreen mainScreen].bounds.size.height;
        int buttonWidth = 300;
        int buttonHeight = 50;
        
        switch ((int)screenHeight) {
            case 480:
                buttonWidth = 216;
                buttonHeight = 36;
                break;
            case 568:
                buttonWidth = 255;
                buttonHeight = 43;
                break;
            case 667:
                buttonWidth = 300;
                buttonHeight = 50;
                break;
            case 736:
                buttonWidth = 332;
                buttonHeight = 56;
                break;
        }

        self.get_strated_button.frame = CGRectMake(self.view.frame.size.width/2 - buttonWidth/2, self.view.frame.size.height - 85, buttonWidth, buttonHeight);
        [self.view addSubview:self.get_strated_button];
        [self.get_strated_button addTarget:self action:@selector(getStartedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.get_strated_button.layer.cornerRadius = self.get_strated_button.frame.size.height/2;
        self.get_strated_button.layer.masksToBounds = YES;
        [self.get_strated_button setTitle:@"Get Started" forState:UIControlStateNormal];
        self.get_strated_button.titleLabel.font = [UIFont fontWithName:@"SourceSansPro-Semibold" size:15.0f];
        [self.get_strated_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.view.backgroundColor = [UIColor colorWithRed:62/255.0f green:187/255.0f blue:100/255.0f alpha:1.0f];
    }
    return self;
}

-(void)getStartedButtonAction:(id)sender
{
    [self.walk_through_object getStartedButtonAction:sender];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewControllers = [[NSMutableArray alloc] init];
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Setup Methods

- (void)setupWithClassName:(NSString *)className nibName:(NSString *)nibName images:(NSArray *)images descriptions:(NSArray *)descriptions
{
    // TODO: must depend on the device
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height-100;

    [self.scrollView setBackgroundColor:[UIColor colorWithRed:62/255.0f green:187/255.0f blue:100/255.0f alpha:1.0f]];
    
    NSInteger nbSlides = MAX(images.count, descriptions.count);
    
    for (NSInteger i = 0; i < nbSlides; i++) {
        TDBInterface *slide = [[NSClassFromString(className) alloc] initWithNibName:nibName bundle:nil];
    
        NSString *text = (i >= descriptions.count) ? @"" : [descriptions objectAtIndex:i];
        UIImage *image = (i >= images.count) ? nil : [images objectAtIndex:i];
        [slide setupWithImage:image andText:text];
        
        slide.delegate = [[TDBWalkthrough sharedInstance] delegate];
        
        slide.view.frame = CGRectMake(width * i, 0, width, height);
        
        [self.scrollView addSubview:slide.view];
        
        [self.viewControllers addObject:slide];
    }
    
    self.scrollView.contentSize = CGSizeMake(width * nbSlides, height);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    NSLog(@"*** %d *** %d",page,self.pageControl.numberOfPages);
    if (page == self.pageControl.numberOfPages) {
        [(TDBInterface *)self.viewControllers[page] showButtons];
    }
}


@end
