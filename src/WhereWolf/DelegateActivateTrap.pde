
// Delegate used to init player specifc for each clients
public class DelegateActivateTrap extends Delegate{
 
 DelegateActivateTrap(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((Trap)(thisComponent)).activate(boolean(argv[0])); 
 }
}


