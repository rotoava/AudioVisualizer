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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)start:(id)sender {
    
    
//    [[MicrophoneStream  sharedInstance]  start];
    
    [self  createStreamer];
    [streamer start];

}
- (IBAction)stop:(id)sender {
//    [[MicrophoneStream  sharedInstance]  stop];

    [self  destroyStreamer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)createStreamer
{
    
    NSString *urlString = @"http://dingfengappei.qiniudn.com/music.mp3";
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];
	NSURL *url = [NSURL URLWithString:urlString];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
    
    
    
    WaveView *waveView =[[WaveView alloc]   initWithFrame:CGRectMake(0, 300, 320, 200)];
    waveView.dataSource =streamer;
    [self.view  addSubview:waveView];

    
    
    
}

- (void)start
{
}
- (void)stop
{
}

- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		[streamer stop];
		streamer = nil;
	}
}
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
        NSLog(@"isWaiting");
	}
	else if ([streamer isPlaying])
	{        NSLog(@"isPlaying");

	}
	else if ([streamer isIdle])
	{
         NSLog(@"destroyStreamer");

		[self destroyStreamer];
	}
}

@end
