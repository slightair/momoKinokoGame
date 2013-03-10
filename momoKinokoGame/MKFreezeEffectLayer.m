//
//  MKFreezeEffectLayer.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/06.
//  Copyright 2013年 slightair. All rights reserved.
//

#import "MKFreezeEffectLayer.h"
#import "MKSpecialItem.h"

#define kCircleSizeDelta 8

void drawFilledCircle(CGPoint center, float r, ccColor4F color);

@interface MKFreezeEffectLayer ()

- (void)specialItemDidTouch:(NSNotification *)notification;

@property (nonatomic, assign) CGPoint circlePosition;
@property (nonatomic, assign) CGFloat circleSize;
@property (nonatomic, assign) CGFloat circleSizeMax;

@end

@implementation MKFreezeEffectLayer

+ (id)node
{
    CCLayerColor *layer = [self layerWithColor:ccc4(0, 0, 0, 255)];
    layer.blendFunc = (ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR};

    return layer;
}

- (void)draw
{
    [super draw];

    if (CGPointEqualToPoint(self.circlePosition, CGPointZero)) {
        return;
    }
    
    drawFilledCircle(self.circlePosition, self.circleSize, ccc4f(1.0, 1.0, 1.0, 1.0));

    self.circleSize += kCircleSizeDelta;
    if (self.circleSize > self.circleSizeMax) {
        self.circlePosition = CGPointZero;
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(specialItemDidTouch:)
                                                 name:MKSpecialItemNotificationDidTouchItem
                                               object:nil];
}

- (void)onExit
{
    [super onExit];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)specialItemDidTouch:(NSNotification *)notification
{
    CGPoint location = [notification.userInfo[MKSpecialItemExecutionLocationUserInfoKey] CGPointValue];

    self.circleSize = 0.0;
    self.circlePosition = location;
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