//
//  SearchTableViewController.m
//  AcronymSearch
//
//  Created by Penchala, Sandeep Kumar on 3/7/15.
//  Copyright (c) 2015 Sandeep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTableViewController.h"
#import "AFNetworking.h"
#import "Acronyms.h"
#import "MBProgressHUD.h"
@interface SearchTableViewController ()

@end
static NSString *baseURL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=";
@implementation SearchTableViewController
@synthesize acronyms = _acronyms;

- (void)viewDidLoad {
    [super viewDidLoad];
    _acronyms = [NSMutableArray new];
    [self addDummyData];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Loading";
    HUD.detailsLabelText = @"updating data";
    HUD.square = YES;

    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _acronyms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"tableViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Acronyms *acronym = [_acronyms objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Abbreviation : %@", [acronym lf]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Since : %@ ,  Freq : %@", [acronym since],[acronym freq]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UISearchDisplayController delegate methods

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self showHUDView];
    [self fetchAcronyms:searchBar.text];
   
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    
}

-(void)fetchAcronyms:(NSString *)input
{
    NSString *string = [baseURL stringByAppendingString:input];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak __typeof(self)weakSelf = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf parseObjects:responseObject];
        [[weakSelf tableView] reloadData];
        [weakSelf removeHUDView];
        [weakSelf.searchDisplayController.searchResultsTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf removeHUDView];
        [self showAlertwithTitle:@"Error" andMessage:@"Some thing went wrong :-("];
        
    }];
    
    [operation start];
}


-(void) parseObjects:(NSDictionary *) response
{
    if([response count])
    {
    _acronyms = [NSMutableArray new];
    NSDictionary *innerDict = [[response objectEnumerator] nextObject];
    NSDictionary *lfsDict = [innerDict objectForKey:@"lfs"];
    for (int i=0; i < lfsDict.count; i++)
    {
        NSDictionary *dict = [[lfsDict objectEnumerator]nextObject];
        [self addAcronymsToArray:dict];
        for (int j = 0; j < [[dict objectForKey:@"vars"] count]; j++)
        {
            NSDictionary *vars = [[[dict objectForKey:@"vars"] objectEnumerator]nextObject];
            [self addAcronymsToArray:vars];
        }
    }
    }
    else
    {
        [self showAlertwithTitle:@"Oops" andMessage:@"No data"];
                              
    }
}

-(void)showAlertwithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:title
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles: nil];
    [alert show];
}

-(void) addAcronymsToArray:(NSDictionary *)dict
{
    Acronyms *acronyms = [[Acronyms alloc]init];
    acronyms.lf = [dict objectForKey:@"lf"];
    acronyms.freq = [dict objectForKey:@"freq"];
    acronyms.since = [dict objectForKey:@"since"];
    [_acronyms addObject:acronyms];

}

-(void)removeHUDView
{
    [HUD show:NO];
    [HUD removeFromSuperview];
}

-(void)showHUDView
{
    [self.view addSubview:HUD];
    [HUD show:YES];
}
-(void) addDummyData
{
    for (int i= 1; i < 10; i++) {
        Acronyms *acronym = [[Acronyms alloc]init];
        acronym.lf = @"sample";
        acronym.since = @"1898";
        acronym.freq = @"12";
        [_acronyms addObject:acronym];
    }
}


@end
