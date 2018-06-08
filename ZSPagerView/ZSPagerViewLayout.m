//
//  ZSPagerViewLayout.m
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import "ZSPagerViewLayout.h"
#import "ZSPagerView.h"
#import "ZSPagerViewLayoutAttributes.h"
#import "ZSPagerViewTransformer.h"

@interface ZSPagerViewLayout()

@property (nonatomic ,strong ,nullable) ZSPagerView *pagerView;

@property (nonatomic ,assign) BOOL isInfinite;

@property (nonatomic ,assign) CGSize collectionViewSize;

@property (nonatomic ,assign) NSInteger numberOfSections;

@property (nonatomic ,assign) NSInteger numberOfItems;

@property (nonatomic ,assign) CGFloat actualInteritemSpacing;

@property (nonatomic ,assign) CGSize actualItemSize;
@end

@implementation ZSPagerViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentSize = CGSizeZero;
        self.leadingSpacing = 0;
        self.itemSpacing = 0;
        self.needsReprepare = YES;
        self.scrollDirection = ScrollHorizontal;
        
        self.isInfinite = YES;
        self.collectionViewSize = CGSizeZero;
        self.numberOfSections = 1;
        self.numberOfItems = 0;
        self.actualInteritemSpacing = 0;
        self.actualItemSize = CGSizeZero;
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}
//- (Class)layoutAttributesClass {
//    return <#expression#>
//}
- (ZSPagerView *)pagerView {
    UIView *view = self.collectionView.superview.superview;
    if ([view isKindOfClass:[ZSPagerView class]]) {
        return (ZSPagerView *)view;
    }
    return nil;
}

