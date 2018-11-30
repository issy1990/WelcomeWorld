//
//  ChooseCompanyIndustry.m
//  workruit
//
//  Created by Admin on 10/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "WRChooseCompanyIndustry.h"
#import "WRAddExperianceController.h"
#import "WRSkillsViewController.h"

@interface WRChooseCompanyIndustry ()
{
}
@end

@implementation WRChooseCompanyIndustry
{
    IBOutlet UIView * myView;

}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backButton.hidden = self.isBackButtonHide;
    
    if(self.isCommingFromEditApplicant || self.isNextButtonHide){
        self.nextButton.hidden = NO;
        [self.nextButton setImage:nil forState:UIControlStateNormal];
        [self.nextButton setTitle:@"Save" forState:UIControlStateNormal];
        
    }

    NSMutableArray *params = nil;
    if([Utility isComapany]){
        self.mutableArray = [CompanyHelper getArrayWithParentKey:@"industries"];
        params = [[[CompanyHelper sharedInstance] getParamsObject] valueForKey:@"companyIndustriesSet"];
        for (NSMutableDictionary *dictionary1  in self.mutableArray)
            for (NSMutableDictionary *dictionary  in params)
                if ([[dictionary valueForKey:@"industryId"] intValue] == [[dictionary1 valueForKey:@"industryId"] intValue]){
                    [dictionary1 setObject:@"1" forKey:@"isSelected"];
                    break;
                }
                else
                    [dictionary1 setObject:@"0" forKey:@"isSelected"];
    }
    else{
        self.mutableArray = [CompanyHelper getArrayWithParentKey:@"jobFunctions"];
        params = [[ApplicantHelper sharedInstance].paramsDictionary valueForKey:@"jobfunctions"];
        
        for (NSMutableDictionary *dictionary1  in self.mutableArray)
            for (NSMutableDictionary *dictionary  in params)
                if ([[dictionary valueForKey:@"jobFunctionId"] intValue] == [[dictionary1 valueForKey:@"jobFunctionId"] intValue]){
                    [dictionary1 setObject:@"1" forKey:@"isSelected"];
                    break;
                }
                else
                    [dictionary1 setObject:@"0" forKey:@"isSelected"];

    }

    //Setting the table view footer view to zeero
    self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    
    if([Utility isComapany]){
        self.headerLbl.text = @"Choose Industry";
        self.messageLbl.hidden = NO;
        self.messageLbl.text = @"Please select up-to 3 industries.";
        self.topConstrant.constant = 40;
    }else{
        self.headerLbl.text = @"Choose Your Role";
        self.messageLbl.hidden = NO;
        self.messageLbl.text = @"Select up-to 3 job functions.";
        self.topConstrant.constant = 40;
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"saveJobSkills"];

    }
    [Utility setThescreensforiPhonex:myView];


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mutableArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = MULTIPLE_SELECTION_CELL_IDENTIFIER;
    MultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MULTIPLE_SELECTION_CELL owner:self options:nil];
        cell = (MultipleSelectionCell *)[topLevelObjects objectAtIndex:0];
    }
    if([Utility isComapany]){
        cell.titleLbl.text = @"Industry";
        cell.titleLbl.text = [[self.mutableArray objectAtIndex:indexPath.row] valueForKey:@"industryName"];
    }
    else{
        cell.titleLbl.text = @"Job Function";
        cell.titleLbl.text = [[self.mutableArray objectAtIndex:indexPath.row] valueForKey:@"jobFunctionName"];
    }
    
    if([[[self.mutableArray objectAtIndex:indexPath.row] valueForKey:@"isSelected"] intValue] == 1)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self checkCountInArray] .count >= 3){
        [[self.mutableArray objectAtIndex:indexPath.row] setObject:@"0" forKey:@"isSelected"];
        [tableView reloadData];
    
        if([self checkCountInArray].count == 3)
            [CustomAlertView showAlertWithTitle:@"Message" message:[Utility isComapany]?@"Please select minimum of 1 or maximum of 3 industries.":@"Please select minimum of 1 or maximum of 3 job functions." OkButton:@"Ok" delegate:self];

        return;
    }
    
    if([[[self.mutableArray objectAtIndex:indexPath.row] valueForKey:@"isSelected"] intValue] == 1)
        [[self.mutableArray objectAtIndex:indexPath.row] setObject:@"0" forKey:@"isSelected"];
    else
        [[self.mutableArray objectAtIndex:indexPath.row] setObject:@"1" forKey:@"isSelected"];
    
        [tableView reloadData];
}

