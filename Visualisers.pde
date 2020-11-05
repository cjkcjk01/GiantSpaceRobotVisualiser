// A collection of the main visualisers,
// At any time there is one "current visualiser"
//

class Visualisers {
  ArrayList<Visualiser> visualisers;
  Visualiser currentVisualiser;
  int visIndex;
  int visCount;

  Visualisers() {
    visualisers = new ArrayList<Visualiser>();
    visCount = 0;
  }

  void addVisualiser(Visualiser v) {
    visualisers.add(v);
    visCount = visualisers.size();
    visIndex = 0;
    currentVisualiser = visualisers.get(visIndex);
  }

  void setVisualiser(int v) {
    if (v == 1) {
      visIndex -= 1;
      if (visIndex < 0) {
        visIndex = visCount-1;
      }
    } else if (v == 2) {
      visIndex += 1;
      if (visIndex >= visCount) {
        visIndex = 0;
      }
    }

    currentVisualiser = visualisers.get(visIndex);
  }

  void toggleButton1() {
    currentVisualiser.toggleButton1();
  }
  void toggleButton2() {
    currentVisualiser.toggleButton2();
  }
  void setFader1(int v) {
    currentVisualiser.setFader1(v);
  }
  void setFader2(int v) {
    currentVisualiser.setFader2(v);
  }
  void setKnob1(int v) {
    currentVisualiser.setKnob1(v);
  }
  void setScaling(int v) {
    currentVisualiser.setScaling(v);
  }
  String getName() {
    return currentVisualiser.name;
  }
}

// Generic visualiser class, specific visualisers are lower down
// A visualiser has the following controls mapped onto the Maschine Jam and Traktor transport
// each specific visualiser decides which of these to make use of and how to respond to them
// 1) Browse knob, scrolls through range of 0-127 
// 2) Button 1, toggle
// 3) Button 2, toggle 
// 4) Fader 1, slider with range 0-127
// 5) Fader 2, slider with range 0-127

// Each visualiser chooses how to interpret the music, normally using an FFT for
// frequency analysis. Oblivion and Sprocket basically sweep through the whole 
// spectrum. We may want to limit a specific visualiser (such as the Candywarp one)
// to few, or more specific frequency bands.
// To help with this, below is the code needed to pick out the frequency range used by Traktor's
// Z-ISO EQ.
//
//    float[] traktorEQ;
//
//    traktorEQ[0] = fft.calcAvg(20.0, 90.0);      // Bass response
//    traktorEQ[1] = fft.calcAvg(90.0, 1470.0);    // Mid response
//    traktorEQ[2] = fft.calcAvg(1470.0, 18000.0); // High response


abstract class Visualiser {
  String    name;
  PGraphics pg;
  int       halfWidth;
  int       halfHeight;
  boolean   button1;
  boolean   button2;
  int       fader1;
  int       fader2;
  int       knob1;
  float     scaling = 1;

  // init FFT analysis
  FFT     fft;
  float   smoothing = 0.60;
  float[] fftSmooth;
  int     avgSize;

  Visualiser (String n) {
    name = n;
    pg = createGraphics(width, height, P3D);

    halfWidth  = width/2;
    halfHeight = height/2;

    // Each visualiser can has four parameters that can be set from the controller
    // two buttons and two sliders. It is up to the specific visualiser to decide what to do with these
    button1 = false;
    button2 = false;
    fader1  = 0;
    fader2  = 0;
    knob1   = 0;
  }

  void draw() {
    image(pg, 0, 0);
  }

  void toggleButton1() {
    button1 = !button1;
  }

  void toggleButton2() {
    button2 = !button2;
  }

  void setFader1(int v) {
    fader1 = v;
  }
  void setFader2(int v) {
    fader2 = v;
  }
  void setKnob1(int v) {
    knob1 = v;
  }
  void setScaling(float s) {
    scaling = map(s, 0, 127, 0, 20);
  }


  float dB(float x) {
    if (x == 0) {
      return 0;
    } else {
      return 10 * (float)Math.log10(x);
    }
  }
}

