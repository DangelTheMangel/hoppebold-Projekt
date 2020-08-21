PVector location;
PVector velocity = new PVector();
PVector gravity1 = new PVector(0, 1);
PVector gravity2 = new PVector(0, 1);
ArrayList<Mover> moveListe = new ArrayList<Mover>();



void setup() {
  size(640, 360);

  velocity = new PVector(2.5, 5);

  for (int i = 0; i< 2; i++) {
    moveListe.add(new Mover(location = new PVector(100+ 50*i, 100)));
  }
}

void draw() {
  clear();
  background(255);
  
    for(int i = 0; i < width; ++i){
    
  float x = i;
  float y = 3 * sin(x + PI/3 ) + (height - 60);
  noStroke();
  ellipse(x,y,3,3);
  }
  
  for (int i = 0; i< moveListe.size(); i++) {
    Mover mover = moveListe.get(i);
    
    if (i == 1) {
      mover.applyForce(gravity1);
      mover.ShitUdate();
    } else {
      mover.applyForce(gravity2);
      mover.update();
    }

    mover.display();
    mover.checkEdges();
  }

  if (mousePressed) {
    for (int i = 0; i< moveListe.size(); i++) {
      Mover mover = moveListe.get(i);
      PVector wind = new PVector(0, -10);
      mover.applyForce(wind);
    }
  }
}


class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;

  //The object now has mass!
  float mass;

  Mover(PVector location ) {

    //And for now, we’ll just set the mass equal to 1 for simplicity.
    mass = 2;
    this.location = location;
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  //Newton’s second law.
  void applyForce(PVector force) {
    //Receive a force, divide by mass, and add to acceleration.
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void ShitUdate() {
    //Motion 
    velocity.add(acceleration);
    velocity.mult(0.99);
    location.add(velocity);
    //Now add clearing the acceleration each time!
    acceleration.mult(0.1);
  }

  void update() {

    PVector friction = velocity.mult(0);
    friction.normalize();
    friction.mult(2);
    //Motion 
    acceleration.add(friction);
    velocity.add(acceleration);
    location.add(velocity);

    //Now add clearing the acceleration each time!
    //acceleration.mult(0);
  }

  void display() {
    stroke(0);
    fill(175);
    //Scaling the size according to mass.
    ellipse(location.x, location.y, mass*16, mass*16);
  }

  //Somewhat arbitrarily, we are deciding that an object bounces when it hits the edges of a window.
  void checkEdges() {
        if (location.x > width-16) {
      location.x = width-16;
      velocity.x *= -1;
    } else if (location.x < 0) {
      velocity.x *= -1;
      location.x = 0;
    }

    if (location.y > height-16) {
      //Even though we said we shouldn't touch location and velocity directly, there are some exceptions. Here we are doing so as a quick and easy way to reverse the direction of our object when it reaches the edge.
      location.y = height-16;
      velocity.y *= -1;
      acceleration.mult(-1);
    } else if (location.y < 0){
      velocity.y *= -1;
      location.y = 0;
      }
    }
  }

