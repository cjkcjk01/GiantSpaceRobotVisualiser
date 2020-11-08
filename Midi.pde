// Handles midi messages, currently we are only using CC values, but the methods are here for //<>//
// note on and off in case they are needed at some stage.
// It then uses Java's reflection techniques (https://www.oracle.com/technical-resources/articles/java/javareflection.html)
// to call a method for each individual message that is received
// (Rather than try to find out if a class exists we simply create a class for every cc value (it was easier!))

void noteOn(int channel, int pitch, int velocity, long timestamp, String bus_name) {
  //println("Note On       : Channel = " + channel + " Pitch = " + pitch + " Vel = "+ velocity);
}

void noteOff(int channel, int pitch, int velocity, long timestamp, String bus_name) {
  //println("Note Off      : Channel = " + channel + " Pitch = " + pitch + " Vel = "+ velocity);
}

void controllerChange(int channel, int number, int value, long timestamp, String bus_name) {
  //println("Control Change: Channel = " + channel + " CC" + number + " Value = "+value + " bus name = " + bus_name);

  if (channel == midiChannel) {
    try {
      Class[] cls = new Class[1];
      cls[0] = int.class;
      Method handler = this.getClass().getMethod( "onCCChange" + number, cls );
      handler.invoke(this, value);
    } 
    catch (Exception e) {
      println("Midi error in control change : number = " + number + ", value = " + value );
      e.printStackTrace();
    }
  }
}

// *****************************************
// * Hotcues & deck specific settings
// *****************************************

// Deck volume faders
void onCCChange100(int value) {
  deckA.setVolume(value);
}
void onCCChange101(int value) {
  deckB.setVolume(value);
}
void onCCChange102(int value) {
  deckC.setVolume(value);
}
void onCCChange103(int value) {
  deckD.setVolume(value);
}

// Deck play status
void onCCChange110(int value) {  
  if (value == 127) {
    deckA.setIsPlaying(true);
  } else { 
    deckA.setIsPlaying(false);
  }
}
void onCCChange111(int value) {  
  if (value == 127) {
    deckB.setIsPlaying(true);
  } else { 
    deckB.setIsPlaying(false);
  }
}
void onCCChange112(int value) {  
  if (value == 127) {
    deckC.setIsPlaying(true);
  } else { 
    deckC.setIsPlaying(false);
  }
}
void onCCChange113(int value) {  
  if (value == 127) {
    deckD.setIsPlaying(true);
  } else { 
    deckD.setIsPlaying(false);
  }
}

// Hotcues for Decks
void onCCChange1(int value) {  
  deckA.readyHotcue(value);
}
void onCCChange2(int value) {  
  deckB.readyHotcue(value);
}
void onCCChange3(int value) {  
  deckC.readyHotcue(value);
}
void onCCChange4(int value) {  
  deckD.readyHotcue(value);
}

//select hotcue packs
void onCCChange56(int value) {  
  if (value > 0) {
    deckA.setPack(value);
  }
}
void onCCChange57(int value) {  
  if (value > 0) {
    deckB.setPack(value);
  }
}
void onCCChange58(int value) {  
  if (value > 0) {
    deckC.setPack(value);
  }
}
void onCCChange59(int value) {  
  if (value > 0) {
    deckD.setPack(value);
  }
}

// ********************************************
// * respond to effects being used in Traktor *
// ********************************************

// Set the degree of blur based on the Traktor filter knob
void onCCChange105(int value) {  
  deckA.setFilter(value);
}
void onCCChange106(int value) {  
  deckB.setFilter(value);
}
void onCCChange107(int value) {  
  deckC.setFilter(value);
}
void onCCChange108(int value) {  
  deckD.setFilter(value);
}

// Shader to visualise the delay(echo) effect
void onCCChange64(int value) {  
  if (value > 100) {
    delayOn = true;
  } else if (value == 0) {
    delayOn = false;
  }
}

// Shader to visualise the gate/slice/mash effect
void onCCChange65(int value) {  
  if (value > 100) {
    sliceOn = true;
  } else if (value == 0) {
    sliceOn = false;
  }
}

// ********************************************
// * Visualiser settings                      *
// ********************************************

// Select the main visualiser
void onCCChange21(int value) {  
  visualisers.setVisualiser(value);
}

// Sends a value from the browse knob to the current visualiser
void onCCChange45(int value) {  
  visualisers.setKnob1(value);
}

// set the scaling for the fft analysis, which is it's sensitivity to volume
void onCCChange48(int value) {  
  visualisers.setScaling(value);
}

// Button1 for visualiser
void onCCChange27(int value) {   
  if (value > 100) {
    visualisers.toggleButton1();
  }
}

// Button2 for visualiser
void onCCChange28(int value) {  
  if (value > 100) {
    visualisers.toggleButton2();
  }
}

// Fader1 for visualiser
void onCCChange52(int value) {
  visualisers.setFader1(value);
}
// Fader2 for visualiser
void onCCChange53(int value) {
  visualisers.setFader2(value);
}

