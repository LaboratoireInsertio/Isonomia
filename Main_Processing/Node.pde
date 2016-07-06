class Node {
  // Current node (pin 4) P2 state:
  private boolean stateP2 = false;

  // Stores the raw address locally:
  private XBeeAddress64 addr64;

  // Stores the formatted address locally:
  private String address;


  // Initialize Node object:
  Node(XBeeAddress64 _addr64) {
    addr64 = _addr64;
    getRealState();


    // Parse the address int array into a formatted string:
    String[] hexAddress = new String[addr64.getAddress().length];
    for (int i=0; i<addr64.getAddress().length;i++) {
      // Format each address byte with leading zeros:
      hexAddress[i] = String.format("%02x", addr64.getAddress()[i]);
    }
    // Join the array together with colons for readability:
    address = join(hexAddress, ":"); 

    // Prints the node address in the serial port:
    println("Sender address: " + address);
  }


  // Checks the remote actuator node (pin 4) P2 to see if its on or off:
  void getRealState() {
    try {
      println("node to query: " + addr64);

      // Query actuator device (pin 4) P2 (Digital output high = 5, low = 4)
      // Ask for the state of the P2 pin:
      ZNetRemoteAtRequest request=  new ZNetRemoteAtRequest(addr64, "P2"); 

      // Parse the response with a 10s timeout:
      ZNetRemoteAtResponse response = (ZNetRemoteAtResponse)
        xbee.sendSynchronous(request, 10000); 

      if (response.isOk()) {
        // Get the state of the actuator from the response:
        int[] responseArray = response.getValue();
        int responseInt = (int) (responseArray[0]);

        // If the response is good then store the on/off state: 
        if (responseInt == 4|| responseInt == 5) { 
          // State of pin is 4 for off and 5 for on:
          stateP2 = !boolean( responseInt - 4);
          println("successfully got state " + stateP2 + " for pin 4 (P2)");
        }
        else {  
          // If the current state is unsupported (like an analog input)
          // then print an error to the console:
          println("unsupported setting " + responseInt + " on pin 4 (P2)");
        }
      } 
      // If there's an error in the response, print that to the 
      // console and throw an exception:
      else {
        throw new RuntimeException("failed to get state for pin 4. " +
          " status is " + response.getStatus());
      }
    } 
    // Print an error if there's a timeout waiting for the response:
    catch (XBeeTimeoutException e) {
      println("XBee request timed out. Check remote's configuaration, " +
        " range and power");
    } 
    // Print an error message for any other errors the occur:
    catch (Exception e) {
      println("unexpected error: " + e + "  Error text: " + e.getMessage());
    }
  }


  // Toggles the state of the node:
  void toggleState() {
    // Change the state of the switch:
    stateP2 = !stateP2;

    // Turn the actuator on or off (pin 4) P2 (Digital output 
    // high = 5, low = 4):
    try {
      // Start with the off command:
      int[] command = {
        4
      };
      // Change to the on command if the current state is off:
      if (!stateP2) command[0]=5;
      // Otherwise set the state to off: 
      else command[0]=4;

      // Send the new AT configuration to the node (pin 4) P2:
      ZNetRemoteAtRequest request = 
        new ZNetRemoteAtRequest(addr64, "P2", command);
      ZNetRemoteAtResponse response = 
        (ZNetRemoteAtResponse) xbee.sendSynchronous(request, 5000);

      // If everything worked, print a message to the console:
      if (response.isOk()) {
        println("toggled pin 4 (P2) on node " + address);
      } 
      // If there was a problem, throw an exception:
      else {
        throw new RuntimeException(
        "failed to toggle pin 4.  status is " + response.getStatus());
      }
    } 
    // If the request timed out, print that error to the console and
    // change the state back to what it was originally:
    catch (XBeeTimeoutException e) {
      println("XBee request timed out. Check remote's " +
        "configuaration, range and power");
      stateP2 = !stateP2;
    } 
    // If some other error occured, print that to the console and 
    // change the state back to what it was originally:
    catch (Exception e) {
      println("unexpected error: " + e + 
        "  Error text: " + e.getMessage());
      stateP2 = !stateP2;
    }
  }


  // Returns node address:
  String getAddress() {
    return address;
  }


  // Returns node P2 state:
  boolean getStateP2() {
    return stateP2;
  }
}