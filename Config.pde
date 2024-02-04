// We support two midi controllers, one is traktor itself, it needs to be routed //<>//
// through a virtual midi port. I have used BOME Midi Translator for this
// (its port is called "BMT 1".
// The Traktor Midi output is defined via a tsi file called "Visuliser Controller"
//
// The second is a device that controls the various settings, I am currently using
// a Midi Fighter Twister. Previously I have used a Maschine Jam.
// We only suport Midi CCs.

// there are three JSON config files used
// config.json       - This stores the screen setup, midi devices and various other settings
// midiConfigTraktor - Stores the midi commands that are sent by traktor
// midiConfig        - Stores the rest of the midi commands that control the visualisers etc.

void loadConfig() {
  mainJSON = loadJSONObject("config.json");
  loadMidiDevice();
  loadMidiChannel();
  loadWordPacks();
  loadBackgroundPalettes();
}

// ****************************************************************************
// Set up Midi interfaces
// We need a connection from the Maschine Jam and the Traktor controller,
// use the config file to specify the correct names for the machine you are on
// ****************************************************************************
MidiBus[] buses;
//MidiBus busA; //The first MidiBus
//MidiBus busB; //The second MidiBus

void loadMidiDevice() {
  // display the available midi devices (uncomment for debugging)
  //  MidiBus.list();

  String deviceName;

  // load MIDI device info from config.json
  JSONArray d = mainJSON.getJSONArray("MIDIdevice");
  if (d.size() == 0) {
    println("No Midi device name found in config.json file");
    println("Failed to assign any input devices.\nUse in non-Midi mode.");
  }
  buses = new MidiBus[d.size()];

  for (int i=0; i<d.size(); i++) {
    JSONObject m = d.getJSONObject(i);
    deviceName = m.getString("device");

    String[] available_inputs = MidiBus.availableInputs();
    for (int j = 0; j < available_inputs.length; j++) {
      if (available_inputs[j].indexOf(deviceName) > -1 ) {
        buses[i] = new MidiBus(this, deviceName, deviceName, deviceName);

        println("Added Midi device - " + buses[i].getBusName());
      }
    }
  }
}

void loadMidiChannel() {
  //String midiChannel;

  // load MIDI channel info from config.json
  JSONArray d = mainJSON.getJSONArray("MIDIchannel");
  if (d.size() == 0) {
    println("No Midi channel definition found in config.json file");
    println("in this case we will assume 11, but that may not be correct for you!");
  }
  JSONObject m = d.getJSONObject(0);
  midiChannel = m.getInt("channel")-1;
}

// *******************************************
// Set up word packs
// *******************************************

void loadWordPacks() {
  beatWords = new WordPacks();

  JSONArray wordData = mainJSON.getJSONArray("wordpacks");

  for (int i = 0; i < wordData.size(); i++) {
    JSONObject d2 = wordData.getJSONObject(i);
    JSONArray d3 = d2.getJSONArray("words");

    // Convert JSON array to String array
    String[] s = toStringArray(d3);

    // Set up a word pack
    beatWords.addWords(s);
  }
}

// *******************************************
// Set up backgound palettes
// *******************************************
void loadBackgroundPalettes() {
  ArrayList<color[]> palettes = new ArrayList<color[]>();

  JSONArray bgData = mainJSON.getJSONArray("palettes");

  for (int i = 0; i < bgData.size(); i++) {
    JSONObject d2 = bgData.getJSONObject(i);
    JSONArray  d3 = d2.getJSONArray("colours");

    // step through the array, get the hex colour value (in web colour format).
    // To use it as a Processing colour we need to convert it to a hex integer
    // so we strip of the leading "#" character and add "FF" to the start. The "FF" is the
    // alpha value.
    color[] palette;
    palette = new color[d3.size()];

    for (int j = 0; j < d3.size(); j++) {
      String s = d3.getString(j);
      // strip off the # character
      s = s.substring(1, s.length());

      // make the colour, we need to prefix it with the alpha value
      color c = unhex("FF" + s);
      palette[j] = c;
    }
    palettes.add(palette);
  }

  // use the list of color palettes to make the background colour handling object
  myBgPalette = new BgPalette(palettes);
}

public static String[] toStringArray(JSONArray array) {
  String[] arr = new String[array.size()];
  for (int i=0; i<arr.length; i++) {
    arr[i]=array.getString(i);
  }
  return arr;
}

void midiConfig() {
  midiJSON = loadJSONObject("midiConfig.json");

  JSONArray midiControlData = midiJSON.getJSONArray("MIDIControls");
  int channel, control, functionKey;
  String functionName;

  for (int i = 0; i < midiControlData.size(); i++) {
    JSONObject d2 = midiControlData.getJSONObject(i);

    channel = d2.getInt("channel");
    control = d2.getInt("control");
    functionName = d2.getString("functionName");
    functionKey = (channel * 100) + control;
    midiFunctions.put(functionKey, functionName);
  }
}

void midiTraktorConfig() {
  midiTraktorJSON = loadJSONObject("midiTraktorConfig.json");

  JSONArray midiControlData = midiTraktorJSON.getJSONArray("MIDIControls");
  int channel, control, functionKey;
  String functionName;

  for (int i = 0; i < midiControlData.size(); i++) {
    JSONObject d2 = midiControlData.getJSONObject(i);

    channel = d2.getInt("channel");
    control = d2.getInt("control");
    functionKey = (channel * 100) + control;
    functionName = d2.getString("functionName");
    midiFunctions.put(functionKey, functionName);
  }
}
