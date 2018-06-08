//
//  ZSPageControl.m
//  ZSScrollView
//
//  Created by safiri on 2018/5/23.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import "ZSPageControl.h"

@interface ZSPageControl()

@property (nonatomic ,assign) BOOL needsUpdateIndicators;

@property (nonatomic ,assign) BOOL needsCreateIndicators;

@property (nonatomic ,strong) NSMutableArray <CAShapeLayer *>*indicatorLayers;

/// [UIControlState: UIColor]
@property (nonatomic ,strong) NSMutableDictionary <NSNumber *,UIColor*>*strokeColors;
/// [UIControlState: UIColor]
@property (nonatomic ,strong) NSMutableDictionary <NSNumber *,UIColor*>*fillColors;
/// [UIControlState: UIBezierPath]
@property (nonatomic ,strong) NSMutableDictionary <NSNumber *,UIBezierPath*>*paths;
/// [UIControlState: UIImage]
@property (nonatomic ,strong) NSMutableDictionary <NSNumber *,UIImage*>*images;
/// [UIControlState: CGFloat]
@property (nonatomic ,strong) NSMutableDictionary <NSNumber *,NSNumber*>*alphas;
/// [UIControlState: CGAffineTransform]
@property (nonatomic ,strong) NSMutableDictionary <NSNumber *, NSValue*>*transforms;
@end

@implementation ZSPageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = self.contentInsets.left;
    CGFloat y = self.contentInsets.top;
    CGFloat width = self.frame.size.width - self.contentInsets.left - self.contentInsets.right;
    CGFloat height = self.frame.size.height - self.contentInsets.top - self.contentInsets.bottom;
    self.contentView.frame = CGRectMake(x, y, width, height);
}
- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    CGFloat diameter = self.itemSpacing;
    CGFloat spacing = self.interitemSpacing;
    
    //x:
    CGFloat x = 0.0;
    if (@available(iOS 11.0, *)) {
        if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeading) {
            x = 0;
        }
    }
    if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
        x = 0;
    }else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentCenter || self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentFill) {
        CGFloat midX = CGRectGetMidX(self.contentView.bounds);
        CGFloat amplitude = self.numberOfPages/2*diameter + spacing*(self.numberOfPages-1)/2;
        x = midX - amplitude;
    }else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
        CGFloat contentWidth = diameter*self.numberOfPages + (self.numberOfPages-1)*spacing;
        x = self.contentView.frame.size.width - contentWidth;
    }
    
    for (NSInteger i = 0; i < self.indicatorLayers.count; i++) {
        UIControlState state = (i == self.currentPage) ? UIControlStateSelected : UIControlStateNormal;
        UIImage *image = self.images[@(state)];
        CGSize size = image.size;
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = CGSizeMake(diameter, diameter);
        }
        CGPoint origin = CGPointMake(x - (size.width-diameter)*0.5, CGRectGetMidY(self.contentView.bounds)-size.height*0.5);
        CAShapeLayer *layer = self.indicatorLayers[i];
        layer.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        x = x + spacing + diameter;
    }
}
// MARK: puclic func
- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state {
    if ([self.strokeColors[@(state)] isEqual:strokeColor]) {
        return;
    }
    self.strokeColors[@(state)] = strokeColor;
    [self setNeedsUpdateIndicators];
}

- (void)setFillColor:(UIColor *)fillColor forState:(UIControlState)state {
    if ([self.fillColors[@(state)] isEqual:fillColor]) {
        return;
    }
    self.fillColors[@(state)] = fillColor;
    [self setNeedsUpdateIndicators];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if ([self.images[@(state)] isEqual:image]) {
        return;
    }
    self.images[@(state)] = image;
    [self setNeedsUpdateIndicators];
}

- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state {
    if (self.alphas[@(state)].floatValue == alpha) {
        return;
    }
    self.alphas[@(state)] = [NSNumber numberWithFloat:alpha];
    [self setNeedsUpdateIndicators];
}

- (void)setPath:(UIBezierPath *)path forState:(UIControlState)state {
    if ([self.paths[@(state)] isEqual:path]) {
        return;
    }
    self.paths[@(state)] = path;
    [self setNeedsUpdateIndicators];
}

//MARK: private func

- (void)commonInit {
    // Content View
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    [self addSubview:view];
    self.contentView = view;
    self.userInteractionEnabled = NO;
    
    //
    _numberOfPages = 0;
    _currentPage = 0;
    _itemSpacing = 6;
    _interitemSpacing = 6;
    _contentInsets = UIEdgeInsetsZero;
    _hidesForSinglePage = NO;
}

- (void)setNeedsUpdateIndicators {
    self.needsUpdateIndicators = YES;
    [self setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateIndicatorsIfNecessary];
    });
}

