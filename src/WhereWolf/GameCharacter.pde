/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 23/05/2015 
        Last Modified : 22/05/2015
*/


/*
*/
public abstract class GameCharacter extends Component{
  
  AnimatorController animator;
  Rigidbody rigid;
  Collider characterCollider;
 
  private int life;  
  protected int armorLife;
  protected boolean isAlive = true;
  
  private PImage lifeSprite = ImageManager.getImage("data/Sprites/heart.png");
  private PImage armorLifeSprite = ImageManager.getImage("data/Sprites/armorHeart.png");
  
  private PVector colliderHalfDimensions;
  
  protected boolean facingRight = false;
  
  protected SpriteSheet walkAndIdle;  
  protected SpriteSheet deadSpriteSheet;
  
  protected Parameters params;
  protected State walkLeft,walkRight,idleRight,idleLeft, dead;
  
  protected boolean invulnerable = false;
  protected float takeDamageCooldown = 1300;
  protected float blinkDelay = 100;
  protected float blinkChrono;
  protected float blinkNumber = 0;
  protected float maxBlinkNumber; // defined by takeDamageCooldown
  protected boolean visible = true;
  
 
  protected boolean isRunning = false;
  protected Rect staticColliderRect;
  protected Rect runningColliderRect;
  
  private float damageMovementFactor = 150;
  private float damageMovementDecreaseSpeed = 2;
  
  private float xMovementCausedByDamage = 0;  
  private float minXmovementCausedByDamage = 0;  
  private float minYmovementCausedByDamage = 0;
  private float maxYmovementCausedByDamage = 0.5f;
  
  protected boolean staticGrave = false;
  
  private boolean canMove = true; 
  private float immobileChrono;
  private float immobileDelay;
  
  private float openChestImmobileDelay = 1000;
  
  private float movementSpeed = 70.0f;
  //private float movementSpeed = 170.0f;
  
  private boolean airJumpForDebug = true;
  
  private float invinciblityDuration;
  
  private GameObject invincibilityEffect;
  private GameObject powerEffect;
  
  protected float damageMultiplicator = 1;
  

  GameCharacter(){
    deadSpriteSheet = new SpriteSheet(characterSpriteSheetPath + "grave.png", 1, 1);
    dead = new State(new Animation(deadSpriteSheet, 0, false), 1);

    staticColliderRect = new Rect(0, 4, 6, 24);
    runningColliderRect = new Rect(0, 4, 10, 24);
  }
  
