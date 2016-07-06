class Switch {
  // Current switch state:
  private boolean state;
  // The position has been asigned:
  private boolean visible;
  // Switch position:
  private int x, y;
  // Switch size (diammeter):
  private int d;
  // Address of the assigned node:
  private String nodeAddress;
  
  // Location on map:
  private Location loc;


  // Initialize the swhitch object:
  Switch(String _address, boolean _state) {
    nodeAddress = _address;
    state = _state;
    visible = false;
    d = 25;


    // TEMP //////////
    //   x = 15;
    //   y = 15;
    //////////////////
  }


  // Draws the switch if the position has been assigned:
  void render() {
    noStroke();
    if (state) fill(0, 100, 0, 100);
    else fill(100, 0, 0, 100);
    
    // location in sketch coordinates:
    Point2f p = map.locationPoint(loc);
    
    x = int(p.x);
    y = int(p.y);

    ellipse(p.x, p.y, d, d);
  }


  // Changes switch state:
  void assignState(boolean _state) {
    state = _state;
  }


  // Assigns switch position:
  void assignPosition(int _x, int _y, Location _loc) {
    x = _x;
    y = _y;
    
    // location in map:
    loc = _loc;
    
    visible = true;
  }


  // Returns switch address
  String getAddress() {
    return nodeAddress;
  }


  // Returns position in x:
  int getX() {
    return x;
  }


  // Returns position in y:
  int getY() {
    return y;
  }


  // Returns diameter:
  int getD() {
    return d;
  }


  // Returns state:
  boolean getState() {
    return state;
  }


  // Returns visibility:
  boolean isVisible() {
    return visible;
  }
  
  
  // Returns location:
  Location getLocation() {
    return loc;
  }
}