- (void)prepareLayout {
    UICollectionView *collectionView = self.collectionView;
    ZSPagerView *pagerView = self.pagerView;
    if (collectionView == nil || pagerView == nil) {
        return;
    }
    if (!self.needsReprepare && CGSizeEqualToSize(self.collectionViewSize, collectionView.frame.size)) {
        return;
    }
    
    self.needsReprepare = NO;
    
    self.collectionViewSize = collectionView.frame.size;
    
    // Calculate basic parameters/variables
    self.numberOfSections = [pagerView numberOfSectionsInCollectionView:collectionView];
    self.numberOfItems = [pagerView collectionView:collectionView numberOfItemsInSection:0];
    
    CGSize size = pagerView.itemSize;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = collectionView.frame.size;
    }
    self.actualItemSize = size;
    ZSPagerViewTransformer *transformer = pagerView.transformer;
    if (transformer) {
        //self.actualInteritemSpacing = [transformer pro]
    }else {
        self.actualInteritemSpacing = pagerView.interitemSpacing;
    }
    
    self.scrollDirection = pagerView.scrollDirection;
    self.leadingSpacing = self.scrollDirection == ScrollHorizontal ? (collectionView.frame.size.width-self.actualItemSize.width)*0.5 : (collectionView.frame.size.height-self.actualItemSize.height)*0.5;
    self.itemSpacing = (self.scrollDirection == ScrollHorizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing;
    
    
    NSInteger numberOfItems = self.numberOfItems*self.numberOfSections;
    if (self.scrollDirection == ScrollHorizontal) {
        CGFloat contentSizeWidth = self.leadingSpacing * 2;// Leading & trailing spacing
        contentSizeWidth += (numberOfItems-1)*self.actualInteritemSpacing;// Interitem spacing
        contentSizeWidth += numberOfItems*self.actualItemSize.width;// Item sizes
        self.contentSize = CGSizeMake(contentSizeWidth, collectionView.frame.size.height);
    }else  {
        CGFloat contentSizeHeight = self.leadingSpacing*2;// Leading & trailing spacing
        contentSizeHeight += (numberOfItems-1)*self.actualInteritemSpacing;// Interitem spacing
        contentSizeHeight += (numberOfItems)*self.actualItemSize.height;// Item sizes
        self.contentSize = CGSizeMake(collectionView.frame.size.width, contentSizeHeight);
    }
    
    [self adjustCollectionViewBounds];
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    if (self.itemSpacing <= 0 || CGRectEqualToRect(rect, CGRectZero)) {
        return layoutAttributes;
    }
    
    CGRect rect1 = CGRectIntersection(rect, CGRectMake(0, 0, self.contentSize.width, self.contentSize.height));
    if (CGRectEqualToRect(rect1, CGRectZero)) {
        return layoutAttributes;
    }
    
    // Calculate start position and index of certain rects
    NSInteger numberOfItemsBefore = self.scrollDirection == ScrollHorizontal ? MAX((CGRectGetMinX(rect1)-self.leadingSpacing)/self.itemSpacing, 0) : MAX((CGRectGetMinY(rect1)-self.leadingSpacing)/self.itemSpacing, 0);
    CGFloat startPosition = self.leadingSpacing + numberOfItemsBefore*self.itemSpacing;
    NSInteger startIndex = numberOfItemsBefore;
    NSInteger itemIndex = startIndex;
    
    CGFloat origin = startPosition;
    CGFloat min1 = MIN(CGRectGetMaxX(rect1), self.contentSize.width-self.actualItemSize.width-self.leadingSpacing);
    CGFloat min2 = MIN(CGRectGetMaxY(rect1), self.contentSize.height-self.actualItemSize.height-self.leadingSpacing);
    CGFloat maxPosition = self.scrollDirection == ScrollHorizontal ? min1 : min2;
    // https://stackoverflow.com/a/10335601/2398107
    
    while ((origin-maxPosition) <= MAX(100.0*FLT_EPSILON*fabs(origin+maxPosition), CGFLOAT_MIN)) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex%self.numberOfItems inSection:itemIndex/self.numberOfItems];
        ZSPagerViewLayoutAttributes *attributes = (ZSPagerViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
        [self applyTransformToAttributes:attributes withTransformer:self.pagerView.transformer];
        [layoutAttributes addObject:attributes];
        itemIndex += 1;
        origin += self.itemSpacing;
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZSPagerViewLayoutAttributes *attributes = [ZSPagerViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGRect frame = [self frameForIndexPath:indexPath];
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    attributes.center = center;
    attributes.size = self.actualItemSize;
    return attributes;
}
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    UICollectionView *collectionView = self.collectionView;
    if (collectionView == nil) {
        return proposedContentOffset;
    }
    
    CGFloat proposedContentOffsetX;
    if (self.scrollDirection == ScrollVertical) {
        proposedContentOffsetX = proposedContentOffset.x;
    }else {
        CGFloat translation = -[collectionView.panGestureRecognizer translationInView:collectionView].x;
        CGFloat offset = round(proposedContentOffset.x/self.itemSpacing)*self.itemSpacing;
        CGFloat minFlippingDistance = MIN(0.5*self.itemSpacing, 150);
        CGFloat originalContentOffsetX = collectionView.contentOffset.x - translation;
        if (fabs(translation) <= minFlippingDistance) {
            if (fabs(velocity.x) >= 0.3 && fabs(proposedContentOffset.x-originalContentOffsetX) <= self.itemSpacing*0.5) {
                offset += self.itemSpacing * (velocity.x)/fabs(velocity.x);
            }
        }
        proposedContentOffsetX = offset;
    }
    
    CGFloat proposedContentOffsetY;
    if (self.scrollDirection == ScrollHorizontal) {
        proposedContentOffsetY = proposedContentOffset.y;
    }else {
        CGFloat translation = -[collectionView.panGestureRecognizer translationInView:collectionView].y;
        CGFloat offset = round(proposedContentOffset.y/self.itemSpacing)*self.itemSpacing;
        CGFloat minFlippingDistance = MIN(0.5*self.itemSpacing, 150);
        CGFloat originalContentOffsetY = collectionView.contentOffset.y - translation;
        if (fabs(translation) <= minFlippingDistance) {
            if (fabs(velocity.y) >= 0.3 && fabs(proposedContentOffset.y-originalContentOffsetY) <= self.itemSpacing*0.5) {
                offset += self.itemSpacing * (velocity.y)/fabs(velocity.y);
            }
        }
        proposedContentOffsetY = offset;
    }
    
    return CGPointMake(proposedContentOffsetX, proposedContentOffsetY);
}

