//
//  WaveView.h
//  AudioVisualizer
//
//  Created by DING FENG on 4/27/14.
//  Copyright (c) 2014 dinfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

// float waveform[waveformLength];

@protocol WaveViewProtocol <NSObject>
@required
- (Float32 *)fetchWaveSamplesLen:(int)lenth;

@end

@interface WaveView : UIView

@property (nonatomic, weak) id<WaveViewProtocol> dataSource;

@end
