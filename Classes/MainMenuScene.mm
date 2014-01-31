//Credit to Nintendo for the Mario sprite and tileset


#import "MainMenuScene.h"
#import "World1Level1Scene.h"
#import "World1Level2Scene.h"
#import "World1Level3Scene.h"
#import "HelpScene.h"

@implementation MainMenuScene

- (id) init {
	self = [super init];
	if (self != nil) {
		//adds tilemap to main menu scene
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"main.tmx"];
		[self addChild:map z:0 tag:1];
		[self addChild:[MainMenuLayer node] z:1];
	}
	return self;
}

@end

@implementation MainMenuLayer

- (id) init {
	self = [super init];
	if (self != nil) {
		//sets font for menu
		[CCMenuItemFont setFontSize:48];
		[CCMenuItemFont setFontName:@"Marker Felt"];
		
		//creates menu item for level 1
		CCMenuItem *start = [CCMenuItemFont itemFromString:@"Level 1" 
												target:self 
											  selector:@selector(newGame:)];
		//creates menu item for level 2
		CCMenuItem *lvl2 = [CCMenuItemFont itemFromString:@"Level 2"
												   target:self
												 selector:@selector(newLevel2:)];
		//creates menu item for level 3
		CCMenuItem *lvl3 = [CCMenuItemFont itemFromString:@"Level 3"
												   target:self
												 selector:@selector(newLevel3:)];
		//creates menu item for help screen
		CCMenuItem *help = [CCMenuItemFont itemFromString:@"Help" 
											   target:self 
											  selector:@selector(help:)];
		
		//changes font color of all items
		[(CCMenuItemFont *)start setColor:ccc3(0,0,0)];
		[(CCMenuItemFont *)lvl2 setColor:ccc3(0,0,0)];
		[(CCMenuItemFont *)lvl3 setColor:ccc3(0,0,0)];
		[(CCMenuItemFont *)help setColor:ccc3(0,0,0)];
		
		//adds all items to the menu item
		CCMenu *menu = [CCMenu menuWithItems:start, lvl2, lvl3, help, nil];
		
		//aligns menu
		[menu alignItemsVertically];
		
		//adds menu to scene
		[self addChild:menu];
	}
	return self;
}

//when level 1 is pressed, replace scene with level1
-(void)newGame:(id)sender {
	World1Level1Scene *scene = [World1Level1Scene node];
	[[CCDirector sharedDirector] replaceScene:scene];		
}

//when level 2 is pressed, replace scene with level2
-(void)newLevel2:(id)sender {
	World1Level2Scene *scene = [World1Level2Scene node];
	[[CCDirector sharedDirector] replaceScene:scene];
}

//when level 3 is pressed, replace scene with level3
-(void)newLevel3:(id)sender {
	World1Level3Scene *scene = [World1Level3Scene node];
	[[CCDirector sharedDirector] replaceScene:scene];
}

//when help is pressed, replace scene with help
-(void)help:(id)sender {
	HelpScene *scene = [HelpScene node];
	[[CCDirector sharedDirector] replaceScene:scene];		
}

@end