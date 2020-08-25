PVector gravity= new PVector(0, 2);
ArrayList<Ball> ballList = new ArrayList<Ball>();
ArrayList<Ball> groundList = new ArrayList<Ball>();
ArrayList<PVector> RBGList = new ArrayList<PVector>();
AlmindeligKnap btnAddBall;
AlmindeligKnap btnRestart;
int numBalls = 6;

void setup() {
  size(640, 360);
  frameRate(60);

  PVector location;
  PVector velocity;
  PVector RBG;
  //velocity = new PVector(2.5, 5);

  // Moving balls
  for (int i = 0; i < numBalls; i++) {
    location = new PVector(random(0, width), random(0, height));
    velocity = new PVector(-10, 0);
    RBG = new PVector(196, 196, 196);
    Ball ball = new Ball(location, velocity, RBG, 32);
    ball.applyForce(gravity);
    ballList.add(ball);
  }

  // Ground balls
  for (int i = 0; i < width/16 + 1; i++) {
    int x  = i * 160;
    float y  = 400;
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    RBG = new PVector(random(75, 150), random(75, 150), random(75, 150));
    Ball ball = new Ball(location, velocity, RBG, 180 );
    groundList.add(ball);
  }

  // RBGliste
  for (int i = 0; i < width; i++) {

    PVector RBGA = new PVector(random(160, 255), random(160, 255), random(160, 255));
    RBGList.add(RBGA);
  }
  btnAddBall = new AlmindeligKnap(this, 10, 10, height/6, height/6, "+") ;
  btnRestart = new AlmindeligKnap(this, 20 +  height/6, 10, height/6, height/6, "Reset") ;
}

void draw() {
  clear();
  background(255);
  //bagrund
  for (int o = 0; o < width/10 + 1; ++o) {
    for (int p = 0; p < height/10 + 1; ++p) {
      fill(RBGList.get(p).x, RBGList.get(p).y, RBGList.get(p).z);
      ellipse(o*10, p*10, 20, 20);
    }
  }

  //udsende
  for (int i = 0; i< ballList.size(); i++) {
    Ball ball = ballList.get(i);
    ball.checkEdges();
    ball.collide();
    ball.updateMotion();
    ball.display();
  }

  for (int i = 0; i< groundList.size(); i++) {
    Ball ball = groundList.get(i);
    ball.display();
  }

  btnAddBall.tegnKnap();
  btnRestart.tegnKnap();
}
public void mousePressed() {
  btnAddBall.registrerRelease();
  btnAddBall.registrerKlik(mouseX, mouseY);

  btnRestart.registrerRelease();
  btnRestart.registrerKlik(mouseX, mouseY);

  if (btnAddBall.erKlikket()) {
    PVector loc = new PVector(random(0, width), random(0, height));
    PVector vel = new PVector(-10, 10);
    PVector RBG = new PVector(196, 196, 196);

    ballList.add(new Ball(loc, vel, RBG, 32));
    ballList.get(ballList.size() - 1).applyForce(gravity);
  }

  if (btnRestart.erKlikket()) {
    println("fuck");
    
    ballList.clear();
    groundList.clear();
    RBGList.clear();
    
    setup();
  }
}
/**
 * Class for describing a ball and its movements.
 */
class Ball {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector RBG;
  Boolean Collison = false;
  float mass = 2;
  int diameter = (int)mass * 16 ;
  int radius = diameter/2;
  float spring = 0.05;

  Ball(PVector location, PVector velocity, PVector RBG, int diameter ) {
    this.location = location;
    this.velocity = velocity;
    this.RBG = RBG;
    this.diameter = diameter;
    acceleration = new PVector(0, 0);
  }

  // Newton’s second law
  void applyForce(PVector force) {
    //Receive a force, divide by mass, and add to acceleration.
    PVector acc = PVector.div(force, mass);
    acceleration.add(acc);
  }

