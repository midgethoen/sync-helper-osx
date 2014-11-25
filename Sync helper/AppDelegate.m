//
//  AppDelegate.m
//  Statusbar test
//
//  Created by Midge 't Hoen on 03-05-13.
//  Copyright (c) 2013 Midge 't Hoen. All rights reserved.
//

#import "AppDelegate.h"
#import "ProfileMenuItem.h"

@interface AppDelegate (private)
-(void)profileMenuItemClicked:(NSMenuItem *)menuItem;
-(void)syncProfile:(NSString *)profile;
-(void)syncAllProfiles;
-(void)taskFinished:(NSNotification *)aNotification;
-(void)updateStatusMenuItem;
@end

@implementation AppDelegate
@synthesize statusItem = _statusItem, syncsAutomatically = _syncsAutomatically;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    //setup the menu
    [self stopIconAnimation]; //this also initializes the images and sets idle state
    [[self statusItem] setMenu:[self createMenu]];
    
    //load user defaults
    [self setSyncsAutomatically:[[NSUserDefaults standardUserDefaults] boolForKey:@"autosync"]];
    [self updateStatusMenuItem];
    
    //register for task finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskFinished:)
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
}

-(id)init{
    if (self = [super init]){
        _profileBeingSynced = -1;
    }
    return self;
}

-(NSMenu *)createMenu{
    NSMenu *menu = [NSMenu new];
    statusMenuItem = [[NSMenuItem alloc] initWithTitle:@"bla"
                                                action:nil
                                         keyEquivalent:@""];
    [menu addItem:statusMenuItem];
    [menu addItem:[NSMenuItem separatorItem]];
    for (ProfileMenuItem *profile in [self profiles]){
        [menu addItem:profile];
        
    }
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Sync all now", @"Sync all profiles now menu item")
                                             action:@selector(syncAllProfiles) keyEquivalent:@""]];
    autoSyncMenuItem = [[NSMenuItem alloc] initWithTitle:@"none"
                                                  action:@selector(toggleSyncsAutomattically:)
                                           keyEquivalent:@""];
    [menu addItem:autoSyncMenuItem];
    return menu;
}
-(NSStatusItem *)statusItem{
    if (!_statusItem){
        NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
        _statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
        [_statusItem setHighlightMode:YES];
    }
    return _statusItem;
}
-(NSArray *)profiles{
    if (!_profiles){
        _profiles = [NSMutableArray array];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *err;
        NSArray *contents = [fm contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/Unison"]
//                              includingPropertiesForKeys:nil
//                                                 options:nil
                                                   error:&err];
        if (err) @throw [NSException exceptionWithName:@"Something went wrong fetching profiles" reason:err.localizedDescription userInfo:nil];
        
        for (NSString *item in contents) {
            if ([[item pathExtension] isEqualToString:@"prf"] &&
                ![[item substringToIndex:1] isEqualToString:@"_"]){
                ProfileMenuItem *pmi = [[ProfileMenuItem alloc] initWithTitle:@"" action:@selector(profileMenuItemClicked:) keyEquivalent:@""];
                [pmi setName:[item stringByDeletingPathExtension]];
                [pmi setExitCode:UnisonExitCodeSucces];
                [_profiles addObject:pmi];
            }
        }
    }
    return _profiles;
}

-(void)profileMenuItemClicked:(ProfileMenuItem *)menuItem{
    NSLog(@"sync %@", menuItem.title);
    [self syncProfile:menuItem withUi:YES];
}

#pragma mark - Automatic syncing
-(void)toggleSyncsAutomattically:(NSMenuItem *)menuItem{
    self.syncsAutomatically = !self.syncsAutomatically;
}
-(BOOL)syncsAutomatically{
    return _syncsAutomatically;
}
-(void)setSyncsAutomatically:(BOOL)syncsAutomatically{
    _syncsAutomatically = syncsAutomatically;
    [[NSUserDefaults standardUserDefaults] setBool:syncsAutomatically forKey:@"autosync"];
    if (syncsAutomatically){
        syncTimer = [NSTimer scheduledTimerWithTimeInterval:5*60 //5 min
                                                     target:self
                                                   selector:@selector(syncAllProfiles)
                                                   userInfo:nil
                                                    repeats:YES];
        autoSyncMenuItem.title = NSLocalizedString(@"Turn automatic syning off", @"menu item");
    } else {
        [syncTimer invalidate];
        syncTimer = nil;
        autoSyncMenuItem.title = NSLocalizedString(@"Turn automatic syning on", @"menu item");
    }
}

