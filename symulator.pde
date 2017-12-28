// Okno główne
PFont f;
int j;

int ghostX[];
int ghostY[];
Table ghostTab;

int objectX[];
int objectY[];
Table objectTab;

Table newTab;
TableRow newRow;

// Robot
float signal[];
float omega[];
float omegaL;
float omegaR;
float dirR;
float dirL;

// Obiekty
Robot robot;
Siec siec;

void setup() {
  newTab = new Table();
  newTab.addColumn("x");
  newTab.addColumn("y");
  saveTable(newTab, "ghost.tsv");
  
  omega = new float[4];
  signal = new float[2];
  f = createFont("Arial", 16);
  
  //Okno główne
  size(400, 400);
  strokeWeight(1);
  
  //Symulacja
  robot = new Robot(30, 20, /*height/2+*/140, /*width/2+*/280, 2, 0.1, 0.05);
  siec = new Siec(2, 8, 4);
}

void draw() {
  
  /***  Okno główne  ***/
  background(127);
  fill(255);
  stroke(1);
  rectMode(CENTER);
  rect(height/2, width/2, 350, 350);
  
  /***  Ślad robota  ***/
  ghostTab = loadTable("ghost.tsv", "tsv, header");
  ghostX = new int[ghostTab.getRowCount()];
  ghostY = new int[ghostTab.getRowCount()];
  
  /***  Przeszkody  ***/
  objectTab = loadTable("objects.tsv", "tsv, header");
  objectX = new int[objectTab.getRowCount()];
  objectY = new int[objectTab.getRowCount()];
  
  for (TableRow row : objectTab.rows()) {
    point(row.getInt("x"), row.getInt("y"));
  }
  
  /***  Sygnał czułek  ***/
  robot.GenerateSignals();
  
  //Odpowiedź sieci na obliczony sygnał
  omega = siec.FeedForward(signal);
  //println(omega[0], omega[1]);
  //omega[0] /= 10;
  //omega[1] /= 10;
  
  //println(omega[0], omega[1]);
  
  if (omega[2] >= 0) {
    if (omega[0] < 35) { omega[0] = 30; }
    else if (omega[0] >= 35 && omega[0] < 45) { omega[0] = 40; }
    else if (omega[0] >= 45 && omega[0] < 55) { omega[0] = 50; }
    else if (omega[0] >= 55 && omega[0] < 65) { omega[0] = 60; }
    else if (omega[0] >= 65) { omega[0] = 70; }
  } else if (omega[2] < 0) {
    if (omega[0] < 35) { omega[0] = -30; }
    else if (omega[0] >= 35 && omega[0] < 45) { omega[0] = -40; }
    else if (omega[0] >= 45 && omega[0] < 55) { omega[0] = -50; }
    else if (omega[0] >= 55 && omega[0] < 65) { omega[0] = -60; }
    else if (omega[0] >= 65) { omega[0] = -70; }
  }
  if (omega[3] >= 0) {
    if (omega[1] < 35) { omega[1] = 30; }
    else if (omega[1] >= 35 && omega[1] < 45) { omega[1] = 40; }
    else if (omega[1] >= 45 && omega[1] < 55) { omega[1] = 50; }
    else if (omega[1] >= 55 && omega[1] < 65) { omega[1] = 60; }
    else if (omega[1] >= 65) { omega[1] = 70; }
  } else if (omega[3] < 0) {
    if (omega[1] < 35) { omega[1] = -30; }
    else if (omega[1] >= 35 && omega[1] < 45) { omega[1] = -40; }
    else if (omega[1] >= 45 && omega[1] < 55) { omega[1] = -50; }
    else if (omega[1] >= 55 && omega[1] < 65) { omega[1] = -60; }
    else if (omega[1] >= 65) { omega[1] = -70; }
  }
  
  omega[0] /= 40;
  omega[1] /= 40;
  //println(omega[0], omega[1]);
  
  if (omega[2]<0 && omega[3]<0) {
    robot.Step(omega);
  }
  
  robot.Step(omega);
  robot.Display();
  
  j++;
}

void mouseClicked() {
  println(mouseX, mouseY);
}

class Robot {
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
  
