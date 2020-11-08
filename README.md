# GiantSpaceRobot Traktor Visualiser

## Description

A visualiser that is tightly linked to Traktor, responding to a combination of the audio and controls such as filters and effects. It extends my Maschine Jam mapping ([https://maps.djtechtools.com/mappings/6883](https://maps.djtechtools.com/mappings/6883)) to control the visualiser.

Warning! The install and setup for this is fiddly. You need to be familiar and comfortable with Traktor, Traktor mappings, Midi and programming in Processing (if you want to tweak things).

# Installation

There are four main parts to the install

1. Setting up Traktor and the Maschine Jam, setting up a virtual midi port and setting up processing
   1. Traktor TSI files and Machine Jam config file and instructions are at https://maps.djtechtools.com/mappings/6883

- Processing
  - Latest version at https://processing.org/download/, the version used was 3.5.4
  - You will need the following libraries installed
    - Minim
    - Midibus
    - spout
- Virtual Midi port, there are lots of options, I used Bome Midi Translator (https://www.bome.com/) and route Traktor through its virtual port. Loopmidi is another popular choice https://www.tobias-erichsen.de/software/loopmidi.html
- GSR visualiser, code is on Github, feel free to download and use, suggest additional features or pull a copy and make some updates. My code could do with lots of refinements!
  - https://github.com/cjkcjk01/GiantSpaceRobotVisualiser

The steps are:

1. Have Traktor 3.4.0 (or above) installed

2. Set up a virtual midi port (note its name)

3. Install the tsi files in Traktor

4. Install the processing framework

5. Download the visualiser code and put it in the Processing sketch directory

6. Find the config.json file in the sketch\data directory

   1. Make sure you change the midi ports to the correct ones for your system, there are normally two, the Maschine Jam one and what ever the name is for your virtual midi port.
   2. Set the screen size appropriately, I run it full screen on my second display. Bear in mind that the bigger the window the more processing power it will require, your framerate may suffer. Adjust to suit your system. Low resolutions still look great especially on a projector.

7. I recommend starting the various apps in this order; virtual midi port, Traktor, Processing.

   

## Functionality

 - Three built in visualisations, each with a set of tweakable parameters
	 - Oblivion
		 - Sensitivity
		 - Browse knob	Change palette
		 - Button 1  		Background retention toggle
		 - Button 2  		More drama
		 - Fader 1  		Rotation speed
		 - Fader2 		Opacity
	 - Sprocket
		 - Sensitivity
		 - Browse knob 	no effect
		 - Button 1		Background retention toggle
		 - Button 2		Colour mode (linear or random)
		 - Fader 1		Rotation speed
		 - Fader2Outline colour
	 - Candywarp
		 - Sensitivity  no effect
		 - Browse knob  Select frequency band that visualiser responds to, bass to the left, treble to the right
		 - Button 1  no effect
		 - Button 2  no effect
		 - Fader 1  Cycle
		 - Fader2  Warp
 - Visualiser overlays
	 - Waveform, an oscilloscope type display of the current audio with adjustable sensitivity
	 - Kaleidoscope, very trippy!
 - Hot cue image packs, trigger images corresponding to hot cues, you can assign any pack to any deck
 - Beat words, display a sentence, word by word, changing on the beat
 - Selectable opacity
 - Post processing shaders, apply visual effects to the whole display, choose from up to 15 difference effects. Each shader has parameters to tweak it
 - Effect specific shaders
	 - Filter – blurs the display as filter is increased or decreased
	 - Echo – Uses a [sobel](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwi5hI7g_M3sAhUhwuYKHeIIBwUQFjACegQIBBAC&url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FSobel_operator&usg=AOvVaw2TW22hgpeNPJEQ1dSzk4R0) effect while a delay is engaged
	 - Slice/mash/gate – uses a vhs-jitter effect
 - Beat background, changes the background colour on each beat. Cycles through a configurable palette.
 - SPOUT option, outputs the display texture for use in other apps. Useful for things like projection mapping.

  

# Software requirements

- **Traktor 3.4.x**

- **A Virtual midi port**
  - I use Bome Midi Translator (https://www.bome.com/) and route Traktor through its virtual port
  - Loopmidi is another popular https://www.tobias-erichsen.de/software/loopmidi.html
- **Processing 3.5.4**
  - https://processing.org/download/
- GiantSpaceRobot visualiser code
  - https://github.com/cjkcjk01/GiantSpaceRobotVisualiser



# Hardware requirements

I use a Traktor Kontrol S5 and a Native Instrument's Maschine Jam to control Traktor. You do not need a hardware controller at all, but you need to map the appropriate MIDI outputs in Traktor to use the visualiser to its full potential. Details of the midi values used are in a the MIDI section below.can use any midi controller for Traktor (if you have a mapping for it) 

# Configuration

There are a lot configuration options, detailed below

## Config file

Config.json is the config for the visualiser, it can be found in the visualiser’s data directory. It has the following settings

- screensize, this defines the output window
    - fullscreen, true or false
    - Display number, used to direct output to a second or third monitor or projector
    - Width, only used if fullscreen is set to false
    - Height, ditto
- MIDIdevice
	- This is a list of midi ports that the visualiser will respond to
-   wordpacks
	- A set of lists of words that will be displayed, in order, changing on the beat
- Palettes
	- A set of lists of colour values (in hex) that are cycled through when the option to change background on the beat is selected in the visualiser

## Hot cue packs

A hotcue pack is a set of eight images stored in a directory named “hotcue_pack#” where # is number of the pack. You can have eight pack in total. It comes with a set ready to go, you can replace them with ones of your choice. They need to be in png format and I recommend 640x640 as a resolution, as a balance between level of detail and performance.

## Midi controls

These are hard wired right now, making them configurable is on the roadmap. For info, the “midi commands.txt” file lists the values used, you can find it in the data directory.

## Oblivion palettes

The Oblivion visualiser uses a cool way to configure its colour gradients, it simply reads in a png file, steps through the x coordinates and adds the colour of each pixel to a list. The palette images are stored in the “gradients” directory. You can add more by opening an existing one in an image editor and saving an edited version with a new name. They need to be named in the format “gradient_xxx” , where xxx is any valid string.

## Coding

The GiantSpaceRobot Traktor visualiser is written using the [Processing](https://processing.org/) framework, the code is available under an open source license, feel free to modify. I will paste a link to a github repository when it is ready.

# Keyboard Controls

There are a few keyboard controls that are useful when you are debugging and dont want to reach for your midi controller.

| Key  | Description                                    |
| ---- | ---------------------------------------------- |
| i    | Info, useful info such as FPS                  |
| h    | Displays help                                  |
| ?    | Displays help                                  |
| w    | Toggles the waveform                           |
| d    | Next visualiser                                |
| a    | previous visualiser                            |
| p    | Toggle SPOUT option (see Stout section in doc) |



# Midi Controls

The visualiser uses the following MIDI CC values to control its functions. A config file for the Maschine Jam is included, if you are using some other controller then you will need to be able to configure it to send these values.



| MIDI CC Number | Value                                                        | Description                                                  |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 100            | 0-127                                                        | Deck A volume                                                |
| 101            | 0-127                                                        | Deck B volume                                                |
| 102            | 0-127                                                        | Deck C volume                                                |
| 103            | 0-127                                                        | Deck D volume                                                |
| 110            | 0-126 = off, 127 = on                                        | Deck A play status                                           |
| 111            | 0-126 = off, 127 = on                                        | Deck B play status                                           |
| 112            | 0-126 = off, 127 = on                                        | Deck C play status                                           |
| 113            | 0-126 = off, 127 = on                                        | Deck D play status                                           |
| 1              | 15 = Hot cue 1<br/>31 = Hot cue 2<br/>47 = Hot cue 3<br/>63 = Hot cue 4<br/>79 = Hot cue 5<br/>95 = Hot cue 6<br/>111 = Hot cue 7<br />127 = Hot cue 8 | Deck A hot cue pressed                                       |
| 2              | 15 = Hot cue 1<br/>31 = Hot cue 2<br/>47 = Hot cue 3<br/>63 = Hot cue 4<br/>79 = Hot cue 5<br/>95 = Hot cue 6<br/>111 = Hot cue 7<br />127 = Hot cue 8 | Deck B hot cue pressed                                       |
| 3              | 15 = Hot cue 1<br/>31 = Hot cue 2<br/>47 = Hot cue 3<br/>63 = Hot cue 4<br/>79 = Hot cue 5<br/>95 = Hot cue 6<br/>111 = Hot cue 7<br />127 = Hot cue 8 | Deck C hot cue pressed                                       |
| 4              | 15 = Hot cue 1<br/>31 = Hot cue 2<br/>47 = Hot cue 3<br/>63 = Hot cue 4<br/>79 = Hot cue 5<br/>95 = Hot cue 6<br/>111 = Hot cue 7<br />127 = Hot cue 8 | Deck D hot cue pressed                                       |
| 56             | 0-7                                                          | Deck A, set hot cue pack. The value indicates which pack to associate with the deck |
| 57             | 0-7                                                          | Deck B, set hot cue pack. The value indicates which pack to associate with the deck |
| 58             | 0-7                                                          | Deck C, set hot cue pack. The value indicates which pack to associate with the deck |
| 59             | 0-7                                                          | Deck D, set hot cue pack. The value indicates which pack to associate with the deck |
| 105            | 0-127                                                        | Deck A filter value                                          |
| 106            | 0-127                                                        | Deck B filter value                                          |
| 107            | 0-127                                                        | Deck C filter value                                          |
| 108            | 0-127                                                        | Deck D filter value                                          |
| 21             | 1,2                                                          | Select main visualiser. 1 chooses the previous one, 2 chooses the next one |
| 45             | 0-127                                                        | Visualiser browse knob, generally an encoder, function varies depending on which main visualiser is running |
| 46             | Toggles if value > 100                                       | Toggle black or white background mode                        |
| 48             | 0-127                                                        | Visualiser scaling                                           |
| 27             | Toggles if value > 100                                       | Visualiser button 1                                          |
| 28             | Toggles if value > 100                                       | Visualiser button 2                                          |
| 52             | 0-127                                                        | Visualiser fader 1                                           |
| 53             | 0-127                                                        | Visualiser fader 2                                           |
| 26             | Toggles if value > 100                                       | Toggle waveform display                                      |
| 49             | 0-127                                                        | Waveform scaling                                             |
| 29             | Toggles if value > 100                                       | Toggle kaleidoscope mode                                     |
| 50             | 0-127                                                        | Beat words opacity                                           |
| 41             | triggers next step if value > 120                            | Increment background colour and beat words                   |
| 30             | Toggles if value > 100                                       | Toggle background colour change on beat                      |
| 47             | 0 = off<br />1-16 = number of wordpack to use                | Select beat words pack                                       |
| 60             | 1-15                                                         | Select post processing shader                                |
| 61             | Toggles if value > 100                                       | Toggle post processing shader                                |
| 54             | 0-127                                                        | Post processing parameter 1                                  |
| 55             | 0-127                                                        | Post processing parameter 2                                  |
| 64             | On if value > 100,<br />off if value = 0                     | Display delay/echo effect shader                             |
| 65             | On if value > 100,<br />off if value = 0                     | Display gater/slice/mash effect shader                       |

# SPOUT

SPOUT is a way of directing the display output to another application, such as a projection mapping app. I have used it successfully with vpt8 (https://hcgilje.wordpress.com/vpt/)

Details at;

https://spout.zeal.co/

https://github.com/leadedge/SpoutProcessing

# Acknowledgements

## Oblivion

Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.
[https://blog.dragonlab.de/2016/04/into-oblivion-music-visualizer/](https://blog.dragonlab.de/2016/04/into-oblivion-music-visualizer/)
[https://github.com/TobiasWehrum/GenerativeArt/tree/master/s044_into_oblivion](https://github.com/TobiasWehrum/GenerativeArt/tree/master/s044_into_oblivion)

## Sprocket

[http://www.benfarahmand.com/2013/10/source-code-audio-visualizer-with.html](http://www.benfarahmand.com/2013/10/source-code-audio-visualizer-with.html)
[https://gist.github.com/benfarahmand/6902359](https://gist.github.com/benfarahmand/6902359)

## Candywarp

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

[https://editor.isf.video/shaders/5e7a802d7c113618206dec38](https://editor.isf.video/shaders/5e7a802d7c113618206dec38)

# Shaders

## Sobel
From shadertoy [https://www.shadertoy.com/view/ldsSWr](https://www.shadertoy.com/view/ldsSWr)  
// Basic edge detection via convolution  
// Ken Slade - [ken.slade@gmail.com](mailto:ken.slade@gmail.com)  
// at https://www.shadertoy.com/view/ldsSWr
// Based on original Sobel shader by:  
// Jeroen Baert - jeroen.baert@cs.kuleuven.be (www.forceflow.be)  
// at https://www.shadertoy.com/view/Xdf3Rf

## VHS_glitch
[https://www.shadertoy.com/view/ldjGzV](https://www.shadertoy.com/view/ldjGzV)
https://www.shadertoy.com/user/ryk
Please respect ryk’s request to “please do not use this for commercial purposes.”

Post processing shaders
[https://genekogan.com/works/processing-shader-examples/](https://genekogan.com/works/processing-shader-examples/)

