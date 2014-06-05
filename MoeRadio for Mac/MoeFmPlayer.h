//
//  MoeFmPlayer.h
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"

@class MoeFmPlayer;

@protocol MoeFmPlayerDelegate

- (void)player:(MoeFmPlayer *)player needToUpdatePlaylist:(NSArray *)currentplaylist;

@optional
- (void)player:(MoeFmPlayer *)player updateLastSongTime:(NSInteger)lasttime;
- (void)player:(MoeFmPlayer *)player updateMetadata:(NSDictionary *)metadata;


- (void)player:(MoeFmPlayer *)player stateChangesTo:(AudioStreamerState)state;
- (void)player:(MoeFmPlayer *)player stoppingWithError:(NSString *)error;

- (void)player:(MoeFmPlayer *)player needNetworkAccess:(BOOL)allow;
- (void)player:(MoeFmPlayer *)player logTheSong:(BOOL)yes;

- (void)player:(MoeFmPlayer *)player playlistDownloadCompete:(NSArray *)playlist;

@end


@interface MoeFmPlayer : NSObject<NSSpeechSynthesizerDelegate>{
    NSString *saystring;
    NSSpeechSynthesizer *synthesizer;
}

@property (strong, nonatomic) NSArray *playlist;
@property (assign, nonatomic) BOOL voiceOverP;

- (MoeFmPlayer *) initWithDelegate:(NSObject <MoeFmPlayerDelegate> *)delegate;

- (void)start;
- (void)pause;
- (void)startOrPause;
- (void)stop;
- (void)next;
- (void)previous;
@end
