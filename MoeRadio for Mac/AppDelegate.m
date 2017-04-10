//
//  AppDelegate.m
//  MoeRadio for Mac
//
//  Created by bi119aTe5hXk on 12-10-8.
//  Copyright (c) 2013年 HT&L. All rights reserved.
//

#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()
@property (strong, nonatomic) MoeFmPlayer *player;
@property (strong, nonatomic) MoeFmAPI *playlistAPI;
@property (strong, nonatomic) MoeFmAPI *imageAPI;
@property (nonatomic) NSInteger page;
- (MoeFmAPI *)createAPI;
@end



@implementation AppDelegate
@synthesize windowlevel = _windowlevel;
@synthesize player = _player;
@synthesize playlistAPI = _playlistAPI;
@synthesize imageAPI = _imageAPI;

-(void)applicationWillTerminate:(NSNotification *)notification{
    subidcopy = nil;
    _subid = nil;
    [self systemOverVoiceSay:@"終了します" delay:NO stopPrev:NO];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *) __unused theApplication hasVisibleWindows:(BOOL)flag{
    if (!flag){
        [[self window] makeKeyAndOrderFront:self];
    }
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Init...");
    NSLog(@"Powered by");
    NSLog(@" __   __              __            ");
    NSLog(@"|  ＼／  |           ／ _|           ");
    NSLog(@"| ＼  ／ | ___   ___| |_ ___  __  __ ");
    NSLog(@"| |＼／| |／_ ＼/  _ ＼  _／_ ＼| | | |");
    NSLog(@"| |   | |  (_) |  __／ || (_) | |_| |");
    NSLog(@"|_|   |_|＼___／＼___|_| ＼___／＼__,_|");
    NSLog(@"Product by ©HT&L 2009-2017, Developer: @bi119aTe5hXk. @Ariagle. @gregwym.");
    NSLog(@"なにこれ(°Д°)？！");
    
    Gestalt(gestaltSystemVersionMajor, &versMaj);
    Gestalt(gestaltSystemVersionMinor, &versMin);
    Gestalt(gestaltSystemVersionBugFix, &versBugFix);
    NSLog(@"Your system version is: %d.%d.%d\n", versMaj, versMin, versBugFix);
    
    musicdataloaded = NO;
    synthesizer = [[NSSpeechSynthesizer alloc] init];
    
    userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"windowlevel",nil]];
    [userdefaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"voiceOver",nil]];
    windowlevel = [userdefaults boolForKey:@"windowlevel"];
    voiceOver = [userdefaults boolForKey:@"voiceOver"];
    
    [self systemOverVoiceSay:@"初期化"  delay:NO stopPrev:NO];
    
    [self setNameScrollText:NSLocalizedString(@"MAIN_TITLE_INIT", nil)];
    [self setInfoScrollText:NSLocalizedString(@"MAIN_SUBTITLE_LOAD_COMPETE", nil)];
    
    if(!self.playlistAPI){
        self.playlistAPI = [self createAPI];
    }
    if(!self.imageAPI){
        self.imageAPI = [self createAPI];
    }
    if(!self.player){
        self.player = [[MoeFmPlayer alloc] initWithDelegate:self];
    }
    
    if (windowlevel == YES) {
        [self.window setLevel:kCGStatusWindowLevel];
        [self.windowlevel setState:NSOnState];
        [self.windowlevelcheckbox setState:NSOnState];
    }else{
        [self.window setLevel:kCGNormalWindowLevel];
        [self.windowlevel setState:NSOffState];
        [self.windowlevelcheckbox setState:NSOffState];
    }
    
    if (voiceOver == YES) {
        voiceOver = YES;
        _player.voiceOverP = YES;
        [self.voiceovercheckbox setState:NSOnState];
        
    }else{
        voiceOver = NO;
        _player.voiceOverP = NO;
        [self.voiceovercheckbox setState:NSOffState];
    }
    self.page = 0;
    playmode = @"normal";
    [self.switchtoplaynormal setState:NSOnState];
    
    [self systemOverVoiceSay:@"初期化完了" delay:YES stopPrev:NO];
}
-(IBAction)windowlevel:(id)sender{
    if (windowlevel == YES) {
        windowlevel = NO;
        [self.window setLevel:kCGNormalWindowLevel];
        [self.windowlevel setState:NSOffState];
        [self.windowlevelcheckbox setState:NSOffState];
        [userdefaults setBool:NO forKey:@"windowlevel"];
    }else{
        windowlevel = YES;
        [self.window setLevel:kCGStatusWindowLevel];
        [self.windowlevel setState:NSOnState];
        [self.windowlevelcheckbox setState:NSOnState];
        [userdefaults setBool:YES forKey:@"windowlevel"];
    }
}
-(IBAction)voiceover:(id)sender{
    if (voiceOver == YES) {
        voiceOver = NO;
        _player.voiceOverP = NO;
        [self.voiceovercheckbox setState:NSOffState];
        [userdefaults setBool:NO forKey:@"voiceOver"];
    }else{
        voiceOver = YES;
        _player.voiceOverP = YES;
        [self.voiceovercheckbox setState:NSOnState];
        [userdefaults setBool:YES forKey:@"voiceOver"];
        synthesizer = [[NSSpeechSynthesizer alloc] init];
    }
}


