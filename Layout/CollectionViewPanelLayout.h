//
//  CollectionViewPanelLayout.h
//  Layout
//
//  Created by Joseph Lin on 7/16/15.
//  Copyright (c) 2015 Joseph Lin All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CollectionViewPanelLayout : UICollectionViewLayout

@property (nonatomic) NSArray *numberOfSectionsInPanels;

@property (nonatomic) UIEdgeInsets panelInsets;
@property (nonatomic) CGFloat panelSpacing;

@property (nonatomic) UIEdgeInsets sectionInsets;
@property (nonatomic) CGFloat sectionSpacing;
@property (nonatomic) CGFloat itemSpacing;

@property (nonatomic) NSNumber *sectionHeight;

- (NSInteger)numberOfPanels;
- (NSInteger)panelForSection:(NSInteger)section;

@end
