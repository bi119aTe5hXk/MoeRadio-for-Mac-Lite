//
//  MoeFmPlayer.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MoeFmPlayer.h"
#import "AudioStreamer.h"

@interface MoeFmPlayer ()
@property (unsafe_unretained, nonatomic) NSObject <MoeFmPlayerDelegate> *delegate;
@property (strong, nonatomic) AudioStreamer *streamer;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) NSURL *audioURL;
@property (assign, nonatomic) NSUInteger trackNum;

@end


@implementation MoeFmPlayer
@synthesize playlist = _playlist;
@synthesize delegate = _delegate;
@synthesize streamer = _streamer;
@synthesize updateTimer = _updateTimer;
@synthesize trackNum = _trackNum;


- (MoeFmPlayer *) initWithDelegate:(NSObject <MoeFmPlayerDelegate> *)delegate{
	self = [super init];
	self.delegate = delegate;
    synthesizer = [[NSSpeechSynthesizer alloc] init];
	return self;
}

# pragma mark - Getter and Setter

- (void)setPlaylist:(NSArray *)playlist{
	_playlist = playlist;
	self.trackNum = 0;
	[self stop];
	[self start];
}


# pragma mark - Streamer

- (void)createStreamerWithURL:(NSURL *)streamURL{
	if(self.streamer){
		[self destroyStreamer];
	}
	self.streamer = [[AudioStreamer alloc] initWithURL:streamURL];
    [self.streamer setMeteringEnabled:YES];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(streamerStateChanged:)
	 name:ASStatusChangedNotification 
	 object:self.streamer];
	
	//NSLog(@"New streamer created:%@",streamURL);
}

- (void)destroyStreamer
{
	if(self.streamer){
		[self.streamer stop];
		self.streamer = nil;
		
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:self.streamer];
	}
}

- (void)toggleTimers:(BOOL)create 
{
	if (create) {
		if (self.streamer) {
			[self toggleTimers:NO];
			self.updateTimer =
			[NSTimer
			 scheduledTimerWithTimeInterval:0.001
			 target:self
			 selector:@selector(updateProgress:)
			 userInfo:nil
			 repeats:YES];
		}
	}
	else {
		if (self.updateTimer)
		{
			[self.updateTimer invalidate];
			self.updateTimer = nil;
		}
	}
}

- (void)streamerStateChanged:(NSNotification *)aNotification
{
//	MFMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	[self.delegate player:self stateChangesTo:[self.streamer state]];
	
	if ([self.streamer isPlaying])
	{
		//NSLog(@"Streamer is playing");
		[self toggleTimers:YES];
		return;
	}
	else if ([self.streamer isWaiting])
	{
		//NSLog(@"Streamer is waiting");
		[self toggleTimers:NO];
	}
	else if ([self.streamer isPaused]) {
		//NSLog(@"Streamer is paused");
		[self toggleTimers:NO];
	}
	else if ([self.streamer isIdle])
	{
		//NSLog(@"Streamer is idle");
		[self toggleTimers:NO];
	}
	
	if(self.streamer.errorCode != AS_NO_ERROR){
		//NSLog(@"Streamer stoped with error %@", [AudioStreamer stringForErrorCode:[self.streamer errorCode]]);
		if([self.delegate respondsToSelector:@selector(player:stoppingWithError:)]){
			//[self.delegate player:self stoppingWithError:[AudioStreamer stringForErrorCode:[self.streamer errorCode]]];
		}
		[self stop];
        [self next];
	}
	
	if(self.streamer.stopReason == AS_STOPPING_EOF){
		NSLog(@"Streamer reach EOF(End Of File), play next");

        [self systemOverVoiceSay:@"歌曲文件異常終了"];

		[self next];
	}
    
}

- (void)updateProgress:(NSTimer *)timer
{
	if(self.streamer){
        [self.delegate player:self updateLastSongTime:self.streamer.duration - self.streamer.progress];
	}
}



- (void)updateMetadata
{
	[self.delegate player:self updateMetadata:[self.playlist objectAtIndex:self.trackNum]];
    [self.delegate player:self playlistDownloadCompete:self.playlist];
}

- (void)start
{
	if(!self.playlist){
		[self.delegate player:self needToUpdatePlaylist:self.playlist];
		return;
	}
	if(!self.streamer){
		NSDictionary *music = [self.playlist objectAtIndex:self.trackNum];
		NSString *audioAddress = [music objectForKey:@"url"];
		_audioURL = [NSURL URLWithString:audioAddress];
		[self createStreamerWithURL:_audioURL];
		[self updateMetadata];
	}
	if (![self.streamer isPlaying]) {
		[self.streamer start];
		NSLog(@"Player start on track %ld", self.trackNum);
	}
}
- (void)startTrack:(NSUInteger)trackNum
{
	if(!self.streamer){}
	else if(trackNum == self.trackNum && [self.streamer isPlaying]){
		return;
	}
	else if([self.streamer isWaiting]){
		return;
	}
	
	if(trackNum >= [self.playlist count]){
		[self.delegate player:self needToUpdatePlaylist:self.playlist];
		return;
	}
	
	self.trackNum = trackNum;
	
	[self stop];
	[self start];
}

- (void)pause{
	if(self.streamer){
		[self.streamer pause];
        [self systemOverVoiceSay:@"一時停止"];
	}
}

- (void)startOrPause{
	if(!self.streamer || [self.streamer isPaused] || [self.streamer isIdle]){
		[self start];
        [self systemOverVoiceSay:@"再生を開始します"];
	}
	else if([self.streamer isPlaying]) {
		[self pause];
	}
}

- (void)stop{
	if(self.streamer){
		[self.streamer stop];
		[self destroyStreamer];
	}
	//NSLog(@"Player stop");
}

- (void)next{
    [self systemOverVoiceSay:@"次の曲"];
	[self startTrack:self.trackNum + 1];
}

- (void)previous{
    [self systemOverVoiceSay:@"上の曲"];
//	if(self.streamer){
//		[self.streamer seekToTime:0];
//	}
//	else {
//		[self startTrack:self.trackNum - 1];
//	}
    if (self.trackNum == 0) {
        [self.streamer seekToTime:0];
        
    }else{
        [self startTrack:self.trackNum - 1];
    }
}
- (void)seektotime:(float)time{
    NSLog(@"%f",time);
    if (self.streamer.duration){
		double newSeekTime = (time / 100.0) * self.streamer.duration;
		[self.streamer seekToTime:newSeekTime];
	}
}


-(void)systemOverVoiceSay:(NSString *)string{
    if (_voiceOverP == YES) {
        [synthesizer setVolume:0.8];
        [synthesizer setDelegate:self];
        
        if (synthesizer.isSpeaking == NO) {
            [synthesizer startSpeakingString:string];
            
        }else{
            [synthesizer stopSpeakingAtBoundary:NSSpeechImmediateBoundary];
            [synthesizer startSpeakingString:string];
        }
        
        
    }
}

@end
