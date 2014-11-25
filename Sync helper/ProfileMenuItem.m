//
//  ProfileMenuItem.m
//  Statusbar test
//
//  Created by Midge 't Hoen on 04-05-13.
//  Copyright (c) 2013 Midge 't Hoen. All rights reserved.
//

#import "ProfileMenuItem.h"
@interface ProfileMenuItem (private)
-(void)resetTitle;
@end

@implementation ProfileMenuItem
@synthesize name = _name, exitCode = _exitCode;

-(void)setName:(NSString *)name{
    _name = name;
    [self resetTitle];
}

-(void)setExitCode:(UnisonExitCode)exitCode{
    _exitCode = exitCode;
    [self resetTitle];
}

-(void)resetTitle{
    switch (self.exitCode) {
        case UnisonExitCodeSucces:
            self.title = self.name;
            break;
            
        case UnisonExitCodeSkipped:
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ (Files skipped)", @"menu status files where skipped with profile placeholder"), self.name];
            break;
            
        case UnisonExitCodeNonFatalErrorOccurred:
        case UnisonExitCodeFatalErrorOccurred:
            self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ (Error occured)", @"menu status error occured with profile placeholder"), self.name];
            break;

        default:
            break;
    }
}


@end
