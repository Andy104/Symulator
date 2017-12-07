class Robocik {
  // Wymiary rzeczywiste robota
  float l;
  float r;
  float wl, wp;
  
  // Współrzędne robota - pozycja bezwględna
  PVector position;
  float phi;
  
  // Współrzędne końców czułek - pozycja bezwzględna
  PVector rrot, lrot;
  
  // Współrzędne czułek - pozycja względna
  PVector dimensions;
  PVector a, b, cR, dR, cL, dL;  // - d - koniec czułek, pozycja względna
  
  // Sygnał czułek
  PVector d1, d2;
  float dd, l2, angle;
  
  // Konstruktor
  Robocik(int szerokosc, int dlugosc, int x, int y, int theta, float odleglosc, float promien) {
    l = odleglosc;
    r = promien;
    
    position = new PVector(x, y);
    phi = theta;
    
    rrot = new PVector(0,0);
    lrot = new PVector(0,0);
    
    dimensions = new PVector(szerokosc, dlugosc);
    a = new PVector(dimensions.x/2, dimensions.y/4);
    b = new PVector(a.x + 8, a.y + 2);
    cL = new PVector(a.x + 15, a.y + 2);
    dL = new PVector(a.x + 20, a.y + 12);
    cR = new PVector(a.x + 15, a.y + 2);
    dR = new PVector(a.x + 20, a.y + 12);
  }
  
  float Velocity() {
    float vel = wp + wl * r / 2;
    return vel;
  }
  
  float Omega() {
    float omg = (wp - wl) * r / l;
    return omg;
  }
  
  float Vxn() {
    float vx = Velocity() * cos(phi);
    return vx;
  }
  
  float Vyn() {
    float vy = Velocity() * sin(phi);
    return vy;
  }
  
  void Xn() {
    float xn = position.x + Vxn();
    position.x = xn;
  }
  
  void Yn() {
    float yn = position.y + Vyn();
    position.y = yn;
  }
  
  void Phin() {
    float phin = phi + Omega();
    phi = phin;
  }
  
  void Step(float[] wheel) {
    wl = wheel[0];
    wp = wheel[1];

    Phin();
    Xn();
    Yn();
    
    newRow = newTab.addRow();
    newRow.setFloat("x", position.x);
    newRow.setFloat("y", position.y);
    saveTable(newTab, "ghost.tsv");
  }
  
  PVector localToGlobal(char dir) {      //  local -> Rotation() -> global
    PVector rot = new PVector(0,0);
    if (dir == 'l') {
      rot.x = position.x + dL.x * cos(phi) + dL.y * sin(phi);
      rot.y = dL.x * sin(phi) + position.y - dL.y * cos(phi);
    }
    else if (dir == 'r') {
      rot.x = position.x + dR.x * cos(phi) - dR.y * sin(phi);
      rot.y = dR.x * sin(phi) + position.y + dR.y * cos(phi);
    }
    return rot;
  }
  
  PVector globalToLocal(char dir) {      //  global -> Derotation() -> local
    PVector rot = new PVector(0,0);
    if (dir == 'l') {
      rot.x = dL.x * cos(phi) - dL.y * sin(phi);
      rot.y = - dL.x * sin(phi) + dL.y * cos(phi);
    }
    else if (dir == 'r') {
      rot.x = dR.x * cos(phi) + dR.y * sin(phi);
      rot.y = - dR.x * sin(phi) - dR.y * cos(phi);
    }
    return rot;
  }
  
  PVector CollisionDetection(PVector pos, char dir) {
    PVector col = new PVector(a.x+20,a.y+12);
    for (int i = 0; i < objectTab.getRowCount(); i++) {
      TableRow row = objectTab.getRow(i);
      
      if (dir == 'r') {
        if ((int)pos.x == row.getInt("x") && (int)pos.y == row.getInt("y")) {
          col.x = (int)(pos.x - position.x - 2);
          col.y = (int)(pos.y - position.y - 2);
        }
      }
      if (dir == 'l') {
        if ((int)pos.x == row.getInt("x") && (int)pos.y == row.getInt("y")) {
          col.x = (int)(pos.x - position.x - 2);
          col.y = (int)(pos.y - position.y + 2);
          println("short", col.x);
          println("short", col.y);
        }
      }
    }
    return col;
  }
  
  void GenerateSignals() {
    dR = CollisionDetection(rrot, 'r');
    dL = CollisionDetection(lrot, 'l');
    
    println("GenerateSignal", dR.x, dR.y, dL.x, -dL.y);
    
    d1.x = b.x - a.x;
    d1.y = -b.y + a.y;
    d2.x = dL.x - cL.x;
    d2.y = -dL.y + cL.y;
    dd = d1.x*d2.x-d1.y*d2.y;
    l2 = (d1.x*d1.x+d1.y*d1.y)*(d2.x*d2.x+d2.y*d2.y);
    angle = acos(dd/sqrt(l2));
    signal[1] = (1300 - 600)*(degrees(angle) - 120) / (75 - 120) + 600;

    d1.x = b.x - a.x;
    d1.y = -b.y + a.y;
    d2.x = dR.x - cR.x;
    d2.y = -dR.y + cR.y;
    dd = d1.x*d2.x-d1.y*d2.y;
    l2 = (d1.x*d1.x+d1.y*d1.y)*(d2.x*d2.x+d2.y*d2.y);
    angle = acos(dd/sqrt(l2));
    signal[0] = (1500 - 800)*(degrees(angle) - 120) / (75 - 120) + 800;
  }
  
  void Sensors() {
    noFill();
    stroke(1);
    bezier(a.x, -a.y, b.x, -b.y, cL.x, -cL.y, dL.x, -dL.y);
    bezier(a.x, a.y, b.x, b.y, cR.x, cR.y, dR.x, dR.y);
  }
  
  void Body() {
    fill(0);
    noStroke();
    rectMode(CENTER);
    rect(0, 0, dimensions.x, dimensions.y);
  }
  
  void Display() {
    strokeWeight(1);
    for(TableRow row : ghostTab.rows()) {
      point(row.getInt("x"), row.getInt("y"));
    }
    
    ellipseMode(RADIUS);
    fill(50);
    ellipse(rrot.x, rrot.y, 1, 1);
    ellipse(lrot.x, lrot.y, 1, 1);
    
    pushMatrix();
    translate(position.x, position.y);
    rotate(phi);
    
    Sensors();
    Body();
    
    popMatrix();
  }
}