//
//  MicrophoneStream.m
//  AudioVisualizer
//
//  Created by DING FENG on 1/27/14.
//  Copyright (c) 2014 dinfeng. All rights reserved.
//

#import "MicrophoneStream.h"
#include <AudioToolbox/AudioToolbox.h>

#include "AudioRingBuffer.h"

@implementation MicrophoneStream
@synthesize sampleRate = _sampleRate;
@synthesize ringBuffers = _ringBuffers;




OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers)



{
    OSStatus error = AudioUnitRender(*audioUnit,
                                     actionFlags,
                                     audioTimeStamp,
                                     busNumber,
                                     numFrames,
                                     buffers);
    NSLog(@"errorerrorerror  %d",(int)error);
    NSLog(@"fffffff");
    
    
    MicrophoneStream* owner = (__bridge MicrophoneStream *)(userData);
    [owner inputCallback:actionFlags
             inTimeStamp:audioTimeStamp
             inBusNumber:busNumber
             inNumberFrame:numFrames
             AudioBufferList:buffers];

//    AudioBuffer *input = &_inputBufferList->mBuffers[i];
//    [[_ringBuffers objectAtIndex:i]  pushSamples:input->mData count:input->mDataByteSize / sizeof(Float32)];
    
    
    
//    if(convertedSampleBuffer == NULL) {
//        // Lazy initialization of this buffer is necessary because we don't
//        // know the frame count until the first callback
//        convertedSampleBuffer = (float*)malloc(sizeof(float) * numFrames);
//    }
//    
//    SInt16 *inputFrames = (SInt16*)(buffers->mBuffers->mData);
//    
//    // If your DSP code can use integers, then don't bother converting to
//    // floats here, as it just wastes CPU. However, most DSP algorithms rely
//    // on floating point, and this is especially true if you are porting a
//    // VST/AU to iOS.
//    for(int i = 0; i < numFrames; i++) {
//        convertedSampleBuffer[i] = (float)inputFrames[i] / 32768.f;
//    }
//    
//    // Now we have floating point sample data from the render callback! We
//    // can send it along for further processing, for example:
//    // plugin->processReplacing(convertedSampleBuffer, NULL, sampleFrames);
//    
//    // Assuming that you have processed in place, we can now write the
//    // floating point data back to the input buffer.
//    for(int i = 0; i < numFrames; i++) {
//        // Note that we multiply by 32767 here, NOT 32768. This is to avoid
//        // overflow errors (and thus clipping).
//        inputFrames[i] = (SInt16)(convertedSampleBuffer[i] * 32767.f);
//    }
    
    return noErr;
}



//AudioUnitRender(					AudioUnit						inUnit,
//                AudioUnitRenderActionFlags *	ioActionFlags,
//                const AudioTimeStamp *			inTimeStamp,
//                UInt32							inOutputBusNumber,
//                UInt32							inNumberFrames,
//                AudioBufferList *				ioData)
//__OSX_AVAILABLE_STARTING(__MAC_10_2,__IPHONE_2_0);
//


//renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
//               const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
//               UInt32 numFrames, AudioBufferList *buffers)
//
//



- (void)inputCallback:(AudioUnitRenderActionFlags *)ioActionFlags
          inTimeStamp:(const AudioTimeStamp *)inTimeStamp
          inBusNumber:(UInt32)inBusNumber
          inNumberFrame:(UInt32)inNumberFrame
          AudioBufferList:(AudioBufferList *)buffers

