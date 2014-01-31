//
//
//
//  Credit given to Nintendo for the use of the Mario sprite and the tileset

#import "World1Level1Scene.h"
#import "MainMenuScene.h"
#define PTM_RATIO 32


enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
	kJumpImpulse = 500,
};

@implementation World1Level1Scene
- (id) init {
	self = [super init];
	if (self != nil) {
		[self addChild:[World1Level1Layer node] z:0];
	}
	return self;
}
@end

@implementation World1Level1Layer

@synthesize shots, blocks;

- (id) init {
	self = [super init];
	if (self != nil) {
		
		// respond to touches
		self.isTouchEnabled = YES;
		
		// turns on accelerometer
		self.isAccelerometerEnabled = YES;
		
		// initializes boolean to detect game end
		didWin = false;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		//creates gravity vector
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		bool doSleep = true;
		
		//assigns gravity to world
		world = new b2World(gravity, doSleep);
		
		//makes gravity in constant affect
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
		
		//bottom left
		groundBox.SetAsEdge(b2Vec2(0,(screenSize.height/2)/PTM_RATIO), b2Vec2(75/PTM_RATIO,(screenSize.height/2)/PTM_RATIO));
		groundBody->CreateFixture(&groundBox, 0);
		
		//bottom right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,(screenSize.height/2)/PTM_RATIO), b2Vec2(425/PTM_RATIO,(screenSize.height/2)/PTM_RATIO));
		groundBody->CreateFixture(&groundBox, 0);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		//sets number of blocks to 7
		self.shots = 7;
		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"level1.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		//creates sprite
		player = [[CCSprite spriteWithFile:@"mario.png"] retain];
		
		//scales sprite
		player.scale = .4;
		
		//gets window size
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		//defines sprite body
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		
		//creates sprite body
		bodyDef.position.Set(50/PTM_RATIO, (s.height/2+40)/PTM_RATIO);
		bodyDef.userData = player;
		body = world->CreateBody(&bodyDef);
		
		//initializes sprite physics
		b2PolygonShape dynamicBox;
		dynamicBox.SetAsBox(.5f, .75f);
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &dynamicBox;
		fixtureDef.density = 1.0f;
		fixtureDef.friction = 0.3f;
		body->CreateFixture(&fixtureDef);
		 
		
		//adds sprite
		[self addChild: player z:1];

		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Blocks: %d", shots] 
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
	
	//change label color to black
	label.color = ccc3(0, 0, 0);
	
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
	
	label.color = ccc3(0, 0, 0);
	
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
		didWin=true;
	}
	
	//displays if a player wins
	if (player.position.y>125 && player.position.x>425) {
		self.win;
		didWin=true;
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

//creates a box not affected by gravity
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

//creates a box affected by physics
-(void) addNewDynamicSpriteWithCoords:(CGPoint)p
{
	//creates a black
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

//apply a force to simulate jumping
-(void) jump {
	body->ApplyForce(b2Vec2(150.0,kJumpImpulse), body->GetWorldCenter());
}

//respond when touch begins
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	
	//if user touches twice, go back to main menu
	if ([touch tapCount] == 2) {
		MainMenuScene *scene = [MainMenuScene node];
		[[CCDirector sharedDirector] replaceScene:scene];
	} 
	
	//if user touches once and the game is still going...
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

//happens when user ends their touch
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//if the user has blocks...
	if(shots>0) {
	
	//Add a new body/atlas sprite at the touched location
		CGPoint location = [touch locationInView: [touch view]];
		CCLOG(@"here");
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		//add new static box
		[self addNewStaticSpriteWithCoords: location];
		
		shots--;
	}
}

- (void) dealloc {
	[super dealloc];
	[player release];
	[blocks release];
}

@end
