//
//  WRJobFunctionViewController.m
//  workruit
//
//  Created by Admin on 7/10/17.
//  Copyright © 2017 Admin. All rights reserved.
//

#import "WRJobFunctionViewController.h"

@interface WRJobFunctionViewController ()
{
    NSMutableArray *categoryNameArr;
    NSInteger expandedSection;
    NSMutableArray *filterdObjectsArr;
    
    NSMutableArray *tagArray;
    NSMutableArray *removedTagsArray;
    
    
    
    ASJTagsView *tagsViewTemp;
    IBOutlet UIView * myView;

    
}

@end

@implementation WRJobFunctionViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     NSMutableArray *params = nil;
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
    
    //Setting the table view footer view to zeero
    self.table_view.tableFooterView = [Utility borderLineWithWidth:self.view.frame.size.width];
    self.table_view.tableHeaderView = [Utility borderLineWithWidth:self.view.frame.size.width];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.table_view setSeparatorColor:DividerLineColor];
    self.headerLbl.text = @"Choose Your Role";
    self.messageLbl.hidden = NO;
    self.messageLbl.text = @"Select up-to 3 job functions.";
    self.topConstrant.constant = 40;
    
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
-(IBAction)previousButtonAction:(id)sender
{
        [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = MULTIPLE_SELECTION_CELL_IDENTIFIER;
    MultipleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:MULTIPLE_SELECTION_CELL owner:self options:nil];
        cell = (MultipleSelectionCell *)[topLevelObjects objectAtIndex:0];
    }
    
    
    
    cell.titleLbl.text = @"Job Function";
    cell.titleLbl.text = [[self.mutableArray objectAtIndex:indexPath.row] valueForKey:@"jobFunctionName"];


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

-(NSMutableArray *)checkCountInArray
{
    NSMutableArray *selected_industies = [[NSMutableArray alloc] initWithCapacity:3];
    for(NSMutableDictionary *dictionary in self.mutableArray)
        if([[dictionary valueForKey:@"isSelected"] intValue] == 1)
            [selected_industies addObject:dictionary];
    return selected_industies;
}
-(IBAction)nextButtonForProcess:(id)sender
{
if(self.isCommingFromEditApplicant)
{
    if([[self checkCountInArray] count] >= 1 && [[self checkCountInArray] count] <= 3){
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"jobfunctions"];
        [self.navigationController popViewControllerAnimated:YES];
    }else
        [CustomAlertView showAlertWithTitle:@"Error" message:@"Please select minimum of 1 or maximum of 3 job functions." OkButton:@"Ok" delegate:self];
    return;
}
    
    if([[self checkCountInArray] count] >= 1){
        [[ApplicantHelper sharedInstance].paramsDictionary setObject:[self checkCountInArray] forKey:@"jobfunctions"];
        [[ApplicantHelper sharedInstance] updateJobFunctionsServer:self requestType:100];
    }else
        [CustomAlertView showAlertWithTitle:@"Error" message:@"Please select minimum of 1 or maximum of 3 job functions." OkButton:@"Ok" delegate:self];
}
-(void)didReceivedResponseWithData:(NSDictionary *)data forTag:(int)tag
{
    if(tag == 100){
        
        
        
        NSString *firstname = [[NSUserDefaults standardUserDefaults]
                               valueForKey:FIRST_NAME_KEY];
        NSString *registrationId = [[NSUserDefaults standardUserDefaults]
                                    valueForKey:APPLICANT_REGISTRATION_ID];
        
        
        NSString *userName = [NSString stringWithFormat:@"%@_%@",firstname,registrationId];
        
        
        [Utility getMixpanelData:APPLICANT_SIGNUP_JOBFUNCTION setProperties:userName];
       
      
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:APPLICANT_STORYBOARD bundle:nil];
        WRSkillsViewController *controller1 = [mystoryboard instantiateViewControllerWithIdentifier:WRSKILLS_VIEWCONTROLLER_IDENTIFIER];
        NSString *valueToSave = @"skillsView";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"screen"];
           [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"responseData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController pushViewController:controller1 animated:YES];
    }
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
