//
//  ViewController.m
//  Layout
//
//  Created by Joseph Lin on 7/16/15.
//  Copyright (c) 2015 Joseph Lin All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewPanelLayout.h"
#import "ButtonCell.h"


@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return section + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ButtonCell class]) forIndexPath:indexPath];
    
    return cell;
}

@end
