//
//  ZSPagerViewTransformer.m
//  ZSScrollView
//
//  Created by safiri on 2018/5/21.
//  Copyright © 2018年 safiri. All rights reserved.
//

#import "ZSPagerViewTransformer.h"
#import "ZSPagerViewLayoutAttributes.h"
#import "ZSPagerView.h"


@implementation ZSPagerViewTransformer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumScale = 0.65;
        self.minimumAlpha = 0.6;
    }
    return self;
}

- (instancetype)initWithType:(ZSPagerViewTransformerType)type {
    self = [self init];
    if (self) {
        self.type = type;
        if (type == zoomOut) {
            self.minimumScale = 0.85;
        }else if (type == depth) {
            self.minimumScale = 0.5;
        }
    }
    return self;
}

- (void)applyTransformToAttributes:(ZSPagerViewLayoutAttributes *)attributes {
    ZSPagerView *pagerView = self.pagerView;
    if (pagerView == nil) {
        return;
    }
    
    CGFloat position = attributes.position;
    ZSPagerViewScrollDirection scrollDirection = pagerView.scrollDirection;
    CGFloat itemSpacing = (scrollDirection == ScrollHorizontal ? attributes.bounds.size.width : attributes.bounds.size.height) + [self proposedInteritemSpacing];
    if (self.type == crossFading) {
        NSInteger zIndex = 0;
        CGFloat alpha = 0;
        CGAffineTransform transform = CGAffineTransformIdentity;
        if (scrollDirection == ScrollHorizontal) {
            transform.tx = -itemSpacing * position;
        }else {
            transform.ty = -itemSpacing * position;
        }
        if (fabs(position) < 1) {// [-1,1]
            // Use the default slide transition when moving to the left page
            alpha = 1 - fabs(position);
            zIndex = 1;
        }else {// (1,+Infinity]
            // This page is way off-screen to the right.
            alpha = 0;
            zIndex = NSIntegerMin;
        }
        attributes.alpha = alpha;
        attributes.transform = transform;
        attributes.zIndex = zIndex;
    }else if (self.type == zoomOut) {
        CGFloat alpha = 0;
        CGAffineTransform transform = CGAffineTransformIdentity;
        if (position >= -CGFLOAT_MAX && position < -1) {//[-CGFLOAT_MAX, -1)
            // This page is way off-screen to the left.
            alpha = 0;
        }else if (position >= -1 && position <= 1) { // [-1,1]
            // Modify the default slide transition to shrink the page as well
            CGFloat scaleFactor = MAX(self.minimumScale, 1 - fabs(position));
            transform.a = scaleFactor;
            transform.d = scaleFactor;
            if (scrollDirection == ScrollHorizontal) {
                CGFloat vertMargin = attributes.bounds.size.height * (1 - scaleFactor) / 2;
                CGFloat horzMargin = itemSpacing * (1 - scaleFactor) / 2;
                transform.tx = position < 0 ?(horzMargin - vertMargin*2) : (-horzMargin + vertMargin*2);
            }else {
                CGFloat horzMargin = attributes.bounds.size.width * (1 - scaleFactor) / 2;
                CGFloat vertMargin = itemSpacing * (1 - scaleFactor) / 2;
                transform.ty = position < 0 ? (vertMargin - horzMargin*2) : (-vertMargin + horzMargin*2);
            }
            // Fade the page relative to its size.
            alpha = self.minimumAlpha + (scaleFactor-self.minimumScale)/(1-self.minimumScale)*(1-self.minimumAlpha);
        }else if (position > 1 && position < CGFLOAT_MAX) {// (1,+CGFLOAT_MAX)
            // This page is way off-screen to the right.
            alpha = 0;
        }
        attributes.alpha = alpha;
        attributes.transform = transform;
    }else if (self.type == depth) {
        CGFloat alpha = 0;
        CGAffineTransform transform = CGAffineTransformIdentity;
        NSInteger zIndex = 0;
        if (position > -CGFLOAT_MAX && position < -1) {// [-Infinity,-1)
            // This page is way off-screen to the left.
            alpha = 0;
            zIndex = 0;
        }else if (position >= -1 && position <= 0) {// [-1,0]
            // Use the default slide transition when moving to the left page
            alpha = 1;
            transform.tx = 0;
            transform.a = 1;
            transform.d = 1;
            zIndex = 1;
        }else if (position > 0 && position < 1) {// (0,1)
            // Fade the page out.
            alpha = 1.0 - position;
            // Counteract the default slide transition
            if (scrollDirection == ScrollHorizontal) {
                transform.tx = itemSpacing * -position;
            }else {
                transform.ty = itemSpacing * -position;
            }
            // Scale the page down (between minimumScale and 1)
            CGFloat scaleFactor = self.minimumScale + (1.0 - self.minimumScale) * (1.0 - fabs(position));
            transform.a = scaleFactor;
            transform.d = scaleFactor;
            zIndex = 0;
        }else if (position >= 1 && position < CGFLOAT_MAX) {// [1,+Infinity)
            // This page is way off-screen to the right.
            alpha = 0;
            zIndex = 0;
        }
        attributes.alpha = alpha;
        attributes.transform = transform;
        attributes.zIndex = zIndex;
    }else if (self.type == overlap || self.type == linear) {
        if (scrollDirection == ScrollVertical) {
            // This type doesn't support vertical mode
            return;
        }
        CGFloat scale = MAX(1 - (1-self.minimumScale)*fabs(position), self.minimumScale);
        CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
        attributes.transform = transform;
        CGFloat alpha = self.minimumAlpha + (1-fabs(position))*(1-self.minimumAlpha);
        attributes.alpha = alpha;
        CGFloat zIndex = (1-fabs(position))*10;
        attributes.zIndex = zIndex;
    }else if (self.type == coverFlow) {
        if (scrollDirection == ScrollVertical) {
            // This type doesn't support vertical mode
            return;
        }
        CGFloat position = MIN(MAX(-attributes.position, -1), 1);
        CGFloat rotation = sin(position*M_PI_2)*M_PI_4*1.5;
        CGFloat translationZ = -itemSpacing*0.5*fabs(position);
        CATransform3D transform3D = CATransform3DIdentity;
        transform3D.m34 = -0.002;
        transform3D = CATransform3DRotate(transform3D, rotation, 0, 1, 0);
        transform3D = CATransform3DTranslate(transform3D, 0, 0, translationZ);
        attributes.zIndex = 100 - fabs(position);
        attributes.transform3D = transform3D;
    }else if (self.type == ferrisWheel || self.type == invertedFerrisWheel) {
        if (scrollDirection == ScrollVertical) {
            // This type doesn't support vertical mode
            return;
        }
        // http://ronnqvi.st/translate-rotate-translate/
        NSInteger zIndex = 0;
        CGAffineTransform transform = CGAffineTransformIdentity;
        if (position >= -5 && position <= 5) {
            CGFloat itemSpacing = attributes.bounds.size.width+[self proposedInteritemSpacing];
            CGFloat count = 14;
            CGFloat circle = M_PI * 2.0;
            CGFloat radius = itemSpacing*count/circle;
            CGFloat ty = radius*(self.type == ferrisWheel ? 1 : -1);
            CGFloat theta = circle / count;
            CGFloat rotation = position*theta*(self.type == ferrisWheel ? 1 : -1);
            transform = CGAffineTransformTranslate(transform, -position*itemSpacing, ty);
            transform = CGAffineTransformRotate(transform, rotation);
            transform = CGAffineTransformTranslate(transform, 0, -ty);
            zIndex = 4.0-fabs(position)*10;
        }
        attributes.alpha = fabs(position) < 0.5 ? 1 : self.minimumAlpha;
        attributes.transform = transform;
        attributes.zIndex = zIndex;
    }else if (self.type == cubic) {
        if (position > -CGFLOAT_MAX && position <= -1) {
            attributes.alpha = 0;
        }else if (position > -1 && position < 1) {
            attributes.alpha = 1;
            attributes.zIndex = (1-position)*10;
            CGFloat direction = position < 0 ? 1 : -1;
            CGFloat theta = position*M_PI_2*(scrollDirection == ScrollHorizontal ? 1 : -1);
            CGFloat radius = scrollDirection == ScrollHorizontal ? attributes.bounds.size.width : attributes.bounds.size.height;
            CATransform3D transform3D = CATransform3DIdentity;
            transform3D.m34 = -0.002;
            if (scrollDirection == ScrollHorizontal) {
                // ForwardX -> RotateY -> BackwardX
                CGPoint temp = attributes.center;
                temp.x += direction*radius*0.5;
                attributes.center = temp;//ForwardX
                transform3D = CATransform3DRotate(transform3D, theta, 0, 1, 0);//RotateY
                transform3D = CATransform3DTranslate(transform3D, -direction*radius*0.5, 0, 0);//BackwardX
            }else {
                // ForwardY -> RotateX -> BackwardY
                CGPoint temp = attributes.center;
                temp.y += direction*radius*0.5; //ForwardY
                transform3D = CATransform3DRotate(transform3D, theta, 1, 0, 0);
                transform3D = CATransform3DTranslate(transform3D, 0, -direction*radius*0.5, 0);//BackwardY
            }
            attributes.transform3D = transform3D;
        }else if (position >= 1 && position < CGFLOAT_MAX) {
            attributes.alpha = 0;
        }else {
            attributes.alpha = 0;
            attributes.zIndex = 0;
        }
    }
}

//An interitem spacing proposed by transformer class. This will override the default interitemSpacing provided by the pager view.
- (CGFloat)proposedInteritemSpacing {
    ZSPagerView *pagerView= self.pagerView;
    if (pagerView == nil) {
        return 0;
    }
    ZSPagerViewScrollDirection scrollDirection = pagerView.scrollDirection;
    switch (self.type) {
        case overlap:
            if (scrollDirection == ScrollVertical) {
                return 0;
            }
            return pagerView.itemSize.width * -self.minimumScale*0.6;
            break;
        case linear:
            if (scrollDirection == ScrollVertical) {
                return 0;
            }
            return pagerView.itemSize.width * -self.minimumScale * 0.2;
            break;
        case coverFlow:
            if (scrollDirection == ScrollVertical) {
                return 0;
            }
            return -pagerView.itemSize.width * sin(M_PI*0.25*0.25*3.0);
            break;
        case ferrisWheel:
        case invertedFerrisWheel:
            if (scrollDirection == ScrollVertical) {
                return 0;
            }
            return -pagerView.itemSize.width * 0.15;
            break;
        case cubic:
            return 0;
            break;
        default:
            break;
    }
    return pagerView.interitemSpacing;
}
@end
