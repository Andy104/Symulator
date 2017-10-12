float ghost[][];

Robot robot;

void setup() {
  size(400, 400);
  background(127);
  fill(255);
  rectMode(CENTER);
  rect(height/2, width/2, 350, 350);
  
  robot = new Robot(height/2, width/2, 1, 0.1, 0.05);
  robot.Display();
}

void draw() {
  fill(255);
  rectMode(CENTER);
  rect(height/2, width/2, 350, 350);
  
  robot.Step(10, 10);
  robot.Display();
}

class Robot {
  float d;
  float r;
  float wl;
  float wp;
  float Tp;
    
  float xpos;
  float ypos;
  float phi;
  
  Robot(float x, float y, float kat, float dl, float pr) {
    Tp = 1;
    xpos = x;
    ypos = y;
    phi = kat;
    
    d = dl;
    r = pr;
  }
  
  float Velocity() {
    float vel = abs(wp + wl) * r / 2;
    return vel;
  }
  
  float Omega() {
    float omg = abs(wp - wl) * r / d;
    return omg;
  }
  
  float Vxn() {
    float vx = (abs(wp + wl) * r / 2) * cos(phi);
    return vx;
  }
  
  float Vyn() {
    float vy = (abs(wp + wl) * r / 2) * sin(phi);
    return vy;
  }
  
  void Xn() {
    float xn = xpos + Tp * Vxn();
    xpos = xn;
  }
  
  void Yn() {
    float yn = ypos + Tp * Vyn();
    ypos = yn;
  }
  
  void Phin() {
    float phin = phi + Tp * Omega();
    phi = phin;
  }
  
  void Step(float prL, float prP) {
    wl = prL;
    wp = prP;
    
    Xn();
    Yn();
    Phin();
  }
  
  void Display() {
    fill(102);
    rectMode(CENTER);
    rect(xpos,ypos,20,10);
  }
}