//
//  ViewController.m
//  testPST
//
//  Created by 曹盛杰 on 13-8-12.
//  Copyright (c) 2013年 曹盛杰. All rights reserved.
//
#define __NO_LOG__

#ifdef __NO_LOG__
#define MYLog(format, ...)
#else
#define MYLog(format, ...) NSLog((@"%s [Line %d]" format),  __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)
#endif


#import "ViewController.h"

#import "DetailViewController.h"
#import "Cell.h"

#import "Test.h"
#import "Event.h"

NSString *kDetailedViewControllerID = @"DetailView";
NSString *kCellID = @"cellID";

@interface ViewController ()
{
//    NSMutableArray *_sections;
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}

@end


@implementation ViewController

-(void)awakeFromNib{
    [super awakeFromNib];
    MYLog(@"awakeFromNib");
}


-(void)setupFetchedResultsController{
    self.fetchedResultsController  = [Test fetchAllGroupedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"name != nil"] sortedBy:@"name" ascending:YES];
    NSLog(@"setupFetchedResultsController");
}

-(NSArray*)beginCoreDataResources{
    MYLog(@"beginCoreDataResources");
    NSArray *arr = [[NSArray alloc]init];
    NSDictionary *dict1 = @{@"name":@"Ni" ,@"age":@2,@"event_title":@"chifan",@"event_subtitle":@"cfSub",@"event_id":@"001",@"event_Des":@"11111",@"event_fangfa":@[@{@"title":@"1-1",@"img":@"1-1.jpg"},@{@"title":@"1-2",@"img":@"1-2.jpg"}]};
    //yh
    NSDictionary *dict2=
  @{@"name":@"YH",@"age":@3,@"event_title":@"kaidianshi",@"event_subtitle":@"p2Sub",@"event_id":@"002",@"event_Des":@"22222",@"event_fangfa":@[@{@"title":@"2-1",@"img":@"2-1.jpg"}]};
    
    NSDictionary *dict3 =@{@"name":@"YH",@"age":@5,@"event_title":@"playg",@"event_subtitle":@"pgSub",@"event_id":@"003",@"event_Des":@"33333",@"event_fangfa":@[@{@"title":@"3-1",@"img":@"3-1.jpg"},@{@"title":@"3-2",@"img":@"3-2.jpg"},@{@"title":@"3-3",@"img":@"3-3.jpg"}]};
    
    //csj
    NSDictionary *dict4 =@{@"name":@"Cao",@"age":@5,@"event_title":@"chaocai",@"event_subtitle":@"ccSub",@"event_id":@"004",@"event_Des":@"66666",@"event_fangfa":@[@{@"title":@"4-1",@"img":@"4-1.jpg"}]};
    arr = @[dict1,dict2,dict3,dict4];
    return arr;
}

-(void)personDataIntoDocument{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"beginFresh"]){
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
        {
            NSArray *persons = [self beginCoreDataResources];
            NSLog(@"保存数据源成功");
            for (NSDictionary *personInfo in persons){
                
                Event *event;
                NSError *error;
                NSArray *events = [localContext executeFetchRequest:[Event requestAllSortedBy:@"event_title" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"unique = %@",[personInfo objectForKey:@"event_id"]] inContext:localContext] error:&error];
                if ([events count] == 0){
                    event = [Event MR_createInContext:localContext];
                    event.unique = [personInfo objectForKey:@"event_id"];
                    event.event_title = [personInfo objectForKey:@"event_title"];
                    event.event_subtitle = [personInfo objectForKey:@"event_subtitle"];
                    
                    
                    #pragma mark - Test
                    Test *test;
                    NSError *error;
                    NSArray *tests = [localContext executeFetchRequest:[Test requestAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"name = %@",[personInfo objectForKey:@"name"]] inContext:localContext] error:&error];
                    if ([tests count] == 0){
                        test = [Test MR_createInContext:localContext];
                        test.name = [personInfo objectForKey:@"name"];
                    }else{
                        test = [tests lastObject];
                    }
                    event.whoDo = test;
                }else{
                    event = [events lastObject];
                }
                
                /*
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSString *urlString = [[[personInfo valueForKey:@"images"]objectForKey:0]valueForKey:@"url"];
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [personInfo setValue:imageData forKey:@"photoImageData"];
                    });
                });
                */
            }
            MYLog(@"MG成功");
        } completion:^(BOOL success, NSError *error) {
            MYLog(@"MG错误情况 %@",error);
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    [self setupFetchedResultsController];
    [self personDataIntoDocument];
    MYLog(@"viewDidLoad");
    [self.collectionView setBackgroundColor:[UIColor grayColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PST
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1;
//}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{ 
//    return 30;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

//- (void)loadView{
//    [super loadView];
//}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    // make the cell's title the  NSIndexPath value
    Test *test = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.label1.text = [NSString stringWithFormat:@"%@",test.name];
    
    return cell;
}


/**
 - (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath{
 Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
 cell.label1.text = [NSString stringWithFormat:@"{%ld,%ld}",(long)indexPath.row,(long)indexPath.section];
 NSString *imageToLoad = [NSString stringWithFormat:@"%d,JPG",indexPath.row];
 cell.image1.image = [UIImage imageNamed:imageToLoad];
 return cell;
 }
 */

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems]objectAtIndex:0];
    Test *test = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setTest:)]){
        [segue.destinationViewController performSelector:@selector(setTest:) withObject:test];
    }
    /*
    if ([segue.identifier isEqualToString:@"showDetail"])
    {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems]objectAtIndex:0];
        DetailViewController *detailViewController = [segue destinationViewController];
        Test *test = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        detailViewController.title = test.name;
    }
     */
}


#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
    MYLog(@"fetchedResultsController");
    _fetchedResultsController.delegate = self;//**
    
    if (_fetchedResultsController != nil){
        return _fetchedResultsController;
    }
    _fetchedResultsController = [Test MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:nil groupBy:nil delegate:nil inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    MYLog(@"_sectionChanges");
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    MYLog(@"_objectChanges");
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    MYLog(@"controllerDidChangeContent");
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _objectChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}




@end