#pragma mark - Actions
-(IBAction)playbtnpressd:(id)sender{
    [self startOrPause];
}
-(IBAction)nextbtnpressd:(id)sender{
    [self next];

}
-(IBAction)prebtnpressd:(id)sender{
    [self previous];
}

-(void)forcereset{
    [self stop];
    NSLog(@"Player Reseting...");
    
    self.playlistAPI = nil;
    self.imageAPI = nil;
    self.player = nil;
    self.wikiimage = nil;
    songnamestr = nil;
    songartiststr = nil;
    songalbumstr = nil;
    musicdataloaded = NO;
    playingprogress = 0;
    songduration = 0;
    self.subid = nil;
    self.artwork.image = nil;
    imageURL = nil;
    self.page = 0;
    
    self.playlistAPI = [self createAPI];
    self.imageAPI = [self createAPI];
    self.player = [[MoeFmPlayer alloc] initWithDelegate:self];

    [self next];
    
    if (voiceOver == YES) {
        voiceOver = YES;
        _player.voiceOverP = YES;
        [self.voiceovercheckbox setState:NSOnState];
    }else{
        voiceOver = NO;
        _player.voiceOverP = NO;
        [self.voiceovercheckbox setState:NSOffState];
    }
    
}


-(IBAction)switchtoplaynormal:(id)sender{
    playmode = @"normal";
    [self forcereset];
    [self.switchtoplaynormal setState:NSOnState];
}

#pragma mark - metadata

