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

/* Acknowledgments
 
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
 
 */

import themidibus.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.lang.reflect.Method;
import java.util.Date;
import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;

import spout.*;

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

// ************************************
// Set up JSON handler for config file
// ************************************

// A JSON object
JSONObject json;

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
VisOblivion  visOblivion;
VisSprocket  visSprocket;
VisCandyWarp visCandyWarp;

// Init the collection of main visualiers
Visualisers visualisers;

// Init the waveform visualiser
// this visualiser can be overlayed on the others
VisWaveform visWaveform;

// This shader can be toggled on as part of the main draw routine
// and affects any object onscreen
ShaderKaleidoscope shaderKaleidoscope;

// **************************
// Set up decks and hotcues
// **************************

// Objects that store the state of each deck
DeckSettings deckA;
DeckSettings deckB;
DeckSettings deckC;
DeckSettings deckD;

// Object to store the overall mixer settings
MixerState mixerState;

// List of images used when a hotkey is pressed
HotcuePacks hotcuePacks;

// Init the word packs, these are lists of words that can be displayed on each beat
WordPacks beatWords;

// Init the palette used to switch the background colour on each beat
BgPalette myBgPalette;

// precalc some constants for performance reasons
final float PI2   = PI*2;
final float PI100 = PI/100;

// used to toggle fps and info display
// press "i" to toggle
boolean infoOn = false;
boolean helpOn = false;

//PImage    img; // image to use for the rotating cube demo
PGraphics pgr; // Graphics for demo

// Declare a SPOUT object, used to direct video output to another application, such as a video projection app
Spout spout;
boolean spoutOn;

void settings() {
  // load the screen definition from the config file
  JSONObject j = loadJSONObject("config.json");

  // load MIDI channel info from config.json
  JSONArray d = j.getJSONArray("screensize");
  if (d.size() == 0) {
    println("Can,t find sceeensize definition in config file, please check this");
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
  spout = new Spout(this);
  spout.createSender("Spout Processing");
  spoutOn = false;

  // *********************
  // Setup Sound stuff
  //**********************
  minim = new Minim(this);
  input = minim.getLineIn(Minim.STEREO, 1024, 48000, 16);

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

  // Set up visualisers
  visWaveform = new VisWaveform("Waveform");

  visOblivion  = new VisOblivion("Oblivion");
  visSprocket  = new VisSprocket("Sprocket");
  visCandyWarp = new VisCandyWarp("CandyWarp");

  // set up the list of main visualisers
  visualisers = new Visualisers();

  visualisers.addVisualiser(visOblivion);
  visualisers.addVisualiser(visSprocket);
  visualisers.addVisualiser(visCandyWarp);

  // Set up decks
  deckA = new DeckSettings("A");
  deckB = new DeckSettings("B");
  deckC = new DeckSettings("C");
  deckD = new DeckSettings("D");

  mixerState = new MixerState();

  hotcuePacks = new HotcuePacks();

  // Read and process the config file, this includes setting up the midi inputs
  // and the word packs
  loadConfig();
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
    displayFPS();
  }
  if (helpOn) {
    resetShader();
    displayHelp();
  }

  // SPOUT is used to export the display to an external program to support things like 
  // post processing and projection mapping 
  if (spoutOn) {
    spout.sendTexture();
  }
}

// Keyboard controls, used for convenience if midi device is not available
void keyPressed() {
  println("key: "+key+" keyCode: "+keyCode);

  if (key == 'i') {
    infoOn = !infoOn;
  }
  if (key == 'd') {
    visualisers.setVisualiser(2);
  }
  if (key == 'a') {
    visualisers.setVisualiser(1);
  }
  if (key == 'w') {
    waveformOn = !waveformOn;
  }
  if (key == 'p') {
    spoutOn = !spoutOn;
  }
  if ((key == 'h')||(key == '?')) {
    helpOn = !helpOn;
  }
}

void displayFPS() {
  push();
  fill(150);
  textSize(12);
  textAlign(BASELINE);
  text("Info\n"
    + "------------\n"
    + "FPS = " + round(frameRate) + "\n"
    + "SPOUT on = " + spoutOn + "\n"
    + "Visualiser = " + visualisers.getName() + "\n"
    + "\n" + "Post Shader = " + VisShaders.getCurrentShaderInfo() + "\n"
    + deckA.getStatus() + "\n" + deckB.getStatus() + "\n" + deckC.getStatus()+ "\n" + deckD.getStatus(), 10, 30);
  //    +  "FFT Scaling = " + visualisers.getScaling() + "\n"

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