// ***************************************************************************
// Oblivion visualiser class
//
// Browse Knob1 - Change pallette 
// Button1      - Background clear toggle
// Button2      - Ellipse on/off
// Fader1       - Rotation
// Fader2       - Opacity
// ***************************************************************************
class VisOblivion extends Visualiser {

  color[]            activeGradient;
  int                gradientIndex;
  ArrayList<color[]> gradients;
  int                opacity = 100;

  int                count = 20;
  float              positionRadius = (pg.height * 0.3) * 1.35;

  float[]            previousValues;
  PVector[][]        prevPos;

  float              rotationAngle = 0.0;
  float              rotationSpeed = 0.0;

  int                previousKnobValue = 0; // for this visualiser the knob is used to choose the next or previous gradient
  //                                           so we simply check the direction the knob is turned
  //                                           and increment or decrement accordingly

  VisOblivion(String n) {
    super(n);

    scaling = 5;

    loadGradients();

    // Initialise the fft analysis
    fft = new FFT(input.bufferSize(), input.sampleRate());

    // set up the arrays to hold the previous values of the fft analysis spectrum
    previousValues = new float[fft.specSize()/10];
    prevPos        = new PVector[previousValues.length][20];
  }

  void draw() {
    calculateFFTValues();

    pg.beginDraw(); 
    if (!button1) {    
      pg.clear();
    }

    pg.noStroke();

    // Rotate display, rate set by Fader1
    pg.translate(width/2, height/2);
    rotationAngle += rotationSpeed; 
    pg.rotate(rotationAngle);
    pg.translate(-width/2, -height/2);

    for (int i = 0; i < previousValues.length; i++)
    { 

      float startAngle = (i*PI/100);
      float deltaAngle = PI*2 / count;
      float value = previousValues[i];
      float percent = (float)i/previousValues.length;

      color col = activeGradient[min((int)(activeGradient.length * percent), activeGradient.length)];
      pg.fill(col, opacity);

      float s = max(2, value*0.5f*positionRadius/360f);

      float distance = positionRadius-(percent*positionRadius*value/40);
      distance = max(-positionRadius, distance);

      for (int j = 0; j < count; j++) {
        float a = startAngle + deltaAngle * j;
        if (j%2 == 0) {
          a -= startAngle*2;
        }
        PVector prev = prevPos[i][j];
        PVector curr = new PVector(width/2 + cos(a) * distance, height/2 + sin(a) * distance);

        // Draw an ellipse, makes the visualisation more dramatic
        if (button2) {
          pg.ellipse(pg.width/2 + cos(a) * distance, pg.height/2 + sin(a) * distance, s, s);
        }

        if (prev != null) {

          float dx = prev.x - curr.x;
          float dy = prev.y - curr.y;
          float d = sqrt(dx*dx + dy*dy);

          pg.pushMatrix();
          pg.translate(curr.x, curr.y);
          pg.rotate(atan2(dy, dx));

          pg.rect(0, -s/2, d, s);

          pg.popMatrix();
        }
        prevPos[i][j] = curr;
      }
    }
    pg.endDraw();

    super.draw();
  }

  void calculateFFTValues()
  {
    fft.forward(input.mix);

    int size = 10;

    for (int n = 0; n < fft.specSize() - size; n += size) {
      float percent = n / (fft.specSize() - size);
      float avg = 0;
      for (int i = n; i < n+size; i++) {
        avg += fft.getBand(n);
      }
      avg = avg * lerp(4, 8, percent) * scaling / size;

      float previous = previousValues[n/size];
      previous *= 0.9;
      previous = max(avg, previous);

      previousValues[n/size] = previous;
    }
  }

  void loadGradients() {
    color[] gradient;

    // Load the colour gradients
    gradientIndex = 0;
    gradients = new ArrayList<color[]>();

    // Read in a list of image files used to define a set of gradients used in the visualisation
    File dir = new File(dataPath("")+"//gradients//");

    File[] files = dir.listFiles();
    boolean gradientReverse = false;
    for ( int i=0; i < files.length; i++ ) { 
      String path = files[i].getAbsolutePath();

      // check the file type and work with jpg/png files
      if ( path.toLowerCase().endsWith(".png") ) {
        PImage image = loadImage( path );

        gradient = new color[image.width];
        for (int j = 0; j < image.width; j++)
        {
          gradient[j] = image.get(gradientReverse ? (image.width - j - 1) : j, 0);
        }
        gradients.add(gradient);
      }
    }
    activeGradient = gradients.get(gradientIndex);
  }