  public void init(){

    gameObject.addComponent(new NetworkView());
    this.addRPC("initPlayer", new DelegateInitPlayer(this));
    
    
    invincibilityEffect = new GameObject("invincibilityEffect", new PVector(-1,5), this.gameObject);
    
    Parameters invincibilityEffectParams = new Parameters();
    invincibilityEffectParams.setBool("Start", true);
    
    
    State invincibilityEffectAnimation =  new State(new Animation(invincibilityEffectSpriteSheet,0,true),15);
    invincibilityEffectAnimation.setScale(0.5f);
    
    AnimatorController invincibilityEffectAnimatorController = new AnimatorController(invincibilityEffectAnimation,invincibilityEffectParams);
    invincibilityEffect.addComponent(invincibilityEffectAnimatorController); 
    
    
    invincibilityEffectAnimatorController.parameters.setBool("Visible", true);
    invincibilityEffectAnimatorController.getCurrentState().startState();
    
    invincibilityEffect.setActive(false);
    
    
    powerEffect = new GameObject("powerEffect", new PVector(-2,5), this.gameObject);
    
    Parameters powerEffectParams = new Parameters();
    powerEffectParams.setBool("Start", true);
    
    
    State powerEffectAnimation =  new State(new Animation(powerEffectSpriteSheet,0,true),15);
    powerEffectAnimation.setScale(0.75f);
    
    AnimatorController powerEffectAnimatorController = new AnimatorController(powerEffectAnimation,powerEffectParams);
    powerEffect.addComponent(powerEffectAnimatorController); 
    
    
    powerEffectAnimatorController.parameters.setBool("Visible", true);
    powerEffectAnimatorController.getCurrentState().startState();
    
    powerEffect.setActive(false);
    
    gameObject.addComponent(new Collider(new Rect(0,0, walkAndIdle.getSpriteWidth(), walkAndIdle.getSpriteHeight())));
    characterCollider = (Collider)(gameObject.getComponent(Collider.class));
    characterCollider.layer = CollisionLayer.CharacterBody;
    characterCollider.passablePlatform = true;
    
    gameObject.addComponent(new Rigidbody());
    rigid = (Rigidbody)(gameObject.getComponent(Rigidbody.class));
    rigid.start();
    
   

    //characterCollider.forceDebugDraw = true;
    
    gameObject.addComponent(animator);
  }
  
 
  public void update(){
    if(!playerInitialized) return;
    super.update();
    
    if(rigid.getVelocity().x != 0 || rigid.getVelocity().y != 0){
      //Network.write("SetCharacterPosition " +  playerId + " " + gameObject.position.x + " " + gameObject.position.y + "endMessage");
    }
    
    //println(isAlive);
    if(isAlive){
      if(canMove) {
        rigid.setVelocity(new PVector(Input.getAxisRaw("Horizontal")*movementSpeed, rigid.getVelocity().y));
      } else {
        rigid.setVelocity(new PVector(0, rigid.getVelocity().y));
        if(millis() - immobileChrono > immobileDelay) canMove = true;
      }
      
      rigid.setVelocity(new PVector(rigid.getVelocity().x + xMovementCausedByDamage, rigid.getVelocity().y));
      
      if(xMovementCausedByDamage < 0){
        xMovementCausedByDamage += damageMovementDecreaseSpeed;
        if(xMovementCausedByDamage > 0) xMovementCausedByDamage = 0;
      }
      
      else if(xMovementCausedByDamage > 0){
        xMovementCausedByDamage -= damageMovementDecreaseSpeed;
        if(xMovementCausedByDamage < 0) xMovementCausedByDamage = 0;
      }
        
        if(Input.getButtonDown("Jump") && canMove && (rigid.grounded || airJumpForDebug)) {

          if(Input.getAxisRaw("Vertical") > 0){            
            for(int i=0 ; i<characterCollider.currentCollisions.size() ; i++){
              if(characterCollider.currentCollisions.get(i).passablePlatform){
                characterCollider.getOverlookColliders().add(characterCollider.currentCollisions.get(i));
              }
            } 

          }
          
          else{
            rigid.setVelocity(new PVector(rigid.getVelocity().x,-160.0f));
          }
        }
        
        else if(Input.getAxisRaw("Vertical") < 0 && rigid.getVelocity().x == 0){   
          for(int i=0 ; i<characterCollider.currentCollisions.size() ; i++){
            Chest chestComponent = (Chest)(characterCollider.currentCollisions.get(i).gameObject.getComponent(Chest.class));
            if(chestComponent != null){ // if collider is a chest and chest is closed
            
              float heightDelta = gameObject.getGlobalPosition().y - characterCollider.currentCollisions.get(i).gameObject.getGlobalPosition().y;
              if(heightDelta > -13 && heightDelta < -9){
                chestComponent.openChest(this); 
                canMove = false;
                immobileDelay = openChestImmobileDelay;
                immobileChrono = millis();
              }
            }
          }
        }
        

      //float xVelocity = (float)rigid.getVelocity().x;
      float xVelocity = Input.getAxisRaw("Horizontal")*movementSpeed;
      if(!canMove) xVelocity = 0;
      animator.parameters.setFloat("SpeedX",xVelocity);
      if(xVelocity > 0) {
        if(!isRunning){
          isRunning = true;
          characterCollider.setArea(runningColliderRect); 
        }
        facingRight = true;
      }
      else if(xVelocity < 0) {
        if(!isRunning){
          isRunning = true;
          characterCollider.setArea(runningColliderRect); 
        }
        facingRight = false;
      }
      
      else{
        if(isRunning){
          isRunning = false;
          characterCollider.setArea(staticColliderRect); 
        } 
      }
      
      if(invulnerable){
        if(millis() - blinkChrono > blinkDelay){
          blinkNumber++;
          visible = !visible;
          animator.parameters.setBool("Visible", visible);
          
          if(blinkNumber == maxBlinkNumber){
            invulnerable = false; 
            invincibilityEffect.setActive(false);
          }
          
          blinkChrono = millis();
          
        }
      }
    }
    
  }
  
