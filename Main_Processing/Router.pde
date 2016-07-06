// Used for communication via xbee api:
import processing.serial.*; 

// xbee api libraries available at http://code.google.com/p/xbee-api/
// Download the zip file, extract it, and copy the xbee-api jar file 
// and the log4j.jar file (located in the lib folder) inside a "code" 
// folder under this Processing sketch’s folder (save this sketch, then 
// click the Sketch menu and choose Show Sketch Folder).
import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeAddress64;
import com.rapplogic.xbee.api.XBeeException;
import com.rapplogic.xbee.api.XBeeTimeoutException;
import com.rapplogic.xbee.api.zigbee.ZNetRemoteAtRequest;
import com.rapplogic.xbee.api.zigbee.ZNetRemoteAtResponse;

import com.rapplogic.xbee.api.ApiId;
import com.rapplogic.xbee.api.AtCommand;
import com.rapplogic.xbee.api.AtCommandResponse;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.zigbee.NodeDiscover;

// Create and initialize a new xbee object:
XBee xbee = new XBee();

class Router {
  // Serial port used for communication with xbee router:
  private String serialPort;

  // For error identification:
  int error=0;

  // Make an array list of node objects for display:
  private ArrayList <Node> nodes = new ArrayList();


  // Initialize Router object:
  Router (String _serialPort) {
    serialPort = _serialPort;

    // The log4j.properties file is required by the xbee api library, and 
    // needs to be in your data folder. You can find this file in the xbee
    // api library you downloaded earlier.
    PropertyConfigurator.configure(dataPath("")+"/log4j.properties");

    println("Opening port: "+serialPort);
    try {
      // Opens your serial port defined above, at 9600 baud:
      xbee.open(serialPort, 9600);
    }
    catch (XBeeException e) {
      println("");
      println("  ** Error opening XBee port: " + e + " **");
      println("");
      println("Is your XBee plugged in to your computer?");
      println("Did you set your COM port?");
      error=1;
    }
  }


  // Looks up for all the nodes on the network and adds them to an
  // ArrayList:
  void nodeDiscovery() {
    // Time in milliseconds for finding nodes (6 seconds):
    long nodeDiscoveryTimeout = 6000;

    // 
    ArrayList tempIncomingNodes = new ArrayList();
    // Reset node list, removing all old records:
    nodes.clear();
    print("clear node list, looking up nodes…");

    try {
      println("sending node discover command");

      // Send the node discover command:
      xbee.sendAsynchronous(new AtCommand("ND")); 
      long startTime = millis();

      // Spend time assigned waiting for replies:
      while (millis () - startTime < nodeDiscoveryTimeout) {       
        try {
          // Look for incoming responses:
          XBeeResponse response = (XBeeResponse) xbee.getResponse(1000); 

          // Check to make sure it's a response to an AT command:
          if ( response.getApiId() == ApiId.AT_RESPONSE) {
            // Parse the node information from the response:
            NodeDiscover newNode = NodeDiscover.parse((AtCommandResponse)response);
            // Add the node to an existing Array List:
            tempIncomingNodes.add(newNode);
            println("node discover response is: " + newNode);
          } 
          else {
            // println("ignoring unexpected response: " + response);
          }
        }
        catch (XBeeTimeoutException e) {
          // Prints dots while radio lookups are in progress:
          print(".");
        }
      }
    }
    // If the ND response times out, note the error:
    catch (XBeeTimeoutException e) {
      println("request timed out. make sure your " + 
        "remote XBee is configured and powered on");
    } 
    // If some other error happens, print it to the status window:
    catch (Exception e) {
      println("unexpected error" + e);
    }
    println("Node Discovery Complete");
    println("number of nodes: " + tempIncomingNodes.size());

    // Once discovery is finished, create as many Node objects as
    // incoming nodes and add them to the nodes ArrayList:
    for (int i = 0; i < tempIncomingNodes.size(); i++) {
      XBeeAddress64 address64 = ((NodeDiscover) tempIncomingNodes.get(i)).getNodeAddress64();
      Node newNode = new Node(address64);
      nodes.add(newNode);
    }
  }


  // Returns the number of nodes:
  int getNumNodes() {
    return nodes.size();
  }


  // Returns the node with the given address, if node doesn't
  // exist, returns null:
  Node getNode(String _address) {
    for (int i = 0; i < nodes.size(); i++) {
      String tempAddress = ((Node) nodes.get(i)).getAddress().toLowerCase();
      if (tempAddress.equals(_address.toLowerCase())) {
        return nodes.get(i);
      }
    }
    return null;
  }


  // Returns the nodes ArrayList:
  ArrayList getNodesArray() {
    return nodes;
  }
}