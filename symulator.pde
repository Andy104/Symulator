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
  robot = new Robot(30, 20, height/2, width/2, 0, 0.1, 0.05);
  siec = new Siec(2, 8, 4);
}

void draw() {
  
  /***  Okno główne  ***/
  background(127);
  fill(255);
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
  
  /***  Sygnał czułek  ***/
  //  Wczytanie położenia przeszkód
  for (TableRow row : objectTab.rows()) {
    point(row.getInt("x"), row.getInt("y"));
  }  
  
  signal = robot.Signals();
  
  //Odpowiedź sieci na obliczony sygnał
  omega = siec.FeedForward(signal);
  omega[0] /= 10;
  omega[1] /= 10;
  
  println(omega[0], omega[1]);

  
  if (omega[2] >= 0) {
    if (omega[0] < 1.5) { omega[0] = 1.2; }
    else if (omega[0] >= 1.5 && omega[0] < 2.5) { omega[0] = 1.4; }
    else if (omega[0] >= 2.5 && omega[0] < 3.5) { omega[0] = 1.6; }
    else if (omega[0] >= 3.5 && omega[0] < 4.5) { omega[0] = 1.8; }
    else if (omega[0] >= 4.5) { omega[0] = 2; }
  } else if (omega[2] < 0) {
    if (omega[0] < 1.5) { omega[0] = -1.2; }
    else if (omega[0] >= 1.5 && omega[0] < 2.5) { omega[0] = -1.4; }
    else if (omega[0] >= 2.5 && omega[0] < 3.5) { omega[0] = -1.6; }
    else if (omega[0] >= 3.5 && omega[0] < 4.5) { omega[0] = -1.8; }
    else if (omega[0] >= 4.5) { omega[0] = -2; }
  }
  if (omega[3] >= 0) {
    if (omega[1] < 1.5) { omega[1] = 1.2; }
    else if (omega[1] >= 1.5 && omega[1] < 2.5) { omega[1] = 1.4; }
    else if (omega[1] >= 2.5 && omega[1] < 3.5) { omega[1] = 1.6; }
    else if (omega[1] >= 3.5 && omega[1] < 4.5) { omega[1] = 1.8; }
    else if (omega[1] >= 4.5) { omega[1] = 2; }
  } else if (omega[3] < 0) {
    if (omega[1] < 1.5) { omega[1] = -1.2; }
    else if (omega[1] >= 1.5 && omega[1] < 2.5) { omega[1] = -1.4; }
    else if (omega[1] >= 2.5 && omega[1] < 3.5) { omega[1] = -1.6; }
    else if (omega[1] >= 3.5 && omega[1] < 4.5) { omega[1] = -1.8; }
    else if (omega[1] >= 4.5) { omega[1] = -2; }
  }
  
  println(omega[0], omega[1]);
  
  robot.Step(omega);
  robot.Display();
  
  j++;
}

void mouseClicked() {
  println(mouseX, mouseY);
}

class Robot {
  //Robot
  float dl;  
  float r;
  float wl;
  float wp;
  float Tp;
  
  //Pozycja bezwzględna robota
  PVector position;
  float phi;
  
  //Wsółrzędne czułek
  PVector robot;
  PVector a, b, c, d;
  
  //Współrzędne końca czułek po rotacji i translacji robota
  PVector rrot;
  PVector lrot;
  
  //Obliczanie sygnału z czułek
  float dx1;
  float dy1;
  float dx2;
  float dy2;
  float dd;
  float l2;
  float angle;
  
  //Konstruktor
  Robot(int szerokosc, int dlugosc, float x, float y, float kat, float dl, float pr) {      //30, 20
    Tp = 1;
    position = new PVector(x, y);
    phi = kat;
    
    this.dl = dl;
    this.r = pr;
    
    robot = new PVector(szerokosc, dlugosc);    //wymiary robota
    a = new PVector(robot.x/2, robot.y/4);      //początek czułki - początek pierwszego odcinka
    b = new PVector(a.x+8, a.y+2);              //koniec pierwszego odcinka
    c = new PVector(a.x+15, a.y+2);             //początek drugiego odcinka
    d = new PVector(a.x+20, a.y+12);            //koniec czułki(30, 17) - koniec drugiego odcinka
    rrot = new PVector(0, 0);
    lrot = new PVector(0, 0);
  }
  
  float Velocity() {
    float vel = wp + wl * r / 2;
    return vel;
  }
  
  float Omega() {
    float omg = (wp - wl) * r / dl;
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
    float xn = position.x + Tp * Vxn();
    position.x = xn;
  }
  
  void Yn() {
    float yn = position.y + Tp * Vyn();
    position.y = yn;
  }
  
  void Phin() {
    float phin = phi + Tp * Omega();
    phi = phin;
  }
  
