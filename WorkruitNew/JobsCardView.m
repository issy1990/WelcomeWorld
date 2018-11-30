//
//  JobsCardView.m
//  Workruit
//
//  Created by Admin on 9/24/16.
//  Copyright © 2016 Admin. All rights reserved.
//
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#import "JobsCardView.h"


@implementation JobsCardView
 NSMutableArray *profilesForJobsArray;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    //NSLog(@"------ %f %f -------",self.frame.size.height,self.frame.size.width);
    
   
    // Initialization code
    self.table_view.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
}

-(void)reloadViewData{
    [self.table_view reloadData];
    //NSLog(@"------ %f %f -------",self.frame.size.height,self.frame.size.width);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        if (SCREEN_HEIGHT == 568) {
            return self.frame.size.height *47/100;
        }
        else{
            return self.frame.size.height *46/100;
        }
       else
        return self.frame.size.height *18/100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        static NSString *cellIdentifier = JOBCARD_HEADER_CELL_NEW_IDENTIFIER;
        //JOBCARD_HEADER_CELL_IDENTIFIER;
        JobCardHeaderCellNew *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARD_HEADER_CELL owner:self options:nil];
            cell = (JobCardHeaderCellNew *)[topLevelObjects objectAtIndex:0];
        }
        
        // Suggested/Recommended/Intersetsed Tags
        if([[self.profile_dictionary valueForKey:@"isInterested"] boolValue])
        {
            cell.intrestedBtn.hidden = NO;
            [cell.intrestedBtn setTitle:@"Interested" forState:UIControlStateNormal];
            [cell.intrestedBtn setBackgroundColor:[UIColor colorWithRed:40/255.0 green:100/255.0 blue:168/255.0 alpha:1]];
            
            if ([[self.profile_dictionary valueForKeyPath:@"suggested.suggested"] boolValue])
            {
              //  cell.recommededBtn.hidden = NO;
               // [cell.recommededBtn setTitle:@"Suggested" forState:UIControlStateNormal];
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
               // cell.intrestedBtn.hidden = NO;
               // [cell.intrestedBtn setTitle:@"Suggested" forState:UIControlStateNormal];
            }
            else if ([[self.profile_dictionary valueForKeyPath:@"recommended.recommended"] boolValue])
            {
                //cell.intrestedBtn.hidden = NO;
               // [cell.intrestedBtn setTitle:@"Recommended" forState:UIControlStateNormal];
            }
            else
            {
                cell.intrestedBtn.hidden = YES;
            }
        }
        
        [cell.profile_image sd_setImageWithURL:[NSURL URLWithString:[Utility getFormatedURL:[self.profile_dictionary valueForKeyPath:@"pic"]]] placeholderImage:[UIImage imageNamed:@"aplicant_placeholder"]];
                
