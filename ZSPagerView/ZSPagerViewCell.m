//
//  ZSPagerViewCell.m
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import "ZSPagerViewCell.h"

@interface ZSPagerViewCell()

@property (nonatomic ,strong) UIColor *selectionColor;

@property (nonatomic ,weak ,nullable) UIView *textLabelBackgroundView;

@end

@implementation ZSPagerViewCell

- (UILabel *)textLabel {
    if (!_textLabel) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.userInteractionEnabled = NO;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        view.hidden = self.isHideTextLable;
        _textLabelBackgroundView = view;
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self.contentView addSubview:view];
        [view addSubview:_textLabel];
        [_textLabel addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _textLabel;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}
- (UIView *)selectedForegroundView {
    if (!_selectedForegroundView) {
        UIView *view = [[UIView alloc] initWithFrame:self.imageView.bounds];
        [self.imageView addSubview:view];
        _selectedForegroundView = view;
    }
    return _selectedForegroundView;
}

- (BOOL)isHighlighted {
    return [super isHighlighted];
}

-(void)setHighlighted:(BOOL)highlighted {
    super.highlighted = highlighted;
    if (highlighted) {
        self.selectedForegroundView.layer.backgroundColor = self.selectionColor.CGColor;
    }else if (![super isSelected]) {
        self.selectedForegroundView.layer.backgroundColor = UIColor.clearColor.CGColor;
    }
}

- (BOOL)isSelected {
    return [super isSelected];
}
- (void)setSelected:(BOOL)selected {
    super.selected = selected;
    self.selectedForegroundView.layer.backgroundColor = selected ? self.selectionColor.CGColor : [UIColor clearColor].CGColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}
- (void)commonInit {
    self.selectionColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOpacity = 0.75;
    self.contentView.layer.shadowOffset = CGSizeZero;
}
- (void)dealloc {
    if (_textLabel) {
        [_textLabel removeObserver:self forKeyPath:@"font"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    
    CGRect rect = self.contentView.bounds;
    CGFloat height = self.textLabel.font.pointSize*1.5;
    rect.size.height = height;
    rect.origin.y = self.contentView.frame.size.height-height;
    //self.textLabel.superview == _textLabelBackgroundView
    self.textLabel.superview.frame = rect;
    CGRect rect1 = self.textLabel.superview.bounds;
    rect1 = CGRectInset(rect1, 8, 0);
    rect1.size.height -= 1;
    rect1.origin.y += 1;
    self.textLabel.frame = rect1;
    
    self.selectedForegroundView.frame = self.contentView.bounds;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"font"]) {
        [self setNeedsLayout];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)setTextLableBackgroundColor:(UIColor *)textLableBackgroundColor {
    _textLableBackgroundColor = textLableBackgroundColor;
    _textLabelBackgroundView.backgroundColor = textLableBackgroundColor;
}
- (void)setHideTextLable:(BOOL)hideTextLable {
    _hideTextLable = hideTextLable;
    self.textLabelBackgroundView.hidden = hideTextLable;
}
@end
