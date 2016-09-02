//
//  ViewController.m
//  AudioVisualizer
//
//  Created by DING FENG on 4/23/14.
//  Copyright (c) 2014 dinfeng. All rights reserved.
//

#import "ViewController.h"
#import "AudioStreamer.h"
#import "MicrophoneStream.h"
#import "WaveView.h"

@interface ViewController ()
{
    AudioStreamer *_streamer;

}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)start:(id)sender {
    [self  createStreamer];
    [_streamer start];
}

- (IBAction)stop:(id)sender {
//    [[MicrophoneStream  sharedInstance]  stop];

    [self  destroyStreamer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createStreamer {
    NSString *urlString = @"http://test86400.b0.upaiyun.com/shanqiu.mp3";
	if (_streamer) {
		return;
	}
    
	[self destroyStreamer];
	NSURL *url = [NSURL URLWithString:urlString];
	_streamer = [[AudioStreamer alloc] initWithURL:url];
	
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:_streamer];
    
    WaveView *waveView =[[WaveView alloc]   initWithFrame:CGRectMake(0, 300, 320, 200)];
    waveView.dataSource = _streamer;
    [self.view  addSubview:waveView];
    
}

- (void)destroyStreamer {
	if (_streamer) {
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:_streamer];
		[_streamer stop];
		_streamer = nil;
	}
}
- (void)playbackStateChanged:(NSNotification *)aNotification {
	if ([_streamer isWaiting]) {
        NSLog(@"isWaiting");
	}
	else if ([_streamer isPlaying]) {
        NSLog(@"isPlaying");
	}
    else if ([_streamer isIdle]){
         NSLog(@"destroyStreamer");
		[self destroyStreamer];
	}
}

@end
