// Handles midi messages, currently we are only using CC values, but the methods are here for //<>//
// note on and off in case they are needed at some stage.
// It then uses Java's reflection techniques (https://www.oracle.com/technical-resources/articles/java/javareflection.html)
// to call a method for each individual message that is received

void noteOn(int channel, int pitch, int velocity, long timestamp, String busName) {
  //println("Note On       : Channel = " + channel + " Pitch = " + pitch + " Vel = "+ velocity + " bus name = " + busName);
}

void noteOff(int channel, int pitch, int velocity, long timestamp, String busName) {
  //println("Note Off      : Channel = " + channel + " Pitch = " + pitch + " Vel = "+ velocity + " bus name = " + busName);
}

void controllerChange(int channel, int number, int value, long timestamp, String busName) {
  int    functionKey;
  String functionName;
  MidiControl midiControl;

  //println("Control Change: Channel = " + channel + " CC" + number + " Value = "+value + " bus name = " + busName);

  if (!midiControls.exists(busName, channel, number)) {
    MidiControl c = new MidiControl(busName, channel, number, value);
    midiControls.addControl(c);
  }

  midiControl = midiControls.get(busName, channel, number);
  midiControl.value = value;

  // make the key to retrive the midi function name from the hashmap
  functionKey = (channel * 100) + number;

  // Retrive the function name from the HashMap of midi functions
  functionName = midiFunctions.get(functionKey);
  if (functionName == null) {
    println("Function for Midi Value " + functionKey + " not found");
    return;
  }

  // use Java Reflection technique to call the required function
  // https://www.baeldung.com/java-reflection has a good explanation of this approach
  try {
    Class[] cls = new Class[1];
    cls[0] = int.class;
    Method handler = this.getClass().getMethod( functionName, cls );
    handler.invoke(this, value);
  }
  catch (Exception e) {
    println("Midi error in control change : number = " + number + ", value = " + value );
    e.printStackTrace();
  }
}

// *****************************************
// * Hotcues & deck specific settings
// *****************************************

// Deck volume faders
void setVolumeDeckA(int value) {
  deckA.setVolume(value);
}
void setVolumeDeckB(int value) {
  deckB.setVolume(value);
}
void setVolumeDeckC(int value) {
  deckC.setVolume(value);
}
void setVolumeDeckD(int value) {
  deckD.setVolume(value);
}

// Deck play status
void setIsPlayingDeckA(int value) {
  if (value == 127) {
    deckA.setIsPlaying(true);
  } else {
    deckA.setIsPlaying(false);
  }
}
void setIsPlayingDeckB(int value) {
  if (value == 127) {
    deckB.setIsPlaying(true);
  } else {
    deckB.setIsPlaying(false);
  }
}
void setIsPlayingDeckC(int value) {
  if (value == 127) {
    deckC.setIsPlaying(true);
  } else {
    deckC.setIsPlaying(false);
  }
}
void setIsPlayingDeckD(int value) {
  if (value == 127) {
    deckD.setIsPlaying(true);
  } else {
    deckD.setIsPlaying(false);
  }
}

// Hotcues for Decks
void readyHotCueDeckA(int value) {
  if (value > 0) {
    deckA.readyHotcue(value);
  }
}
void readyHotCueDeckB(int value) {
  if (value > 0) {
    deckA.readyHotcue(value);
  }
}
void readyHotCueDeckC(int value) {
  if (value > 0) {
    deckA.readyHotcue(value);
  }
}
void readyHotCueDeckD(int value) {
  if (value > 0) {
    deckA.readyHotcue(value);
  }
}

//select hotcue packs
void setHotCuePackA(int value) {
  if (value > 0) {
    deckA.setPack(value);
  }
}
void setHotCuePackB(int value) {
  if (value > 0) {
    deckB.setPack(value);
  }
}
void setHotCuePackC(int value) {
  if (value > 0) {
    deckC.setPack(value);
  }
}
void setHotCuePackD(int value) {
  if (value > 0) {
    deckD.setPack(value);
  }
}

void hotCueClearCueInfo(int Value) {
  cueInfo.clearText();
}

// ********************************************
// * respond to effects being used in Traktor *
// ********************************************