- (void) updateMetadata:(NSDictionary *)metadata
{
    imageURL = nil;
    self.suburl = nil;
    self.wikiurl = nil;
    self.subid = nil;
    self.lfsongurl = nil;
    songnamestr = nil;
    songartiststr = nil;
    songalbumstr = nil;
    
    NSString *name = [metadata objectForKey:@"sub_title"];
    NSString *artist = [metadata objectForKey:@"artist"];
    NSString *album = [metadata objectForKey:@"wiki_title"];
    name = [self htmlEntityDecode:name];
    artist = [self htmlEntityDecode:artist];
    album = [self htmlEntityDecode:album];
    
    songnamestr = name;
    songartiststr = artist;
    songalbumstr = album;
    if([name length] == 0) {
		name = NSLocalizedString(@"UNKONW_SONG", @"");
	}

    [self setNameScrollText:name];
    
    if([artist length] == 0) {
		artist = NSLocalizedString(@"UNKNOW_ARTIST", @"");;
	}
	if([album length] == 0) {
		album = NSLocalizedString(@"UNKNOW_ALBUM", @"");
	}
    NSString *infostr = [NSString stringWithFormat:@"%@ / %@", artist, album];
    [self setInfoScrollText:infostr];
    
    self.suburl = [metadata objectForKey:@"sub_url"];
    self.wikiurl = [metadata objectForKey:@"wiki_url"];
    self.subid = [metadata objectForKey:@"sub_id"];
    
    
    
    //Download ArtWork
	NSString *imageAddress = [[metadata objectForKey:@"cover"] objectForKey:@"large"];

    if (imageAddress != imageAddress1) {
        imageAddress1 = imageAddress;
        self.artwork.image = [NSImage imageNamed:@"cover_large"];
        imageURL = [NSURL URLWithString:imageAddress];
        if(self.imageAPI.isBusy){
            [self.imageAPI cancelRequest];
            NSLog(@"Image API request canceled");
        }
        BOOL status = [self.imageAPI requestImageWithURL:imageURL];
        if(status == NO){
            // Fail to establish connection
            NSLog(@"Unable to load image for %@. Retry.", imageURL);
            status = [self.imageAPI requestImageWithURL:imageURL];
        }else{
            [self.artworkprogress startAnimation:self.artworkprogress];
            [self.artworkprogress setHidden:NO];
        }
    }else{
        //same Album
    }
    
    musicdataloaded = YES;
    
    
    NSString *string = [NSString stringWithFormat:@"%@ 。アーティスト。 %@",name,artist];
    
    //name
    string = [string stringByReplacingOccurrencesOfString:@"未知艺术家" withString:@"作者不明"];
    
    string = [string stringByReplacingOccurrencesOfString:@"μ's" withString:@"みゅーず"];
    string = [string stringByReplacingOccurrencesOfString:@"Give Me 5" withString:@"Give Me five"];
    string = [string stringByReplacingOccurrencesOfString:@"CAN'T" withString:@"CANT"];
    string = [string stringByReplacingOccurrencesOfString:@"Don't" withString:@"Dont"];
    string = [string stringByReplacingOccurrencesOfString:@"☆" withString:@"ほし"];
    string = [string stringByReplacingOccurrencesOfString:@"♡" withString:@"ハーと"];
    string = [string stringByReplacingOccurrencesOfString:@"'s" withString:@"ず"];
    
    
    //spical
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@";" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@"`" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@" And "];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@"|" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"。"];
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@"。"];
    
    
    [self systemOverVoiceSay:string delay:YES stopPrev:YES];
    

}


- (void) updateArtworkWithImage:(NSImage *)image{
    self.artwork.image = image;
    self.wikiimage = image;
    [_artworkdetail setImage:image];
    [self.artworkprogress stopAnimation:self.artworkprogress];
    [self.artworkprogress setHidden:YES];
}



#pragma mark - Player Controls

- (void)start{
	[self.player start];
}
- (void)pause{
	[self.player pause];
}
- (void)startOrPause{
	[self.player startOrPause];
}
- (void)stop{
	[self.player stop];
}
- (void)next{
    [self stop];
	[self.player next];
}
- (void)previous{
    [self stop];
    imageURL = nil;
    playingprogress = 0;
	[self.player previous];
}



#pragma mark - MoeFmAPI returns

- (void)player:(MoeFmPlayer *)player needToUpdatePlaylist:(NSArray *)currentplaylist
{
	//NSLog(@"Requesting playlist");
    [self setInfoScrollText:NSLocalizedString(@"MAIN_TITLE_LOADING_PLAYLIST",@"")];
	if(self.playlistAPI.isBusy){
		NSLog(@"Playlist API is busy, try again later");
        [self setInfoScrollText:NSLocalizedString(@"MAIN_TITLE_LOADING_PLAYLIST_BUSY",@"")];
        
		return;
	}
    ++self.page;
    NSString *url = [@playlisturl stringByAppendingFormat:@"&page=%ld",self.page];
	BOOL status = [self.playlistAPI requestListenPlaylistWithURL:url];
	if(status == NO){
		// Fail to establish connection
		NSLog(@"Unable to create connection for playlist");
	}
}
- (void)player:(MoeFmPlayer *)player updateMetadata:(NSDictionary *)metadata{
	[self updateMetadata:metadata];
}