// Toggle the waveform visualiser
void onCCChange26(int value) {  
  if (value > 100) {
    waveformOn = !waveformOn;
  }
}
// set the scaling for the waveform visualiser, which is it's sensitivity to volume
void onCCChange49(int value) {  
  visWaveform.scale(value);
}

// Toggle the kaleidoscope shader
void onCCChange29(int value) {  
  if (value > 100) {
    kaleidoscopeOn = !kaleidoscopeOn;
  }
}

// set the alpha value for the beat text
void onCCChange50(int value) {  
  beatWords.setAlpha(value);
}

//************************************************
// Background colour and word display settings
//************************************************

// Detect a beat and change the background color on each beat,
// as well as incrementing to the next word to display 
void onCCChange41(int value) {  
  if (value > 120) {
    myBgPalette.incColor();
    beatWords.nextWord();
  }
}

// Toggle the beat sync (change background color on each beat)
void onCCChange30(int value) {  
  if (value > 100) {
    myBgPalette.toggle();
  }
}

// Toggle black or white background
void onCCChange46(int value) { 
  if (value > 100) {
    myBgPalette.toggleBlackOrWhite();
  }
}

// toggle the word display and set the list of words to use
void onCCChange47(int value) {  
  beatWords.setCurrentPack(value);
}

//*************************************
// Post processing shader selection
//*************************************

// select the shader to use
void onCCChange60(int value) {
  VisShaders.setShader(value);
}
// toggle the post processing shaders
void onCCChange61(int value) {
  VisShaders.toggleVisShaders();
}
// change the first parameter of the post processing shader
void onCCChange54(int value) {
  VisShaders.setX(value);
}
// change the second parameter of the post processing shader
void onCCChange55(int value) {
  VisShaders.setY(value);
}

//************************************************************************
// And all the unassigned CC values, waiting for you to give them meaning
//************************************************************************

