// This shader is used to represent the filter control in Traktor.
// If any deck is using the filter, has a volume over a certain threshold and is playing
// then the blur is engaged. Its intesity is linked to the level of the fliter knob.
class BlurShader {
  float   intensity;
  boolean on;
  PShader shade;

  BlurShader() {
    intensity = 0;
    on = true;

    shade = loadShader("blurFrag.glsl", "blurVert.glsl");
    shade.set("blurDegree", 0.0);
  }

  void draw() {
    if (mixerState.filterIntensity > 0) {
      shade.set("blurDegree", mixerState.filterIntensity);
      filter(shade);
    }
  }

  void intensity(float v) {
    intensity = v;
  }
}

// A class to store a set of shaders used as "post processing" effects
// they may have different parameters, these can be set using two faders on the Maschine Jam
class PostProcessingShaders {
  ArrayList<VisShader> VisShaders;
  VisShader currentVisShader;
  boolean VisShadersOn;
  int x;
  int y;

  PostProcessingShaders() {
    VisShaders = new ArrayList<VisShader>();
    VisShaders.add(shaderBrcosa     = new ShaderBrcosa());
    VisShaders.add(shaderHue        = new ShaderHue());
    VisShaders.add(shaderPixelate   = new ShaderPixelate());
    VisShaders.add(shaderChannels   = new ShaderChannels());
    VisShaders.add(shaderThreshold  = new ShaderThreshold());
    VisShaders.add(shaderNeon       = new ShaderNeon());
    VisShaders.add(shaderDeform     = new ShaderDeform());
    VisShaders.add(shaderPixelrolls = new ShaderPixelRolls());
    VisShaders.add(shaderModcolor   = new ShaderModcolor());
    VisShaders.add(shaderHalftone   = new ShaderHalftone());
    VisShaders.add(shaderInvert     = new ShaderInvert());

    currentVisShader = VisShaders.get(0);
    x = width/2;
    y = height/2;
    VisShadersOn = false;
  }

  void draw() {
    if (VisShadersOn) {
      currentVisShader.draw();
    }
  }

  void setShader(int value) {
    if (value >= VisShaders.size()) {
      value = 0;
    }
    currentVisShader = VisShaders.get(value);
  }

  String getCurrentShaderInfo() {
    return currentVisShader.name + " X = " + x + " Y = " + y;
  }

  void setX(int value) {
    x = round(map(value, 0, 127, 0, width));
    currentVisShader.setX(x);
  }

  void setY(int value) {
    y = round(map(value, 0, 127, 0, height));
    currentVisShader.setY(y);
  }

  void toggleVisShaders() {
    VisShadersOn = !VisShadersOn;
  }
}

abstract class VisShader {
  String name;
  String filename;
  boolean on;
  PShader shade;
  int x;
  int y;

  VisShader(String n, String f) {
    name = n;
    filename = f;
    shade = loadShader(filename);
    x = width/2;
    y = height/2;
}

  void draw() {
    filter(shade);
  }

  void setX(int i) {
    x = i;
  }

  void setY(int i) {
    y = i;
  }
}

class ShaderBrcosa extends VisShader {
  ShaderBrcosa() {
    super("brcosa", "brcosa.glsl");
    x = width/3;
    y = 10;//height/3;
    shade.set("brightness", 1.0);
  }

  void draw() {
    shade.set("contrast", map(x, 0, width, -5, 5));
    shade.set("saturation", map(y, 0, height, -5, 5));
    super.draw();
  }
}

class ShaderHue extends VisShader {
  ShaderHue() {
    super("hue", "hue.glsl");
  }

  void draw() {
    shade.set("hue", map(x, 0, width, 0, TWO_PI));
    super.draw();
  }
}

class ShaderPixelate extends VisShader {
  ShaderPixelate() {
    super("pixelate", "pixelate.glsl");
  }

  void draw() {
    shade.set("pixels", 0.1 * x, 0.1 * x);
    super.draw();
  }
}

class ShaderChannels extends VisShader {
  ShaderChannels() {
    super("channels", "channels.glsl");
  }

  void draw() {
    shade.set("rbias", 0.0, 0.0);
    shade.set("gbias", map(y, 0, height, -0.2, 0.2), 0.0);
    shade.set("bbias", 0.0, 0.0);
    shade.set("rmult", map(x, 0, width, 0.8, 1.5), 1.0);
    shade.set("gmult", 1.0, 1.0);
    shade.set("bmult", 1.0, 1.0);
    super.draw();
  }
}

class ShaderThreshold extends VisShader {
  ShaderThreshold() {
    super("threshold", "threshold.glsl");
  }

  void draw() {
    shade.set("threshold", map(x, 0, width, 0, 1));
    super.draw();
  }
}

class ShaderNeon extends VisShader {
  ShaderNeon() {
    super("neon", "neon.glsl");
  }

  void draw() {
    shade.set("brt", map(x, 0, width, 0, 0.5));
    shade.set("rad", (int) map(y, 0, height, 0, 3));
    super.draw();
  }
}

class ShaderDeform extends VisShader {
  ShaderDeform() {
    super("deform", "deform.glsl");
  }

  void draw() {
    shade.set("time", (float) millis()/1000.0);
    shade.set("mouse", (float) x/width, (float) y/height);
    shade.set("turns", map(sin(0.01*frameCount), -1, 1, 2.0, 10.0));
    super.draw();
  }
}

class ShaderPixelRolls extends VisShader {
  ShaderPixelRolls() {
    super("pixelRolls", "pixelrolls.glsl");
  }

  void draw() {
    shade.set("time", (float) millis()/1000.0);
    shade.set("pixels", x/5, 150.0);
    shade.set("rollRate", map(y, 0, height, -0.5, 0.5));
    shade.set("rollAmount", 0.25);
    super.draw();
  }
}

class ShaderModcolor extends VisShader {
  ShaderModcolor() {
    super("modcolor", "modcolor.glsl");
  }

  void draw() {
    shade.set("modr", map(x, 0, width, 0, 0.5));
    shade.set("modg", 0.3);
    shade.set("modb", map(y, 0, height, 0, 0.5));
    super.draw();
  }
}

class ShaderHalftone extends VisShader {
  ShaderHalftone() {
    super("halftone", "halftone.glsl");
  }

  void draw() {
    shade.set("pixelsPerRow", (int) map(x, 0, width, 2, 100));
    super.draw();
  }
}

class ShaderInvert extends VisShader {
  ShaderInvert() {
    super("inversion", "invert.glsl");
  }
  void draw() {
    super.draw();
  }
}

class ShaderVHSGlitch extends VisShader {
  ShaderVHSGlitch() {
    super("VHS Glitch", "vhs_glitch.glsl");
    shade.set("iResolution", float(width), float(height));
  }
  void draw() {
    shade.set("iGlobalTime", millis() / 1000.0);
    super.draw();
  }
}

class ShaderSobel extends VisShader {
  ShaderSobel() {
    super("Sobel", "sobel.glsl");
    shade.set("iResolution", float(width), float(height));
  }
  void draw() {
    super.draw();
  }
}

class ShaderKaleidoscope extends VisShader {
  int viewAngleMod;
  float rot;

  ShaderKaleidoscope() {
    super("Kaleidoscope", "kaleidoscope.glsl");
    shade.set("rotation", 0);
    shade.set("viewAngle", TWO_PI/10 );
  }

  void draw() {
    shader(shade);
  }
}
