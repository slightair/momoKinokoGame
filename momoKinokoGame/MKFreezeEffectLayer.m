//
//  MKFreezeEffectLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/06.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKFreezeEffectLayer.h"
#import "MKSpecialItem.h"

typedef NS_ENUM(NSInteger, MKFreezeEffectState)
{
    MKFreezeEffectStateNotFreezing = 100,
    MKFreezeEffectStateFreezing,
    MKFreezeEffectStateFroze,
    MKFreezeEffectStateThawing,
    MKFreezeEffectStateUnknown = -1
};

#define kNormalColor (ccc4f(0.0, 0.0, 0.0, 1.0))
#define kNegativeColor (ccc4f(1.0, 1.0, 1.0, 1.0))
#define kCircleSizeDelta 8

void drawFilledCircle(CGPoint center, float r, ccColor4F color);

@interface MKFreezeEffectLayer ()

- (void)freezingDidStart:(NSNotification *)notification;
- (void)thawingDidStart:(NSNotification *)notification;

@property (nonatomic, assign) CGPoint circlePosition;
@property (nonatomic, assign) CGFloat circleSize;
@property (nonatomic, assign) CGFloat circleSizeMax;
@property (nonatomic, assign) MKFreezeEffectState effectState;

@end

@implementation MKFreezeEffectLayer

+ (id)node
{
    CCLayerColor *layer = [self layerWithColor:ccc4BFromccc4F(kNormalColor)];
    layer.blendFunc = (ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR};

    return layer;
}

- (void)draw
{
    [super draw];

    CGSize windowSize = [CCDirector sharedDirector].winSize;
    switch (self.effectState) {
        case MKFreezeEffectStateNotFreezing:
            break;

        case MKFreezeEffectStateFreezing:
            drawFilledCircle(self.circlePosition, self.circleSize, kNegativeColor);

            self.circleSize += kCircleSizeDelta;
            if (self.circleSize > self.circleSizeMax) {
                self.effectState = MKFreezeEffectStateFroze;
                self.circleSize = 0;
            }

            break;

        case MKFreezeEffectStateFroze:
            ccDrawSolidRect(CGPointZero, ccp(windowSize.width, windowSize.height), kNegativeColor);
            break;

        case MKFreezeEffectStateThawing:
            ccDrawSolidRect(CGPointZero, ccp(windowSize.width, windowSize.height), kNegativeColor);
            drawFilledCircle(self.circlePosition, self.circleSize, kNormalColor);

            self.circleSize += kCircleSizeDelta;
            if (self.circleSize > self.circleSizeMax) {
                self.effectState = MKFreezeEffectStateNotFreezing;
                self.circleSize = 0;
            }

            break;

        default:
            break;
    }
}

- (void)onEnter
{
    [super onEnter];

    CGSize windowSize = [CCDirector sharedDirector].winSize;
    CGFloat circleSizeMax = sqrt(pow(windowSize.width, 2) + pow(windowSize.height, 2));

    self.circleSize = 0.0;
    self.circleSizeMax = circleSizeMax;
    self.circlePosition = CGPointZero;
    self.effectState = MKFreezeEffectStateNotFreezing;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(freezingDidStart:)
                                                 name:MKSpecialItemNotificationDidTouchItem
                                               object:nil];
}

- (void)onExit
{
    [super onExit];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)freezingDidStart:(NSNotification *)notification
{
    CGPoint location = [notification.userInfo[MKSpecialItemExecutionLocationUserInfoKey] CGPointValue];

    self.effectState = MKFreezeEffectStateFreezing;
    self.circleSize = 0.0;
    self.circlePosition = location;
}

- (void)thawingDidStart:(NSNotification *)notification
{
    self.effectState = MKFreezeEffectStateThawing;
    self.circleSize = 0.0;
}

@end

void drawFilledCircle(CGPoint center, float r, ccColor4F color)
{
    int segs = r * 2;
    CGPoint *vertices = calloc(segs + 2, sizeof(CGPoint));
    if (!vertices) {
        return;
    }
	const float coef = 2.0f * (float)M_PI/segs;

    for (int i=0; i<=segs; i++) {
		CGFloat rads = i * coef;
        vertices[i] = ccp(r * cos(rads) + center.x, r * sin(rads) + center.y);
    }
    vertices[segs+1] = center;

    ccDrawSolidPoly(vertices, segs+2, color);

	free( vertices );
}