  // Update motion
  void updateMotion() {
    // Friction
    PVector friction = velocity.copy();
    friction.mult(-.04);

    // Motion 
    velocity.add(friction);
    velocity.add(acceleration);
    location.add(velocity);

    //herprintln("friction: " + friction + " acceleration: " + acceleration + " velocity: " + velocity + " location: " + location);
  }

  void display() {
    stroke(0);
    fill(RBG.x, RBG.y, RBG.z);
    //Scaling the size according to mass.
    ellipse(location.x, location.y, diameter, diameter);
  }

  //Somewhat arbitrarily, we are deciding that an object bounces when it hits the edges of a window.
  void checkEdges() {
    // Check sides
    if (location.x > width - radius) {
      location.x = width - radius;
      velocity.x *= -1;
    } else if (location.x < 0) {
      velocity.x *= -1;
      location.x = 0 + radius;
    }

    // Check top and bottom
    if (location.y > height - radius) {      
      velocity.y *= -1;
      location.y = height - radius;
      //println("her" + velocity);
    } else if (location.y < 0 ) {
      velocity.y *= -1;
      location.y = 0  + radius;
    }
    boolean rev = false;
    // Check ground balls
    for (int i = 0; i < groundList.size(); i++) {
      Ball ground = groundList.get(i);
      float dx = ground.location.x - location.x;
      float dy = ground.location.y - location.y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = ground.diameter/2 + diameter/2;

      if (distance < minDist) {
        float angle = atan2(dy, dx);
        float targetX = ground.location.x - cos(angle) * minDist;
        float targetY = ground.location.y - sin(angle) * minDist;


        location.x = targetX;
        location.y = targetY;
        if (rev == false)
          velocity.mult(-1);
        rev = true;
      }
    }
  }

  void collide() {
    for (int i = 0; i < ballList.size(); i++) {
      Ball other = ballList.get(i);
      if (other == this)
        continue;

      float dx = other.location.x - location.x;
      float dy = other.location.y - location.y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = other.diameter/2 + diameter/2;
      if (distance < minDist) { 
        float angle = atan2(dy, dx);
        float targetX = location.x + cos(angle) * minDist;
        float targetY = location.y + sin(angle) * minDist;
        float ax = (targetX - other.location.x) * spring;
        float ay = (targetY - other.location.y) * spring;

        velocity.x -= ax;
        velocity.y -= ay;


        other.velocity.x += ax;
        other.velocity.y += ay;
      }
    }
  }
}


public abstract class Knap {
  //variabler
  float positionX, positionY, sizeX, sizeY;
  float mouseX, mouseY;
  String text;
  boolean klikket = false;


  PApplet p;

  Knap(PApplet papp, int posX, int posY, int sizeX, int sizeY, String text ) {
    p = papp;
    positionX = posX;
    positionY = posY;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.text = text;
  }

  void klik() {
    if (p.mousePressed &&
      mouseX > positionX &&
      mouseX < positionX + sizeX &&
      mouseY > positionY &&
      mouseY < positionY + sizeY) {
    }
  }

  void setTekst(String tekst) {
    p.fill(0);

    p.text(tekst, positionX +(sizeX/16), positionY + (sizeY/2));
  }

  void tegnKnap() {
    p.stroke(1, 46, 74, 100);
    p.fill(255, 255, 255, 100);
    p.rect(positionX, positionY, sizeX, sizeY);
    setTekst(text);
  }

  boolean erKlikket() {
    return klikket;
  }

  abstract void registrerKlik(float mouseX, float mouseY);
}

public class AlmindeligKnap extends Knap {

  AlmindeligKnap(PApplet papp, int posX, int posY, int sizeX, int sizeY, String text) {
    super(papp, posX, posY, sizeX, sizeY, text  );
  }

  @Override
    void registrerKlik(float mouseX, float mouseY) {
    this.mouseX = mouseX;
    this.mouseY = mouseY;
    if (mouseX > positionX &&
      mouseX < positionX + sizeX &&
      mouseY > positionY &&
      mouseY < positionY + sizeY) {
      klikket = true;
    }
  }

  void registrerRelease() {
    klikket = false;
  }
}
