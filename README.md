# GiantSpaceRobot Traktor Visualiser

## Description

A visualiser that is tightly linked to Traktor, responding to a combination of the audio and controls such as filters and effects. It extends my Maschine Jam mapping ([https://maps.djtechtools.com/mappings/6883](https://maps.djtechtools.com/mappings/6883)) to control the visualiser.

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

  

# Software

Traktor 3.4.x

Virtual midi port, I use Bome Midi Translator and route traktor through its virtual port. You should be able to use any 

# Configuration

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