- (void)player:(MoeFmPlayer *)player stateChangesTo:(AudioStreamerState)state{
	switch (state) {
		case AS_WAITING_FOR_DATA:
            self.playbtn.image = [NSImage imageNamed:@"pause.png"];
            self.playbtn.alphaValue = 1;
            [self.songprogress startAnimation:self.songprogress];
            [self.songprogress setHidden:NO];
			break;
            
		case AS_BUFFERING:
            self.playbtn.image = [NSImage imageNamed:@"pause.png"];
            self.playbtn.alphaValue = 1;
            [self.songprogress startAnimation:self.songprogress];
            [self.songprogress setHidden:NO];
			break;
            
		case AS_PLAYING:
            self.playbtn.image = [NSImage imageNamed:@"pause.png"];
            self.playbtn.alphaValue = 1;
            [self.songprogress stopAnimation:self.songprogress];
            [self.songprogress setHidden:YES];
			break;
            
		case AS_PAUSED:
            self.playbtn.image = [NSImage imageNamed:@"play.png"];
            self.playbtn.alphaValue = 1;
            [self.songprogress stopAnimation:self.songprogress];
            [self.songprogress setHidden:YES];
			break;
            
		case AS_STOPPED:
            self.playbtn.image = [NSImage imageNamed:@"play.png"];
            self.playbtn.alphaValue = 1;
            [self.songprogress stopAnimation:self.songprogress];
            [self.songprogress setHidden:YES];
			break;
			
		default:
			break;
	}
}
- (void)player:(MoeFmPlayer *)player stoppingWithError:(NSString *)error
{
    NSLog(@"Error:%@",error);
    if (musicdataloaded == NO) {
        [self setNameScrollText:NSLocalizedString(@"MAIN_TITLE_ERROR",@"")];
        [self setInfoScrollText:NSLocalizedString(@"MAIN_SUBTITLE_PLAYER_ERR",@"")];
        [self systemOverVoiceSay:@"申し訳ございません" delay:NO stopPrev:NO];
        NSRunAlertPanel(NSLocalizedString(@"ALERT_TITLE_PLAYER_ERR",@""), error, nil,nil,nil);
    }
    self.page = 0;
}


#pragma mark - MoeFmAPI Delegates
- (MoeFmAPI *)createAPI{
	return [[MoeFmAPI alloc] initWithApiKey:@MFCkey delegate:self];
}
- (void)api:(MoeFmAPI *)api readyWithPlaylist:(NSArray *)playlist{
	[self.player setPlaylist:playlist];
}
- (void)api:(MoeFmAPI *)api readyWithImage:(NSImage *)image{
	[self updateArtworkWithImage:image];
}
- (void)api:(MoeFmAPI *)api requestFailedWithError:(NSError *)error{
	NSLog(@"Error:%@",error);
    NSString *err = [NSString stringWithFormat:@"%@",error];
    if (musicdataloaded == NO) {
        [self setNameScrollText:NSLocalizedString(@"MAIN_TITLE_ERROR",@"")];
        [self setInfoScrollText:NSLocalizedString(@"MAIN_SUBTITLE_REQUEST_FAILED",@"")];
        [self systemOverVoiceSay:@"申し訳ございません" delay:NO stopPrev:NO];
        NSRunAlertPanel(NSLocalizedString(@"ALERT_TITLE_REQUEST_FAILED",@""), err, nil,nil,nil);
    }
    self.page = 0;
}

