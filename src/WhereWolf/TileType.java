


enum TileType{
  Empty, Opened, Closed, EmptyPot, FirePot, FlowerPot, Bookcase, 
  Chest, Lava, PlatformLeft, PlatformMid, PlatformRight, Canvas,
  Saw, SawTrail, Chair, Couch, Furniture, Statue, Vase, DownSpikes, 
  UpSpikes, LeftSpikes, RightSpikes;

  public static TileType fromInteger(int x) {
        switch(x) {
          case 0 : return Empty;
          case 1 : return Opened;
          case 2 : return Closed;
          case 3 : return EmptyPot;
          case 4 : return FirePot;
          case 5 : return FlowerPot;
          case 6 : return Bookcase;
          case 7 : return Chest;
          case 8 : return Lava;
          case 9 : return PlatformLeft;
          case 10 : return PlatformMid;
          case 11 : return PlatformRight;
          case 12 : return Canvas;
          case 13 : return Saw;
          case 14 : return SawTrail;
          case 15 : return Chair;
          case 16 : return Couch;
          case 17 : return Furniture;
          case 18 : return Statue;
          case 19 : return Vase;
          case 20 : return DownSpikes;
          case 21 : return UpSpikes;
          case 22 : return LeftSpikes;
          case 23 : return RightSpikes;
        }
        
        return null;
    }
    
};