{
    // Retrieve input samples.
    OSStatus error = noErr;

    
    
        if (error ==noErr)
        {
            
            
            for (UInt32 i = 0; i < _inputBufferList->mNumberBuffers; i++)
            {
                AudioBuffer *input = &_inputBufferList->mBuffers[i];
                // Fixed amplitude is good enough for our purposes
                const double amplitude = 0.25;
                double theta=M_PI;
                double theta_increment = 2.0 * M_PI * 100 / 44100;
                // This is a mono tone generator so we only need the first buffer
                Float32 *buffer = (Float32 *)_inputBufferList->mBuffers[i].mData;
                // Generate the samples
                for (UInt32 frame = 0; frame < inNumberFrame; frame++)
                {
                    buffer[frame] = sin(theta) * amplitude;
                    theta += theta_increment;
                    if (theta > 2.0 * M_PI)
                    {
                        theta -= 2.0 * M_PI;
                    }
                }
                
                AudioRingBuffer *buffers[1];
                for (UInt32 i = 0; i < 1; i++) {
                    buffers[i] = [[AudioRingBuffer alloc] init];
                }
                _ringBuffers = [NSArray arrayWithObjects:buffers count:1];
                [[_ringBuffers objectAtIndex:0]  pushSamples:input->mData count:input->mDataByteSize / sizeof(Float32)];
                if (i==0)
                {
                }
            }

}

}

- (void)start
{
    
    
    int r= initAudioSession();
    NSAssert(r == 0, @"Failed to initAudioSession (%d).", (int)r);
    r= [self  initAudioStreams:audioUnit];
    NSAssert(r == 0, @"Failed to initAudioStreams (%d).", (int)r);

    r= startAudioUnit(audioUnit);
    NSAssert(r == 0, @"Failed to startAudioUnit (%d).", (int)r);
}

- (void)stop
{
     int r= stopProcessingAudio(audioUnit);
    NSAssert(r == 0, @"Failed to stopProcessingAudio (%d).", (int)r);
}
// Yeah, global variables suck, but it's kind of a necessary evil here
AudioUnit *audioUnit = NULL;
float *convertedSampleBuffer = NULL;

int initAudioSession()
{
    audioUnit = (AudioUnit*)malloc(sizeof(AudioUnit));
    
    //todo   for  ios7 http://stackoverflow.com/questions/21464530/ios-deprecation-of-audiosessioninitialize-and-audiosessionsetproperty
    
    
    
    
    if(AudioSessionSetActive(true) != noErr) {
        return 1;
    }
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &sessionCategory) != noErr) {
        return 1;
    }
    
    Float32 bufferSizeInSec = 0.02f;
    if(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                               sizeof(Float32), &bufferSizeInSec) != noErr) {
        return 1;
    }
    
    UInt32 overrideCategory = 1;
    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                               sizeof(UInt32), &overrideCategory) != noErr) {
        return 1;
    }
    
    // There are many properties you might want to provide callback functions for:
    // kAudioSessionProperty_AudioRouteChange
    // kAudioSessionProperty_OverrideCategoryEnableBluetoothInput
    // etc.
    
    return 0;
}


-(int)initAudioStreams:(AudioUnit *)audioUnit
{

    
    OSStatus error;
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &audioCategory) != noErr) {
        return 1;
    }
    
    UInt32 overrideCategory = 1;
    if(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                               sizeof(UInt32), &overrideCategory) != noErr) {
        // Less serious error, but you may want to handle it and bail here
    }
    
    AudioComponentDescription componentDescription;
    componentDescription.componentType = kAudioUnitType_Output;
    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    componentDescription.componentFlags = 0;
    componentDescription.componentFlagsMask = 0;
    AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
    if(AudioComponentInstanceNew(component, audioUnit) != noErr) {
        return 1;
    }
    
    UInt32 enable = 1;
    if(AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_EnableIO,
                            kAudioUnitScope_Input, 1, &enable, sizeof(UInt32)) != noErr) {
        return 1;
    }
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; // Render function
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_SetRenderCallback,
                            kAudioUnitScope_Input, 0, &callbackStruct,
                            sizeof(AURenderCallbackStruct)) != noErr) {
        return 1;
    }
    
    AudioStreamBasicDescription streamDescription;
    // You might want to replace this with a different value, but keep in mind that the
    // iPhone does not support all sample rates. 8kHz, 22kHz, and 44.1kHz should all work.
    streamDescription.mSampleRate = 44100;
    // Yes, I know you probably want floating point samples, but the iPhone isn't going
    // to give you floating point data. You'll need to make the conversion by hand from
    // linear PCM <-> float.
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    // This part is important!
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger |
    kAudioFormatFlagsNativeEndian |
    kAudioFormatFlagIsPacked;
    // Record in mono. Use 2 for stereo, though I don't think the iPhone does true stereo recording
    streamDescription.mChannelsPerFrame = 1;
    
    // Always should be set to 1
    streamDescription.mFramesPerPacket = 1;
    // 1 sample per frame, will always be 2 as long as 16-bit samples are being used
    streamDescription.mBytesPerFrame = 2;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame *streamDescription.mChannelsPerFrame;
    // Not sure if the iPhone supports recording >16-bit audio, but I doubt it.
    streamDescription.mBitsPerChannel = 16;
    // Always set to 0, just to be sure
    streamDescription.mReserved = 0;
    
    
    const UInt32 kInputElement = 1;
    const UInt32 kOutputElement = 0;
    
    
    
    
