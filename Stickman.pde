class Stickman {
  PGraphics pg;
  int stickManOriginX, stickManOriginY;

  int   armRadius           =  50;
  int   armMinAngle         = -20;
  int   armMaxAngle         =  85;

  float rightArmAngle        = 0;
  float rightArmCurrentAngle = 0;
  float rightArmTargetAngle  = 0;
  float rightArmDiff         = 0;

  float leftArmAngle         = 0;
  float leftArmCurrentAngle  = 0;
  float leftArmTargetAngle   = 0;
  float leftArmDiff          = 0;

  int   legOffset           =  70;
  int   legRadius           =  80;
  int   legMinAngle         =  10;
  int   legMaxAngle         =  85;

  float rightLegAngle        = 0;
  float rightLegCurrentAngle = 0;
  float rightLegTargetAngle  = 0;
  float rightLegDiff         = 0;

  float leftLegAngle         = 0;
  float leftLegCurrentAngle  = 0;
  float leftLegTargetAngle   = 0;
  float leftLegDiff          = 0;

  int startTime, elapsedTime;
  int beatDuration = 400;

  float originX, originY, speed = 0;

  float danceStartX = -25;
  float danceStartY = 0;

  float danceDistanceX = 50;
  float danceDistanceY = 25;
  int   danceDirection;

  color headColor;
  int   bodyThickness;

  float stickManScale;

  Stickman(PGraphics pgraphics, int x, int y, float scale) {

    pg = pgraphics;
    stickManOriginX = x;
    stickManOriginY = y;
    originX = danceStartX;

    // randomise the dancedirection
    if (int(random(0, 9)) < 5) {
      danceDirection = -1;
    } else {
      danceDirection = 1;
    }

    //pick a random color for the head
    push();
    colorMode(HSB,255,255,255);
    headColor = color(int(random(255)), 190, 200); // HSB Hue Saturation Brightness
    pop();

    //and a thickness for the body
    bodyThickness = int(random(3, 10));

    //set the scale of the stickman
    stickManScale = scale;
  }

  void draw() {
    update();

    pg.push();
    pg.scale(stickManScale);
    pg.translate(stickManOriginX, stickManOriginY);
    pg.translate(originX, -originY);
    pg.stroke(240);
    pg.strokeWeight(bodyThickness);

    pg.colorMode(HSB);
    pg.fill(headColor);

    // draw head and body
    pg.line(0, -30, 0, 70);
    pg.ellipse(0, -60, 60, 60);

    // Draw arms
    pg.line(0, 0, cos(radians(rightArmAngle)) * armRadius, sin(radians(rightArmAngle)) * armRadius);
    pg.line(0, 0, cos(radians(leftArmAngle))  * armRadius, sin(radians(leftArmAngle))  * armRadius);

    // Draw legs
    pg.translate(0, legOffset);
    pg.line(0, 0, cos(radians(rightLegAngle)) * legRadius, sin(radians(rightLegAngle)) * legRadius);
    pg.line(0, 0, cos(radians(leftLegAngle))  * legRadius, sin(radians(leftLegAngle))  * legRadius);

    pg.pop();
  }

  void danceMove() {

    startTime = millis();

    rightArmCurrentAngle = rightArmAngle;
    rightArmTargetAngle  = random(armMinAngle, armMaxAngle);
    rightArmDiff         = rightArmTargetAngle - rightArmAngle;

    leftArmCurrentAngle = leftArmAngle;
    leftArmTargetAngle  = 180 - random(armMinAngle, armMaxAngle);
    leftArmDiff         = leftArmTargetAngle - leftArmAngle;

    rightLegCurrentAngle = rightLegAngle;
    rightLegTargetAngle  = random(legMinAngle, legMaxAngle);
    rightLegDiff         = rightLegTargetAngle - rightLegAngle;

    leftLegCurrentAngle = leftLegAngle;
    leftLegTargetAngle  = 180 - random(legMinAngle, legMaxAngle);
    leftLegDiff         = leftLegTargetAngle - leftLegAngle;

    danceDirection *= -1;
    danceStartX = originX;
  }

  void update() {
    elapsedTime = millis() - startTime;

    // if the movement is finished then reset some things and return early
    if (elapsedTime > beatDuration) {
      elapsedTime = beatDuration;

      // reset originX and originY, they can get out of step due to rounding errors caused by
      // the mismatch between millis() and frames
      if (originX < 0) {
        originX = -(danceDistanceX/2);
      } else {
        originX = danceDistanceX/2;
      }
      originY = 0;

      return;
    }

    // normalise the progression through the duration of a beat
    float t = norm(elapsedTime, 0, beatDuration);

    // move the origin in a smooth bounce timed with the beat
    originX = danceStartX + ((danceDistanceX * t) * danceDirection);
    originY = danceStartY + (sin(map(originX, -danceDistanceX/2, danceDistanceX/2, 0, PI)) * 20);

    if (rightArmDiff < 0) {
      rightArmAngle = rightArmCurrentAngle - (abs(rightArmDiff) * easeInOutQuint(t));
    } else {
      rightArmAngle = rightArmCurrentAngle + (abs(rightArmDiff) * easeInOutQuint(t));
    }

    if (leftArmDiff < 0) {
      leftArmAngle = leftArmCurrentAngle - (abs(leftArmDiff) * easeInOutQuint(t));
    } else {
      leftArmAngle = leftArmCurrentAngle + (abs(leftArmDiff) * easeInOutQuint(t));
    }

    if (rightLegDiff < 0) {
      rightLegAngle = rightLegCurrentAngle - (abs(rightLegDiff) * easeInOutQuint(t));
    } else {
      rightLegAngle = rightLegCurrentAngle + (abs(rightLegDiff) * easeInOutQuint(t));
    }

    if (leftLegDiff < 0) {
      leftLegAngle = leftLegCurrentAngle - (abs(leftLegDiff) * easeInOutQuint(t));
    } else {
      leftLegAngle = leftLegCurrentAngle + (abs(leftLegDiff) * easeInOutQuint(t));
    }
  }

  float easeInOutQuint(float t) {
    t *= 2;
    if (t < 1) return 0.5 * t * t * t * t * t;
    t -= 2;
    return 0.5 * (t * t * t * t * t + 2);
  }
}