-(IBAction)nextButtonForProcess:(id)sender
{
    if(self.isCommingFromEditApplicant){
        if([[self checkCountInArray] count] >= 1 && [[self checkCountInArray] count] <= 3){
                [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"jobfunctions"];
                [self.navigationController popViewControllerAnimated:YES];
        }else
                [CustomAlertView showAlertWithTitle:@"Error" message:@"Please select minimum of 1 or maximum of 3 job functions." OkButton:@"Ok" delegate:self];
        return;
    }else if(self.isNextButtonHide){
        
        if([[self checkCountInArray] count] >= 1 && [[self checkCountInArray] count] <= 3){
            [[CompanyHelper sharedInstance].params setObject:[self checkCountInArray] forKey:@"companyIndustriesSet"];
            [self.navigationController popViewControllerAnimated:YES];
        }else
            [CustomAlertView showAlertWithTitle:@"Error" message:@"Please select minimum of 1 or maximum of 3 industries." OkButton:@"Ok" delegate:self];
        
        return;
    }
        
    
    
    if([Utility isComapany]){
        if([[self checkCountInArray] count] >= 1){
            //Set the params
            [[CompanyHelper sharedInstance].params setObject:[self checkCountInArray] forKey:COMAPNY_INDUSTRIES_SET_KEY];

            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:COMPANY_STORYBOARD bundle:nil];
            WREditCompanyProfile *edit_profile_controller = [mystoryboard instantiateViewControllerWithIdentifier:WREDIT_COMPANY_PROFILE_IDENTIFIER];
            edit_profile_controller.isSignUpProcess = YES;
            [self.navigationController pushViewController:edit_profile_controller animated:YES];
            
        }else
            [CustomAlertView showAlertWithTitle:@"Error" message:@"Please select minimum of 1 or maximum of 3 industries." OkButton:@"Ok" delegate:self];
        
    }else{
        if([[self checkCountInArray] count] >= 1){
            [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"jobfunctions"];
            [[ApplicantHelper sharedInstance] updateJobFunctionsServer:self requestType:100];
        }else
            [CustomAlertView showAlertWithTitle:@"Error" message:@"Please select minimum of 1 or maximum of 3 job functions." OkButton:@"Ok" delegate:self];
    }
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 100){
        
        if ([Utility isComapany]) {
            [FireBaseAPICalls captureMixpannelEvent:COMPANY_INDUSTRIES];
        }else{
            [FireBaseAPICalls captureMixpannelEvent:APPLICANT_JOB_FUNCTION];
        }

        if([[data valueForKey:@"percentage"] floatValue] > 0)
            [ApplicantHelper sharedInstance].profilePercentage = [[data valueForKey:@"percentage"] floatValue];

        [ApplicantHelper sharedInstance].halfProfile = [[data valueForKey:@"halfProfile"] boolValue];
        
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRSkillsViewController *controller1 = [mystoryboard instantiateViewControllerWithIdentifier:WRSKILLS_VIEWCONTROLLER_IDENTIFIER];
        [self.navigationController pushViewController:controller1 animated:YES];
    }
}

-(IBAction)previousButtonAction:(id)sender
{
    if(self.isCommingFromEditApplicant || self.isNextButtonHide) {
            [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [[CompanyHelper sharedInstance].params setObject:[self checkCountInArray] forKey:@"companyIndustriesSet"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSMutableArray *)checkCountInArray
{
    NSMutableArray *selected_industies = [[NSMutableArray alloc] initWithCapacity:3];
    for(NSMutableDictionary *dictionary in self.mutableArray)
        if([[dictionary valueForKey:@"isSelected"] intValue] == 1)
            [selected_industies addObject:dictionary];
    return selected_industies;
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
