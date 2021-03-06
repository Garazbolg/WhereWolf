
public class TrapPrefab extends GameObject {
  
  public TrapPrefab(String name, PVector position){
    
    super("trap" + position, new PVector(position.x,position.y + 8)); // Warning : must create a new pvector else it use reference and follow character position
    Scene.addChildren(this);
    this.addComponent(new Trap()); 
    ((Trap)this.getComponent(Trap.class)).init();
  }
}
