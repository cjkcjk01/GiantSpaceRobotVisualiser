// A class for deck specific settings, used to store things like volume, play/stop status and to
// link a specific hotcue pack to the deck
class DeckSettings {
  String    name;
  int       hotcuePack;
  int       hotcueIndex;
  int       faderValue;
  float     filterValue;
  boolean   blurOn;
  boolean   playing;

  DeckSettings(String n) {
    name        = n;
    hotcuePack  = 0;
    hotcueIndex = 0;
    faderValue  = 0;
    filterValue = 0;
    playing     = false;
    blurOn      = false;
  }

  // sets the hotcue pack associated with the deck
  void setPack(int value) {
    int pack = (int)map(value, 0, 127, 0, 7);

    // check to see if there is a matching pack loaded
    if (pack > hotcuePacks.size()) {
      println ("Warning - Pack number " + pack + " does not exist. /n Setting to pack 0 ");
      hotcuePack  = 0;
      hotcueIndex = 0;
    } else {
      hotcuePack = pack;
      hotcueIndex = 0;
    }
    cueInfo.setText("hc" + pack);
  }

  // cues up the next hotcue to draw
  // The value parameter is set by Traktor, it is a midi CC value in the range 0-127. Which hotcue has been pressed
  // is indicated by the range of the midi values
  void readyHotcue(int value) {

    hotcueIndex = (int)map(value, 0, 127, 0, 7);
    hotcuePacks.readyHotcue(hotcuePack, hotcueIndex);
  }

  void setVolume(int v) {
    faderValue = v;
    isBlurOn();
  }

  int getVolume() {
    return faderValue;
  }

  void setIsPlaying(boolean p) {
    playing = p;
  }

  boolean isPlaying() {
    return playing;
  }

  void setFilter(int v) {
    filterValue = map(v, 1, 127, -8, 8);
    if ((filterValue > -0.15) && (filterValue < 0.15)) {
      filterValue = 0;
    }
    isBlurOn();
  }

  float getFilter() {
    return filterValue;
  }

  // Display the deck status on the screen
  void showStatus(PVector pos) {

    push();
    // Show Deck Name
    textFont(font, 200);
    textSize(72);
    text(name, pos.x, pos.y);

    // show play/stop stasus
    push();
    translate(pos.x, pos.y + 15);

    int size = 40;
    if (playing) {
      triangle(0, 0, 0, size, 0 + size, size/2);
    } else {
      square(0, 0, size);
    }
    pop();

    // Show fader value
    push();
    translate(pos.x, pos.y + 60);

    fill(100);
    rect(0, 0, 25, 127);

    translate(0, 127);
    push();
    stroke(255);
    fill(color(50, 50, 200));
    rect(0, 0, 25, -faderValue);
    pop();
    //translate(0, 127);
    fill(255);
    textSize(12);
    text("Fader", 0, 17);
    pop();

    // Show filter value
    float fv = map(filterValue, -8, 8, 0, 127);
    int middle = 127/2;
    push();

    translate(pos.x + 45, pos.y + 60);
    fill(100);
    rect(0, 0, 25, 127);

    translate(0, middle);
    push();
    stroke(255);
    fill(color(50, 50, 200));
    rect(0, 0, 25, middle - fv);
    pop();

    translate(0, middle);
    fill(255);
    textSize(12);
    text("Filter", 0, 17);
    pop();

    pop();

    return;
  }

  // if the deck is playing, the filter is engaged and the volume is more than a certain value
  // then toggle the blur indicator on
  void isBlurOn() {
    if (playing && faderValue > 30 && (abs(filterValue)) > 0) {
      blurOn = true;
    } else {
      blurOn = false;
    }
    mixerState.checkForBlurOn();
  }
}

// A class that stores the state of the mixer and effects
// and that decides what to display as a result of that
class MixerState {
  DeckSettings[] decks;
  float filterIntensity; // stores 0 if the blur is off, or the
  // highest filter value across the 4 decks if it is on