  // If the browser knob is moved clockwise (value increases) then select next gradient,
  // if anti-clockwise the select previous
  void setKnob1(int v) {
    int inc = 0;
    int gradSize = gradients.size() - 1;

    if (v > previousKnobValue) {
      inc = 1;
    } else {
      inc= -1;
    }

    gradientIndex += inc;

    // Wrap the index back to the start (or end) of the array accordingly 
    if (gradientIndex >  gradSize) {
      gradientIndex=0;
    }
    if (gradientIndex < 0) {
      gradientIndex=gradSize;
    }
    activeGradient = gradients.get(gradientIndex);

    // and store the previoub knob value so that we can tell if it is going up or down
    previousKnobValue = v;
  }

  void setFader1(int v) {
    rotationSpeed = map(v, 0, 127, -0.1, 0.1);
    if ((rotationSpeed > -0.01) && (rotationSpeed < 0.01)) {
      rotationSpeed = 0.0;
    }
  }
  void setFader2(int v) {
    opacity = round(map(v, 0, 127, 0, 255));
  }

  void setScaling(float s) {
    scaling = map(s, 0, 127, 0, 20);
  }
}

// ************************************************************************************************
// Waveform visualiser class
//
// Draws a simple osciliscope type wavform 
// ************************************************************************************************
class VisWaveform extends Visualiser {
  int scale = 500;

  VisWaveform(String n) {
    super(n);
  }

  void draw() {

    pg.beginDraw(); 
    pg.clear();
    pg.strokeWeight(2);

    if (myBgPalette.getBlackOrWhite()) {
      pg.stroke(10);
    } else {
      pg.stroke(250);
    }

    pg.pushMatrix();
    pg.translate(0, halfHeight);

    float distance = (float)width/input.bufferSize();
    for (int i = 0; i < input.bufferSize()-1; i++)
    {
      float x1 = distance*i;
      float x2 = distance*(i+1);

      pg.line(x1, input.left.get(i)*scale, x2, input.left.get(i+1)*scale);
    }

    pg.popMatrix();
    pg.endDraw();
    super.draw();
  }

  void scale(int v) {
    scale = round(map(v, 0, 127, 100, 1000));
  }
}

// ************************************************************************************************
// visSprocket Visualiser class
// Browse Knob1 - 
// Button1      - Background retention on/off
// Button2      - Color mode (random or linear)
// Fader1       - Rotation speed
// Fader2       - Stroke colour
// ************************************************************************************************
class VisSprocket extends Visualiser {

  int     specSize;
  float[] angle, x, y;
  float   f, b, density;
  int outlineColour = 10;

  VisSprocket(String n) {
    super(n);
    fft = new FFT(input.bufferSize(), input.sampleRate());
    specSize = fft.specSize();
    
    y        = new float[specSize];
    x        = new float[specSize];
    angle    = new float[specSize];
    density  = 1;
    fader1 = 800;
  }

  void draw() {

    fft.forward(input.mix);

    pg.beginDraw(); 

    if (!button1) {
      pg.clear();
    }

    pg.push();
    if (button2) {
      pg.colorMode(RGB);
    } else {
      pg.colorMode(HSB);
    } 

    pg.translate(pg.width/2, pg.height/2);

    for (int i = 0; i < specSize; i++) {
      if (button2) {
        pg.fill(random(255), random(255), random(255), 255);
      } else {
        pg.fill(i, 150, 150, 150);
      }

      f = fft.getFreq(i);
      b = fft.getBand(i);

      pg.stroke(outlineColour);
      y[i] = y[i] + b/10;
      x[i] = x[i] + f/10;
      angle[i] = angle[i] + f/(fader1+1);

      pg.rotateX(sin(angle[i]/2)/density);
      pg.rotateY(cos(angle[i]/2)/density);

      pg.pushMatrix();
      pg.translate((x[i]+5)%pg.width/5, (y[i]+5)%pg.height/5);
      pg.box(f * scaling);
      pg.popMatrix();
    }
    pg.pop();

    pg.endDraw(); 
    super.draw();
  }

