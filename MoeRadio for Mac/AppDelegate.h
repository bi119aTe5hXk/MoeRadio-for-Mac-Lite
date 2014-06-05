//
//  AppDelegate.h
//  MoeRadio for Mac
//
//  Created by bi119aTe5hXk on 12-10-8.
//  Copyright (c) 2013年 HT&L. All rights reserved.
//
#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#import "API.h"
#import "MoeFmAPI.h"
#import "MoeFmPlayer.h"

#import <Social/Social.h>

//#import "AppleRemote.h"
//#import "SPMediaKeyTap.h"
//#import "LastFm.h"
//#import "MD5.h"
//#import "NSDataAdditions.h"
#import "FBScrollingTextView.h"

//@class PlayList;
@interface AppDelegate : NSObject <NSApplicationDelegate,MoeFmAPIDelegate,MoeFmPlayerDelegate,NSSharingServiceDelegate,NSSpeechSynthesizerDelegate>{
    
    SInt32 versMaj, versMin, versBugFix;
    
    NSString *serialNumber;
    NSString *reginfo_username;
    NSString *reginfo_key;
    NSNumber *lesdate;
    NSString *saystring;
    
    NSUserDefaults * userdefaults;
    
    NSStatusItem *statusItem;
    
    IBOutlet NSPanel *perferencePanel;
    IBOutlet NSPanel *artworkviewPanel;
    
    NSWindowController *songRatingPanelController;
    NSWindowController *perferencePanelController;
    NSWindowController *artworkviewPanelController;
    
    //song info
    NSURL *imageURL;
    NSURL *lfsongurl;
    double songduration;
    NSString *songnamestr;
    NSString  *songartiststr;
    NSString *songalbumstr;
    NSString *imageAddress1;
    NSString *songid;
    
    BOOL musicdataloaded;
    BOOL windowlevel;
    BOOL voiceOver;
    
    float playingprogress;
    
    NSString *playmode;
    
    NSString *subidcopy;
    
    
    NSSpeechSynthesizer *synthesizer;
    
}

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic)  NSString *suburl;
@property (strong, nonatomic)  NSString *wikiurl;
@property (strong, nonatomic)  NSString *subid;
@property (strong, nonatomic)  NSImage *wikiimage;
@property (strong, nonatomic)  NSURL *mylfpageurl;
@property (strong, nonatomic)  NSURL *lfsongurl;

@property (nonatomic, strong) IBOutlet NSButton *playbtn;
@property (nonatomic, strong) IBOutlet NSButton *nextbtn;
@property (nonatomic, strong) IBOutlet FBScrollingTextView *namescroll;
@property (nonatomic, strong) IBOutlet FBScrollingTextView *infoscroll;
@property (nonatomic, strong) IBOutlet NSImageView *artwork;

@property (nonatomic, strong) IBOutlet NSTextField *songtimel;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *artworkprogress;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *songprogress;



@property (nonatomic, strong) IBOutlet NSMenuItem *windowlevel;
@property (nonatomic, strong) IBOutlet NSMenuItem *switchtoplaynormal;






//btn&menu
-(IBAction)playbtnpressd:(id)sender;
-(IBAction)nextbtnpressd:(id)sender;
-(IBAction)prebtnpressd:(id)sender;
-(IBAction)switchtoplaynormal:(id)sender;


-(IBAction)showalbuminweb:(id)sender;
-(IBAction)showsonginweb:(id)sender;

-(IBAction)windowlevel:(id)sender;
-(IBAction)visitmoefm:(id)sender;
-(IBAction)menufeedback:(id)sender;
-(IBAction)buyfullversion:(id)sender;


//sharebtn
-(IBAction)sharetotwitter:(id)sender;
-(IBAction)sharetofacebook:(id)sender;
-(IBAction)sharetogoogleplus:(id)sender;
-(IBAction)sharetosinaweibo:(id)sender;
-(IBAction)sharetotencentweibo:(id)sender;


//PerPanel
-(IBAction)showPerefencePanel:(id)sender;
@property (nonatomic, strong) IBOutlet NSButton *windowlevelcheckbox;
@property (nonatomic, strong) IBOutlet NSButton *voiceovercheckbox;
-(IBAction)openvoperpanel:(id)sender;
-(IBAction)voiceover:(id)sender;



//ArtWorkPanel
@property (strong, nonatomic) IBOutlet NSImageView *artworkdetail;
@property (nonatomic, strong) IBOutlet NSButton *awpclose;
-(IBAction)showArtworkPanel:(id)sender;
-(IBAction)closeAWP:(id)sender;





@end
