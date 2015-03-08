//
//  SearchTableViewController.h
//  AcronymSearch
//
//  Created by Penchala, Sandeep Kumar on 3/7/15.
//  Copyright (c) 2015 Sandeep. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;

@interface SearchTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    MBProgressHUD *HUD;
}
@property (nonatomic, strong) NSMutableArray *acronyms;



@end
