//
//  ProfileMenuItem.h
//  Statusbar test
//
//  Created by Midge 't Hoen on 04-05-13.
//  Copyright (c) 2013 Midge 't Hoen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface ProfileMenuItem : NSMenuItem

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) UnisonExitCode exitCode;

@end
