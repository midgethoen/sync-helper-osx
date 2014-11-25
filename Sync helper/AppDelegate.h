//
//  AppDelegate.h
//  Statusbar test
//
//  Created by Midge 't Hoen on 03-05-13.
//  Copyright (c) 2013 Midge 't Hoen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "StatusItemView.h"

typedef enum {
    UnisonExitCodeSucces                    = 0,
    UnisonExitCodeSkipped                   = 1,
    UnisonExitCodeNonFatalErrorOccurred     = 2,
    UnisonExitCodeFatalErrorOccurred        = 3,
} UnisonExitCode;

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSStatusItem *_statusItem;
    NSMenuItem *statusMenuItem;
    NSMutableArray *_profiles;
    NSTask *task;
    int _profileBeingSynced;
    BOOL syncingAllProfiles;
    
    NSArray *images;
    NSTimer *animationTimer;
    unsigned int animationFrame;
    
    //automatic syncing
    NSMenuItem *autoSyncMenuItem;
    NSTimer *syncTimer;
}

@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, assign) BOOL syncsAutomatically;

@end
