// A collection of the midi controls used //

class MidiControls {
  ArrayList<MidiControl> controls;

  MidiControls() {
    controls = new ArrayList<MidiControl>();
  }

  void addControl(MidiControl c) {
    controls.add(c);
  }

  void list() {
    int size = controls.size();
    println("Controls = " + size);
  }

  MidiControl get(String name, int c, int n) {
    int size = controls.size();
    int index = 0;

    // first search for the bus name
    for (int i=0; i < size; i++) {
      if (controls.get(i).busName == name) {
        if (controls.get(i).channel == c) {
          if (controls.get(i).controlNum == n) {
            index = i;
            break;
          }
        }
      }
    }
    return controls.get(index);
  }

  boolean exists(String name, int c, int n) {
    boolean exists = false;
    int size = controls.size();

    // first search for the bus name
    for (int i=0; i < size; i++) {
      if (controls.get(i).busName == name) {
        if (controls.get(i).channel == c) {
          if (controls.get(i).controlNum == n) {
            exists = true;
            break;
          }
        }
      }
    }
    return exists;
  }

  void draw() {
    // position and size of box used to delineate the area that the midi control information is displayed in
    int boxX = 50;
    int boxY = height - 100;
    int boxWidth = width - (boxX * 2);
    int boxHeight = 65;

    // Variables used to control text placement within the box
    int initXOffset = boxX + 5;
    int initYOffset = 14;

    int x = 5;
    int y = initYOffset;

    int yInc = 15;
    int xInc = 25;

    // Draw the box and various titles
    push();
    translate(boxX, boxY);
    fill(50);
    rect(0, 0, boxWidth, boxHeight);

    fill(200);
    textSize(14);
    text("Midi Controls Info", x, y);
    textSize(12);
    y+=yInc;
    text("Channel", x, y);
    y+=yInc;
    text("Control", x, y);
    y+=yInc;
    text("Value", x, y);
    x = x + initXOffset;
    y = initYOffset + yInc;

    // draw the individual control details
    for (int i=0; i < controls.size(); i++) {
      controls.get(i).draw(x, y);
      x = x + xInc;
    }
    pop();
  }
}

class MidiControl {
  String busName;
  int channel;
  int value;
  int controlNum;

  MidiControl(String name, int c, int n, int v) {
    busName    = name;
    channel    = c;
    controlNum = n;
    value      = v;
  }

  void method1() {
  }

  void draw(int x, int y) {
    text(channel, x, y);
    y+=15;
    text(controlNum, x, y);
    y+=15;
    text(value, x, y);
  }

  void updateControlState(int channel, int value) {
    myBus.sendControllerChange(channel, controlNum, value); // Send a controllerChange }
  }
}