  PVector Rotation(PVector point, char dir) {
    PVector rot = new PVector(0,0);
    if (dir == 'l') {
      rot.x = point.x + d.x * cos(phi) + d.y * sin(phi);
      rot.y = d.x * sin(phi) + point.y - d.y * cos(phi);
    }
    else if (dir == 'r') {
      rot.x = point.x + d.x * cos(phi) - d.y * sin(phi);
      rot.y = d.x * sin(phi) + point.y + d.y * cos(phi);
    }
    return rot;
  }
  
  void CollisionDetection(PVector posL, PVector posR) {
    for (int i = 0; i < objectTab.getRowCount(); i++) {
      TableRow row = objectTab.getRow(i);
      
      if (row.getInt("x") == (int)posR.x && row.getInt("y") == (int)posR.y) {
        println("czułka prawa", row.getInt("x"), row.getInt("y"), (int)posR.x, (int)posR.y);
      }
      if (row.getInt("x") == (int)posL.x && row.getInt("y") == (int)posL.y) {
        println("czułka lewa ", row.getInt("x"), row.getInt("y"), (int)posL.x, (int)posL.y);
      }
    }
  }
  
  void Sensors() {
    noFill();
    bezier(a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y);
    bezier(a.x, -a.y, b.x, -b.y, c.x, -c.y, d.x, -d.y);
    
    //println(a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y);
  }
  
  float[] Signals() {
    float sig[] = new float[2];
    
    CollisionDetection(lrot, rrot);
    
    dx1 = b.x - a.x;
    dy1 = b.y - a.y;
    dx2 = d.x - c.x;
    dy2 = d.y - c.y;
    dd = dx1*dx2-dy1*dy2;
    l2 = (dx1*dx1+dy1*dy1)*(dx2*dx2+dy2*dy2);
    angle = acos(dd/sqrt(l2));
    sig[1] = (1300 - 600)*(degrees(angle) - 120) / (75 - 120) + 600;

    dx1 = b.x - a.x;
    dy1 = -b.y + a.y;
    dx2 = d.x - c.x;
    dy2 = -d.y + c.y;
    dd = dx1*dx2-dy1*dy2;
    l2 = (dx1*dx1+dy1*dy1)*(dx2*dx2+dy2*dy2);
    angle = acos(dd/sqrt(l2));
    sig[0] = (1500 - 800)*(degrees(angle) - 120) / (75 - 120) + 800;

    println("lewe: ", sig[0], "prawe:", sig[1]);
    return sig;
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
  
  void Display() {
    strokeWeight(1);
    for(TableRow row : ghostTab.rows()) {
      point(row.getInt("x"), row.getInt("y"));
    }
    
    rrot = Rotation(position, 'r');
    
    d.x = mouseX - 200;
    d.y = mouseY - 200;
    lrot = Rotation(position, 'l');
    
    ellipseMode(RADIUS);
    fill(50);
    ellipse(rrot.x, rrot.y, 1, 1);
    ellipse(lrot.x, lrot.y, 1, 1);
    
    pushMatrix();
    translate(position.x, position.y);
    rotate(phi);
    
    Sensors();
    
    fill(0);
    noStroke();
    rectMode(CENTER);
    rect(0, 0, robot.x, robot.y);
    stroke(1);
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
  { -62.700579376402330, 58.770106555361350, 0.028744987797917, -2.216777908752713, -8.209967103803248, 0.457904520577887, 0.774210319199532, 8.406062313348830 },
  { 1.016086908218715, -15.282513299116458, 0.185173506110019, 10.284891268760440, -49.137130037744640, -2.890990735994227, -0.034431136269521, -0.042125806097272 },
  { 44.062027741629320, -49.003161622440985, -0.505934070982419, -6.579267943511259, 14.386299668964696, -1.499808903544442, 1.240743740277368, 9.638293398056357 }
  };
  float hiddenWeight[][] = {
  { 0.261971039520792, -0.121840234804018, -0.353319653902830, -0.353319653902825 },
  { 0.045581011346906, -0.173352847899195, 0.654044426946931, 0.654044426946930 },
  { 1.606763811025532, -3.915080122788438, -1.723955896289036, -1.723955896288743 },
  { -0.189457859799339, -0.014973885739545, 0.332242276190160, 0.332242276190153 },
  { -0.035275422600605, 0.157692863056024, -0.777186165166509, -0.777186165166502 },
  { 0.157126477152867, 0.453813757438312, -0.175297103205640, -0.175297103205618 },
  { -3.957230648337938, 0.023763640156817, 0.325867925846360, 0.325867925846363 },
  { 2.086084580232911, -0.177834075734740, 0.155045465286736, 0.155045465286596 },
  { 1.560455402833735, -1.707057678367934, -0.188330772081619, -0.188330772081334 }
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
    inputNeuron[0] = ((1 + 1) * (InputVals[0] - 800) / (1500 - 800)) - 1;
    inputNeuron[1] = ((1 + 1) * (InputVals[1] - 600) / (1300 - 600)) - 1;
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
        OutputVals[z] = 40 * (outputNeuron[z] + 1) / 2 + 10;
      }
      if (z == 1) {
        OutputVals[z] = 40 * (outputNeuron[z] + 1) / 2 + 10;
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