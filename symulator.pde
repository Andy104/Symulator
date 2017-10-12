float ghost[][];
float x = 200;
float y = 200;
float phi = 45;

Robot robot;

void setup() {
  size(400, 400);
  background(127);
  fill(255);
  rectMode(CENTER);
  rect(height/2, width/2, 350, 350);
  
  robot = new Robot(height/2, width/2, 0);
  robot.Display();
}


void draw() {
  size(400, 400);
  background(127);
  fill(255);
  rectMode(CENTER);
  rect(height/2, width/2, 350, 350);
  
  robot.Step(x, y, phi);
  robot.Display();
  
  x += 1;
  y += 1;
  //phi += 1;
}

class Robot {
  float xpos;
  float ypos;
  float phi;
  
  Robot(float x, float y, float kat) {
    xpos = x;
    ypos = y;
    phi = kat;
  }
    
  void Step(float x, float y, float kat) {
    xpos = x;
    ypos = y;
    phi = kat;
    
    fill(192);
    noStroke();
    rectMode(CENTER);
    rect(xpos, ypos, 40, 40);
  }
  
  void Display() {
    pushMatrix();
    translate(xpos, ypos);

    rotate(radians(phi));

    fill(0);
    rect(0, 0, 40, 40);
    popMatrix();
  }
}