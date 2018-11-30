//
//  popOverListController.m
//  workruit
//
//  Created by Admin on 10/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "PopOverListController.h"


@interface PopOverListController ()
{
    
}
@end

@implementation PopOverListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)filterTheArrayWithBegen:(NSString *)query
{
    //filterdArray
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:
                               @"SELF BEGINSWITH[cd] %@", query];
    _filterdCountriesArray =[NSMutableArray arrayWithArray:[_allCountriesArray
                                                            filteredArrayUsingPredicate:sPredicate]];
    [_filterdCountriesArray insertObject:[NSString stringWithFormat:@"Add ‘%@’ as a Company",query] atIndex:_filterdCountriesArray.count];
    [self.tableView reloadData];
}

-(void)filterTheArray:(NSString *)query
{
    //filterdArray
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:
                               @"SELF CONTAINS[cd] %@", query];
    _filterdCountriesArray =[NSMutableArray arrayWithArray:[_allCountriesArray
                                                           filteredArrayUsingPredicate:sPredicate]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filterdCountriesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"] ;
    }
    cell.textLabel.text = [_filterdCountriesArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didSelectValue:forIndex:)]) {
        [self.delegate didSelectValue:[_filterdCountriesArray objectAtIndex:indexPath.row] forIndex:(int)indexPath.row];
        self.delegate=nil;
        
    }
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
