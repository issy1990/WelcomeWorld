//
//  ApplicantCardView.m
//  workruit
//
//  Created by Admin on 11/22/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#import "ApplicantCardView.h"
#import "HeaderFiles.h"

@implementation ApplicantCardView
@synthesize imageView;
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)awakeFromNib
{
    [super awakeFromNib];
    CGSize card_size = [Utility getCardHeight];
    
    self.table_view = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, card_size.width, card_size.height) style:UITableViewStylePlain];
    self.table_view.scrollEnabled = NO;
    self.table_view.delegate = self;
    self.table_view.dataSource = self;
    self.table_view.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.table_view];
    self.table_view.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self performSelector:@selector(reloadViewData) withObject:self afterDelay:0.5f];
    
    self.likeTickImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 96, 96)];
    self.likeTickImage.alpha = 0.0f;
    self.likeTickImage.image = [UIImage imageNamed:@"like_icon"];
    [self addSubview:self.likeTickImage];
    
    self.passTickImage = [[UIImageView alloc] initWithFrame:CGRectMake(card_size.width-106, 10, 96, 96)];
    self.passTickImage.alpha = 0.0f;
    self.passTickImage.image = [UIImage imageNamed:@"pass_icon"];
    [self addSubview:self.passTickImage];
    
    
    self.imageView.hidden = YES;
    [self addSubview:self.imageView];
    [self startAnim];
    
    UIGestureRecognizer *viewReongnizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(expandActivity:)];
    [self addGestureRecognizer:viewReongnizer];
    
}
-(void)expandActivity:(UITapGestureRecognizer *)sender {
    
    [self.imageView removeFromSuperview];
    
}
+ (NSString *)extractNumberFromText:(NSString *)text
{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet controlCharacterSet] invertedSet];
    return [[text componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}
-(void)reloadViewData
{
    [self.table_view reloadData];
    
    //NSLog(@"------ %f %f -------",self.frame.size.height,self.frame.size.width);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        if (SCREEN_HEIGHT == 568)
            return self.frame.size.height *58/100;
        else
            return self.frame.size.height *55/100;
        else  if(indexPath.row == 1)
            return self.frame.size.height *20/100;
        else
            return self.frame.size.height *25/100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        static NSString *cellIdentifier = JOBCARD_HEADER_CELL_IDENTIFIER;
        JobCardHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARD_HEADER_CELL owner:self options:nil];
            cell = (JobCardHeaderCell *)[topLevelObjects objectAtIndex:0];
        }
        
        if (![[self.profile_dictionary valueForKey:@"external_jobs"]isEqualToString:@"1"])
        {
            cell.view_constrant.constant = 60;
            cell.jobsite.hidden = YES;
            
            // Suggested/Recommended/Intersetsed Tags
            if([[self.profile_dictionary valueForKey:@"isInterested"] boolValue])
            {
                [cell.intrestedBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:100/255.0 blue:168/255.0 alpha:1]];
                
                cell.intrestedBtn.hidden = NO;
                [cell.intrestedBtn setTitle:@"Interested" forState:UIControlStateNormal];
                
                if ([[self.profile_dictionary valueForKeyPath:@"suggested.suggested"] boolValue])
                {
                   // cell.recommededBtn.hidden = NO;
                   ////// [cell.recommededBtn setTitle:@"Suggested" forState:UIControlStateNormal];
                }
                else if ([[self.profile_dictionary valueForKeyPath:@"recommended.recommended"] boolValue])
                {
                   // cell.recommededBtn.hidden = NO;
                   // [cell.recommededBtn setTitle:@"Recommended" forState:UIControlStateNormal];
                }
                else
                {
                    cell.recommededBtn.hidden = YES;
                }
            }
            else
            {
                cell.intrestedBtn.hidden = YES;

                
                [cell.intrestedBtn setBackgroundColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:182/255.0 alpha:1]];

                cell.recommededBtn.hidden = YES;
                
                if ([[self.profile_dictionary valueForKeyPath:@"suggested.suggested"] boolValue])
                {
                  //  cell.intrestedBtn.hidden = NO;
                  //  [cell.intrestedBtn setTitle:@"Suggested" forState:UIControlStateNormal];
                }
                else if ([[self.profile_dictionary valueForKeyPath:@"recommended.recommended"] boolValue])
                {
                   // cell.intrestedBtn.hidden = NO;
                   // [cell.intrestedBtn setTitle:@"Recommended" forState:UIControlStateNormal];
                }
                else
                {
                    cell.intrestedBtn.hidden = YES;
                }
            }
            
            NSDate *date = [Utility getDateWithStringDate:[self.profile_dictionary valueForKey:@"createdDate"] withFormat:@"MMM yyyy dd hh:mm a"];
            NSString *dateWithDays = [Utility getAgoTimeIntervalInString:date];
            NSString *compareString = [NSString stringWithFormat:@"%@ - %@ years", [self.profile_dictionary valueForKeyPath:@"experienceMin"],[self.profile_dictionary valueForKeyPath:@"experienceMax"]];
            
            if([compareString  isEqualToString:@"-1 - -1 years"])
            {
                cell.datePostedLbl.text  =[NSString stringWithFormat:@"%@ - (Posted Today)",[self.profile_dictionary valueForKeyPath:@"jobType.jobTypeTitle"]] ;
                cell.profile_image.image = [UIImage imageNamed:@"app_icon_image"];
            }
            else{
                cell.datePostedLbl.text = [NSString stringWithFormat:@"%@ - (Posted %@)",[self.profile_dictionary valueForKeyPath:@"jobType.jobTypeTitle"],dateWithDays];
                
                [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"company.picture"]]]
                                      placeholderImage:[UIImage imageNamed:@"company_placeholder"]
                                               options:SDWebImageRefreshCached];
            }
            
            NSString *profile_url = [self.profile_dictionary valueForKeyPath:@"company.pic"];
            if (profile_url == nil){
                profile_url = [self.profile_dictionary valueForKeyPath:@"company.picture"];
            }
            
            [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:profile_url]] placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]];

            //companyName
            cell.nameLbl.text = [self.profile_dictionary valueForKeyPath:@"title"];
            
            NSString * industies = [self getCompanyStringArray:[self.profile_dictionary valueForKeyPath:@"company.companyIndustriesSet"]];
            cell.companyProfileLbl.text = industies;
            
          
            cell.designationLbl.text = [self.profile_dictionary valueForKeyPath:@"company.companyName"];
            
            if([[self.profile_dictionary valueForKeyPath:@"jobType.jobTypeTitle"] isEqualToString:@"Internship"])
            {
                NSString *start_date =[Utility getStringWithDate:[self.profile_dictionary valueForKeyPath:@"startDate"] withOldFormat:@"MMM yyyy" newFormat:@"MMM"];
                
                NSString *end_date = [self.profile_dictionary valueForKeyPath:@"endDate"];
                end_date = [Utility getStringWithDate:[self.profile_dictionary valueForKeyPath:@"endDate"] withOldFormat:@"MMM yyyy" newFormat:@"MMM yy"];
                
                cell.yearLbl.text = [NSString stringWithFormat:@"%@ - %@", start_date,end_date];
            }else{
                
                NSString *compareString = [NSString stringWithFormat:@"%@ - %@ years", [self.profile_dictionary valueForKeyPath:@"experienceMin"],[self.profile_dictionary valueForKeyPath:@"experienceMax"]];
                
                if([compareString  isEqualToString:@"-1 - -1 years"])
                {
                    cell.yearLbl.text = @"1 - 20 years";
                    self.imageView.hidden = NO;
                }
                else{
                    cell.yearLbl.text = compareString;
                    self.imageView.hidden = YES;
                }
            }
            
            
            cell.locationLbl.text = [self.profile_dictionary valueForKeyPath:@"location.title"];
            
            if([[self.profile_dictionary valueForKeyPath:@"unpaid"] boolValue]){
                cell.packageLbl.text = @"Unpaid";
            } else if(![[self.profile_dictionary valueForKeyPath:@"unpaid"] boolValue] && [[self.profile_dictionary valueForKeyPath:@"hideSalary"] boolValue])
                cell.packageLbl.text = @"-- ₹ --";
            else
                cell.packageLbl.text = [NSString stringWithFormat:@"₹ %@L - %@L", [self.profile_dictionary valueForKeyPath:@"salaryMin"],[self.profile_dictionary valueForKeyPath:@"salaryMax"]];
        }
        else
        {
            cell.jobsite.hidden = NO;
            cell.view_constrant.constant = 60;
            cell.view_constrant.constant = 60;
            cell.intrestedBtn.hidden = YES;
            cell.recommededBtn.hidden = YES;
            
            //companyName
            cell.nameLbl.text = [self.profile_dictionary valueForKeyPath:@"title"];
            
            if ([self.profile_dictionary valueForKeyPath:@"industry"]!=nil&&![[self.profile_dictionary valueForKeyPath:@"industry"]isEqualToString:@""]) {
                cell.companyProfileLbl.text = [self.profile_dictionary valueForKeyPath:@"industry"];
            }else{
                cell.companyProfileLbl.text=@"--";
            }
            cell.designationLbl.text = [self.profile_dictionary valueForKeyPath:@"company"];
            
            NSString * locStr= [self.profile_dictionary valueForKeyPath:@"location"];
            cell.locationLbl.text =locStr;
            
if ([self.profile_dictionary valueForKey:@"salary"] != nil && ![[self.profile_dictionary valueForKey:@"salary"] isEqual:@""]&& ![[self.profile_dictionary valueForKey:@"salary"] isEqual:@"nil"])
    {
        NSArray * dataArray =[[self.profile_dictionary valueForKeyPath:@"salary"] componentsSeparatedByString:@" "];
                
                if ([[self.profile_dictionary valueForKeyPath:@"salary"]isEqualToString:@"Not disclosed"]||[[self.profile_dictionary valueForKeyPath:@"salary"]isEqualToString:@"Negotiable"]||[[self.profile_dictionary valueForKeyPath:@"salary"]isEqualToString:@"Not Disclosed by Recruiter"]||[[self.profile_dictionary valueForKeyPath:@"salary"]isEqualToString:@"no"])
                {
                    cell.packageLbl.text = [self.profile_dictionary valueForKeyPath:@"salary"];
                }
                else
                {
                    NSString * str, *str1;
                    if ([dataArray count] ==2) {
                        str =[dataArray objectAtIndex:0];
                        str1=[dataArray objectAtIndex:1];
                        NSString * subStr =[str substringFromIndex:1];
                        NSString * subStr1 =[str1 substringFromIndex:1];
                        
                        int myint = [subStr intValue];
                        int myint1 = [subStr1 intValue];
                        
                        NSString *intWithK = myint >= 1000 ? [NSString stringWithFormat:@"%dk", myint / 1000] : [NSString stringWithFormat:@"%ld", (long)myint];
                        NSString *intWithK1 = myint1 >= 1000 ? [NSString stringWithFormat:@"%dk", myint1 / 1000] : [NSString stringWithFormat:@"%ld", (long)myint1];
                        
                        NSString * total =[NSString stringWithFormat:@"%@K - %@K",intWithK,intWithK1];
                        if ([total isEqualToString:@"0K - 0K"])
                        {
                            cell.packageLbl.text =@"Not disclosed";
                        }
                        else{
                            cell.packageLbl.text = [self.profile_dictionary valueForKeyPath:@"salary"];
                        }
                    }
                    else{
                        cell.packageLbl.text = [self.profile_dictionary valueForKeyPath:@"salary"];
                    }
                }
            }
            else
            {
                cell.packageLbl.text = @"--";
            }
            
            if ([self.profile_dictionary valueForKeyPath:@"experience"] !=nil&&![[self.profile_dictionary valueForKeyPath:@"experience"] isEqual:@""])
            {
                cell.yearLbl.text = [NSString stringWithFormat:@"%@", [self.profile_dictionary valueForKeyPath:@"experience"]];
            }
            else{
                cell.yearLbl.text = @"--";
            }
            
            if ([self.profile_dictionary valueForKeyPath:@"postedOn"] !=nil)
            {
                if ([self.profile_dictionary valueForKey:@"employmentType"] ==nil)
                {
                     cell.datePostedLbl.text  =[NSString stringWithFormat:@"Fulltime - (Posted %@)",[self.profile_dictionary valueForKeyPath:@"postedOn"]] ;
                }
                else{
                     cell.datePostedLbl.text  =[NSString stringWithFormat:@"%@ - (Posted %@)",[self.profile_dictionary valueForKey:@"employmentType"],[self.profile_dictionary valueForKeyPath:@"postedOn"]] ;
                }
            }
            else{
                cell.datePostedLbl.text = [NSString stringWithFormat:@"Fulltime - (Posted %@)",@"NA"];
            }
            
            cell.jobsite.hidden = NO;
            
            cell.jobsite.text= [NSString stringWithFormat:@"Job via %@",[self.profile_dictionary valueForKeyPath:@"website"]];
            
            NSMutableAttributedString *text =[[NSMutableAttributedString alloc]initWithAttributedString: cell.jobsite.attributedText];
            
            if ([[self.profile_dictionary valueForKeyPath:@"website"] isEqualToString:@"indeed"]) {
                [text addAttribute:NSForegroundColorAttributeName
                             value:UIColorFromRGB(0x1D5AF1)
                             range:NSMakeRange(8, cell.jobsite.text.length - 8)];
            }
            else if ([[self.profile_dictionary valueForKeyPath:@"website"] isEqualToString:@"monster"]) {
                [text addAttribute:NSForegroundColorAttributeName
                             value:UIColorFromRGB(0x534698)
                             range:NSMakeRange(8, cell.jobsite.text.length - 8)];
            }
            else if ([[self.profile_dictionary valueForKeyPath:@"website"] isEqualToString:@"naukri"]) {
                [text addAttribute:NSForegroundColorAttributeName
                             value:UIColorFromRGB(0x25A1DD)
                             range:NSMakeRange(8, cell.jobsite.text.length - 8)];
            }
            else if ([[self.profile_dictionary valueForKeyPath:@"website"] isEqualToString:@"timesJob"])
            {
                
                text = [[NSMutableAttributedString alloc]initWithAttributedString: cell.jobsite.attributedText];
                
                [text addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x000000) range:NSMakeRange(8,cell.jobsite.text.length - 8)];
                
                [text addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFF0004) range:NSMakeRange(13,2)];
            }
            [cell.jobsite setAttributedText: text];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.row==1)
    {
        JobCardSkillsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JOBCARD_SKILLS_CELL_IDENTIFIER_Card"];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JobCardSkills_Card" owner:self options:nil];
            cell = (JobCardSkillsCell *)[topLevelObjects objectAtIndex:0];
        }
        
        if (![[self.profile_dictionary valueForKey:@"external_jobs"]isEqualToString:@"1"])
        {
            cell.skillsLable.text = [self getSkillStringArray:[self.profile_dictionary valueForKey:@"skills"]];
        }
        else
        {
            if ([self.profile_dictionary valueForKey:@"skills"]!=nil&&![[self.profile_dictionary valueForKeyPath:@"skills"] isEqualToString:@""])
            {
                NSString * strData =[self.profile_dictionary valueForKey:@"skills"];
                NSMutableArray * array = [[strData componentsSeparatedByString:@","] mutableCopy];
                cell.skillsLable.text = [self getSkillStringArray:array];
            }
            else{
                cell.skillsLable.text =@"--";
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        JobCardTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JOBCARD_TEXTVIEW_CELL_IDENTIFIER];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JobCardTextViewCell_Card" owner:self options:nil];
            cell = (JobCardTextViewCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.text_view.editable = NO;
        cell.text_view.scrollEnabled = NO;
        
        if (![[self.profile_dictionary valueForKey:@"external_jobs"]isEqualToString:@"1"])
        {
            cell.text_view.text = [self.profile_dictionary valueForKey:@"description"];
        }
        else{
            if ([self.profile_dictionary valueForKey:@"summary"]!=nil&&![[self.profile_dictionary valueForKey:@"summary"]isEqualToString:@""])
            {
                cell.text_view.text = [self.profile_dictionary valueForKey:@"summary"];
            }
            else
            {
                cell.text_view.text =@"--";
            }
        }
        
        cell.text_view.textContainer.maximumNumberOfLines = 3;
        cell.text_view.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

-(NSString *)getSkillStringArray:(NSMutableArray *)array
{
    NSMutableString *skill = [[NSMutableString alloc] init];
    for(NSString *string in array){
        if([[array lastObject] isEqualToString:string]){
            [skill appendFormat:@"%@",string];
        }else{
            [skill appendFormat:@"%@ • ",string];
        }
    }
    return skill;
}


-(NSString *)getCompanyStringArray:(NSMutableArray *)array
{
    NSMutableString *skill = [[NSMutableString alloc] init];
    
    for(int i = 0; i < [array count]; i++){
        NSMutableDictionary *dictionary = [array objectAtIndex:i];
        if([[array lastObject] isEqual:dictionary])
            [skill appendFormat:@"%@",[dictionary valueForKeyPath:@"industry.industryName"]];
        else
            [skill appendFormat:@"%@, ",[dictionary valueForKeyPath:@"industry.industryName"]];
    }
    return skill;
}

static NSInteger count = 0;
//static NSInteger maxBlind = 1000000;

- (void)startAnim
{
    CGFloat animDuration = 1.0f;
    [UIView animateWithDuration:animDuration
                     animations:^{
                         self.imageView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:animDuration
                                          animations:^{
                                              self.imageView.alpha = 1.f;
                                          } completion:^(BOOL finished) {
                                              
                                              [self startAnim];
                                              count++;
                         }];
                     }];
}

@end

