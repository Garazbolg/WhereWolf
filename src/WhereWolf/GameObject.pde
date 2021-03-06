/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 17/04/2015 
        Last Modified : 22/04/2015
*/

public static class Scene{
 private static GameObject root;
 
 public static void startScene(GameObject g){
  root =  g;
 }
 
 public static void addChildren(GameObject g){
   root.addChildren(g); 
 }
 
 public static void draw(){
  root.draw(); 
 }
 
 public static void debugDraw(){
  root.debugDraw(); 
 }
}


public class GameObject extends Updatable implements Drawable,DebugDrawable{
  
 public String name;
 public PVector position;
 public boolean isTile = false;
 public boolean isChildTile = false;
 
 private ArrayList<Component> components;
 private ArrayList<GameObject> children;
 protected GameObject parent;
 public RPCHolder rpcHolder;

 
 public GameObject(){
  }
  
 public GameObject(String n, PVector pos){
   position = pos;
   name = n;
  components = new ArrayList<Component>(); 
  children = new ArrayList<GameObject>();
  parent = null;
  Scene.addChildren(this);
  rpcHolder = new RPCHolder();
 }
 
 GameObject(String n, PVector pos, GameObject newParent){
   position = pos;
   name = n;
  components = new ArrayList<Component>(); 
  children = new ArrayList<GameObject>();
  parent = null;
  if(newParent != null) newParent.addChildren(this);
  
  rpcHolder = new RPCHolder();
 }
 
 
 public void setActive(boolean state){
   super.setActive(state);
   for(Component c : components)
     c.setActiveInHierarchy(state);
   for(GameObject go : children)
     go.setActiveInHierarchy(state);
 }
 
 public void setActiveInHierarchy(boolean state){
   super.setActiveInHierarchy(state);
   for(Component c : components)
     c.setActiveInHierarchy(state);
   for(GameObject go : children)
     go.setActiveInHierarchy(state);
 }
 
 
 public PVector getPosition(){
  if(parent != null)
     return PVector.add(parent.getPosition(),position);
    
  return position; 
 }
 
 public void setPosition(PVector newPosition){
   position = new PVector(newPosition.x, newPosition.y);
 }
 
 //return the first component of type T and null if there isn't
 public Component getComponent(Class cl){
  for(Component c : components){
   if(c.getClass() == cl)
     return c;
  } 

  return null;
 }
 
  //same as getComponent but including subclasses
  public Component getComponentIncludingSubclasses(Class cl){
    for(Component c : components) {
      if(cl.isInstance(c)){
        return c;
      }
    }

    return null;
  }
 
 public void addChildren(GameObject nGameObject){
   if(!children.contains(nGameObject)){
     children.add(nGameObject);
     if(nGameObject.parent != null)
       nGameObject.parent.children.remove(nGameObject);
     nGameObject.parent = this;
   }
 }
 
 public boolean addComponent(Component newComponent){
     if(newComponent.gameObject == null && getComponent(newComponent.getClass()) == null){
       components.add(newComponent);
       newComponent.gameObject = this;
      return true; 
     }
     return false;
 }
 
 public boolean removeComponent(Component c){
   c.OnDestroy();
   return components.remove(c);
 }

 public void draw(){
     if(!isActive()) return;
     
     
     pushMatrix();
     translate(position.x,position.y);
     
     Renderer render = (Renderer) getComponent(Renderer.class);
     if(render != null)
       render.draw();
       
     for(Component c : components){
      if(c instanceof Drawable){
       Drawable d = (Drawable)c;
       d.draw();
      } 
     }
     
     for(GameObject g : children){
      g.draw(); 
     }
     
     popMatrix();
 }
 
 public void debugDraw(){
   if(!isActive()) return;
   pushMatrix();
   translate(position.x,position.y);
   for(GameObject g : children){
      g.debugDraw(); 
     }
   
    for(Component c : components){
      if(c instanceof DebugDrawable){
       DebugDrawable d = (DebugDrawable)c;
       d.debugDraw();
      } 
     }
     
   fill(0);
   stroke(0);
   //text(name,-textWidth(name)/2,0);
   popMatrix();
 }
 
 public void update(){}
 
 
 
  //What happens when the collider of the gameObject enter in collision with an other collider
 public void onCollisionEnter(Collider other){
    for(Component c : components)
       if(! (c instanceof Collider))
          c.onCollisionEnter(other);
 }
  
 //What happens when the collider of the gameObject start to overlap an other collider
 public void onTriggerEnter(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onTriggerEnter(other);
 }
  
 //What happens when the collider of the gameObject is in collision with an other collider
 public void onCollisionStay(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onCollisionStay(other);
 }
 
 //What happens when the collider of the gameObject is overlapping an other collider
 public void onTriggerStay(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onTriggerStay(other);
 }
  
 //What happens when the collider of the gameObject stop colliding with an other collider
 public void onCollisionExit(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onCollisionExit(other);
 }
 
 //What happens when the collider of the gameObject stop overlapping an other collider
 public void onTriggerExit(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onTriggerExit(other);
 }
 
 public void destroy(){
   
   if(parent != null){
      parent.children.remove(this);
      this.parent = null;
   }
   
   
   for(int i=0 ; i<children.size() ; i++){
     children.get(i).destroy();
   }
   
  for(int i=0 ; i<components.size() ; i++){
    removeComponent(components.get(i));
  }
   
   super.OnDestroy();
 }
 
 public PVector getGlobalPosition(){
    PVector globalPosition = new PVector(position.x, position.y);
    GameObject parentIterator = parent;
    while(parentIterator != null){
      globalPosition.add(parentIterator.position);
      parentIterator = parentIterator.parent;
    }
    
    return globalPosition;
 }
 
 
 
 //------------------------------------------
 // DEBUG METHODS
 //------------------------------------------
 
 // print all components attached to gameObject
 public void printAllComponents(){
   
   println("\n");
   println("Debug Method - printAllComponents");
   println("isServer = " + Network.isServer);
   println("Gameobject " + this.name);
   println("Parent = " + this.parent);
   if(this.parent != null) println("Like parent is not null,  his name is : " + this.parent.name);
   println("List of gameObject's components :");
   for(Component c : components){
     println(c);
   } 
  
   println("End of Debug Method - printAllComponents");
   println("\n");
 }
 
 // print hierarchy from gameObject to root
 public void printGameObjectParents(){
   
   println("\n");
   println("Debug Method - printGameObjectParents");
   println("isServer = " + Network.isServer);
   println("Current gameObject name is " + this.name);
   println("Parents succession : ");
   GameObject parentIterator = parent;
    while(parentIterator != null){
      println(parentIterator.name);
      parentIterator = parentIterator.parent;
    }
    
   println("End of Debug Method - printGameObjectParents");
   println("\n");
 }
 
}