//
- (void)forceInvalidate {
    self.needsReprepare = YES;
    [self invalidateLayout];
}

- (CGPoint)contentOffsetForIndexPath:(NSIndexPath *)indexPath {
    CGPoint origin = [self frameForIndexPath:indexPath].origin;
    UICollectionView *collectionView = self.collectionView;
    if (collectionView == nil) {
        return origin;
    }
    CGFloat contentOffsetX;
    if (self.scrollDirection == ScrollVertical) {
        contentOffsetX = 0;
    }else {
        contentOffsetX = origin.x - (collectionView.frame.size.width*0.5-self.actualItemSize.width*0.5);
    }
    CGFloat contentOffsetY;
    if (self.scrollDirection == ScrollHorizontal) {
        contentOffsetY = 0;
    }else {
        contentOffsetY = origin.y - (collectionView.frame.size.height*0.5-self.actualItemSize.height*0.5);
    }
    return CGPointMake(contentOffsetX, contentOffsetY);
}
- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfItems = self.numberOfItems*indexPath.section + indexPath.item;
    CGFloat originX;
    if (self.scrollDirection == ScrollVertical) {
        originX = (self.collectionView.frame.size.width-self.actualItemSize.width)*0.5;
    }else {
        originX = self.leadingSpacing + numberOfItems*self.itemSpacing;
    }
    CGFloat originY;
    if (self.scrollDirection == ScrollHorizontal) {
        originY = (self.collectionView.frame.size.height-self.actualItemSize.height)*0.5;
    }else {
        originY = self.leadingSpacing+numberOfItems*self.itemSpacing;
    }
    
    CGRect frame = CGRectMake(originX, originY, self.actualItemSize.width, self.actualItemSize.height);
    return frame;
}
// MARK:- Private functions

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)adjustCollectionViewBounds {
    UICollectionView *collectionView = self.collectionView;
    ZSPagerView *pagerView = self.pagerView;
    if (collectionView == nil || pagerView == nil) {
        return;
    }
    NSInteger currentIndex = MAX(0, MIN(pagerView.currentIndex, pagerView.numberOfItems-1));
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:self.isInfinite ? self.numberOfSections/2 : 0];
    CGPoint contentOffset = [self contentOffsetForIndexPath:newIndexPath];
    CGRect newBounds = CGRectMake(contentOffset.x, contentOffset.y, collectionView.frame.size.width, collectionView.frame.size.height);
    collectionView.bounds = newBounds;
    pagerView.currentIndex = currentIndex;
}
- (void)applyTransformToAttributes:(ZSPagerViewLayoutAttributes *)attributes withTransformer:(ZSPagerViewTransformer *)transformer {
    UICollectionView *collectionView = self.collectionView;
    if (collectionView == nil || transformer == nil) {
        return;
    }
    if (self.scrollDirection == ScrollHorizontal) {
        CGFloat ruler = CGRectGetMidX(collectionView.bounds);
        attributes.position = (attributes.center.x-ruler)/self.itemSpacing;
    }else {
        CGFloat ruler = CGRectGetMidY(collectionView.bounds);
        attributes.position = (attributes.center.y-ruler)/self.itemSpacing;
    }
    attributes.zIndex = self.numberOfItems - attributes.position;
    [transformer applyTransformToAttributes:attributes];
}
// MARK:- Notification
- (void)didReceiveNotification:(NSNotification *)noti {
    if (CGSizeEqualToSize(self.pagerView.itemSize, CGSizeZero)) {
        [self adjustCollectionViewBounds];
    }
}
@end
