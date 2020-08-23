PVector gravity= new PVector(0, 9);
ArrayList<Ball> ballList = new ArrayList<Ball>();
ArrayList<Ball> groundList = new ArrayList<Ball>();
int numBalls = 4;

void setup() {
  size(640, 360);
  frameRate(60);

  PVector location;
  PVector velocity;
  PVector RBG;
  //velocity = new PVector(2.5, 5);

  // Moving balls
  for (int i = 0; i < numBalls; i++) {
    location = new PVector(100 + i, 100 + 50 * i);
    velocity = new PVector(-10, 0);
    RBG = new PVector(196, 196, 196);
    Ball ball = new Ball(location, velocity, RBG);
    ball.applyForce(gravity);
    ballList.add(ball);
  }

  // Ground balls
  for (int i = 0; i < width/16 + 1; i++) {
    int x  = i * 16;
    float y  = 3 * sin(x + PI/3 ) + (height - 60) ;
    location = new PVector(x, y);
    velocity = new PVector(0, 0);
    RBG = new PVector(random(0, 255), random(0, 255), random(0, 255));
    Ball ball = new Ball(location, velocity, RBG);
    groundList.add(ball);
  }
}

void draw() {
  clear();
  background(255);

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

  Ball(PVector location, PVector velocity, PVector RBG) {
    this.location = location;
    this.velocity = velocity;
    this.RBG = RBG;
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
    friction.mult(-.01);


    // Motion 
    velocity.add(friction);
    velocity.add(acceleration);
    location.add(velocity);

    println("friction: " + friction + " acceleration: " + acceleration + " velocity: " + velocity + " location: " + location);
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
      println("her" + velocity);
    } else if (location.y < 0 ) {
      velocity.y *= -1;
      location.y = 0  + radius;
    }

    // Check ground balls
    for (int i = 0; i < groundList.size(); i++) {
      Ball ground = groundList.get(i);
      float dx = ground.location.x - location.x;
      float dy = ground.location.y - location.y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = ground.diameter/2 + diameter/2;
      if (distance < minDist) {
        velocity.x *= -1;
        velocity.y *= -1;
        location.y = ground.location.y - diameter;
        location.x = ground.location.x - diameter;
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

        if (other.velocity.mag() > 0) {
          other.velocity.x += ax;
          other.velocity.y += ay;
        } else
          println("halløj");
      }
    }
  }
}
