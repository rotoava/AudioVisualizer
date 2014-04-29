//
//  MicrophoneStream.h
//  AudioVisualizer
//
//  Created by DING FENG on 1/27/14.
//  Copyright (c) 2014 dinfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

@interface MicrophoneStream : NSObject


{
    AudioUnit _auHAL;// Audio Hardware Abstraction Layer (HAL). The Audio HAL functions as the device interface for the I/O Kit Audio family and its drivers. For input streams, its job is to make the audio data it receives from drivers accessible to its clients. For output streams, its job is to take the audio data from its clients and pass it to a particular audio driver.
    AudioBufferList *_inputBufferList;
    NSArray *_ringBuffers;
    Float32 _sampleRate;


}

// Sampling rate.
@property (nonatomic, readonly) Float32 sampleRate;
// Ring buffer array.
@property (nonatomic, readonly) NSArray *ringBuffers;
// Control methods.
- (void)start;
- (void)stop;

// Retrieve the shared instance.
+ (MicrophoneStream *)sharedInstance;

@end
