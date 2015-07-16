//
//  CollectionViewPanelLayout.m
//  Layout
//
//  Created by Joseph Lin on 7/16/15.
//  Copyright (c) 2015 Joseph Lin All rights reserved.
//

#import "CollectionViewPanelLayout.h"



#pragma mark - Background View

static NSString * const WICollectionElementKindPanelBackground = @"WICollectionElementKindPanelBackground";

@interface WIControlPanelBackgroundView : UICollectionReusableView

@end

@implementation WIControlPanelBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.layer.cornerRadius = 10.0;
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

@end



#pragma mark - Separator View

static NSString * const WICollectionElementKindPanelSeparator = @"WICollectionElementKindPanelSeparator";

@interface WIControlPanelSeparatorView : UICollectionReusableView

@end

@implementation WIControlPanelSeparatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
    return self;
}

@end



#pragma mark - Custom Layout

@interface CollectionViewPanelLayout ()
@property (nonatomic) NSNumber *sectionHeight;
@property (nonatomic) NSMutableDictionary *panelFrames;
@end


@implementation CollectionViewPanelLayout

- (void)initialize
{
    self.numberOfSectionsInPanels = @[@1, @2, @2];
    self.panelInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    self.panelSpacing = 10.0;
    self.sectionInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.sectionSpacing = 20.0;
    self.itemSpacing = 10.0;
    [self registerClass:[WIControlPanelBackgroundView class] forDecorationViewOfKind:WICollectionElementKindPanelBackground];
    [self registerClass:[WIControlPanelSeparatorView class] forDecorationViewOfKind:WICollectionElementKindPanelSeparator];
}

- (id)init
{
    self = [super init];
    [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initialize];
    return self;
}


#pragma mark - Override

- (CGSize)collectionViewContentSize
{
    // Do not scroll
    CGSize contentSize = self.collectionView.frame.size;
    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray array];

    NSInteger lastPanelIndex = -1;
    NSInteger numberOfSectionsAtTheEndOfCurrentPanel = 0;
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            itemAttributes.zIndex = 2;
            [layoutAttributes addObject:itemAttributes];
            
        }
        
        NSInteger panelIndex = [self panelForSection:section];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];

        if (lastPanelIndex != panelIndex) {
            lastPanelIndex = panelIndex;
            NSInteger sectionsInPanel = [self numberOfSectionsInPanel:panelIndex];
            numberOfSectionsAtTheEndOfCurrentPanel += sectionsInPanel;

            UICollectionViewLayoutAttributes *backgroundAttributes = [self layoutAttributesForDecorationViewOfKind:WICollectionElementKindPanelBackground atIndexPath:indexPath];
            backgroundAttributes.zIndex = 0;
            [layoutAttributes addObject:backgroundAttributes];
        }
        
        if (section + 1 < numberOfSectionsAtTheEndOfCurrentPanel) {
            UICollectionViewLayoutAttributes *separatorAttributes = [self layoutAttributesForDecorationViewOfKind:WICollectionElementKindPanelSeparator atIndexPath:indexPath];
            separatorAttributes.zIndex = 1;
            [layoutAttributes addObject:separatorAttributes];
        }
        
    }

    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger panelIndex = [self panelForSection:indexPath.section];
    CGRect panelFrame = [self frameForPanel:panelIndex];
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:indexPath.section];
    CGFloat width = CGRectGetWidth(panelFrame) - self.sectionInsets.left - self.sectionInsets.right - self.itemSpacing * (numberOfItems - 1);
    width /= numberOfItems;
    CGFloat x = self.sectionInsets.left + indexPath.item * (width + self.itemSpacing);
    CGFloat height = self.sectionHeight.doubleValue;
    
    NSInteger sectionWithinPanel = [self sectionWithinPanelForSection:indexPath.section];
    CGFloat y = self.sectionInsets.top + sectionWithinPanel * (self.sectionHeight.doubleValue + self.sectionSpacing);

    CGRect rect = CGRectMake(x + panelFrame.origin.x, y + panelFrame.origin.y, width, height);
    
    NSLog(@"{%ld,%ld}: %@", (long)indexPath.section, (long)indexPath.item, NSStringFromCGRect(rect));
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = rect;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger panelIndex = [self panelForSection:indexPath.section];
    CGRect panelFrame = [self frameForPanel:panelIndex];
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];

    if ([elementKind isEqualToString:WICollectionElementKindPanelBackground]) {
        attributes.frame = panelFrame;
    }
    else if ([elementKind isEqualToString:WICollectionElementKindPanelSeparator]) {
        CGFloat x = self.sectionInsets.left;
        CGFloat width = CGRectGetWidth(panelFrame) - self.sectionInsets.left - self.sectionInsets.right;
        CGFloat y = CGRectGetHeight(panelFrame) / [self numberOfSectionsInPanel:panelIndex] * ([self sectionWithinPanelForSection:indexPath.section] + 1);
        CGFloat height = 1.0;
        CGRect rect = CGRectMake(x + panelFrame.origin.x, y + panelFrame.origin.y, width, height);
        attributes.frame = rect;
    }
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGRectEqualToRect(oldBounds, newBounds)) {
        return YES;
    }
    return NO;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];
    [self invalidateCache];
}


#pragma mark - Tools

- (void)invalidateCache
{
    self.sectionHeight = nil;
    [self.panelFrames removeAllObjects];
}

