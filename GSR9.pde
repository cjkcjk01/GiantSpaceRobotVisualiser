// ************************************************************************************* //<>//
// * giantspacerobot visualiser for Traktor                                            *
// * Heavily based on awesome visualisers from Tobias Wehrum (Oblivion), Ben Farahmand's
// * (Sprocket) and mojovideotech (Candywarp shader)
// * (attributed below)                                                                *
// * This extends giantspacerobot's https://maps.djtechtools.com/mappings/6883         *
// * to use a page on the Maschine Jam to control various parameters in a visualiser.  *
// * It responds to the audio from Traktor, as well as various midi messages from a    *
// * Traktor controller                                                                *
// *************************************************************************************

// Acknowledgments

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Oblivion
// Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
// Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
// This notice shall be included in all copies or substantial portions of the Software.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
// Atomic Sprocket Visualiser
// Benjamin Farahmand
// https://gist.github.com/benfarahmand/6902359#file-audio-visualizer-atomic-sprocket
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// CandyWarp  by mojovideotech
//
// based on :
// glslsandbox.com/e#38710.0
// Posted by Trisomie21
// modified by @hintz
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////

// MacOS Notes
// There are problems with theMidiBus Library on MacOS, to solve you need to use
// version 9 rather than the version 8 that is installed with the library manager.
// It can be found here https://github.com/micycle1/themidibus/releases/tag/p4
//
// Problem with smooth() and PGraphics,
// details here https://github.com/benfry/processing4/issues/694
//
// Problems with Minim getLineIn(), need to use Minim.MONO rather than Minim.STEREO


// Initialisation

import themidibus.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.lang.reflect.Method;
import java.util.Date;
import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;

//import spout.*;

// ***********************
// Initialise audio stuff
// ***********************

Minim minim;
AudioInput input;

// ***********************
// Initialise Midi stuff
// ***********************

MidiBus myBus;
//ArrayList midiDevices = new ArrayList();
// the midi channel defaults to 11, but can be overridden via the config file
// (Midi channel 11 is numbered 10 in MidiBus (!)
int midiChannel = 10;

// *********************************************
// Initialise up JSON handlers for config files
// *********************************************

// A JSON object
JSONObject mainJSON;
JSONObject midiJSON;
JSONObject midiTraktorJSON;

// ***********************
// Init text display
// ***********************

PFont font;

// ****************************************
// Init the shaders & visualiser options
// ****************************************

// Shaders used in post processing
ShaderBrcosa     shaderBrcosa;
ShaderHue        shaderHue;
ShaderPixelate   shaderPixelate;
ShaderChannels   shaderChannels;
ShaderThreshold  shaderThreshold;
ShaderNeon       shaderNeon;
ShaderDeform     shaderDeform;
ShaderPixelRolls shaderPixelrolls;
ShaderModcolor   shaderModcolor;
ShaderHalftone   shaderHalftone;
ShaderInvert     shaderInvert;

PostProcessingShaders VisShaders;

// Shaders used to represent effects in traktor
ShaderVHSGlitch shaderVhs_glitch; // Represent the Gate/Slice or Beatmasher effects in Traktor
ShaderSobel     shaderSobel;      // Represent an echo effect in Traktor
BlurShader      shaderBlur;       // Represent a filter effect in Traktor

// Options used in the main draw routine
boolean kaleidoscopeOn = false;
boolean waveformOn     = false;
boolean delayOn        = false;
boolean sliceOn        = false;

// Init the main visualisers
// One of these can be in action at a time
VisOblivion     visOblivion;
VisSprocket     visSprocket;
VisCandyWarp    visCandyWarp;
VisJazzUniverse visJazzUniverse;
VisCircleTunnel visCircleTunnel;
VisBeatLoop     visBeatLoop;

// Init the collection of main visualiers
Visualisers visualisers;

// Init the waveform visualiser
// this visualiser can be overlayed on the others
VisWaveform visWaveform;

// This shader can be toggled on as part of the main draw routine
// and affects any object onscreen
ShaderKaleidoscope shaderKaleidoscope;

// Init the collection of Midi Controls
MidiControls midiControls;

PGraphics pgr; // Graphics rendering destination used in the visualisers