  //Konstruktor
  Robot(int szerokosc, int dlugosc, int x, int y, float theta, float axe2, float wheelRadius) {      //30, 20
    l = axe2;
    r = wheelRadius;
    
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
    
    d1 = new PVector(0,0);
    d2 = new PVector(0,0);
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
  
  PVector Rotation(PVector point, char dir) {
    PVector rot = new PVector(0,0);
    if (dir == 'l') {
      rot.x = point.x + dL.x * cos(phi) + dL.y * sin(phi);
      rot.y = dL.x * sin(phi) + point.y - dL.y * cos(phi);
    }
    else if (dir == 'r') {
      rot.x = point.x + dR.x * cos(phi) - dR.y * sin(phi);
      rot.y = dR.x * sin(phi) + point.y + dR.y * cos(phi);
    }
    return rot;
  }
  
  PVector CollisionDetection(PVector pos, char dir) {
    PVector col = new PVector(a.x+20,a.y+12);
    for (int i = 0; i < objectTab.getRowCount(); i++) {
      TableRow row = objectTab.getRow(i);
      
      if (dir == 'r') {
        if ((int)pos.x +5 >= row.getInt("x") &&(int)pos.x -5 <= row.getInt("x") && (int)pos.y +5 >= row.getInt("y") && (int)pos.y -5 <= row.getInt("y")) {
          col.x = col.x-0.15;
          col.y = col.y;
        }
      }
      if (dir == 'l') {
        if ((int)pos.x +5 >= row.getInt("x") &&(int)pos.x -5 <= row.getInt("x") && (int)pos.y +5 >= row.getInt("y") && (int)pos.y -5 <= row.getInt("y")) {
          col.x = col.x-0.15;
          col.y = col.y;
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
    signal[1] = (1900 - 1000)*(degrees(angle) - 120) / (75 - 120) + 1000;// + random(-49.0);

    d1.x = b.x - a.x;
    d1.y = -b.y + a.y;
    d2.x = dR.x - cR.x;
    d2.y = -dR.y + cR.y;
    dd = d1.x*d2.x-d1.y*d2.y;
    l2 = (d1.x*d1.x+d1.y*d1.y)*(d2.x*d2.x+d2.y*d2.y);
    angle = acos(dd/sqrt(l2));
    signal[0] = (1900 - 1000)*(degrees(angle) - 120) / (75 - 120) + 1000;// + random(-49.0);

    println("lewe: ", signal[0], "prawe:", signal[1]);
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
    
    rrot = Rotation(position, 'r');
    lrot = Rotation(position, 'l');
    
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

class Siec {
  float InputVals[];
  float OutputVals[];
  float sum;
  
  int inputLayer;
  int hiddenLayer;
  int outputLayer;
  
  float inputWeight[][] = {
  { 3.97681621216933, -3.43496298788826, 0.518062070134451, 0.821710432630776, 0.714825677501889, 3.13587278595063, -1.13347989568598, 2.75103671091913 },
  { -1.12567585837059, -5.60379820912743, -1.67260335217006, -0.590835467054184, 2.04527923010639, 2.53399406174777, -4.57620518303079, 1.37198169402332 },
  { -3.51380189962795, 5.82953064721858, 0.136053628312775, 0.298490163292096, -1.17434690710991, 1.96714436336079, -1.62541860897994, 2.79152826743692 }
  };
  float hiddenWeight[][] = {
  { -0.374539869053815, 0.00520958749709069, 1.45041597489166, 1.45051279535150 },
  { 0.0450913679372663, 0.105106685428046, -0.730598594275543, -0.730520130391922 },
  { 0.163770796582358, -0.199147228985666, 3.12217013960246, 3.12381551881537 },
  { -1.27075427183792, 0.710953002540675, -3.38983944095807, -3.39103910088049 },
  { -0.242669899517994, -0.646304722160610, 2.14853795645904, 2.14974643764777 },
  { -0.158782162500928, -0.146909674635699, -0.00961714629595829, -0.008957030265926 },
  { 0.120545026126452, 0.269719021014171, -0.403459385194824, -0.403554762692929 },
  { 0.221448389101420, 0.086036007781647, 0.826170858432722, 0.823929019418342 },
  { -0.145356096680302, -0.346164769000769, 2.12361827932047, 2.12594115099956 }
  };
  
  float inputNeuron[];
  float hiddenNeuron[];
  float outputNeuron[];
  
  Siec(int in, int hid, int out) {
    inputLayer = in;
    hiddenLayer = hid;
    outputLayer = out;
    
    inputNeuron = new float[in];
    hiddenNeuron = new float[hid];
    outputNeuron = new float[out];
    
    InputVals = new float[in];
    OutputVals = new float[out];
  }
  
  float Tansig(float value) {
    return (2 / (1 + exp((-2) * value))) -1 ;
  }
  
  float[] FeedForward(float InputVals[]) {
    int x;
    int y;
    int z;
    
    //println("\nInputVals[0] = " + InputVals[0] );
    //println("InputVals[1] = " + InputVals[1] );
    
    //println("\nInputLayer: ", inputLayer);
    inputNeuron[0] = (1 + 1) * (InputVals[0] - 1000) / (1900 - 1000) - 1;
    inputNeuron[1] = (1 + 1) * (InputVals[1] - 1000) / (1900 - 1000) - 1;
    //println("Neuron " + x + " = " + inputNeuron[x]);
    
    //println("\nHiddenLayer: ", hiddenLayer);
    for(y = 0; y < hiddenLayer; y++) {
      sum = 0;
      for(x = 0; x < inputLayer; x++) {
        sum += inputNeuron[x] * inputWeight[x][y];
      }
      sum += 1.0 * inputWeight[x][y];
      hiddenNeuron[y] = Tansig(sum);
      //println("Neuron " + y + " = " + hiddenNeuron[y]);
    }
    
    //println("\nOutputLayer: ", outputLayer);
    for(z = 0; z < outputLayer; z++) {
      sum = 0;
      for(y = 0; y < hiddenLayer; y++) {
        sum += hiddenNeuron[y] * hiddenWeight[y][z];
      }
      sum += 1.0 * hiddenWeight[y][z];
      outputNeuron[z] = sum;
      //println("Neuron " + z + " = " + outputNeuron[z]);
      
      if (z == 0) {
        OutputVals[z] = 40 * (outputNeuron[z] + 1) / 2 + 30;
      }
      if (z == 1) {
        OutputVals[z] = 40 * (outputNeuron[z] + 1) / 2 + 30;
      }
      if (z == 2) {
        OutputVals[z] = 2 * (outputNeuron[z] + 1) / 2 - 1;
      }
      if (z == 3) {
        OutputVals[z] = 2 * (outputNeuron[z] + 1) / 2 - 1;
      }
    }
    
    return OutputVals;
  }
}