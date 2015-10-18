
SceneState scene;

String launchString = "Launch a game";
String playString = "Play";
String waitingPlayerString;

PImage titleBackground;
PImage title;
float titleBackgroudOffset = 0;
float titleScale = 1;
boolean displayPressA = false;
float displayPressATimer = 0;

Rect mouse;
Rect launchButton;
Rect playButton;

int textSize = 32;


PVector cameraPosition;
float cameraWidth;
float cameraHeight;

// Data paths
String characterSpriteSheetPath = "data/Characters/";
String mapTilesSpriteSheetPath = "data/Sprites/";
String spritesPath = "data/Sprites/";

private SpriteSheet tilesSpriteSheet;
private SpriteSheet torchSpriteSheet;
private SpriteSheet lavaSpriteSheet;
private SpriteSheet trapSpriteSheet;
private SpriteSheet sawSpriteSheet;
private SpriteSheet transformationEffectSpriteSheet;
private SpriteSheet invincibilityEffectSpriteSheet;
private SpriteSheet powerEffectSpriteSheet;

MessageHandler messageHandler;

int clientId = (int)random(2,255);
String ipAdress = "127.0.0."+clientId;

static WhereWolf globalEnv;

void setup(){
  
 //Init Programme
 size(displayWidth,displayHeight, P2D);
 frameRate(120);
 noSmooth(); //To prevent antialiasing
 ((PGraphicsOpenGL)g).textureSampling(3);
 textSize(textSize);   
 
 ImageManager.start(this);
 Input.start(this);
 messageHandler = new MessageHandler(this);
 
 scene = SceneState.Title;
 
 launchButton = new Rect(width/2, height/2, 1.5f*textWidth(launchString), 1.5f*textSize);

 
 mouse = new Rect(mouseX, mouseY, 32, 32); // To represent the mouse on the screen
 
 titleBackground = ImageManager.getImage("Misc/title_WhereWolf.png");
 //titleBackground.resize(0,displayHeight);
 titleScale = displayHeight* 1.0f /titleBackground.height;
 title = ImageManager.getImage("Misc/title.png");
 
 // Defines inputs
 Input.addAxis("Horizontal","Q","D");
 Input.addAxis("Horizontal","joystick Axe X");
 Input.addAxis("Vertical","Z","S");
 Input.addAxis("Vertical","joystick Axe Y");
 Input.addButton("Jump","ESPACE"); // Warning : not working on mac... so I also add K button to jump
 //Input.addButton("Jump","K");
 Input.addButton("Jump","joystick Bouton 0");
 Input.addButton("Fire","A");
 Input.addButton("Fire","joystick Bouton 1");
 Input.addButton("DebugGetDamage","P");
 Input.addButton("ShowHideMiniMap","M");
 Input.addButton("Special","joystick Bouton 2");
 Input.addButton("Special","E");
 
 Input.addAxis("Horizontal2","J","L");
 Input.addAxis("Vertical2","I","K");
 Input.addButton("Jump2","O");

  // Load game sprite sheets  
  tilesSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "tilesSpriteSheet.png", 24, 20);
  torchSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "torchSpriteSheet.png", 4, 1);
  lavaSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "lavaSpriteSheet.png", 4, 1);
  trapSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "trapSpriteSheet.png", 3, 1);
  sawSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "fullSawSpriteSheet.png", 2, 1);
  transformationEffectSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "transformationEffectSpriteSheet.png", 9, 1);
  invincibilityEffectSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "invincibilityEffectSpriteSheet.png", 6, 1);
  powerEffectSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "powerEffectSpriteSheet.png", 3, 1);
  
  globalEnv = this;
  //Time.setTimeScale(0);
  
  Updatables.start();
  GUI.start(this);
}
 


