// A collection of the main visualisers, //<>// //<>//
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
    visIndex = 0;
  }

  void addVisualiser(Visualiser v) {
    visualisers.add(v);
    visCount = visualisers.size();
    visIndex = 0;
    currentVisualiser = visualisers.get(visIndex);
  }

  void setVisualiser(int v) {
    currentVisualiser = visualisers.get(visIndex);
    cueInfo.clearText();
  }

  // Cue the next visualiser
  void cueVisualiserByMidi(int v) {
    visIndex = (int)map(v, 0, 127, 0, visCount-1);
    if (visIndex > visCount - 1) {
      visIndex = visCount - 1;
    }
    if (visIndex < 0) {
      visIndex = 0;
    }
    cueInfo.setText(str(visIndex));
    
  }

  // Cue the next visualiser
  void cueVisualiserByKeyboard(int v) {
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
    cueInfo.setText(str(visIndex));
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
  void onBeatAction()
  {
    currentVisualiser.onBeatAction();
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
//
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

  // Set up an FFT analysis
  void initAnalysis() {
    fft = new FFT(input.bufferSize(), input.sampleRate());
    fft.logAverages(11, 1);

    avgSize=fft.avgSize();
    fftSmooth = new float[avgSize];
  }
  void onBeatAction()
  {
  }

  // Run an FFT analysis
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
// Draws a simple osciliscope type waveform
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
// Button1      - sets the 3D primitive used, box or sphere
// Button2      - Color mode (random or linear)
// Fader1       - Rotation speed
// Fader2       - Density of the arcs
// ************************************************************************************************
class VisSprocket extends Visualiser {

  int     specSize;
  float[] angle, x, y;
  float   volume;
  float   size = 1.0;
  float   size2 = 0;
  float   maxSize;

  int     speed = 800;
  float   density = 1;

  VisSprocket(String n) {
    super(n);

    // run an FFt and store the size of the array of volumes for each frequency band
    fft = new FFT(input.bufferSize(), input.sampleRate());
    specSize = fft.specSize();

    // set up arrays to hold position and angle for each band
    y       = new float[specSize];
    x       = new float[specSize];
    angle   = new float[specSize];
  }

  void draw() {

    fft.forward(input.mix);

    pg.beginDraw();

    pg.lights();
    pg.directionalLight(225, 225, 225, 0, 0, -1);
    pg.sphereDetail(8);
    pg.noStroke();

    pg.push();
    pg.clear();

    if (button2) {
      pg.colorMode(RGB);
    } else {
      pg.colorMode(HSB);
    }

    pg.translate(pg.width/2, pg.height/2);

    for (int i = 0; i < specSize; i++) {

      // set the colours
      if (button2) {
        pg.fill(random(255), random(255), random(255), 255);
      } else {
        pg.fill(i, 150, 150, 255);
      }

      volume = fft.getFreq(i); //volume is the magnitude returned from the fft array for each frequency band

      y[i] = y[i] + volume/10;
      x[i] = x[i] + volume/10;

      angle[i] = angle[i] + volume/(speed+1);

      pg.rotateX(sin(angle[i]/2)/density);
      pg.rotateY(cos(angle[i]/2)/density);

      pg.pushMatrix();
      pg.translate((x[i]+5)%pg.width/4, (y[i]+5)%pg.height/4);

      // map the frequency value into a restricted range, so that the boxes are never too small to see,
      // or so big that they dominate

      size = volume * scaling;
      map(volume, 0, 60, 20, 50);

      // Maintain a running maximum
      if (size > maxSize) {
        maxSize = size;
      }

      size2 = map(size, 0, maxSize, 5, 50);

      if (!button1) {
        pg.box(size2);
      } else {
        pg.sphere(size2);
      }

      pg.popMatrix();
    }
    pg.pop();

    pg.endDraw();
    super.draw();
  }

  void initAnalysis() {
  }

  void setFader1(int v) {
    speed = round(map(v, 0, 127, 80, 800));
  }

  void setFader2(int v) {
    density = round(map(v, 0, 127, 1, 50));
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

    shade = loadShader("Shaders/visCandywarp.glsl");

    // settings that are fixed in this visualisation
    shade.set("iResolution", float(width), float(height));
    shade.set("thickness", 0.1); // Default :  0.1  Min :  0.5  Max :   1.0
    shade.set("loops", 61.0);    // Default : 61.0  Min : 10.0  Max : 100.0
    shade.set("tint", 0.1);      // Default :  0.1  Min : -0.5  Max :   0.5
    shade.set("rate", 1.3);      // Default :  1.3  Min : -3.0  Max :   3.0
    shade.set("hue", 0.33);      // Default :  0.33 Min : -0.5  Max :   0.5

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

// ************************************************************************************************
// JazzUniverse Visualiser class
// Button1 - no action
// Button2 - no action
// Fader1  - Changes one of the shaders colors
// Fader2  - Changes the shader's warp parameter
// Knob1   - Picks the frequency range to react to, all the way to the left for bass,
//           to the right for treble
// ************************************************************************************************
class VisJazzUniverse extends Visualiser {

  PShader shade;

  float thickness = 0;      // Default :  0.0  Min :  0.0  Max :   0.5
  float twee=1.0;           // Default :  0.0  Min :  0.0  Max :   2.0
  float drie=1.0;           // Default :  1.0  Min :  0.0  Max :  10.0
  float vier=0.0;           // Default :  0.0  Min :  0.0  Max :   1.0
  float vijf=1.0;           // Default :  1.0  Min :  0.5  Max :   1.0
  float rotationSpeed=0.0;  // Deafult :  0.0  Min:   0.0  Max :   1.0
  PVector color3;

  color c;
  float h = 0; //Hue value of color c, set by fader1

  int     fftIndex = 1;
  int     prevKnobValue = 0;

  VisJazzUniverse(String n) {
    super(n);

    shade = loadShader("Shaders/visJazzUniverse.glsl");

    // settings that are fixed in this visualisation
    shade.set("iResolution", float(width), float(height));
    shade.set("thickness", thickness);
    shade.set("vijf", vijf);

    // settings that vary in this visualisation
    shade.set("time", millis()/1000.0);
    shade.set("twee", twee);
    shade.set("drie", drie);
    shade.set("vier", vier);

    //initialise the variable color
    pushStyle();
    colorMode(HSB, 1, 1, 1);
    c = color(1, 1, 1);
    popStyle();

    color3 = new PVector(0.0, 1.0, 0.1);
    shade.set("color3", color3);

    // set up fft analysis
    initAnalysis();
  }

  void draw() {
    analyse();

    pg.beginDraw();
    pg.push();
    pg.colorMode(HSB, 1, 1, 1);
    shade.set("time", millis()/1000.0);

    shade.set("twee", twee);
    shade.set("drie", drie);

    vier = map(fftSmooth[fftIndex], 0, 18, 0.0, 1.0); //use a specific frequency band to modulate the shader's scale attribute
    shade.set("vier", vier);

    color3.set(norm(red(c), 0, 255), norm(green(c), 0, 255), norm(blue(c), 0, 255));
    shade.set("color3", color3);

    pg.filter(shade);

    pg.pop();
    pg.endDraw();
    super.draw();
  }

  void setFader1(int v) {
    h = map(v, 0, 127, 0, 1);
    pushStyle();
    colorMode(HSB, 1, 1, 1);
    c = color(h, 1, 1);
    popStyle();
  }

  void setFader2(int v) {
    drie = map(v, 0, 127, -5.0, 5.0);
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

// ************************************************************************************************
// CircleTunnel Visualiser class
// Button1 - no action
// Button2 - no action
// Fader1  - Changes the shader's cycle parameter
// Fader2  - Changes the shader's warp parameter
// Knob1   - Picks the frequency range to react to, all the way to the left for bass,
//           to the right for treble
// ************************************************************************************************
class VisCircleTunnel extends Visualiser {

  PShader shade;

  float circleSize = 200.0; // Default :  0.0  Min :  0.0  Max : 200.5
  float speed = 0.2;        // Default :  0.0  Min :  0.0  Max :   2.0
  float moveX = 0;          // Default :  1.0  Min :  0.0  Max :  10.0
  float moveY = 0;          // Default :  0.0  Min :  0.0  Max :   1.0
  float hue1 = 0.01; // Red hue value in HSB color space
  float hue2 = 0.45; // Green(ish) hue value in HSB color space
  color pointColorA = color(hue1, 0.2, 0.2, 1.0); // Default : 0.6,0.2,0.2,1.0
  color pointColorB = color(hue2, 0.4, 0.4, 1.0); // Default : 0.8,0.4,0.4,1.0

  // variables used to rotate the center of the visualisation
  float radius = .1;
  float angle;
  float rotationSpeed = 0;
  float rotationFriction = 0.1;

  int   fftIndex = 1;
  int   prevKnobValue = 0;

  VisCircleTunnel(String n) {
    super(n);

    shade = loadShader("Shaders/visCircleTunnel.glsl");

    // settings that are fixed in this visualisation
    shade.set("iResolution", float(width), float(height));
    shade.set("speed", speed);
    shade.set("circleSize", circleSize);

    // settings that vary in this visualisation
    shade.set("time", millis()/1000.0);
    shade.set("moveX", moveX);
    shade.set("moveY", moveY);
    shade.set("pointColorA", 0.6, 0.2, 0.2, 1.0);
    shade.set("pointColorB", 0.8, 0.4, 0.4, 1.0);

    // set up fft analysis
    initAnalysis();
  }

  void draw() {

    analyse();


    pg.beginDraw();
    pg.push();
    shade.set("time", millis()/1000.0);

    //rotate the center point of the visualisation
    // float x = cos(angle)*radius;
    // float y = sin(angle)*radius;
    // angle += PI/rotationSpeed; //increment the angle to move the point

    shade.set("moveX", moveX);
    shade.set("moveY", moveY);

    //    traktorEQ[0] = fft.calcAvg(20.0, 90.0);      // Bass response
    //    traktorEQ[1] = fft.calcAvg(90.0, 1470.0);    // Mid response
    //    traktorEQ[2] = fft.calcAvg(1470.0, 18000.0); // High responsehue1 = map(fftSmooth[fftIndex], 0, 18, 0.0, 10.0); //use a specific frequency band to modulate the shader's scale attribute

    hue1 = map(fft.calcAvg(20.0, 90.0), 0, 10, 0, 0.1);
    hue2 = map(fft.calcAvg(90.0, 18000.0), 0, 1, 0.3, 0.9);

    pg.colorMode(HSB, 1.0, 1.0, 1.0);
    color c1 = pg.color(hue1, 1.0, 1.0, 1.0);
    color c2 = pg.color(hue2, 1.0, 1.0, 1.0);

    shade.set("pointColorA", norm(red(c1), 0, 255), norm(green(c1), 0, 255), norm(blue(c1), 0, 255), 1.0);
    shade.set("pointColorB", norm(red(c2), 0, 255), norm(green(c2), 0, 255), norm(blue(c2), 0, 255), 1.0);

    pg.filter(shade);
    pg.pop();
    pg.endDraw();

    super.draw();
  }

  void setFader1(int v) {
    moveX = map(v, 0, 127, -1, 1);
  }
  void setFader2(int v) {
    moveY = map(v, 0, 127, -1, 1);
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

  void onBeatAction()
  {
  }
}

// ************************************************************************************************
// Beatloop visualiser class
//
// Button1 - no action
// Button2 - no action
// Fader1  - no action
// Fader2  - Changes friction applied to the orbiting dot
// Knob1   - Sets the number of stick people drawn, also know as "rave mode"
// ************************************************************************************************
class VisBeatLoop extends Visualiser {
  int scale = 500;
  // Circle parameters
  float radius = 200;
  float centerX = 0;
  float centerY = 0;

  // Point parameters
  float pointRadius = 10;
  color pointColor = color(255);  // White
  float pointSpeed = 0;  // Angular speed
  float pointImpetus = 0.2;  // Angular impetus
  float pointFriction = 0.66;

  // Point variables
  float angle = 0;
  float x = centerX + radius * cos(angle);
  float y = centerY + radius * sin(angle);

  int   prevKnobValue = 0;

  Stickman[] stickmen;
  int stickmenArraySize = 100;
  int stickmenIndex = 0;

  VisBeatLoop(String n) {
    super(n);

    // set up the array of stickmen,
    // the first one is always in the center and at a scale of 1.0, the rest are randomly placed around the screen
    stickmen = new Stickman[stickmenArraySize];
    stickmen[0] = new Stickman(pg, 0, 0, 1.0);
    for (int i=1; i<stickmenArraySize; i++) {
      stickmen[i] = new Stickman(pg, round(random(-width/2, width/2)), round(random(-height/2, height/2)), random(0.5, 1.5));
    }
  }

  void draw() {
    pg.smooth(4); // Warning, some values for this (eg. 8) cause an OpenGL error on Apple Silicon. A value of 4 seems fine!

    pg.beginDraw();
    pg.clear();
    pg.strokeWeight(2);
    pg.noFill();

    if (myBgPalette.getBlackOrWhite()) {
      pg.stroke(10);
      pointColor = color(10);
    } else {
      pg.stroke(250);
      pointColor = color(250);
    }

    pg.pushMatrix();
    pg.translate(halfWidth, halfHeight);

    pg.circle(centerX, centerY, radius * 2);

    // Calculate new position
    angle += pointSpeed;
    x = centerX + radius * cos(angle);
    y = centerY + radius * sin(angle);

    // Draw point
    pg.fill(pointColor);
    pg.circle(x, y, pointRadius * 2);

    // Apply friction to speed
    pointSpeed *= pointFriction;

    // draw the stickmen
    for (int i=0; i < stickmenIndex; i++) {
      stickmen[i].draw();
    }

    pg.popMatrix();
    pg.endDraw();
    super.draw();
  }

  void scale(int v) {
    scale = round(map(v, 0, 127, 100, 1000));
  }

  void setFader1(int v) {
    pointFriction = map(v, 0, 127, 0.5, .99);
  }

  // set the number of stick people drawn, also know as "rave mode"
  void setKnob1(int v) {

    if (v > prevKnobValue) {
      stickmenIndex += 1;
    } else {
      stickmenIndex -= 1;
    }
    if (stickmenIndex < 0) {
      stickmenIndex = 0;
    }
    if (stickmenIndex > stickmenArraySize) {
      stickmenIndex = stickmenArraySize;
    }

    // and store the previoub knob value so that we can tell if it is going up or down
    prevKnobValue = v;
  }

  void onBeatAction() {
    // Apply impetus to point when space key is pressed
    pointSpeed += pointImpetus;
    // get the stick people to make a dance move
    for (int i=0; i<stickmenArraySize; i++) {
      stickmen[i].danceMove();
    }
  }
}
