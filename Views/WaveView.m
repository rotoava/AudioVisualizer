//
//  WaveView.m
//  AudioVisualizer
//
//  Created by DING FENG on 4/27/14.
//  Copyright (c) 2014 dinfeng. All rights reserved.
//

#import "WaveView.h"
#import "SpectrumAnalyzer.h"
#import "MicrophoneStream.h"
#import "AudioRingBuffer.h"
#import "AudioStreamer.h"


#define MIN_DB (-60.0f)

static float ConvertLogScale(float x)
{
    return -log10f(0.1f + x / (MIN_DB * 1.1f));
}

@interface WaveView ()
{
    SpectrumAnalyzer *_analyzer;
}
@end


@implementation WaveView
@synthesize dataSource= _dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor  whiteColor];
        [NSTimer scheduledTimerWithTimeInterval:(1.0f / 60) target:self selector:@selector(refresh) userInfo:nil repeats:YES];

    }
    return self;
}
- (void)refresh
{
    
    [self  setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGSize size = self.frame.size;
    
    AudioStreamer *microphoneStream  = (AudioStreamer *)_dataSource;
//    [_analyzer processAudioInput:microphoneStream allChannels:YES];
    if (_dataSource) {
    }else
    {
        return;
    }
    [_analyzer processAudioInput:microphoneStream channel:0];
    {
        NSUInteger waveformLength = 4096;
        float waveform[waveformLength];
        
      //  NSLog(@"microphoneStream.ringBuffers  +++   ____  ::::::%@",microphoneStream.ringBuffers);
        [microphoneStream.ringBuffers.firstObject copyTo:waveform length:waveformLength];
        UIBezierPath *path = [UIBezierPath bezierPath];
        float xScale = size.width / waveformLength;
        
        for (NSUInteger i = 0; i < waveformLength; i++) {
            float x = xScale * i;
            float y = (waveform[i] * 0.5f + 0.5f) * size.height;
            if (i == 0) {
                [path moveToPoint:CGPointMake(x, y)];
            } else {
                
                if (y>-200&&y<200) {
                    [path addLineToPoint:CGPointMake(x, y)];
                }
            }
        }
        [[UIColor redColor] setStroke];
         path.lineWidth = 0.5f;
        [path stroke];
    }
}

@end