  void initAnalysis() {
  }

  void setFader1(int v) {
    fader1 = round(map(v, 0, 127, 80, 800));
  }
  void setFader2(int v) {
    outlineColour = round(map(v, 0, 127, 0, 255));
  }
  void setScaling(float s) {
    scaling = map(s, 0, 127, 0.5, 10);
  }
}

// ************************************************************************************************
// CandyWarp Visualiser class
// Button1 - no action
// Button2 - no action
// Fader1  - Changes the shader's cycle parameter
// Fader2  - Changes the shader's warp parameter
// Knob1   - Picks the frequency range to react to, all the way to the left for bass,
//           to the right for treble
// ************************************************************************************************
class VisCandyWarp extends Visualiser {

  PShader shade;
  float   cycle = 0.2;
  float   warp  = 2.5;
  float   scale = 84.0;

  int     fftIndex = 1;
  int     prevKnobValue = 0;

  VisCandyWarp(String n) {
    super(n);

    shade = loadShader("Candywarp.glsl");

    // settings that are fixed in this visualisation
    shade.set("iResolution", float(width), float(height));
    shade.set("thickness", 0.1); // Default :  0.1  Min :  0.5  Max :   1.0    
    shade.set("loops", 61.0);    // Default : 61.0  Min : 10.0  Max : 100.0
    shade.set("tint", 0.1);      // Default :  0.1  Min : -0.5  Max :   0.5
    shade.set("rate", 1.3);      // Default :  1.3  Min : -3.0  Max :   3.0
    shade.set("hue", 0.33);     // Default :  0.33 Min : -0.5  Max :   0.5

    // settings that vary in this visualisation
    shade.set("time", millis()/1000.0);
    shade.set("cycle", cycle); // Default :  0.4  Min :  0.01 Max :   0.99
    shade.set("warp", warp);  // Default :  2.5  Min : -5.0  Max :   5.0
    shade.set("scale", scale); // Default : 84.0  Min : 10.0  Max : 100.0

    // set up fft analysis
    initAnalysis();
  }

  void draw() {

    analyse();

    pg.beginDraw();

    shade.set("time", millis()/1000.0);
    shade.set("warp", warp);
    shade.set("cycle", cycle);

    scale = map(fftSmooth[fftIndex], 0, 18, 20.0, 100.0); //use a specific frequency band to modulate the shader's scale attribute
    shade.set("scale", scale);

    pg.filter(shade);

    pg.endDraw(); 
    super.draw();
  }
  void initAnalysis() {

    fft = new FFT(input.bufferSize(), input.sampleRate());
    fft.logAverages(11, 1);

    avgSize=fft.avgSize();
    fftSmooth = new float[avgSize];
  }

  void analyse() {
    final float noiseFloor = 0; //-10; // Minimum sound level that we respond to

    fft.forward(input.mix);

    for (int i = 0; i < avgSize; i++) {
      // Get spectrum value (using dB conversion or not, as desired)
      float fftCurr;
      fftCurr = dB(fft.getAvg(i));
      if (fftCurr < noiseFloor) {
        fftCurr = noiseFloor;
      }

      // Smooth using exponential moving average
      fftSmooth[i] = (smoothing) * fftSmooth[i] + ((1 - smoothing) * fftCurr);
    }
  }

  void setFader1(int v) {
    cycle = map(v, 0, 127, 0.01, 0.4);
  }
  void setFader2(int v) {
    warp = map(v, 0, 127, -5.0, 5.0);
  }

  void setKnob1(int v) {
    int inc = 0;

    if (v > prevKnobValue) {
      inc = 1;
    } else {
      inc= -1;
    }

    fftIndex += inc;

    // Constrain the index to the range of the array 
    if (fftIndex >  avgSize-1) {
      fftIndex=avgSize-1;
    }
    if (fftIndex < 0) {
      fftIndex=0;
    }
    // and store the previoub knob value so that we can tell if it is going up or down
    prevKnobValue = v;
  }
}