  MixerState() {
    decks = new DeckSettings[4];
    decks[0] = deckA;
    decks[1] = deckB;
    decks[2] = deckC;
    decks[3] = deckD;
    filterIntensity = 0;
  }

  void checkForBlurOn() {
    if ((deckA.blurOn) || (deckB.blurOn) || (deckC.blurOn) || (deckD.blurOn)) {

      filterIntensity = 0;
      for (DeckSettings d : decks) {
        if (abs(d.filterValue) > filterIntensity) {
          filterIntensity = abs(d.filterValue);
        }
      }
    } else {
      filterIntensity = 0;
    }
  }
}

// A class that stores a list of hotcue packs
// Each pack is an array 8 images and is linked to the deck hotcues.
// When a hotcue is triggered the appropriate image is displayed.

class HotcuePacks {
  ArrayList<PImage[]> hotcues;
  int     hotcueFrames;
  int     hotcueFrameCount;
  boolean hotcueReady;
  int     currentPack;
  int     currentHotcue;
  PImage  currentImage;
  int     alphaDec;
  int     alpha;
  int     imageX;
  int     imageY;

  HotcuePacks() {
    hotcues = loadHotcuePacks();
    hotcueFrames = 15; // How many frames to draw the hotcue for
    hotcueFrameCount = 0;
    alpha = 255;
    alphaDec = alpha/hotcueFrames;


    currentPack = 0;
    currentHotcue = 0;
    readyHotcue(currentPack, currentHotcue);
    hotcueReady = false;
    imageX = width/2;
    imageY = height/2;
  }

  void draw() {
    if (hotcueReady) {
      imageMode(CENTER);
      tint(255, alpha);
      image(currentImage, imageX, imageY, width, height);
      imageMode(CORNER);
      hotcueFrameCount++;
      if (hotcueFrameCount > hotcueFrames)
      {
        hotcueFrameCount = 0;
        hotcueReady = false;
      }
      alpha = alpha - alphaDec;
      noTint();
    }
  }

  void readyHotcue(int p, int hc) {
    currentPack = p;
    currentHotcue = hc;
    hotcueFrameCount = 0;
    alpha = 255;

    currentImage = hotcues.get(currentPack)[hc];

    hotcueReady = true;
  }

  int size() {
    return hotcues.size();
  }

  ArrayList<PImage[]> loadHotcuePacks() {
    ArrayList<PImage[]> hc = new ArrayList();

    // Get the sketch's data directory
    File dataDir = new File(dataPath(""));

    FilenameFilter hotCueFilter = new FilenameFilter() {
      public boolean accept(File dir, String name) {
        return name.startsWith("hotcue");
      }
    };

    //list all the hotcue packs in the directory
    File[] hotcueDirs = dataDir.listFiles(hotCueFilter);

    if (hotcueDirs.length < 1) {
      println("No hotcue directory found");
      println("make sure that you have at least one directory,");
      println("inside the sketch's data directory, named \"hotcue_pack<x>\"");
      exit();
    }

    for (File d : hotcueDirs) {
      PImage hotcueImages[] = getHotcueImages(d);
      if (hotcueImages != null) {
        hc.add(hotcueImages);
      }
    }
    return hc;
  }

  // Looks in the data directory for hotcue packs
  // and returns an array of images for each one that it finds.
  PImage[] getHotcueImages(File dir ) {
    PImage hotcueImages[] = new PImage[8];

    File[] files = dir.listFiles();
    for (int i=0; i < files.length; i++) {
      String path = files[i].getAbsolutePath();

      if (path.toLowerCase().endsWith(".png")) {
        PImage image = loadImage( path );
        image.resize(width, 0);
        hotcueImages[i] = image;
      }
    }
    if (hotcueImages.length < 8) {
      println("Warning - Less than 8 images found in " + dir);
      return null;
    } else {
      return(hotcueImages);
    }
  }
}