//        cell.nameLbl.text = [self.profile_dictionary valueForKey:@"userJobTitle"];
        
        cell.nameLbl.text =[NSString stringWithFormat:@"%@ (%@)",[self.profile_dictionary valueForKey:@"firstname"],[self.profile_dictionary valueForKey:@"userJobTitle"]];
        
        cell.designationLbl.text = [Utility getJobFunctions:[self.profile_dictionary valueForKey:@"jobFunctions"]];
      //  cell.designationLbl.text =[cell.designationLbl.text uppercaseString ];
        
        cell.yearLbl.text = [NSString stringWithFormat:@"%@",[self.profile_dictionary valueForKey:@"totalExperienceText"]];
        cell.locationLbl.text = [self.profile_dictionary valueForKey:@"location"];
       
        if([[self.profile_dictionary valueForKey:@"hideSalary"] boolValue])
            cell.packageLbl.text = @"- ₹ -";
        else
            cell.packageLbl.text = [NSString stringWithFormat:@"₹ %@L - %@L",[self.profile_dictionary valueForKey:@"minSalaryExp"],[self.profile_dictionary valueForKey:@"maxSalaryExp"]];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
        
    }
    else if(indexPath.row ==1||indexPath.row==2){
        JobCardCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:JOBCARD_CUSTOM_CELL_IDENTIFIER];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:JOBCARD_CUSTOM_CELL owner:self options:nil];
            cell = (JobCardCustomCell *)[topLevelObjects objectAtIndex:0];
        }
        if(indexPath.row == 1)
        {
            if([[self.profile_dictionary valueForKey:@"userExperienceSet"] count] > 0){
                cell.expLbl.text = @"EXPERIENCE";
                cell.roleLbl.text = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:0]valueForKey:@"company"];
                cell.designationLbl.text = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:0] valueForKey:@"jobTitle"];
            
                NSString *startDate = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:0] valueForKey:@"startDate"];
                startDate = [Utility getStringWithDate:startDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                NSString *endDate = [[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:0] valueForKey:@"endDate"];
                endDate = [Utility getStringWithDate:endDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];

                if([[[[self.profile_dictionary valueForKey:@"userExperienceSet"] objectAtIndex:0] valueForKey:@"isPresent"] boolValue])
                        cell.dateLbl.text = [NSString stringWithFormat:@"%@ - Present",startDate];
                    else
                        cell.dateLbl.text = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];
                
                cell.place_holder.hidden = YES;
                cell.expLbl.hidden = NO;
                cell.roleLbl.hidden = NO;
                cell.designationLbl.hidden = NO;
                cell.dateLbl.hidden = NO;

            }else{
                cell.place_holder.hidden = NO;
                cell.place_holder.text = @"No work experience provided.";
                
                cell.expLbl.hidden = YES;
                cell.roleLbl.hidden = YES;
                cell.designationLbl.hidden = YES;
                cell.dateLbl.hidden = YES;
            }
        }else if(indexPath.row == 2){
            cell.expLbl.text = @"EDUCATION";
            
            if([[self.profile_dictionary valueForKey:@"userEducationSet"] count] > 0){
                
                cell.roleLbl.text = [NSString stringWithFormat:@"%@",[[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:0] valueForKey:@"institution"]];
                
                cell.designationLbl.text = [NSString stringWithFormat:@"%@ - %@",[[[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:0] valueForKey:@"degree"] valueForKey:@"shortTitle"],[[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:0] valueForKey:@"fieldOfStudy"]];
                
                NSString *startDate = [[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:0] valueForKey:@"startDate"];
                startDate = [Utility getStringWithDate:startDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                
                NSString *endDate = [[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:0] valueForKey:@"endDate"];
                
                endDate = [Utility getStringWithDate:endDate withOldFormat:@"MM-yyyy" newFormat:@"MMM yyyy"];
                
                if([[[[self.profile_dictionary valueForKey:@"userEducationSet"] objectAtIndex:0] valueForKey:@"isPresent"] boolValue])
                        cell.dateLbl.text = [NSString stringWithFormat:@"%@ - Present",startDate];
                    else
                        cell.dateLbl.text = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];
                
                cell.place_holder.hidden = YES;
                cell.expLbl.hidden = NO;
                cell.roleLbl.hidden = NO;
                cell.designationLbl.hidden = NO;
                cell.dateLbl.hidden = NO;
                
            }else{
                cell.place_holder.hidden = NO;
                cell.place_holder.text = @"No education provided.";
                
                cell.expLbl.hidden = YES;
                cell.roleLbl.hidden = YES;
                cell.designationLbl.hidden = YES;
                cell.dateLbl.hidden = YES;
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    }
    else{
        
        JobCardSkillsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JOBCARD_SKILLS_CELL_IDENTIFIER_Card"];
        if (nil == cell)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JobCardSkills_Card" owner:self options:nil];
            cell = (JobCardSkillsCell *)[topLevelObjects objectAtIndex:0];
        }
        cell.skillsLable.text = [self getSkillStringArray:[self.profile_dictionary valueForKey:@"userSkillsSet"]];
        cell.skillsLable.textAlignment = NSTextAlignmentLeft;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        }
}
-(NSString *)getSkillStringArray:(NSMutableArray *)array
{
    NSMutableString *skill = [[NSMutableString alloc] init];
    for(NSDictionary *dict in array)
    {
        if([[[array lastObject]valueForKey:@"title"] isEqualToString:[dict valueForKey:@"title"]])
        {
            [skill appendFormat:@"%@",[dict valueForKey:@"title"]];
        }else{
            [skill appendFormat:@"%@ • ",[dict valueForKey:@"title"]];
        }
    }
    return skill;
}
@end