void draw(){
  
  background(100);
  
  Input.update();
  Updatables.update();
  
  messageHandler.update();
  
  fill(0);
  //text(ipAdress, width - textWidth(ipAdress), 32);
    
  switch(scene){
    
   case Title :
     pushMatrix();
     scale(titleScale);
     image(titleBackground,titleBackgroudOffset-titleBackground.width,0);
     image(titleBackground,titleBackgroudOffset,0);
     image(titleBackground,titleBackgroudOffset+titleBackground.width,0);
     
     titleBackgroudOffset += Time.unscaledDeltaTime() * titleBackground.width * 0.3f;
     
     if(titleBackgroudOffset > titleBackground.width)
       titleBackgroudOffset -= titleBackground.width;
     if(Input.getButtonDown("Jump"))
       scene = SceneState.MainMenu;
      popMatrix();
      
      image(title,width/2-title.width/2,title.height/2);
      
      if(displayPressA){
        fill(255);
        GUI.labelCenter(new PVector(width/2,height/3.0f*2),"Press A ...");
        fill(0);
      }
      displayPressATimer += Time.unscaledDeltaTime()*1.5;
      
      if(displayPressATimer > 1){
        displayPressA = ! displayPressA;
        displayPressATimer -= 1;
      }
      
   break;
   
   case MainMenu :
    
      pushMatrix();
     scale(titleScale);
     image(titleBackground,titleBackgroudOffset-titleBackground.width,0);
     image(titleBackground,titleBackgroudOffset,0);
     image(titleBackground,titleBackgroudOffset+titleBackground.width,0);
     
     titleBackgroudOffset += Time.unscaledDeltaTime() * titleBackground.width * 0.3f;
     
     if(titleBackgroudOffset > titleBackground.width)
       titleBackgroudOffset -= titleBackground.width;
      popMatrix();
      
      image(title,width/2-title.width/2,title.height/2);
    
    fill(255);
    launchButton.draw();   
    
    fill(0);
    text(launchString, launchButton.position.x - textWidth(launchString)/2, launchButton.position.y + textSize/4);
    
    if(Input.getButtonDown("Jump")){
      connectToServer();
    } else{
      if(mouse.intersect(launchButton)){
        fill(255,0,0);
        if(mousePressed){
          connectToServer();
        }
      } else{
        fill(0);
      }
    }
    
    
   //rect(mouse.position.x, mouse.position.y, 2*mouse.halfDimension.x, 2*mouse.halfDimension.y);
  break;
  
  case ServerWaitingForLaunch :
    fill(255);
    playButton.draw();
    fill(0);
    text(waitingPlayerString, width/2-textWidth(playString),height/2-textSize);
    text(playString, playButton.position.x - textWidth(playString)/2, playButton.position.y + textSize/4);
    
    if(Input.getButtonDown("Jump")){          
      Scene.startScene(new GameObject("Scene", new PVector(), null));
      map = new MapManager(8, ""); 
      launchGame();
    } else{  
      if(mouse.intersect(playButton)){
        fill(255,0,0);
        if(mousePressed){
          Scene.startScene(new GameObject("Scene", new PVector(), null));
          map = new MapManager(8, ""); 
          launchGame();
        }
      }
      
      else{
        fill(0);    
      }
    }
    

    
    
    
  break;
  
  case ClientWaitingForLaunch :
    fill(0);
    text(waitingPlayerString, width/2-textWidth(playString),height/2-textSize);
    //Network.read();
    messageHandler.update();
  break;
    
  case Loading :
    text("Loading...", width/2-textWidth(playString),height/2-textSize);
  break;
  
  case Game :
    gameDraw();
  break;
  
  default :
    println("ERROR ERROR CASE NOT MANAGED");
  break;  
  
  }
  
  if(scene != SceneState.Game){
    mouse.position.x = mouseX;
    mouse.position.y = mouseY;
    mouse.draw(); 
  }
    
}

boolean sketchFullScreen() {
  if(Constants.DEBUG_MODE)
    return false;
    
  //return true;
  return false;
}

public void connectToServer(){
  if(!Network.connectClient(this, "127.0.0.1", 12345, ipAdress)){
    Network.connectServer(this, 12345); 
    waitingPlayerString = "You are the host.\nWaiting for player connexion...";
    scene = SceneState.ServerWaitingForLaunch;
  } else {
    println("Client ip = " + ipAdress);
    waitingPlayerString = "You are a client.\nWaiting for player connexion...";
    scene = SceneState.ClientWaitingForLaunch;
  }
  
 playButton = new Rect(width/2, height/2 + 3*textSize, 1.5f*textWidth(playString), 1.5f*textSize);
}

public void launchGame(){
  scene = SceneState.Loading;
  thread("initGame");
  fill(0);
}
