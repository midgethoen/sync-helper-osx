//
//  StatusItemView.m
//  Statusbar test
//
//  Created by Midge 't Hoen on 03-05-13.
//  Copyright (c) 2013 Midge 't Hoen. All rights reserved.
//

#import "StatusItemView.h"

@implementation StatusItemView;


-(id)initWithFrame:(NSRect)frameRect{
    if (self = [super initWithFrame:frameRect]){
        [self setStatus:StatusIdle];
    }
    return self;
}

-(void)setStatus:(Status)status{
    [self setStatus:status progress:-1];
}
-(void)setStatus:(Status)status progress:(float)progress{
    switch (status) {
        case StatusIdle:{
            CGRect frame = self.frame;
            frame.size.width = frame.size.height;
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:.3f];
            [self.animator setFrame:frame];
            [NSAnimationContext endGrouping];
            
            [self.progressIndicator stopAnimation:nil];
        }
            break;
        case StatusBusy:{
            CGRect frame = self.frame;
            frame.size.width = 100;
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:.3f];
            [self.animator setFrame:frame];
            [NSAnimationContext endGrouping];
            
                    
            [self.progressIndicator startAnimation:nil];
            
            if (progress > 0) {
                [self.progressIndicator setIndeterminate:NO];
                self.progressIndicator.doubleValue = progress;
            } else {
                [self.progressIndicator setIndeterminate:YES];
            }
        }
            break;
            
            
        default:
            break;
    }
}

-(IBAction)beBusy:(id)sender{
    [self setStatus:StatusBusy];
}

-(void)menuDidClose:(NSMenu *)menu{
    menuIsVisible = NO;
}
-(void)menuWillOpen:(NSMenu *)menu{
    menuIsVisible = YES;
}
-(void)mouseUp:(NSEvent *)theEvent{
    if (!menuIsVisible){
        [self.statusItem popUpStatusItemMenu:self.statusItem.menu];
    }
}
@end