- (void)player:(MoeFmPlayer *)player updateLastSongTime:(NSInteger)lasttime{
    [self.songtimel setHidden:NO];
    
    int seconds = lasttime % 60;
    int minutes = (lasttime / 60) % 60;
    if (seconds < 10 && minutes > 10) {
        [self.songtimel setStringValue:[NSString stringWithFormat:@"- %d:0%d",minutes,seconds]];
    }
    if (minutes < 10 && seconds > 10){
        [self.songtimel setStringValue:[NSString stringWithFormat:@"- 0%d:%d",minutes,seconds]];
    }
    if (minutes > 10 && seconds > 10){
        [self.songtimel setStringValue:[NSString stringWithFormat:@"- %d:%d",minutes,seconds]];
    }
    if (minutes < 10 && seconds <10) {
        [self.songtimel setStringValue:[NSString stringWithFormat:@"- 0%d:0%d",minutes,seconds]];
    }
}

-(void)player:(MoeFmPlayer *)player playlistDownloadCompete:(NSArray *)playlist{
    
}
-(void)player:(MoeFmPlayer *)player updateProgress:(float)percentage{
    playingprogress = percentage;
}



-(IBAction)showPerefencePanel:(id)sender{
    if (perferencePanelController == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PerferencePanel" owner:self topLevelObjects:nil];
        perferencePanelController = [[NSWindowController alloc]
                               initWithWindow:perferencePanel];
        }
    [perferencePanelController showWindow:self];
    [perferencePanel becomeFirstResponder];
    if (windowlevel == YES) {
        [self.window setLevel:kCGStatusWindowLevel];
        [self.windowlevel setState:NSOnState];
        [self.windowlevelcheckbox setState:NSOnState];
    }else{
        [self.window setLevel:kCGNormalWindowLevel];
        [self.windowlevel setState:NSOffState];
        [self.windowlevelcheckbox setState:NSOffState];
    }
    if (voiceOver == YES) {
        voiceOver = YES;
        _player.voiceOverP = YES;
        [self.voiceovercheckbox setState:NSOnState];
        [userdefaults setBool:YES forKey:@"voiceOver"];
    }else{
        voiceOver = NO;
        _player.voiceOverP = NO;
        [self.voiceovercheckbox setState:NSOffState];
        [userdefaults setBool:NO forKey:@"voiceOver"];
    }
    
}

-(IBAction)showArtworkPanel:(id)sender{
    if (_wikiimage != nil){
        if (!artworkviewPanelController) {
            [[NSBundle mainBundle] loadNibNamed:@"ArtworkviewPanel" owner:self topLevelObjects:nil];
            artworkviewPanelController = [[NSWindowController alloc] initWithWindow:artworkviewPanel];
            [_artworkdetail setImage:self.wikiimage];
            [artworkviewPanelController showWindow:self];
            [artworkviewPanel becomeFirstResponder];
        }else{
            [artworkviewPanel close];
            artworkviewPanelController = nil;
        }
    }
}

-(IBAction)closeAWP:(id)sender{
    [artworkviewPanel close];
    artworkviewPanelController = nil;
}


-(void)notplayingwarning{
     [self systemOverVoiceSay:@"申し訳ございません" delay:NO stopPrev:NO];
    NSRunAlertPanel(NSLocalizedString(@"ALERT_TITLE_NOT_PLAYING_ERR",@""), NSLocalizedString(@"ALERT_MSG_NOT_PLAYING_ERR",@""), nil,nil,nil);
}
-(void)notloginmoefouwarning{
    [self systemOverVoiceSay:@"申し訳ございません" delay:NO stopPrev:NO];
    NSRunAlertPanel(NSLocalizedString(@"ALERT_TITLE_NOT_LOGIN_IN_MOEFOU",@""), NSLocalizedString(@"ALERT_MSG_NOT_LOGIN_IN_MOEFOU",@""),nil,nil,nil);
}




#pragma mark - share part

