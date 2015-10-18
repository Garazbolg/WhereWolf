
// Delegate used to init player specifc for each clients
public class DelegateFlipFireSprite extends Delegate{
 
 DelegateFlipFireSprite(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   println("DelegateFlipFireSprite - Call");
   ((Villager)(thisComponent)).flipFireSprite(boolean(argv[0])); 
 }
}


