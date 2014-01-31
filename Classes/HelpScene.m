//  Credit to Nintendo for tileset

#import "HelpScene.h"
#import "MainMenuScene.h"

@implementation HelpScene
- (id) init {
	self = [super init];
	if (self != nil) {
		[self addChild:[HelpLayer node] z:1];
	}
	return self;
}
@end

@implementation HelpLayer
- (id) init {
	self = [super init];
	if (self != nil) {
		
		// respond to touches
		isTouchEnabled_ = YES;
		
		//creates tile map and adds to layer
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"help.tmx"];
		[self addChild:map z:0 tag:1];
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Block Jumper" fontName:@"Marker Felt" 
									 fontSize:64];
		
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , 250 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		// create and initialize a Label
		CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Touch the screen to make Mario jump" fontName:@"Marker Felt" 
											   fontSize:16];
		
		
		// position the label on the center of the screen
		label2.position =  ccp( size.width /2 , 200 );
		
		// add the label as a child to this Layer
		[self addChild: label2];
		
		// create and initialize a Label
		CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"Let go of the screen to place a block" fontName:@"Marker Felt" 
											   fontSize:16];
		
	
		
		// position the label on the center of the screen
		label3.position =  ccp( size.width /2 , 175 );
		
		// add the label as a child to this Layer
		[self addChild: label3];
		
		// create and initialize a Label
		CCLabelTTF *label4 = [CCLabelTTF labelWithString:@"Reach the other side to win" fontName:@"Marker Felt" 
											   fontSize:16];
		
		
		
		// position the label on the center of the screen
		label4.position =  ccp( size.width /2 , 150 );
		
		// add the label as a child to this Layer
		[self addChild: label4];
		
		
		// create and initialize a Label
		CCLabelTTF *label5 = [CCLabelTTF labelWithString:@"The total number of blocks is displayed in the right hand corner" fontName:@"Marker Felt" 
											   fontSize:16];
		
	
		
		// position the label on the center of the screen
		label5.position =  ccp( size.width /2 , 125 );
		
		// add the label as a child to this Layer
		[self addChild: label5];
		
		
		// create and initialize a Label
		CCLabelTTF *label6 = [CCLabelTTF labelWithString:@"Hit springs to jump higher" fontName:@"Marker Felt" 
											   fontSize:16];
		
		
	
		
		// position the label on the center of the screen
		label6.position =  ccp( size.width /2 , 100 );
		
		// add the label as a child to this Layer
		[self addChild: label6];
		
		// create and initialize a Label
		CCLabelTTF *label7 = [CCLabelTTF labelWithString:@"Double tap a level to go back to Main Menu" fontName:@"Marker Felt" 
											   fontSize:16];
		
	
		
		// position the label on the center of the screen
		label7.position =  ccp( size.width /2 , 75 );
		
		// add the label as a child to this Layer
		[self addChild: label7];
	}
	
	
	return self;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	MainMenuScene *scene = [MainMenuScene node];
	[[CCDirector sharedDirector] replaceScene:scene];
}

@end
