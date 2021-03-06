/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 21/05/2015 
        Last Modified : 22/05/2015
*/

import java.util.Map;

public class AnimatorController extends Renderer{
  
  public Parameters parameters;
  private State currentState;
  private boolean start = false;

  AnimatorController(State st, Parameters params){
    super();
    
    currentState = st;
    parameters = params;
    
    if(!start) {
      currentState.startState();
      start = true;
    }
  }
  
  public void start(){
    if(currentState != null) {
      currentState.startState();
      start = true;
    } 
  }
  
  public void draw(){
    
    if(parameters.getBool("Visible")) {
      if(gameObject != null){
        PVector checkPosition;
        if(gameObject.isTile) checkPosition = gameObject.position;
        else checkPosition = PVector.add(gameObject.position, gameObject.parent.position);
        
        PImage source = currentState.getSource();
        
        if((checkPosition.x + source.width/2) < (cameraPosition.x + resolutionStripSize)
        || (checkPosition.x - source.width/2) > (cameraPosition.x + cameraWidth)
        || (checkPosition.y + source.height/2) < (cameraPosition.y - cameraOrientation)
        || (checkPosition.y - source.height/2) > (cameraPosition.y - cameraOrientation + cameraHeight)
        ){
          currentState.setVisibleByCamera(false); // animation is played but not displayed
          //return; 
        }
        
        else{
          currentState.setVisibleByCamera(true);
        }
         
       }
       
      currentState.draw();
    }
  }

  public void update(){
   State next = currentState.update(parameters);
   if(next != null){
     currentState = next;
     next.startState();
   }
  }
  
  public State getCurrentState(){
    return currentState; 
  }
  
  public void setCurrentState(State newState){
    currentState = newState; 
  }

}


public class Transition{
  public State from,to;
  
  private String  conditionParameterName;
  
  private boolean conditionParameterValueBool;
  private int     conditionParameterValueInt;
  private float   conditionParameterValueFloat;
  
  private ConditionType condition;
  
  private int conditionDataType = 0;
  
  Transition(State f,State t){
    init(f,t);
  }
  
  Transition(State f,State t,String parameterName, ConditionType ct, boolean value){
      conditionParameterName = parameterName;
      conditionParameterValueBool = value;
      condition = ct;
      conditionDataType = 1;
      init(f,t);
  }
  
  Transition(State f,State t,String parameterName, ConditionType ct, int value){
      conditionParameterName = parameterName;
      conditionParameterValueInt = value;
      condition = ct;
      conditionDataType = 2;
      init(f,t);
  }
  
  Transition(State f,State t,String parameterName, ConditionType ct, float value){
      conditionParameterName = parameterName;
      conditionParameterValueFloat = value;
      
      condition = ct;
      conditionDataType = 3;
      init(f,t);
  }
  
  private void init(State f, State t){
    if(f !=null && t != null){
      from = f;
      to = t;
      from.to.add(this);
    }
    else
      println("Error : Transition Init Failed !!!");
  }
  
  public boolean evaluate(Parameters params){
   if(conditionDataType == 1){
     switch(condition){
       case Equal :
         return params.getBool(conditionParameterName) == conditionParameterValueBool;
       default :
         return params.getBool(conditionParameterName) != conditionParameterValueBool;
     }
   }
   
   if(conditionDataType == 2){
     switch(condition){
       case Equal :
         return params.getInt(conditionParameterName) == conditionParameterValueInt;
         
       case GreaterThan :
         return params.getInt(conditionParameterName) > conditionParameterValueInt;
         
       case LesserThan :
         return params.getInt(conditionParameterName) < conditionParameterValueInt;
         
       case GreaterEqual :
         return params.getInt(conditionParameterName) >= conditionParameterValueInt;
         
       case LesserEqual :
         return params.getInt(conditionParameterName) <= conditionParameterValueInt;
         
       default :
         return params.getInt(conditionParameterName) != conditionParameterValueInt;
     }
   }
   
   if(conditionDataType == 3){
     switch(condition){
       case Equal :
         return params.getFloat(conditionParameterName) == conditionParameterValueFloat;
         
       case GreaterThan :
         return params.getFloat(conditionParameterName) > conditionParameterValueFloat;
         
       case LesserThan :
         return params.getFloat(conditionParameterName) < conditionParameterValueFloat;
         
       case GreaterEqual :
         return params.getFloat(conditionParameterName) >= conditionParameterValueFloat;
         
       case LesserEqual :
         return params.getFloat(conditionParameterName) <= conditionParameterValueFloat;
         
       default :
         return params.getFloat(conditionParameterName) != conditionParameterValueFloat;
     }
   }
   
   return from.getExitTime();
   
  } 
  
}