void onCCChange0(int value) {
}
void onCCChange5(int value) {
}
void onCCChange6(int value) {
}
void onCCChange7(int value) {
}
void onCCChange8(int value) {
}
void onCCChange9(int value) {
}
void onCCChange10(int value) {
}
void onCCChange11(int value) {
}
void onCCChange12(int value) {
}
void onCCChange13(int value) {
}
void onCCChange14(int value) {
}
void onCCChange15(int value) {
}
void onCCChange16(int value) {
}
void onCCChange17(int value) {
}
void onCCChange18(int value) {
}
void onCCChange19(int value) {
}
void onCCChange20(int value) {
}
void onCCChange22(int value) {
}
void onCCChange23(int value) {
}
void onCCChange24(int value) {
}
void onCCChange25(int value) {
}
void onCCChange31(int value) {
}
void onCCChange32(int value) {
}
void onCCChange33(int value) {
}
void onCCChange34(int value) {
}
void onCCChange35(int value) {
}
void onCCChange36(int value) {
}
void onCCChange37(int value) {
}
void onCCChange38(int value) {
}
void onCCChange39(int value) {
}
void onCCChange40(int value) {
}
void onCCChange42(int value) {
}
void onCCChange43(int value) {
}
void onCCChange44(int value) {
}
void onCCChange51(int value) {
}
void onCCChange62(int value) {
}
void onCCChange63(int value) {
}
void onCCChange66(int value) {
}
void onCCChange67(int value) {
}
void onCCChange68(int value) {
}
void onCCChange69(int value) {
}
void onCCChange70(int value) {
}
void onCCChange71(int value) {
}
void onCCChange72(int value) {
}
void onCCChange73(int value) {
}
void onCCChange74(int value) {
}
void onCCChange75(int value) {
}
void onCCChange76(int value) {
}
void onCCChange77(int value) {
}
void onCCChange78(int value) {
}
void onCCChange79(int value) {
}
void onCCChange80(int value) {
}
void onCCChange81(int value) {
}
void onCCChange82(int value) {
}
void onCCChange83(int value) {
}
void onCCChange84(int value) {
}
void onCCChange85(int value) {
}
void onCCChange86(int value) {
}
void onCCChange87(int value) {
}
void onCCChange88(int value) {
}
void onCCChange89(int value) {
}
void onCCChange90(int value) {
}
void onCCChange91(int value) {
}
void onCCChange92(int value) {
}
void onCCChange93(int value) {
}
void onCCChange94(int value) {
}
void onCCChange95(int value) {
}
void onCCChange96(int value) {
}
void onCCChange97(int value) {
}
void onCCChange98(int value) {
}
void onCCChange99(int value) {
}
void onCCChange104(int value) {
}
void onCCChange109(int value) {
}
void onCCChange114(int value) {
}
void onCCChange115(int value) {
}
void onCCChange116(int value) {
}
void onCCChange117(int value) {
}
void onCCChange118(int value) {
}
void onCCChange119(int value) {
}
void onCCChange120(int value) {
}
void onCCChange121(int value) {
}
void onCCChange122(int value) {
}
void onCCChange123(int value) {
}
void onCCChange124(int value) {
}
void onCCChange125(int value) {
}
void onCCChange126(int value) {
}
void onCCChange127(int value) {
}
void onCCChange128(int value) {
}
void onCCChange129(int value) {
}
void onCCChange130(int value) {
}
void onCCChange131(int value) {
}
void onCCChange132(int value) {
}
void onCCChange133(int value) {
}
void onCCChange134(int value) {
}
void onCCChange135(int value) {
}
void onCCChange136(int value) {
}
void onCCChange137(int value) {
}
void onCCChange138(int value) {
}
void onCCChange139(int value) {
}
void onCCChange140(int value) {
}
void onCCChange141(int value) {
}
void onCCChange142(int value) {
}
void onCCChange143(int value) {
}
void onCCChange144(int value) {
}
void onCCChange145(int value) {
}
void onCCChange146(int value) {
}
void onCCChange147(int value) {
}
void onCCChange148(int value) {
}
void onCCChange149(int value) {
}
void onCCChange150(int value) {
}
void onCCChange151(int value) {
}
void onCCChange152(int value) {
}
void onCCChange153(int value) {
}
void onCCChange154(int value) {
}
void onCCChange155(int value) {
}
void onCCChange156(int value) {
}
void onCCChange157(int value) {
}
void onCCChange158(int value) {
}
void onCCChange159(int value) {
}
void onCCChange160(int value) {
}
void onCCChange161(int value) {
}
void onCCChange162(int value) {
}
void onCCChange163(int value) {
}
void onCCChange164(int value) {
}
void onCCChange165(int value) {
}
void onCCChange166(int value) {
}
void onCCChange167(int value) {
}
void onCCChange168(int value) {
}
void onCCChange169(int value) {
}
void onCCChange170(int value) {
}
void onCCChange171(int value) {
}
void onCCChange172(int value) {
}
void onCCChange173(int value) {
}
void onCCChange174(int value) {
}
void onCCChange175(int value) {
}
void onCCChange176(int value) {
}
void onCCChange177(int value) {
}
void onCCChange178(int value) {
}
void onCCChange179(int value) {
}
void onCCChange180(int value) {
}
void onCCChange181(int value) {
}
void onCCChange182(int value) {
}
void onCCChange183(int value) {
}
void onCCChange184(int value) {
}
void onCCChange185(int value) {
}
void onCCChange186(int value) {
}
void onCCChange187(int value) {
}
void onCCChange188(int value) {
}
void onCCChange189(int value) {
}
void onCCChange190(int value) {
}
void onCCChange191(int value) {
}
void onCCChange192(int value) {
}
void onCCChange193(int value) {
}
void onCCChange194(int value) {
}
void onCCChange195(int value) {
}
void onCCChange196(int value) {
}
void onCCChange197(int value) {
}
void onCCChange198(int value) {
}
void onCCChange199(int value) {
}
void onCCChange200(int value) {
}
void onCCChange201(int value) {
}
void onCCChange202(int value) {
}
void onCCChange203(int value) {
}
void onCCChange204(int value) {
}
void onCCChange205(int value) {
}
void onCCChange206(int value) {
}
void onCCChange207(int value) {
}
void onCCChange208(int value) {
}
void onCCChange209(int value) {
}
void onCCChange210(int value) {
}
void onCCChange211(int value) {
}
void onCCChange212(int value) {
}
void onCCChange213(int value) {
}
void onCCChange214(int value) {
}
void onCCChange215(int value) {
}
void onCCChange216(int value) {
}
void onCCChange217(int value) {
}
void onCCChange218(int value) {
}
void onCCChange219(int value) {
}
void onCCChange220(int value) {
}
void onCCChange221(int value) {
}
void onCCChange222(int value) {
}
void onCCChange223(int value) {
}
void onCCChange224(int value) {
}
void onCCChange225(int value) {
}
void onCCChange226(int value) {
}
void onCCChange227(int value) {
}
void onCCChange228(int value) {
}
void onCCChange229(int value) {
}
void onCCChange230(int value) {
}
void onCCChange231(int value) {
}
void onCCChange232(int value) {
}
void onCCChange233(int value) {
}
void onCCChange234(int value) {
}
void onCCChange235(int value) {
}
void onCCChange236(int value) {
}
void onCCChange237(int value) {
}
void onCCChange238(int value) {
}
void onCCChange239(int value) {
}
void onCCChange240(int value) {
}
void onCCChange241(int value) {
}
void onCCChange242(int value) {
}
void onCCChange243(int value) {
}
void onCCChange244(int value) {
}
void onCCChange245(int value) {
}
void onCCChange246(int value) {
}
void onCCChange247(int value) {
}
void onCCChange248(int value) {
}
void onCCChange249(int value) {
}
void onCCChange250(int value) {
}
void onCCChange251(int value) {
}
void onCCChange252(int value) {
}
void onCCChange253(int value) {
}
void onCCChange254(int value) {
}
void onCCChange255(int value) {
}