  public int GetLife(){
    return life;
  }
  
  public void IncreaseLife(int n){
    life += n;
  }
  
  public void DecreaseLife(int n, PVector aggressorPosition){
    if(invulnerable) return;
    
    if(armorLife > 0){
      DecreaseArmorLife(n, aggressorPosition); 
    }
    
    else{
      life -= n;
      canMove = true;
      
      if(life <=0){
        life = 0;
        Die();
      }
      
      else{
        activateBlinkOfInvulnerability(takeDamageCooldown); 
        makeMoveCausedByDamage(aggressorPosition);
      }
    }
  }
      
  public int GetArmorLife(){
    return armorLife;
  }
  
  public void IncreaseArmorLife(int n){
    armorLife += n;
  }
  
  public void DecreaseArmorLife(int n, PVector aggressorPosition){
    if(invulnerable) return;
    armorLife -= n;
    canMove = true;
    if(armorLife <0){
      DecreaseLife(n+armorLife, aggressorPosition);
      armorLife = 0;
    }
    
    else{
      activateBlinkOfInvulnerability(takeDamageCooldown); 
      makeMoveCausedByDamage(aggressorPosition);
    }
  }
  
  public void SetLife(int n){
    life = n;
  }

  public void SetArmorLife(int n){
    armorLife = n;
  }
  
  public void AddArmorLife(int n){
    armorLife += n;
  }
  
  public void DecreaseArmorLife(int n){
    armorLife -= n;
  }
  
  public boolean isAlive(){
    return isAlive; 
  }
  
  public PVector GetColliderHalfDimensions(){
    return colliderHalfDimensions;
  }
  
  public void drawLife(){
    for(int i=0 ; i<life ; i++){
      image(lifeSprite,10+(lifeSprite.width+10)*i,10);
    }
   
    for(int i=0 ; i<armorLife ; i++){
      image(armorLifeSprite,10+(lifeSprite.width+10)*(i+life),10);
    }
  }
  
  public boolean isFacingRight(){
    return facingRight; 
  }
  
  public void makeMoveCausedByDamage(PVector aggressorPosition){
    PVector direction = PVector.sub(gameObject.position, aggressorPosition);
    direction.normalize();
    
    if(direction.y < -0.5f){
      if(direction.x < 0) direction.x += (direction.y + 0.5f);
      else if(direction.x > 0) direction.x -= (direction.y + 0.5f);
      direction.y = -0.5f; 
    }
    
    else if(direction.y > 0.5f) {
      
      if(direction.x < 0) direction.x -= (direction.y - 0.5f);
      else if(direction.x > 0) direction.x += (direction.y - 0.5f);
      direction.y = 0.5f; 
    }
    
    xMovementCausedByDamage = direction.x * damageMovementFactor;
    rigid.setVelocity(new PVector(rigid.getVelocity().x, direction.y * damageMovementFactor - 100));;
  }
  
  public void activateBlinkOfInvulnerability(float duration){
    invulnerable = true;
    blinkChrono = millis();
    blinkNumber = 0;
    maxBlinkNumber = duration / blinkDelay;
    if(maxBlinkNumber % 2 == 0) maxBlinkNumber++; // maxBlinkNumber must be impair number
    
    visible = false;
    animator.parameters.setBool("Visible", visible);
    
  }
  
  public void activateInvincibilityFeedback(){
     invincibilityEffect.setActive(true);
  }
  
