// A class for deck specific settings, used to store things like volume, play/stop status and to 
// link a specific hotcue pack to the deck
class DeckSettings {
  String  name;
  int     hotcuePack;
  int     hotcueIndex;
  int     faderValue;
  float   filterValue;
  boolean blurOn;
  boolean playing;

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
    // check to see if there is a matching pack loaded
    if (value > hotcuePacks.size()) {
      println ("Warning - Pack number " + value + " does not exist. /n Setting to pack 0 ");
      hotcuePack  = 0;
      hotcueIndex = 0;
    } else {
      hotcuePack = value - 1;
      hotcueIndex = 0;
    }
  }

  // cues up the next hotcue to draw
  void readyHotcue(int value) {
    if (faderValue > 25) {
      if (value == 15) {
        hotcueIndex = 0;
      } else if (value == 31) {
        hotcueIndex = 1;
      } else if (value == 47) {
        hotcueIndex = 2;
      } else if (value == 63) {
        hotcueIndex = 3;
      } else if (value == 79) {
        hotcueIndex = 4;
      } else if (value == 95) {
        hotcueIndex = 5;
      } else if (value == 111) {
        hotcueIndex = 6;
      } else if (value == 127) {
        hotcueIndex = 7;
      }
      hotcuePacks.readyHotcue(hotcuePack, hotcueIndex);
    }
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
    filterValue = abs(map(v, 1, 127, -8, 8));
    if (filterValue < 0.15) {
      filterValue = 0;
    }
    isBlurOn();
  }

  float getFilter() {
    return filterValue;
  }

  String getStatus() {
    String s;
    if (playing) {
      s = "Playing";
    } else {
      s = "Paused";
    }
    String status = "Deck " + name + " is " + s + " fader = " + faderValue + " filter = " + filterValue;
    return status;
  }

  // if the deck is playing, the filter is engaged and the volume is more than a certain value
  // then toggle the blur indicator on
  void isBlurOn() {
    if (playing && faderValue > 30 && filterValue > 0) {
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
        if (d.filterValue > filterIntensity) { 
          filterIntensity = d.filterValue;
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