public class State{
  protected Animation animation;
  private float framePerSecond;
  private float currentFrame;
  private boolean visibleByCamera = true;
  private float scaleX,scaleY; 
  
  private ArrayList<Transition> to;
  
  State(Animation anim,float speed){
    framePerSecond = speed;
    animation = anim;
    currentFrame = 0;
    to = new ArrayList<Transition>();
    
    scaleX = scaleY = 1.0f;
  }
  
 public void startState(){
   currentFrame = 0; 
  }
 
 public boolean getExitTime(){
   return !animation.getLoop() && currentFrame > animation.getSize();
 }
 
 public PImage getSource(){
   return  animation.getImage(((int)(currentFrame*framePerSecond)));
 }
 
 public void draw(){
       
     if(visibleByCamera){
       PImage source = animation.getImage(((int)(currentFrame*framePerSecond)));
       pushMatrix();
       scale(scaleX,scaleY);
       image(source,-source.width/2,-source.height/2);
       popMatrix(); 
     }
     currentFrame += Time.deltaTime();
    
     // Animations without loop not worked, I add a poor fix 
     float currentFrameMultiplicator = (animation.getLoop() ? 1 : framePerSecond);
     
     if(currentFrame * currentFrameMultiplicator >= animation.getSize()){
       if(animation.getLoop()){
         currentFrame -= animation.getSize();
       } else{
         currentFrame -= Time.deltaTime();
       }
     }     
       
 }
 
 public State update(Parameters params){
   for(int i = 0; i< to.size() ; i ++){
     if(to.get(i).evaluate(params)){
       return to.get(i).to;
     }
   }
   
   return null;
 }
 
 public void updateFrame(){
   currentFrame += Time.deltaTime();
   if(currentFrame > animation.getSize() && animation.getLoop())
     currentFrame -= animation.getSize();
 }
 
 public void setVisibleByCamera(boolean state){
   visibleByCamera = state;
 }
 
 public void setScale(float newScale){
   scaleX = scaleY = newScale;
 }
 
 public void setScale(float newScaleX, float newScaleY){
   scaleX = newScaleX;
   scaleY = newScaleY;
 }
}


public class Parameters{
  private HashMap<String,Boolean> parametersBool;
  private HashMap<String,Integer> parametersInt;
  private HashMap<String,Float> parametersFloat;
  
  Parameters(){
    parametersBool = new HashMap<String,Boolean>();
    parametersInt = new HashMap<String,Integer>();
    parametersFloat = new HashMap<String,Float>();
  }
  
  public void setBool(String k, boolean value){
    if(k != null)
      parametersBool.put(k,value);
  }
  
  public void setInt(String k, int value){
    if(k != null)
      parametersInt.put(k,value);
  }
  
  public void setFloat(String k, float value){
    if(k != null)
      parametersFloat.put(k,value);
  }
  
  public boolean getBool(String k){
    return (parametersBool.get(k) == null || parametersBool.get(k).booleanValue());
  }
  
  public int getInt(String k){
    return parametersInt.get(k).intValue();
  }
  
  public float getFloat(String k){
    return parametersFloat.get(k).floatValue();
  }
  
  public void print(){
    println("Parameters : ");
    
   for(Map.Entry entry : parametersBool.entrySet()){
     println(entry.getKey() + " : " + entry.getValue());
   } 
   for(Map.Entry entry : parametersInt.entrySet()){
     println(entry.getKey() + " : " + entry.getValue());
   } 
   for(Map.Entry entry : parametersFloat.entrySet()){
     println(entry.getKey() + " : " + entry.getValue());
   } 
  }
}