  public GameObject getPowerEffect(){
     return powerEffect;
  }
  
  public void Die(){
    isAlive = false;
    animator.setCurrentState(dead);
    characterCollider.setArea(new Rect(0, 0, deadSpriteSheet.getSpriteWidth(), deadSpriteSheet.getSpriteHeight()));
    //characterCollider.layer = CollisionLayer.Environment;
    rigid.setVelocity(new PVector(0, rigid.getVelocity().y));
    
    //characterCollider.isTrigger = true;
    //characterCollider.forceDebugDraw = true;
    
    
    staticGrave = false;
  }
  
  public void UpdateCollider(){
    if(rigid.getVelocity().x != 0){
      characterCollider.setArea(runningColliderRect); 
    }
    
    else{
      characterCollider.setArea(staticColliderRect); 
    }
  }
  
  public void setRigid(Rigidbody newRigid){
    rigid = newRigid; 
  }
  
  public void onCollisionEnter(Collider other){
    CheckIfPassThroughtPlatform(other);
  }
   
  public void onCollisionStay(Collider other){
    CheckIfPassThroughtPlatform(other);
  }
   
  public void CheckIfPassThroughtPlatform(Collider other){
    // TODO : too much checks in this if condition, not really optimized but more safe, check rigid.velocity inizialited is essential for sure
    if(rigid == null || rigid.velocity == null || characterCollider == null || other == null || gameObject == null) return; // if condition to avoid error at launch when initialization is not finish
    if(other.passablePlatform && !characterCollider.getOverlookColliders().contains(other)){
      
      float errorMargin = 0.5f;
      errorMargin +=  rigid.velocity.y/100;
      float playerBottomY = gameObject.position.y + ((Rect)(characterCollider.area)).halfDimension.y + characterCollider.area.position.y - errorMargin;
      float platformTopY = other.gameObject.position.y - ((Rect)(other.area)).halfDimension.y + other.area.position.y; 
      if(other.gameObject.isChildTile) platformTopY += other.gameObject.parent.position.y;
     
      if(playerBottomY > platformTopY)  characterCollider.getOverlookColliders().add(other);
    }
  }
  
  public void onCollisionExit(Collider other){
    if(characterCollider.getOverlookColliders().contains(other)){
      characterCollider.getOverlookColliders().remove(other);
    }
  }
  
  public SpriteSheet getWalkAndIdle(){
    return walkAndIdle;
  }
    
  public void setCharacterCollider(Collider newCharacterCollider){
    characterCollider = newCharacterCollider;
  }
  
  public AnimatorController getAnimator(){
    return(animator);
  }
  
  public boolean isImmobile(){
    return rigid.getVelocity().x == 0 && rigid.getVelocity().y == 0;
  }
  
  public void setMovementSpeed(float newSpeed){
    movementSpeed = newSpeed;
  }
  
  public void setDamageMultiplicator(float newMultiplicator){
    damageMultiplicator = newMultiplicator; 
  }
  
  public void initPlayer(){
    player = this.gameObject;
    playerCharacterComponent = (GameCharacter)(player.getComponent(Villager.class));
    spawnPosition = new PVector(player.position.x, player.position.y);
    
    playerColliderHalfDimensions = ((Rect)(((Collider)player.getComponent(Collider.class)).area)).halfDimension;
  
    cameraPosition = new PVector(player.getPosition().x-128+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);
  
    cameraWidth = (displayWidth - (2*resolutionStripSize)) / globalScale;
    cameraHeight = displayHeight / globalScale;
    
    Updatables.start();
  
    scene = SceneState.Game;    
    
    playerInitialized = true; 
    playerId = ((NetworkView)(gameObject.getComponent(NetworkView.class))).getId();
    
    gameObject.printAllComponents();
    gameObject.printGameObjectParents();
    
    gameObject.setActive(true);
    rigid.isKinematic = false;
  }
  
  
  public void Debug(){
     
  }
  
  
}
