import java.io.*;
import java.io.FilenameFilter;

public class MapManager{
  
  private byte[][] mapBlocks; // each Block is stocked as a byte, the four least significant bits defines the connections with neighboring Blocks, the 4 most significant bits are for used to get the specific type of brick to use
  private GameObject[][] mapBlocksGameObjects;
  private TileType[][][] mapTiles; // [xBlock][yBlock][tileNumber] = tileType
  
  private int mapSize; // the max bounds of the map
  private int numberOfBlocks; // the number of Blocks that the map will contain
  
  // where the map generartion will start
  private int generationOriginX;
  private int generationOriginY;
  
  private int[] xSpawnPoints;
  private int[] ySpawnPoints;
  private int playerSpawnPointIterator;
  private int spawnpointDelay;
  private int nextSpawnPoint;
  
  private int tilePixelSize = 16;
  private int blockTileSize = 10; // Block = 8 x 8 tiles
  private int blockPixelSize = blockTileSize*tilePixelSize;
  
  
  // constructor, the size of the map depends of the number of players
  MapManager(int playerNumber){
    
    if(playerNumber < 4) {
      mapSize = 6;
      numberOfBlocks = 7;
    }
    else if(playerNumber < 8) {
      mapSize = 10;
      numberOfBlocks = 20;
    }
    else {
      mapSize = 15;
      numberOfBlocks = 30;
    }
    
    mapBlocks = new byte[mapSize][mapSize];
    mapBlocksGameObjects = new GameObject[mapSize][mapSize];
    mapTiles = new TileType[mapSize][mapSize][blockTileSize*blockTileSize];
    xSpawnPoints = new int[playerNumber];
    ySpawnPoints = new int[playerNumber];
    
    playerSpawnPointIterator = 0;
    spawnpointDelay = numberOfBlocks / playerNumber;
    nextSpawnPoint = numberOfBlocks;
    MapGeneration();
    
    CreateMap();
    //CreateTile(0,0,TileType.Closed);
    

  }
  