- (CGRect)frameForPanel:(NSInteger)panelIndex
{
    id value = self.panelFrames[@(panelIndex)];
    if (value) {
        CGRect rect = [value CGRectValue];
        return rect;
    }

    
    CGFloat x = self.panelInsets.left;
    CGFloat width = CGRectGetWidth(self.collectionView.frame) - self.panelInsets.left - self.panelInsets.right;
    
    __block CGFloat y = self.panelInsets.top;
    [self.numberOfSectionsInPanels enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        if (idx >= panelIndex) {
            *stop = YES;
            return;
        }
        
        NSInteger numberOfSections = obj.integerValue;
        CGFloat panelHeight = self.sectionInsets.top + self.sectionInsets.bottom + self.sectionSpacing * (numberOfSections - 1) + self.sectionHeight.doubleValue * numberOfSections;
        y += panelHeight;
        y += self.panelSpacing;
    }];
    
    NSInteger numberOfSections = [self numberOfSectionsInPanel:panelIndex];
    CGFloat height = self.sectionInsets.top + self.sectionInsets.bottom + self.sectionSpacing * (numberOfSections - 1) + self.sectionHeight.doubleValue * numberOfSections;
    
    CGRect rect = CGRectMake(x, y, width, height);
    value = [NSValue valueWithCGRect:rect];
    self.panelFrames[@(panelIndex)] = value;
    
    return rect;
}


#pragma mark - Getter

- (NSMutableDictionary *)panelFrames
{
    if (!_panelFrames) {
        _panelFrames = [NSMutableDictionary new];
    }
    return _panelFrames;
}

- (NSInteger)numberOfPanels
{
    if (self.numberOfSectionsInPanels) {
        return self.numberOfSectionsInPanels.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInPanel:(NSInteger)panel
{
    if (self.numberOfSectionsInPanels) {
        return [self.numberOfSectionsInPanels[panel] integerValue];
    }
    return [self.collectionView numberOfSections];
}

- (NSInteger)panelForSection:(NSInteger)section
{
    if (!self.numberOfSectionsInPanels) {
        return 0;
    }

    __block NSInteger panel = 0;
    __block NSInteger totalSections = 0;
    [self.numberOfSectionsInPanels enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        totalSections += obj.integerValue;
        panel = idx;
        if (totalSections > section) {
            *stop = YES;
        }
    }];
    return panel;
}

- (NSInteger)sectionWithinPanelForSection:(NSInteger)section
{
    if (!self.numberOfSectionsInPanels) {
        return section;
    }
    
    for (NSNumber *obj in self.numberOfSectionsInPanels) {
        NSInteger numberOfSections = obj.integerValue;
        if (section - numberOfSections < 0) {
            break;
        }
        section -= numberOfSections;
    }
    return section;
}

- (NSNumber *)sectionHeight
{
    if (!_sectionHeight) {
        
        NSInteger numberOfPanels = self.numberOfPanels;
        NSInteger numberOfSections = [self.collectionView numberOfSections];
        NSParameterAssert(numberOfSections > 0);
        
        __block NSInteger numberOfSectionSpacing = 0;
        if (self.numberOfSectionsInPanels) {
            [self.numberOfSectionsInPanels enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
                NSInteger numberOfSections = obj.integerValue;
                if (numberOfSections > 1) {
                    numberOfSectionSpacing += (numberOfSections - 1);
                }
            }];
        }
        else {
            numberOfSectionSpacing = numberOfSections - 1;
        }
        
        CGFloat viewHeight = CGRectGetHeight(self.collectionView.frame);
        CGFloat sectionHeight = viewHeight
        - self.panelInsets.top - self.panelInsets.bottom
        - self.panelSpacing * (numberOfPanels - 1)
        - (self.sectionInsets.top + self.sectionInsets.bottom) * numberOfPanels
        - self.sectionSpacing * numberOfSectionSpacing;
        sectionHeight = sectionHeight / numberOfSections;

        _sectionHeight = @(sectionHeight);
        NSLog(@"sectionHeight = %f", sectionHeight);
    }
    return _sectionHeight;
}


#pragma mark - Setter

- (void)setNumberOfSectionsInPanels:(NSArray *)numberOfSectionsInPanels
{
    // Validate the array
    for (id obj in numberOfSectionsInPanels) {
        NSParameterAssert([obj isKindOfClass:[NSNumber class]]);
        NSParameterAssert([obj integerValue] > 0);
    }
    _numberOfSectionsInPanels = numberOfSectionsInPanels;
    [self invalidateCache];
}

- (void)setPanelInsets:(UIEdgeInsets)panelInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_panelInsets, panelInsets)) {
        _panelInsets = panelInsets;
        [self invalidateCache];
    }
}

- (void)setPanelSpacing:(CGFloat)panelSpacing
{
    if (_panelSpacing != panelSpacing) {
        _panelSpacing = panelSpacing;
        [self invalidateCache];
    }
}

- (void)setSectionInsets:(UIEdgeInsets)sectionInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInsets, sectionInsets)) {
        _sectionInsets = sectionInsets;
        [self invalidateCache];
    }
}

- (void)setSectionSpacing:(CGFloat)sectionSpacing
{
    if (_sectionSpacing != sectionSpacing) {
        _sectionSpacing = sectionSpacing;
        [self invalidateCache];
    }
}

- (void)setItemSpacing:(CGFloat)itemSpacing
{
    if (_itemSpacing != itemSpacing) {
        _itemSpacing = itemSpacing;
        [self invalidateCache];
    }
}

@end
