//
//  CCLabelTTF+MKHelper.m
//  momoKinokoGame
//
//  Created by slightair on 2013/03/15.
//  Copyright (c) 2013年 slightair. All rights reserved.
//

#import "CCLabelTTF+MKHelper.h"

@implementation CCLabelTTF (MKHelper)

+ (CCLabelTTF *)labelWithTitle:(NSString *)title fontName:(NSString *)fontName fontSize:(CGFloat)fontSize;
{
    CGSize shadowOffset = CGSizeMake(1, -1);

    CCLabelTTF *baseLabel = [CCLabelTTF labelWithString:title fontName:fontName fontSize:fontSize];
    baseLabel.color = ccc3(0, 0, 0);

    CCLabelTTF *label = [CCLabelTTF labelWithString:title fontName:fontName fontSize:fontSize];
    label.anchorPoint = ccp(0, 0);
    label.position = ccp(-shadowOffset.width, -shadowOffset.height);
    [baseLabel addChild:label];

    return baseLabel;
}

@end
