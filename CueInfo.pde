class CueInfo {
  String displayText;
  int originX, originY,boxSize, margin;

  CueInfo() {
    displayText = "";
    boxSize = 15;
    margin = 5;
    originX = width - boxSize - margin;
    originY = margin;
  }
  void setText(String t) {
    displayText = t;
  }
  void clearText() {
    displayText = "";
  }

  void draw() {
    if (!(displayText == "")) {
      push();

      translate(originX,originY);
      fill(50);
      stroke(50);
      rect(0, 0, boxSize, boxSize);

      textAlign(CENTER);
      textSize(10);
      fill(220);
      text(displayText, boxSize/2,boxSize/2);
      pop();
    }
  }
}