// *****************************
// Initialise decks and hotcues
// *****************************

// Objects that store the state of each deck
DeckSettings deckA;
DeckSettings deckB;
DeckSettings deckC;
DeckSettings deckD;

// Init the object to store the overall mixer settings
MixerState mixerState;

// Init list of images used when a hotkey is pressed
HotcuePacks hotcuePacks;

// Init the word packs, these are lists of words that can be displayed on each beat
WordPacks beatWords;

// Init the palette used to switch the background colour on each beat
BgPalette myBgPalette;

// *****************************
// Init a few other misc things
// *****************************

// precalc some constants for performance reasons
final float PI2   = PI*2;
final float PI100 = PI/100;

// used to toggle fps and info display
// press "i" to toggle
boolean infoOn = false;
boolean helpOn = false;

// Declare a SPOUT object, used to direct video output to another application, such as a video projection app
//Spout spout;
//boolean spoutOn;

// Set up dictionary of functions that can be triggered by external midi
HashMap<Integer, String> midiFunctions = new HashMap<Integer, String>();

// Init variables used to calc the duration between beats
float[] beatTimes    = new float[4]; // Array that holds the timings of the last few beats
int     currentIndex = 0;
int     beatDuration = 0; // A running average of the duration in milliseconds between beats

// Set up Cue Info (used to display info about setting changes that can then be cued up. For example
// you could choose the next visualiser to display but it does not change until a control is pressed.
// The cue info window shows a small amount of information to help with this.
CueInfo cueInfo;

// **********************************************************************************
// * Settings function
// *
// * Used to set up the canvas size that is read from the config file. See
// * https://processing.org/reference/settings_.html for more details
// **********************************************************************************

void settings() {

  // load the screen definition from the config file
  JSONObject j = loadJSONObject("config.json");
  JSONArray d = j.getJSONArray("screensize");
  if (d.size() == 0) {
    println("Can't find sceeensize definition in config file, please check this");
    exit();
  }

  JSONObject m = d.getJSONObject(0);

  // is this fullscreen or not?
  boolean full = m.getBoolean("fullscreen");

  // set the display to draw on (only applies to fullscreen)
  int display = m.getInt("displaynumber");

  // if not fullscreen, then what are the window dimensions?
  int w = m.getInt("width");
  int h = m.getInt("height");

  if (full) {
    fullScreen(P3D, display);
  } else {
    size(w, h, P3D);
  }
}

// **********************************************************************************
// * Setup
// **********************************************************************************
void setup()
{

  surface.setTitle("GiantSpaceRobot Visualiser");

  // Create a new SPOUT object
  //  spout = new Spout(this);
  //  spout.createSender("Spout Processing");
  //  spoutOn = false;

  // *********************
  // Setup Sound stuff
  //**********************
  minim = new Minim(this);
  input = minim.getLineIn(Minim.MONO, 1024, 48000, 16);

  // *********************
  // Set up text display
  //**********************
  font = loadFont("FranklinGothic-Heavy-200.vlw");

  // ******************
  // * Set up shaders *
  // ******************

  // Add a kaleidoscope effect to the entire display
  shaderKaleidoscope = new ShaderKaleidoscope();

  // Shaders used to represet effects used in Traktor
  shaderVhs_glitch = new ShaderVHSGlitch(); // represents slicer, masher and gater
  shaderSobel      = new ShaderSobel();     // reresents echo
  shaderBlur       = new BlurShader();      // represents filter (or deck FX)

  // set up a list of shaders used for post processing effects
  VisShaders = new PostProcessingShaders();

  // ********************
  // Set up visualisers
  // ********************

  visWaveform = new VisWaveform("Waveform");

  visOblivion     = new VisOblivion("Oblivion");
  visSprocket     = new VisSprocket("Sprocket");
  visCandyWarp    = new VisCandyWarp("CandyWarp");
  visJazzUniverse = new VisJazzUniverse("JazzUniverse");
  visCircleTunnel = new VisCircleTunnel("CircleTunnel");
  visBeatLoop     = new VisBeatLoop("BeatLoop");

  // set up the list of main visualisers
  visualisers = new Visualisers();

  visualisers.addVisualiser(visOblivion);
  visualisers.addVisualiser(visSprocket);
  visualisers.addVisualiser(visCandyWarp);
  visualisers.addVisualiser(visJazzUniverse);
  visualisers.addVisualiser(visCircleTunnel);
  visualisers.addVisualiser(visBeatLoop);

  visWaveform = new VisWaveform("Waveform");

  // ********************
  // Set up midiControls
  // ********************
  midiControls = new MidiControls();

  // Set up Cue info window
  cueInfo = new CueInfo();

  // *************
  // Set up decks
  // *************

  deckA = new DeckSettings("A");
  deckB = new DeckSettings("B");
  deckC = new DeckSettings("C");
  deckD = new DeckSettings("D");

  mixerState = new MixerState();

  hotcuePacks = new HotcuePacks();

  // Read and process the config file, this includes setting up the midi inputs
  // and the word packs
  loadConfig();
  midiConfig();
  midiTraktorConfig();
}