- (void)updateIndicatorsIfNecessary {
    if (!self.needsUpdateIndicators) {
        return;
    }
    if (self.indicatorLayers.count == 0) {
        return;
    }
    self.needsUpdateIndicators = NO;
    self.contentView.hidden = self.hidesForSinglePage && self.numberOfPages <= 1;
    if (!self.contentView.isHidden) {
        for (CAShapeLayer *layer in self.indicatorLayers) {
            layer.hidden = NO;
            [self updateIndicatorAttributesForLayer:layer];
        }
    }
}

- (void)updateIndicatorAttributesForLayer:(CAShapeLayer *)layer {
    NSInteger index = [self.indicatorLayers indexOfObject:layer];
    UIControlState state = index == self.currentPage ? UIControlStateSelected : UIControlStateNormal;
    UIImage *image = self.images[@(state)];
    if (image) {
        layer.strokeColor = nil;
        layer.fillColor = nil;
        layer.path = nil;
        layer.contents = CFBridgingRelease(image.CGImage);
    }else {
        layer.contents = nil;
        UIColor *strokeColor = self.strokeColors[@(state)];
        UIColor *fillColor = self.fillColors[@(state)];
        if (strokeColor == nil && fillColor == nil) {
            layer.fillColor = (state == UIControlStateSelected ? [UIColor whiteColor] : [UIColor grayColor]).CGColor;
            layer.strokeColor = nil;
        }else {
            layer.strokeColor = strokeColor.CGColor;
            layer.fillColor = fillColor.CGColor;
        }
        CGPathRef path = self.paths[@(state)].CGPath;
        if (path) {
            layer.path = path;
        }else {
            layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.itemSpacing, self.itemSpacing)].CGPath;
        }
    }
    
    NSValue *value = self.transforms[@(state)];
    if (value) {
        CGAffineTransform transform = value.CGAffineTransformValue;
        layer.transform = CATransform3DMakeAffineTransform(transform);
    }
    NSNumber *number = self.alphas[@(state)];
    if (number) {
        layer.opacity = number.floatValue;
    }else {
        layer.opacity = 1.0;
    }
}

- (void)setNeedsCreateIndicators {
    self.needsCreateIndicators = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createIndicatorsIfNecessary];
    });
}
- (void)createIndicatorsIfNecessary {
    if (!self.needsCreateIndicators) {
        return;
    }
    self.needsCreateIndicators = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.currentPage >= self.numberOfPages) {
        self.currentPage = self.numberOfPages - 1;
    }
    for (CAShapeLayer *layer in self.indicatorLayers) {
        [layer removeFromSuperlayer];
    }
    [self.indicatorLayers removeAllObjects];
    for (NSInteger i = 0; i < self.numberOfPages; i++) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.actions = @{@"bounds":[NSNull null]};
        [self.contentView.layer addSublayer:layer];
        [self.indicatorLayers addObject:layer];
    }
    [self setNeedsUpdateIndicators];
    [self updateIndicatorsIfNecessary];
    [CATransaction commit];
}


//MARK:_ get set


- (NSMutableDictionary<NSNumber *,UIColor *> *)strokeColors {
    if (!_strokeColors) {
        _strokeColors = [NSMutableDictionary dictionary];
    }
    return _strokeColors;
}
- (NSMutableDictionary<NSNumber *,UIColor *> *)fillColors {
    if (!_fillColors) {
        _fillColors = [NSMutableDictionary dictionary];
    }
    return _fillColors;
}
- (NSMutableDictionary<NSNumber *,UIBezierPath *> *)paths {
    if (!_paths) {
        _paths = [NSMutableDictionary dictionary];
    }
    return _paths;
}
- (NSMutableDictionary<NSNumber *,UIImage *> *)images {
    if (!_images) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}
- (NSMutableDictionary<NSNumber *,NSNumber *> *)alphas {
    if (!_alphas) {
        _alphas = [NSMutableDictionary dictionary];
    }
    return _alphas;
}
- (NSMutableDictionary<NSNumber *,NSValue *> *)transforms {
    if (!_transforms) {
        _transforms = [NSMutableDictionary dictionary];
    }
    return _transforms;
}

- (NSMutableArray<CAShapeLayer *> *)indicatorLayers {
    if (!_indicatorLayers) {
        _indicatorLayers = [NSMutableArray array];
    }
    return _indicatorLayers;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self setNeedsCreateIndicators];
}
- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self setNeedsCreateIndicators];
}
- (void)setItemSpacing:(CGFloat)itemSpacing {
    _itemSpacing = itemSpacing;
    [self setNeedsCreateIndicators];
}
- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing;
    [self setNeedsLayout];
}
- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}
- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    [super setContentHorizontalAlignment:contentHorizontalAlignment];
    [self setNeedsLayout];
}
- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    _hidesForSinglePage = hidesForSinglePage;
    [self setNeedsCreateIndicators];
}
@end
