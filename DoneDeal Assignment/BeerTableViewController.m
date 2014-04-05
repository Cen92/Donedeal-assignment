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
@property int *pagesLoaded;
@property int *numberOfPages;
@property BOOL isLoading;
@end

@implementation BeerTableViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
	[self makeJSONRequest:(int)1];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AFNetworking Reqs

-(void)makeJSONRequest:(int)pageNumber{
    NSMutableString *searchURL = [NSMutableString stringWithString:@"https://api.brewerydb.com/v2/beers/?key=3e6731ff19dc2830a7f15f90c50c7fb9&format=json&styleId=5&p="];
    NSMutableString *page = [NSMutableString stringWithFormat:@"%d", pageNumber];
    [searchURL appendString:page];
    NSURL *url = [NSURL URLWithString:searchURL]; //create url object
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        if(!_beerArray){
            _beerArray = [[responseObject objectForKey:@"data"]mutableCopy];
            
        }
        else{
            [_beerArray addObjectsFromArray:[[responseObject objectForKey:@"data"]mutableCopy]];
        }
        _isLoading = NO;
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isLoading = NO;
        NSLog(@"Request Failed: %@, %@", error, error.userInfo);
       // [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        
    }];
    
    [operation start];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;// Return the number of sections.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_beerArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"tvCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *beerDictionary = [_beerArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [beerDictionary objectForKey:@"name"];

    
    if(indexPath.row == [_beerArray count]-5){
        if(!_isLoading){
            _isLoading = YES;
        _pagesLoaded++;
        [self makeJSONRequest:(int)_pagesLoaded];
        }
        else{
            NSLog(@"Loading...");
        }
        _isLoading = NO;
    }
    return cell;
}

@end
