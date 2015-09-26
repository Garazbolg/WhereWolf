


enum TileType{
  Empty, Opened, Closed, EmptyPot, FirePot, FlowerPot, Bookcase, Chest, Lava, PlatformLeft, PlatformMid, PlatformRight;

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
        }
        
        return null;
    }
    
};
