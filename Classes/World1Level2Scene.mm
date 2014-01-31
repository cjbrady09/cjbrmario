//
//  World1Level2Scene.m
//  MenuTransitions
//
//  Created by Clayton Brady on 4/18/11.
//  Copyright 2011 Drake University. All rights reserved.
//
//  Credit to Nintendo for the use of mario as a sprite and mario tilesets

#import "World1Level2Scene.h"
#import "MainMenuScene.h"
#define PTM_RATIO 32


enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
	kJumpImpulse = 500,
};


@implementation World1Level2Scene


- (id) init {
	self = [super init];
	if (self != nil) {
		[self addChild:[World1Level2Layer node] z:0];
	}
	return self;
}
@end

@implementation World1Level2Layer

@synthesize shots, blocks;

- (id) init {
	self = [super init];
	if (self != nil) {
		// respond to touches
		self.isTouchEnabled = YES;
		
		// sets boolean to false to indicate game is continuing
		didWin = false;
		
		// sets accelerometer on
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		//creates gravity vector
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		bool doSleep = true;
		
		//adds gravity to world
		world = new b2World(gravity, doSleep);
		
		//sets gravity to be continuous
		world->SetContinuousPhysics(true);
		
		//Debug Draw Functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		m_debugDraw->SetFlags(flags);
		
		// Define ground body
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0,0);
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
		
		//Define the ground box shape.
		b2PolygonShape groundBox;
		
		//left platform
		groundBox.SetAsEdge(b2Vec2(0,(275)/PTM_RATIO), b2Vec2(75/PTM_RATIO,(275)/PTM_RATIO));
		groundBody->CreateFixture(&groundBox, 0);
		
		//right platform
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,75/PTM_RATIO), b2Vec2(350/PTM_RATIO,75/PTM_RATIO));
		groundBody->CreateFixture(&groundBox, 0);
		
		// hanging wall
		groundBox.SetAsEdge(b2Vec2(200/PTM_RATIO,(screenSize.height+500)/PTM_RATIO), b2Vec2(200/PTM_RATIO,200/PTM_RATIO));
		groundBody->CreateFixture(&groundBox,0);
		
		// bottom of the hanging wall
		groundBox.SetAsEdge(b2Vec2(200/PTM_RATIO,200/PTM_RATIO), b2Vec2(250/PTM_RATIO,200/PTM_RATIO));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2((screenSize.width-25)/PTM_RATIO,(screenSize.height+500)/PTM_RATIO), b2Vec2((screenSize.width-25)/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		//sets block count to 4
		self.shots = 4;
		
		//adds tiledmap
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"level2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		//creates sprite
		player = [[CCSprite spriteWithFile:@"mario.png"] retain];
		
		//scales sprite
		player.scale = .4;
		
		//gets window size
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		//creates body for sprite
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		
		//sets sprite position and creates body
		bodyDef.position.Set(50/PTM_RATIO, 300/PTM_RATIO);
		bodyDef.userData = player;
		body = world->CreateBody(&bodyDef);
		
		//defines body physics
		b2PolygonShape dynamicBox;
		dynamicBox.SetAsBox(.5f, .75f);
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &dynamicBox;
		fixtureDef.density = 1.0f;
		fixtureDef.friction = 0.3f;
		body->CreateFixture(&fixtureDef);
		
		//adds sprite
		[self addChild: player z:1];
		
		//sets sprite position
		[player setPosition: ccp(25, 280)];
		
		// create and initialize a Labe
		CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Blocks: %d", shots] 
						  //CCLabel *label = [CCLabel labelWithString:@"Shots:"
										 fontName:@"Marker Felt" 
										 fontSize:20];
		
		// position the label on the center of the screen
		label.position = ccp( 400 , 300 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		
		[self schedule: @selector(tick:)];
		
	}
	return self;
} 


-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
}

-(void) registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
													 priority:0 
											  swallowsTouches:YES];
}

-(void) win {

	// create and initialize a Labe
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"You Win!!!" 
										   fontName:@"Times New Roman" 
										   fontSize:56];
	
	//changes text color to red
	label.color = ccc3(255, 0, 0);
	
	// position the label on the center of the screen
	label.position = ccp( 200 , 150 );
	
	// add the label as a child to this Layer
	[self addChild: label];
	
}

-(void) lose {
	// create and initialize a Labe
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game Over" 
										   fontName:@"Times New Roman" 
										   fontSize:56];
	
	//changes text color to red
	label.color = ccc3(255, 0, 0);
	
	// position the label on the center of the screen
	label.position = ccp( 200 , 150 );
	
	// add the label as a child to this Layer
	[self addChild: label];
}

-(void) tick: (ccTime) dt
{	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
	//displays if a player loses
	if (player.position.y<=0) {
		self.lose;
		didWin = true;
	}
	
	//displays if a player wins
	if (player.position.y>75 && player.position.y< 125 && player.position.x>350) {
		self.win;
		didWin = true;
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}

//creates a block unaffected by gravity
-(void) addNewStaticSpriteWithCoords:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	CCSprite *sprite = [[CCSprite spriteWithFile:@"block.png"] retain];
	[batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body1 = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body1->CreateFixture(&fixtureDef);
}

//creates a block affected by gravity
-(void) addNewDynamicSpriteWithCoords:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	CCSprite *sprite = [[CCSprite spriteWithFile:@"block.png"] retain];
	[batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body2 = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body2->CreateFixture(&fixtureDef);
}

//applies a force to simulate jumping
-(void) jump {
	body->ApplyForce(b2Vec2(150.0,kJumpImpulse), body->GetWorldCenter());
}

//happens when touch is began..
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	
	//if user touches twice then return to main menu
	if ([touch tapCount] == 2) {
		MainMenuScene *scene = [MainMenuScene node];
		[[CCDirector sharedDirector] replaceScene:scene];
	} 
	
	//if user touches once and has not finished the game then jump
	else if([touch tapCount] == 1 && didWin==false) {
		
		self.jump;
		
	}
	
	CGPoint location = [touch locationInView: [touch view]];
	
	//creates animation of mario running
	CCAnimation* animation = [CCAnimation animationWithName:@"run" delay:0.1f];
	[animation addFrameWithFilename: @"mario1.png"];
	[animation addFrameWithFilename: @"mario2.png"];
	id action = [CCAnimate actionWithAnimation: animation];
	id actionRepeat = [CCRepeat actionWithAction:action times:5];
	[player runAction:actionRepeat];
	id actionTo = [CCMoveTo actionWithDuration: 1 position:ccp(location.y, location.x)];
	[player runAction: actionTo];

	return YES;
}

//happens when touch is ended..
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//if user has shots left...
	if(shots>0) {
		
		//Add a new body/atlas sprite at the touched location
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		//adds a static block
		[self addNewStaticSpriteWithCoords: location];
		
		//decreases number of blocks left
		shots--;
	}
}
- (void) dealloc {
	[super dealloc];
	[player release];
	[blocks release];
}

@end