  public void MapGeneration(){
   
    // initialization, get a empty map
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         mapBlocks[i][j] = 0;
      }
    }
    
    generationOriginX = mapSize/2;
    generationOriginY = mapSize/2;
       
    while(numberOfBlocks>0){
       if(mapBlocks[generationOriginX][generationOriginY] != 15){ // 15 = (0000 1111)2 if the origin of map generation doesn't already have 4 neighbors
         createBlock(generationOriginX, generationOriginY);
       }
       
       // else, we have to change the origin 
       else {
         if(generationOriginX<mapSize-1) generationOriginX++;
         else if(generationOriginY<mapSize-1) generationOriginY++;
         else {
           numberOfBlocks=0; // critical case
           println("WARNING : map generator can't generate the required number of Blocks"); 
         }
       }
    }
    
    DefineTilesForAllBlock();
  }
  
  public void createBlock(int x, int y){
    
    // Spawn point creation:
    if(numberOfBlocks == nextSpawnPoint && playerSpawnPointIterator<xSpawnPoints.length){
      nextSpawnPoint = nextSpawnPoint - spawnpointDelay;
      xSpawnPoints[playerSpawnPointIterator] = x;
      ySpawnPoints[playerSpawnPointIterator] = y;
      playerSpawnPointIterator++;
    }
    
    // Neighbor creation :
    int neighborNumber = (int)random(1,5); // random number to define how many neighbors the Blocks have
    for(int i=0 ; i<neighborNumber ; i++){
      int neighborSelected = (int)random(0,4); // the type of neighbor is also random, 0 = left, 1 = up, 2 = right, 3 = down;
      
      if(numberOfBlocks>0){
        switch(neighborSelected){
        
          case 0 : if(x>0 && mapBlocks[x-1][y]==0){ // check if the neighbor is in the bounds of the map
                    numberOfBlocks--;
                    mapBlocks[x][y]|=(1<<3); // update fourth bit of the Block to indicate that it has a left neighbor 
                    mapBlocks[x-1][y]=(1<<1); // update first bit of the new neighbor Block to indicate that the neighbor has a right neighbor
                    createBlock(x-1, y); // continue the generation in that neighbor (recursive call)
                    }    
          break;
          
          case 1 : if(y>0 && mapBlocks[x][y-1]==0){
                      numberOfBlocks--;
                      mapBlocks[x][y]|=(1<<2);
                      mapBlocks[x][y-1]=1;
                      createBlock(x, y-1); 
                    }
          break;
          
          case 2 : if(x+1<mapSize && mapBlocks[x+1][y]==0){
                      numberOfBlocks--;
                      mapBlocks[x][y]|=(1<<1);
                      mapBlocks[x+1][y]=(1<<3);
                      createBlock(x+1, y); 
                    }
          break;
          
          case 3 : if(y+1<mapSize && mapBlocks[x][y+1]==0){
                      numberOfBlocks--;
                      mapBlocks[x][y]|=1;
                      mapBlocks[x][y+1]=(1<<2);
                      createBlock(x, y+1); 
                    }
          break;
        }
      }

    }
    
  }
  

  public int GetSpawnIndexX(){
    return xSpawnPoints[0];
  }
  
  public int GetSpawnIndexY(){
    return ySpawnPoints[0];
  }
  
  public PVector GetSpawnPosition(){
    
    // TODO : manage returned spawn position index
    return(new PVector(xSpawnPoints[0]*blockPixelSize+ blockPixelSize, ySpawnPoints[0]*blockPixelSize + blockPixelSize/2));
  }
  
  public void DrawMiniMap(int playerPositionX, int playerPositionY){
   stroke(255);
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         if(mapBlocks[i][j]>0) {
           fill(255);
           
           if(i==playerPositionX && j==playerPositionY) fill(255,0,0); // just to indicate where the player is
           rect(30+60*i, 20+60*j, 60, 60);
           fill(0);
           text(mapBlocks[i][j], 50+60*i, 55+60*j);
           //text(i+" "+j, 50+60*i, 55+60*j);
         }
      }
    }
    
    
    // this code will draw the borders of each Blocks, no border = link door, border = wall
    stroke(0);
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         if(mapBlocks[i][j]>0) {

           // bottom border
           if((mapBlocks[i][j] & 1)==0) { 
             line(30+60*i, 20+60*j+60, 30+60*i+60, 20+60*j+60);
           }
           
           // right border
           if((mapBlocks[i][j] & (1<<1))==0) {
             line(30+60*i+60, 20+60*j, 30+60*i+60, 20+60*j+60);
           }
           
           // above border
           if((mapBlocks[i][j] & (1<<2))==0) {
             line(30+60*i, 20+60*j, 30+60*i+60, 20+60*j);
           }
           
           // left border
           if((mapBlocks[i][j] & (1<<3))==0) {
             line(30+60*i, 20+60*j, 30+60*i, 20+60*j+60);
           }
         }
      }
    }
  }
  
  // Tile = 16x16 pixels 
  public void DrawTile(int posX, int posY, TileType type){
    switch(type){
      case Closed :     
        fill(0,0,255);
      break;
        
      case Opened : 
        fill(255,0,0);
      break;
    } 
    
    //fill(0,0,255);
    rect(posX, posY, tilePixelSize, tilePixelSize);
  }
  
  // Block = 8x8 tiles
  public void DrawBlock(int xBlock, int yBlock){
    for(int i=0 ; i<blockTileSize ; i++){
      for(int j=0 ; j<blockTileSize ; j++){
        DrawTile((xBlock*blockPixelSize + (i+4)*tilePixelSize), (yBlock*blockPixelSize + j*tilePixelSize), mapTiles[xBlock][yBlock][(j*blockTileSize)+i]);
      } 
    }
  }
  
  public void DrawMap(int xCurrentBlock, int yCurrentBlock){
    
    if(xCurrentBlock < 0 || xCurrentBlock >= mapSize || yCurrentBlock < 0 || yCurrentBlock >= mapSize){
      println("ERROR ERROR - Character out of map bounds !");
      return; 
    }
    
    if(mapBlocks[xCurrentBlock][yCurrentBlock]==0){
      println("ERROR ERROR - Character in null/empty block !");
      return; 
    }
    
    println("Player is in " + xCurrentBlock + " " + yCurrentBlock);
    
    DrawBlock(xCurrentBlock,yCurrentBlock);
    
    // Such the player is in (xCurrentBlock, yCurrentBlock) block, we have to draw the neighbors blocks to manage camera scrool
    // Doors inside current block are used to know which neighbors we have to draw
            
    if(HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Left)) DrawBlock(xCurrentBlock-1,yCurrentBlock);
    if(HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Up)) DrawBlock(xCurrentBlock,yCurrentBlock-1);
    if(HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Right)) DrawBlock(xCurrentBlock+1,yCurrentBlock);
    if(HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Down)) DrawBlock(xCurrentBlock,yCurrentBlock+1);
  }
  
  public boolean HaveNeighborInDirection(int abscissa, int ordinate, Direction dir){
    
    switch(dir){
      case Left :
        return((mapBlocks[abscissa][ordinate] & (1<<3))==8);
      case Up :
        return((mapBlocks[abscissa][ordinate] & (1<<2))==4);
      case Right :
        return((mapBlocks[abscissa][ordinate] & (1<<1))==2);
      case Down :
        return((mapBlocks[abscissa][ordinate] & 1)==1);
    }
    
    return false;
  }
  
  public void UpdateMap(int xCurrentBlock, int yCurrentBlock, int xPreviousBlock, int yPreviousBlock){
      if(xCurrentBlock < 0 || xCurrentBlock >= mapSize || yCurrentBlock < 0 || yCurrentBlock >= mapSize){
        println("ERROR ERROR - Character out of map bounds !");
        return; 
      }
      
      if(mapBlocks[xCurrentBlock][yCurrentBlock]==0){
        println("ERROR ERROR - Character in null/empty block !");
        return; 
      }
      

      // TODO : optimization please
      if(HaveNeighborInDirection(xPreviousBlock, yPreviousBlock, Direction.Left))  mapBlocksGameObjects[xPreviousBlock-1][yPreviousBlock].setActive(false);
      if(HaveNeighborInDirection(xPreviousBlock, yPreviousBlock, Direction.Up)) mapBlocksGameObjects[xPreviousBlock][yPreviousBlock-1].setActive(false);
      if(HaveNeighborInDirection(xPreviousBlock, yPreviousBlock, Direction.Right)) mapBlocksGameObjects[xPreviousBlock+1][yPreviousBlock].setActive(false);
      if(HaveNeighborInDirection(xPreviousBlock, yPreviousBlock, Direction.Down)) mapBlocksGameObjects[xPreviousBlock][yPreviousBlock+1].setActive(false);
      
      mapBlocksGameObjects[xCurrentBlock][yCurrentBlock].setActive(true);
      
      if(HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Left))  mapBlocksGameObjects[xCurrentBlock-1][yCurrentBlock].setActive(true);
      if(HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Up)) mapBlocksGameObjects[xCurrentBlock][yCurrentBlock-1].setActive(true);
      if(HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Right)) mapBlocksGameObjects[xCurrentBlock+1][yCurrentBlock].setActive(true);
      if(HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Down)) mapBlocksGameObjects[xCurrentBlock][yCurrentBlock+1].setActive(true);
      
  }
  

  public void DefineTilesForAllBlock(){
    
    int debug = 0;
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
        if(mapBlocks[i][j] != 0){
          
            String folderPath = "";
            
            if((mapBlocks[i][j] & (1<<3))==8) folderPath += '1';
            else folderPath += '0';
            
            if((mapBlocks[i][j] & (1<<2))==4) folderPath += '1';
            else folderPath += '0';
            
            if((mapBlocks[i][j] & (1<<1))==2) folderPath += '1';
            else folderPath += '0';
            
            if((mapBlocks[i][j] & 1)==1) folderPath += '1';
            else folderPath += '0';
            
            folderPath = "Blocks/" + folderPath;

            String path = sketchPath + "/data" + "/" + folderPath; 
            
            File dataFolder = new File(path); 
            println(path);
            int numberOfBlocksPossibilities = dataFolder.list().length;
            int choosenBlock = (int)random(0,numberOfBlocksPossibilities);
            folderPath += "/"; // WARNING : this line must be done before the loadStrings
            
            String[] data=loadStrings(folderPath + char(choosenBlock+48) + ".txt");
            
            for(int k=0 ; k<blockTileSize ; k++){
              for(int l=0 ; l<blockTileSize ; l++){
                
                int tileType = 10*(data[k].charAt(3*l)-48) + (data[k].charAt((3*l)+1))-48;
                mapTiles[i][j][k*blockTileSize + l] = TileType.fromInteger(tileType); // WARNING : Do not forger to define new values in TileType.java
              }
            }
        }
      }
    }
  }
  


  public void CreateMap(){
    
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
        if(mapBlocks[i][j]!=0){
            CreateBlock(i,j);
        }
      } 
    }

  }
  
  // Block = 8x8 tiles
  public void CreateBlock(int xBlock, int yBlock){
    
    //mapBlocksGameObjects[xBlock][yBlock] = new GameObject("Block"+str(xBlock)+str(yBlock), new PVector(xBlock*blockPixelSize,yBlock*blockPixelSize));
    mapBlocksGameObjects[xBlock][yBlock] = new GameObject("Block"+str(xBlock)+str(yBlock), new PVector(0,0));
    
    for(int i=0 ; i<blockTileSize ; i++){
      for(int j=0 ; j<blockTileSize ; j++){
        CreateTile((xBlock*blockPixelSize + (i+4)*tilePixelSize), (yBlock*blockPixelSize + j*tilePixelSize), mapTiles[xBlock][yBlock][(j*blockTileSize)+i], mapBlocksGameObjects[xBlock][yBlock]);
      } 
    }
    
    mapBlocksGameObjects[xBlock][yBlock].setActive(false);
    
  }
  
  // Tile = 16x16 pixels 
  public void CreateTile(int posX, int posY, TileType type, GameObject blockGameObject){
    
    GameObject tile = new GameObject(str(posX)+str(posY), new PVector(posX, posY), blockGameObject);
    
    switch(type){
      case Closed :     
        tile.addComponent(new Collider(new Rect(0, 0, tilePixelSize, tilePixelSize)));
        tile.addComponent(new Sprite(tilesSpriteSheet, 1,0));
      break;
        
      case Opened :  
        tile.addComponent(new Sprite(tilesSpriteSheet, 17,15));
        //tile.addComponent(new Sprite(torchSpriteSheet, 0,0));
      break;
    } 
        
  }
  

  
  // Debug function
  public void PrintTilesFile(String textPath){
    
    String[] data=loadStrings("Blocks/OneRightDoor/0.txt"); 
  
    for(int i=0 ; i<8 ; i++){
      for(int j=0 ; j<8 ; j++){
        print(data[i].charAt(3*j));
        print(data[i].charAt((3*j)+1));
        print(" ");
      }
      print("\n");
    }
  }
  
  public float GetBlockPixelSize(){
    return blockPixelSize;
  }
  
}