-(IBAction)sharetotwitter:(id)sender{
    if (musicdataloaded == YES) {
        if(versMin >= 8)
        {
            NSString *text = [NSString stringWithFormat:@"%@ %@ %@ #NowPlaying #萌否电台 %@",songnamestr,songartiststr,songalbumstr,self.suburl];
            
            NSImage *image = self.wikiimage;
            NSArray * shareItems = [NSArray arrayWithObjects:text, image, nil];
            
            NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
            service.delegate = self;
            [service performWithItems:shareItems];
        } else {
            NSString *songurl = self.suburl;
            NSString *hashtag = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)@"萌否电台",NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSString *urlstr = [NSString stringWithFormat:@"%@",songurl];
            NSString *urlEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)urlstr,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSString *nameEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self.window.title,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@&hashtags=%@&url=%@",nameEncoded,hashtag,urlEncoded]];
            [[NSWorkspace sharedWorkspace] openURL:url];
            //NSLog(@"%@",url);
            nameEncoded = nil;
            urlEncoded = nil;
            hashtag = nil;
        }
    }else{
        [self notplayingwarning];
    }
}
-(IBAction)sharetofacebook:(id)sender{
    if (musicdataloaded == YES) {
        if(versMin >= 8)
        {
            NSString *text = [NSString stringWithFormat:@"%@ %@ %@ #NowPlaying# #萌否电台# %@",songnamestr,songartiststr,songalbumstr,self.suburl];
            NSImage *image = self.wikiimage;
            NSArray * shareItems = [NSArray arrayWithObjects:text, image, nil];
            
            NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
            service.delegate = self;
            [service performWithItems:shareItems];
        } else {
            NSString *songurl = self.suburl;
            NSString *urlstr = [NSString stringWithFormat:@"%@",songurl];
            NSString *urlEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)urlstr,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/sharer.php?u=%@",urlEncoded]];
            [[NSWorkspace sharedWorkspace] openURL:url];
            //NSLog(@"%@",url);
            urlEncoded = nil;
        }
    }else{
        [self notplayingwarning];
    }
}
-(IBAction)sharetogoogleplus:(id)sender{
    if (musicdataloaded == YES) {
        NSString *songurl = self.suburl;
        NSString *hashtag = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)@" #NowPlaying# #萌否电台#",NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
        NSString *urlstr = [NSString stringWithFormat:@"%@",songurl];
        NSString *urlEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)urlstr,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
        NSString *nameEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self.window.title,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://plusone.google.com/_/+1/confirm?url=%@&title=%@%@",urlEncoded,hashtag,nameEncoded]];
        [[NSWorkspace sharedWorkspace] openURL:url];
        //NSLog(@"%@",url);
        nameEncoded = nil;
        urlEncoded = nil;
        hashtag = nil;
    }else{
        [self notplayingwarning];
    }
}
-(IBAction)sharetosinaweibo:(id)sender{
    if (musicdataloaded == YES) {
        if(versMin >= 8)
        {
            NSString *text = [NSString stringWithFormat:@"%@ %@ %@ #萌否电台# #NowPlaying# %@",songnamestr,songartiststr,songalbumstr,self.suburl];
            NSImage *image = self.wikiimage;
            NSArray * shareItems = [NSArray arrayWithObjects:text, image, nil];
            
            NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnSinaWeibo];
            service.delegate = self;
            [service performWithItems:shareItems];
        } else {
            NSString *songurl = self.suburl;
            NSString *hashtag = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)@" #NowPlaying# #萌否电台#",NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSString *urlstr = [NSString stringWithFormat:@"%@",songurl];
            NSString *urlEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)urlstr,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSString *nameEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self.window.title,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://service.weibo.com/share/share.php?title=%@%@&url=%@",nameEncoded,hashtag,urlEncoded]];
            [[NSWorkspace sharedWorkspace] openURL:url];
            //NSLog(@"%@",url);
            nameEncoded = nil;
            urlEncoded = nil;
            hashtag = nil;
        }
    }else{
        [self notplayingwarning];
    }
}
-(IBAction)sharetotencentweibo:(id)sender{
    if (musicdataloaded == YES) {
        if(versMin >= 9){
            NSString *text = [NSString stringWithFormat:@"%@ %@ %@ #萌否电台# %@",songnamestr,songartiststr,songalbumstr,self.suburl];
            NSImage *image = self.wikiimage;
            NSArray * shareItems = [NSArray arrayWithObjects:text, image, nil];
            
            NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTencentWeibo];
            service.delegate = self;
            [service performWithItems:shareItems];
        }else{
            NSString *songurl = self.suburl;
            NSString *hashtag = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)@" #NowPlaying# #萌否电台#",NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSString *urlstr = [NSString stringWithFormat:@"%@",songurl];
            NSString *urlEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)urlstr,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSString *nameEncoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self.window.title,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://v.t.qq.com/share/share.php?title=%@&url=%@%@",nameEncoded,urlEncoded,hashtag]];
            [[NSWorkspace sharedWorkspace] openURL:url];
            //NSLog(@"%@",url);
            nameEncoded = nil;
            urlEncoded = nil;
            hashtag = nil;
        }
    }else{
        [self notplayingwarning];
    }
}