//    UInt32 enableIO = 1;
//    error = AudioUnitSetProperty(*audioUnit,
//                                 kAudioOutputUnitProperty_EnableIO,
//                                 kAudioUnitScope_Input,
//                                 kInputElement,
//                                 &enableIO,
//                                 sizeof(enableIO));
//    
//    if(error !=noErr) {
//        return 1;
//    }
//    enableIO = 0;
//    error = AudioUnitSetProperty(*audioUnit,
//                                 kAudioOutputUnitProperty_EnableIO,
//                                 kAudioUnitScope_Output,
//                                 kOutputElement,
//                                 &enableIO,
//                                 sizeof(enableIO));
//    if(error !=noErr) {
//        return 1;
//    }
    AudioStreamBasicDescription deviceFormat;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    
     error = AudioUnitGetProperty(*audioUnit,
                                          kAudioUnitProperty_StreamFormat,
                                          kAudioUnitScope_Input,
                                          kInputElement,
                                          &deviceFormat,
                                          &size);
    
    
    printf("\n sizeof(Float32) :       %lu ",sizeof(Float32));
    printf("\n mSampleRate :       %f ",deviceFormat.mSampleRate);
    printf("\n mChannelsPerFrame : %i ",(unsigned int)deviceFormat.mChannelsPerFrame);
    printf("\n mFramesPerPacket:   %i ",(unsigned int)deviceFormat.mFramesPerPacket);
    printf("\n mBytesPerFrame:     %i ",(unsigned int)deviceFormat.mBytesPerFrame);
    printf("\n mBitsPerChannel:    %i   \n",(unsigned int)deviceFormat.mBitsPerChannel);
    
    
    streamDescription.mFramesPerPacket = 1;
    streamDescription.mChannelsPerFrame = 2;
    streamDescription.mBytesPerFrame = 4;
    streamDescription.mBytesPerPacket = 4;
    streamDescription.mBitsPerChannel = deviceFormat.mBitsPerChannel;
    streamDescription.mReserved = 0;
    
    // Set up input stream with above properties
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    
    // Ditto for the output stream, which we will be sending the processed audio to
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }

    UInt32 channels = deviceFormat.mChannelsPerFrame;
    AudioRingBuffer *buffers[channels];
    for (UInt32 i = 0; i < channels; i++) {
        buffers[i] = [[AudioRingBuffer alloc] init];
    }
    _ringBuffers = [NSArray arrayWithObjects:buffers count:channels];
    return 0;
}


int startAudioUnit(AudioUnit *audioUnit) {
    
    
    if(AudioUnitInitialize(*audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioOutputUnitStart(*audioUnit) != noErr) {
        return 1;
    }
    
    return 0;
}


int stopProcessingAudio(AudioUnit *audioUnit)
{
    if(AudioOutputUnitStop(*audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioUnitUninitialize(*audioUnit) != noErr) {
        return 1;
    }
    
    *audioUnit = NULL;
    return 0;
}



-(id)init
{
    self = [super init];
    if (self)
    {
        
        int erro = 0;
        
        if(AudioSessionInitialize(NULL, NULL, NULL, NULL) != noErr)
        {
            erro = 1;
        }
        NSAssert(erro == 0, @"Failed to AudioSessionInitialize (%d).", (int)erro);
    }
    return self;
}


+ (MicrophoneStream *)sharedInstance
{
    static MicrophoneStream *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MicrophoneStream alloc] init];
    });
    return instance;
}

@end