// **********************************************************************************
// * Draw
// **********************************************************************************
void draw()
{
  myBgPalette.drawBg();

  if (kaleidoscopeOn) {
    shaderKaleidoscope.draw();
  } else {
    resetShader();
  }

  //draw the hotcue image if one has been triggered
  hotcuePacks.draw();

  // main visualiser
  visualisers.currentVisualiser.draw();

  // waveform display
  if (waveformOn) {
    visWaveform.draw();
  }

  // draw words on the screeen (if any are selected)
  beatWords.display();

  // toggle shaders if certain effects are on
  if (delayOn) {
    shaderSobel.draw();
  }

  if (sliceOn) {
    shaderVhs_glitch.draw();
  }

  // post processing shaders
  VisShaders.draw();

  // apply the blur filter, the degree is defined by the position of the filter knob in traktor
  shaderBlur.draw();

  if (infoOn) {
    resetShader();
    displayInfo();
  }

  if (helpOn) {
    resetShader();
    displayHelp();
  }

  // if there is any cue information then draw it
  cueInfo.draw();

  // SPOUT is used to export the display to an external program to support things like
  // post processing and projection mapping
  //  if (spoutOn) {
  //    spout.sendTexture();
  //  }
}

// Keyboard controls, used for convenience if midi device is not available
void keyPressed() {
  println("key: "+key+" keyCode: "+keyCode);

  if (key == 'i') {
    infoOn = !infoOn;
  }
  if (key == 'd') {
    visualisers.cueVisualiserByKeyboard(2);
  }
  if (key == 'a') {
    visualisers.cueVisualiserByKeyboard(1);
  }
  if (key == 's') {
    visualisers.setVisualiser(1);
  }
  if (key == 'w') {
    waveformOn = !waveformOn;
  }
  if (key == 'p') {
    //    spoutOn = !spoutOn;
  }
  if ((key == 'h')||(key == '?')) {
    helpOn = !helpOn;
  }
}

void displayInfo() {
  push();

  fill(150);
  textSize(12);
  textAlign(BASELINE);
  text("Info\n"
    + "------------\n"
    + "FPS = " + round(frameRate) + "\n"
    //    + "SPOUT on = " + spoutOn + "\n"
    + "Visualiser = " + visualisers.getName() + "\n"
    + "\n" + "Post Shader = " + VisShaders.getCurrentShaderInfo() + "\n"
    , 10, 30);

  // Call each deck to show its status
  int columns = 4;
  int w = width/columns;
  int w2 = w/2;

  int h = height/4;

  PVector pos = new PVector(0, 0);

  pos.set(w2, h);
  deckC.showStatus(pos);

  pos.set(w + w2, h);
  deckA.showStatus(pos);

  pos.set(w*2 + w2, h);
  deckB.showStatus(pos);

  pos.set(w*3 + w2, h);
  deckD.showStatus(pos);

  // Show state of any Midi controls
  midiControls.draw();

  pop();
}

void displayHelp() {
  push();
  fill(150);
  textSize(12);
  textAlign(BASELINE);
  text("Help\n"
    + "------------\n"
    + "i - Info toggle\n"
    + "w - Waveform toggle\n"
    + "d - Next Visualiser\n"
    + "a - Prev Visualiser\n"
    + "p - SPOUT toggle", width -200, 30);
  pop();
}
