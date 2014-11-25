//
//  StatusItemView.h
//  Statusbar test
//
//  Created by Midge 't Hoen on 03-05-13.
//  Copyright (c) 2013 Midge 't Hoen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    StatusIdle,
    StatusBusy
} Status;

@interface StatusItemView : NSView <NSMenuDelegate>{
    Status _currentStatus;
    BOOL menuIsVisible;
}

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) NSStatusItem *statusItem;

-(void)setStatus:(Status)status;
-(void)setStatus:(Status)status progress:(float)progress;
-(IBAction)beBusy:(id)sender;

@end
