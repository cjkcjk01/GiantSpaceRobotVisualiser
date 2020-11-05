// *********************************************
// Color palettes used for the background
// *********************************************

// the background colour can be toggled to change on each beat. A list of colours is loaded
// from the config file into a list of arrays. Each time the option is toggled the next palette is loaded.

class BgPalette {
  ArrayList<color[]> palettes = new ArrayList<color[]>();
  color[] bgColors;
  color   bgColor;
  int     bgColorIndex;
  int     BgPaletteIndex;
  boolean bgBeatSync;
  boolean blackOrWhite;

  BgPalette(ArrayList<color[]> p) {

    palettes = p;

    BgPaletteIndex = 0;
    bgColors = palettes.get(BgPaletteIndex);
    bgColor = bgColors[1];
    bgColorIndex = 0;
    bgBeatSync   = false;
    blackOrWhite = false;
  }

  void incPalette() {
    BgPaletteIndex++;
    if (BgPaletteIndex > palettes.size() - 1) {
      BgPaletteIndex = 0;
    }
    bgColors = palettes.get(BgPaletteIndex);
  }

  color incColor() {
    bgColorIndex++;
    if (bgColorIndex > bgColors.length - 1) {
      bgColorIndex = 0;
    }
    bgColor = bgColors[bgColorIndex];
    return bgColor;
  }

  void toggle() {
    bgBeatSync = !bgBeatSync;
    if (bgBeatSync) {
      incPalette();
    }
  }

  void toggleBlackOrWhite() {
    blackOrWhite = !blackOrWhite;
  }

  boolean getBlackOrWhite() {
    return blackOrWhite;
  }

  void drawBg() {
    if (bgBeatSync) {
      background(bgColor);
    } else {    
      if (blackOrWhite) {
        background(255);
      } else {
        background(0);
      }
    }
  }
}
