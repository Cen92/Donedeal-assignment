//
//  ViewController.m
//  DoneDeal Assignment
//
//  Created by Cionnat Breathnach on 05/04/2014.
//  Copyright (c) 2014 Cionnat Breathnach. All rights reserved.
//

#import "BeerTableViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface BeerTableViewController ()
@property (strong, nonatomic) NSMutableArray *beerArray;
@property (strong, nonatomic) NSNumber *pages;
@property int pagesLoaded;
@property BOOL isLoading;
@end

@implementation BeerTableViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _pagesLoaded = 1;
	[self makeJSONRequest:(int)_pagesLoaded]; //load page one of results
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AFNetworking Reqs

-(void)makeJSONRequest:(int)pageNumber{
    NSMutableString *searchURL = [NSMutableString stringWithString:@"https://api.brewerydb.com/v2/beers/?key=3e6731ff19dc2830a7f15f90c50c7fb9&format=json&styleId=5&p="]; //limit of 400 reqs a day with free account
    NSMutableString *page = [NSMutableString stringWithFormat:@"%d", pageNumber];
    [searchURL appendString:page]; //generating URL for paginated results
    NSURL *url = [NSURL URLWithString:searchURL]; //create url object
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) { //network activity spinner manager from appDelegate

        if(!_beerArray){ //if array is empty
            _beerArray = [[responseObject objectForKey:@"data"]mutableCopy]; // set array to be a copy of data
            _pages = [responseObject objectForKey:@"numberOfPages"]; //get total number of pages from the response
        }
        else{
            [_beerArray addObjectsFromArray:[[responseObject objectForKey:@"data"]mutableCopy]]; //add new objects to end of array
        }
        [self.tableView reloadData]; //reload table view with new data
        _isLoading = NO;
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isLoading = NO;
        NSLog(@"Request Failed: %@, %@", error, error.userInfo);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving List"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_beerArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"tvCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *beerDictionary = [_beerArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [beerDictionary objectForKey:@"name"];
    cell.textLabel.adjustsFontSizeToFitWidth=YES; //reduces font size for beers with longer names
    if(indexPath.row == [_beerArray count]-5){ //if we are 5 cells from the end of the list, load next page
        if(!_isLoading){ //prevents spamming of requests
            if(_pagesLoaded < [_pages integerValue]){ //if there are pages to load
            _isLoading = YES;
            _pagesLoaded++;
            [self makeJSONRequest:(int)_pagesLoaded];
            }
        }
    }
    return cell;
}

@end
