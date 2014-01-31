//  Clayton Brady
//  May 3, 2011
//  Description:  I created a game where the user jumps from one platform to another 
//			by placing a series of blocks.  The user touches the screen and Mario jumps 
//			and then releases the screen to place a block.  The user has a limited number 
//			of blocks.  Mario only jumps to the right and springs will make him jump higher.  
//			Double tapping a screen will bring the user back to the main screen.  The physics is 
//			done using box2d
//	Proposed Points:  I believe I deserve the full 30/30 points.  The code has some minor glitches 
//			to it including the spring not always springing correctly and the blocks label not 
//			updating, but I feel the rest of the code is very good.  It took a little bit of 
//			researching and a lot of time to figure out some of the box2d code and I deviated 
//			slightly from my original idea but I feel I incorporated all that I wanted to.  
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MainMenuScene : CCScene { }

@end

@interface MainMenuLayer : CCLayer { }

-(void)newLevel2:(id)sender;
-(void)newLevel3:(id)sender;
-(void)newGame:(id)sender;
-(void)help:(id)sender;

@end