#pragma mark - Handling unison
-(void)syncAllProfiles{
    syncingAllProfiles = YES;
    [self syncProfile:[[self profiles] objectAtIndex:0] withUi:NO];
}
-(void)syncProfile:(ProfileMenuItem *)profile withUi:(BOOL)ui{
    if (!task){
        [self startIconAnimation];
        
        NSArray *args;
        if (ui) {
            args = [NSArray arrayWithObjects:profile.name, @"-batch", nil];
        } else {
            args = [NSArray arrayWithObjects:profile.name, @"-ui", @"text", @"-batch", nil];
        }
        _profileBeingSynced = (int) [[self profiles] indexOfObject:profile];
        task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/unison"
                                        arguments:args];
    }
}
-(void)taskFinished:(NSNotification *)aNotification{
    UnisonExitCode exitCode = [[aNotification object] terminationStatus];
    [(ProfileMenuItem *)[[self profiles] objectAtIndex:_profileBeingSynced] setExitCode:exitCode];
    task = nil;
    if (syncingAllProfiles){
        if (!(_profileBeingSynced == [[self profiles] count]-1)){
            //this was not the last
            [self syncProfile:[[self profiles] objectAtIndex:_profileBeingSynced+1] withUi:NO];
            [self updateStatusMenuItem];
            return; //skip stopping the animation:)
        }
        [[NSUserDefaults standardUserDefaults] setValue:[[NSDate date] description] forKey:@"syncdate"];
    }
    _profileBeingSynced = -1;
    [self stopIconAnimation];
    [self updateStatusMenuItem];
}

#pragma mark - Status item & icon animation
-(void)updateStatusMenuItem{
    static NSDateFormatter *df = nil;
    if (!df){
        df = [[NSDateFormatter alloc] init];
        [df setLocale:[NSLocale currentLocale]];
//        [df setLenient:YES];
        [df setDoesRelativeDateFormatting:YES];
        [df setDateStyle:NSDateFormatterShortStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
    }
    if (_profileBeingSynced == -1){
        //no profile is being synced
        NSDate *date = [[NSDate alloc] initWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"syncdate"]];
        if (!date){
            statusMenuItem.title = NSLocalizedString(@"Has not been synced", @"sync status");
        } else {
            statusMenuItem.title = [NSString stringWithFormat:NSLocalizedString(@"Synced %@", @"sync status"), [df stringFromDate:date]];
        }
    } else {
        //somthing is being synced, find out which and say so
        statusMenuItem.title = [NSString stringWithFormat:NSLocalizedString(@"Syncing %@", @"sync status"), [[self profiles] objectAtIndex:_profileBeingSynced]];
    }
}

-(NSArray *)images{
    if (!images) {
        NSMutableArray *tImages = [NSMutableArray arrayWithCapacity:12];
        for (int i = 0 ; i < 7; i++) {
            [tImages addObject:[NSImage imageNamed:[NSString stringWithFormat:@"sbicon%i", i]]];
            [tImages addObject:[NSImage imageNamed:[NSString stringWithFormat:@"sbicon%i_h", i]]];
        }
        images = [NSArray arrayWithArray:tImages];
    }
    return images;
}
-(void)startIconAnimation{
    if (!animationTimer){
        animationFrame = 0;
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.08
                                                          target:self
                                                        selector:@selector(nextAnimationFrame)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}
-(void)stopIconAnimation{
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
    self.statusItem.image = [[self images] objectAtIndex:0];
    self.statusItem.alternateImage = [[self images] objectAtIndex:1];
}
-(void)nextAnimationFrame{
    animationFrame = (animationFrame+1)%6;
    self.statusItem.image = [[self images] objectAtIndex:2*animationFrame];
    self.statusItem.alternateImage = [[self images] objectAtIndex:2*animationFrame+1];
}

@end