// Set the degree of blur based on the Traktor filter knob
void setFilterA(int value) {
  deckA.setFilter(value);
}
void setFilterB(int value) {
  deckB.setFilter(value);
}
void setFilterC(int value) {
  deckC.setFilter(value);
}
void setFilterD(int value) {
  deckD.setFilter(value);
}

// Shader to visualise the delay(echo) effect
void setDelayStatus(int value) {
  if (value > 100) {
    delayOn = true;
  } else if (value == 0) {
    delayOn = false;
  }
}

// Shader to visualise the gate/slice/mash effect
void setGlitchStatus(int value) {
  if (value > 100) {
    sliceOn = true;
  } else if (value == 0) {
    sliceOn = false;
  }
}

// ********************************************
// * Visualiser settings                      *
// ********************************************

// Cue up the next main visualiser
void cueVisualiser(int value) {
  visualisers.cueVisualiserByMidi(value);
}

// Select the main visualiser
void selectVisualiser(int value) {
  visualisers.setVisualiser(value);
}

// Sends a value from the browse knob to the current visualiser
void setVisualiserKnobValue(int value) {
  visualisers.setKnob1(value);
}

// set the scaling for the fft analysis, which is it's sensitivity to volume
void setVisualiserScalingValue(int value) {
  visualisers.setScaling(value);
}

// Button1 for visualiser
void toggleVisualiserButton1(int value) {
  if (value > 100) {
    visualisers.toggleButton1();
  }
}

// Button2 for visualiser
void toggleVisualiserButton2(int value) {
  if (value > 100) {
    visualisers.toggleButton2();
  }
}

// Fader1 for visualiser
void setVisualiserFader1(int value) {
  visualisers.setFader1(value);
}

// Fader2 for visualiser
void setVisualiserFader2(int value) {
  visualisers.setFader2(value);
}

// Toggle the waveform visualiser
void toggleWaveform(int value) {
  waveformOn = !waveformOn;
}

// set the scaling for the waveform visualiser, which is it's sensitivity to volume
void setWaveformScale(int value) {
  visWaveform.scale(value);
}

// Toggle the kaleidoscope shader
void toggleKaleidoscope(int value) {
  kaleidoscopeOn = !kaleidoscopeOn;
}

void setKaleidoscopeRotation(int value) {
  shaderKaleidoscope.setRotation(value);
}
void setKaleidoscopeViewAngle(int value) {
  shaderKaleidoscope.setViewAngle(value);
}

// set the alpha value for the beat text
void setBeatTextAlpha(int value) {
  beatWords.setAlpha(value);
}

//************************************************
// Background colour and word display settings
//************************************************

// carry out any actions that happen when a beat is detected
void triggerBeatActions(int value) {
  if (value > 120) {
    myBgPalette.incColor();     // Increments the background color on each beat,
    beatWords.nextWord();       // Draws the next word in the wordlist
    visualisers.onBeatAction(); // Triggers any beat related actins in the current visualiser

    // Calculate the duration between beats
    float currentTime = millis();
    beatTimes[currentIndex] = currentTime;
    currentIndex = (currentIndex + 1) % beatTimes.length;

    int sum = 0;
    int count = 0;
    for (int i = 0; i < beatTimes.length; i++) {
      if (beatTimes[i] > 0) {
        sum += currentTime - beatTimes[i];
        count++;
      }
    }

    if (count > 0) {
      beatDuration = sum / count;
    }
  }
}

// Toggle the beat sync (change background color on each beat)
void toggleBackgroundBeatSync(int value) {
  if (value > 100) {
    myBgPalette.toggle();
  }
}

// Toggle black or white background
void toggleBlackOrWhiteBackground(int value) {
  if (value > 100) {
    myBgPalette.toggleBlackOrWhite();
  }
}

// toggle the word display and set the list of words to use
void toggleWordDisplay(int value) {
  beatWords.setCurrentPack(value);
}

//*************************************
// Post processing shader selection
//*************************************

// select the shader to use
void selectPostShader(int value) {
  VisShaders.setShader(value);
}
// toggle the post processing shaders
void togglePostShader(int value) {
  VisShaders.toggleVisShaders();
}
// change the first parameter of the post processing shader
void setPostShaderValue1(int value) {
  VisShaders.setX(value);
}
// change the second parameter of the post processing shader
void setPostShaderValue2(int value) {
  VisShaders.setY(value);
}