#pragma mark - web

-(IBAction)visitmoefm:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@mainurl]];
}
-(IBAction)menufeedback:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@supporturl]];
}
-(IBAction)buyfullversion:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@buylink]];
}
-(IBAction)showsonginweb:(id)sender{
    if (musicdataloaded == YES) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.suburl]];
    }else{
        [self notplayingwarning];
    }
}
-(IBAction)showalbuminweb:(id)sender{
    if (musicdataloaded == YES) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.wikiurl]];
    }else{
        [self notplayingwarning];
    }
}

-(IBAction)openvoperpanel:(id)sender{
    [[NSWorkspace sharedWorkspace]
     openFile:@"/System/Library/PreferencePanes/Speech.prefPane"];
}

-(NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    string = [string stringByReplacingOccurrencesOfString:@"&rarr;" withString:@"→"];
    string = [string stringByReplacingOccurrencesOfString:@"&larr;" withString:@"←"];
    string = [string stringByReplacingOccurrencesOfString:@"&darr;" withString:@"↓"];
    string = [string stringByReplacingOccurrencesOfString:@"&uarr;" withString:@"↑"];
    string = [string stringByReplacingOccurrencesOfString:@"&hellip;" withString:@"…"];
    string = [string stringByReplacingOccurrencesOfString:@"&infin;" withString:@"∞"];
    string = [string stringByReplacingOccurrencesOfString:@"&mu;" withString:@"μ"];
    string = [string stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"“"];
    string = [string stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"”"];
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"“"];
    string = [string stringByReplacingOccurrencesOfString:@"&middot;" withString:@"·"];
    string = [string stringByReplacingOccurrencesOfString:@"&minus;" withString:@"−"];
    string = [string stringByReplacingOccurrencesOfString:@"&times;" withString:@"×"];
    string = [string stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"’"];
    return string;
}

-(void)systemOverVoiceSay:(NSString *)string delay:(BOOL)delay stopPrev:(BOOL)stopprev{
    if (voiceOver == YES) {
        saystring = string;
        
        [synthesizer setVolume:0.8];
        [synthesizer setDelegate:self];
        
        
        if (stopprev == YES) {
            [synthesizer stopSpeakingAtBoundary:NSSpeechImmediateBoundary];
        }
        
        
        if (delay == YES) {
            [NSTimer scheduledTimerWithTimeInterval:0.9
                                             target:self
                                           selector:@selector(say)
                                           userInfo:nil
                                            repeats:NO];
        }else{
            [synthesizer startSpeakingString:saystring];
        }
    }
}
-(void)say{
    [synthesizer startSpeakingString:saystring];
}



-(void)setNameScrollText:(NSString *)str{
    self.namescroll.font = [NSFont systemFontOfSize:13];
	[self.namescroll setString:str];
    [self.namescroll setScrollingSpeed:0.5];
}
-(void)setInfoScrollText:(NSString *)str{
    self.infoscroll.font = [NSFont systemFontOfSize:9];
	[self.infoscroll setString:str];
    [self.infoscroll setScrollingSpeed:1.0];
    
    [self.infoscroll setAlphaValue:0.7];
}



@end
