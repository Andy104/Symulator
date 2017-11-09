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
  
  //  Sprawdzenie położenia przeszkód i czułek
  for (int i = 0; i < objectTab.getRowCount(); i++) {
    TableRow row = objectTab.getRow(i);
    if ((row.getInt("x") == (int)round(robot.xSensorEnd + robot.xpos)) && (row.getInt("y") == (int)round(robot.ySensorEnd + robot.ypos))) {
      println("przeszkoda");
      //robot.czulki(wykryto przeszkode);
      //robot.czulki(położenie punktu zaczepienia);
      //robot.czulki(row.getInt("x"), row.getInt("y"));
    } else {
      //robot.czulki(brak przeszkody);
      //robot.czulki(położenie czułki swobodne);
      //robot.czulki((int)round(robot.xSensorEnd + robot.xpos), (int)round(robot.ySensorEnd + robot.ypos));
    }
  }
  
  
  if (j <= 100) {signal[0] = 1000; signal[1] = 1300; }
  else if (j > 100 && j <= 120) {signal[0] = 1800; signal[1] = 1200;}
  else if (j > 120 && j <= 220) {signal[0] = 1000; signal[1] = 1300; }
  else if (j > 220 && j <= 250) {signal[0] = 1200; signal[1] = 2000; }
  else {j = 0;}
  
  //Odpowiedź sieci na obliczony sygnał
  omega = siec.FeedForward(signal);  
  
  //Przeliczenie wartości PWM na prędkość
  if (omega[1] >= -0.5) { omega[0] = abs(omega[0]); }
  if (omega[3] >= -0.5) { omega[2] = abs(omega[2]); }
  
  if (omega[0] < 5) { omegaL = 1.0; }
  else if (omega[0] >= 5 && omega[0] < 15) { omegaL = 1.1; }
  else if (omega[0] >= 15) { omegaL = 1.2; }
  
  if (omega[2] < 5) { omegaR = 1.0; }
  else if (omega[2] >= 5 && omega[2] < 15) { omegaR = 1.1; }
  else if (omega[2] >= 15) { omegaR = 1.2; }
  
  /*println();
  println("wL = " + omegaL);
  println("dirL = " + dirL);
  println("wR = " + omegaR);
  println("dirR = " + dirR);*/
  
  robot.Step(omegaL, omegaR);
  robot.Display();
  
  j++;
}

class Robot {
  //Robot
  float d;  
  float r;
  float wl;
  float wp;
  float Tp;
    
  float xpos;
  float ypos;
  float phi;
  
  float xRobot;
  float yRobot;
  float xSensorStart;
  float ySensorStart;
  float xSensorEnd;
  float ySensorEnd;
  
  //Czułki
  int numSegments;
  float xSeg[];
  float ySeg[];
  float angleSeg[];
  float segLength;
  float targetX, targetY;
  
  //Konstruktor
  Robot(int szerokosc, int dlugosc, float x, float y, float kat, float dl, float pr) {
    Tp = 1;
    xpos = x;
    ypos = y;
    phi = kat;
    
    d = dl;
    r = pr;
    
    xRobot = szerokosc;
    yRobot = dlugosc;
    
    xSensorStart = xRobot / 2;
    xSensorEnd = xSensorStart + 15;
    ySensorStart = yRobot / 4;
    ySensorEnd = ySensorStart + 12;
    
    numSegments = 10;
    segLength = 2;
    xSeg = new float[numSegments];
    ySeg = new float[numSegments];
    angleSeg = new float[numSegments];
    
  }
  
  void positionSegment(int a, int b) {
    xSeg[b] = xSeg[a] + cos(angleSeg[a]) * segLength;
    ySeg[b] = ySeg[a] + sin(angleSeg[a]) * segLength; 
  }

  void reachSegment(int i, float xin, float yin) {
    float dx = xin - xSeg[i];
    float dy = yin - ySeg[i];
    angleSeg[i] = atan2(dy, dx);  
    targetX = xin - cos(angleSeg[i]) * segLength;
    targetY = yin - sin(angleSeg[i]) * segLength;
    //println(i, " ", targetX, " ", targetY);
  }

  void segment(float x, float y, float a, float deltaX, float deltaY) {
    strokeWeight(1);
    pushMatrix();
    translate(x+deltaX, y+deltaY);
    rotate(a);
    line(0, 0, segLength, 0);
    popMatrix();
  }
  
  float Velocity() {
    float vel = wp + wl * r / 2;
    return vel;
  }
  
  float Omega() {
    float omg = (wp - wl) * r / d;
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
  
  void Step(float left, float right) {
    wl = left;
    wp = right;

    Phin();
    Xn();
    Yn();
    
    newRow = newTab.addRow();
    newRow.setFloat("x", xpos);
    newRow.setFloat("y", ypos);
    saveTable(newTab, "ghost.tsv");
  }
  
  void Signal() {
    
  }
  
  void Signal(int left, int right) {
    
  }
  
  void Display() {
    strokeWeight(1);
    for(TableRow row : ghostTab.rows()) {
      point(row.getInt("x"), row.getInt("y"));
    }
    
    pushMatrix();
    translate(xpos, ypos);
    rotate(phi);
    
    reachSegment(0, xSensorEnd, ySensorEnd);
    for(int i=1; i<numSegments; i++) {
      reachSegment(i, targetX, targetY);
    }
    for(int i=xSeg.length-1; i>=1; i--) {
      positionSegment(i, i-1);  
    } 
    for(int i=0; i<xSeg.length; i++) {
      segment(xSeg[i], ySeg[i], angleSeg[i], xSensorStart, ySensorStart); 
    }
    
    float max = 0;
    for (int n = 0; n < numSegments; n++) {
      max += degrees(abs(angleSeg[n]));
    }
    //println(max / numSegments);
    
    fill(0);
    noStroke();
    rectMode(CENTER);
    rect(0, 0, xRobot, yRobot);
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
    {-2.2262353443724119, 0.240911501250247, -7.771985610902895, -0.135920811990952, -10.958964644094142, 38.361989501327564, 19.054150135051130, 6.588522811927432}, 
    {-2.3124582332364492, 11.974140101969004, 41.407328218704606, 12.065838399079153, 5.832571029618378, 1.571468312227123, -31.209524873306574, -6.167941966749249}, 
    {6.1316912347136343, 11.81473315018301, 14.800956804396813, 11.589835002168435, 6.4383831481577252, 19.483460284520937, 15.99047038410459, -2.0871817576418819}
  };
  float hiddenWeight[][] = {
    { 0.0332948105995429, 1.03118922991245, -0.0563395212141743, 0.0838689487760870 },
    { -4.14283514896582, -0.0680578448082310, -0.046413382601782, -0.068053620706070 },
    { 0.004308689913784, 0.007347666907454, 0.506020624454071, 0.007348054653341 },
    { 4.313373924496300, 0.063182512909129, 0.042335875246172, 0.063177555653699 },
    { -0.965116013113119, -0.0005670790341832, -0.001106585549589, -0.000565684212302 },
    { -0.004755527827990, -1.024101049166465, -0.512340546554027, -1.024149381049142 },
    { 0.000065709634845, -0.000980268322908, -0.502208161178029, -0.000978254757323 },
    { 1.003663346325185, 1.040947251050357, 0.523370722488140, 1.040995335965606 },
    { 0.755945612986882, -0.017336471473698, 0.068061150656458, 0.929980775367793 }
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
    for(x = 0; x < inputLayer; x++) {
      inputNeuron[x] = ((1 + 1) * (InputVals[x] - 1000) / (4000 - 1000)) - 1;
      //println("Neuron " + x + " = " + inputNeuron[x]);
    }
    
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
        OutputVals[z] = 20 * (outputNeuron[z] + 1) / (1 + 1);
      }
      if (z == 1) {
        OutputVals[z] = 2 * (outputNeuron[z] + 1) / 2 - 1;
      }
      if (z == 2) {
        OutputVals[z] = 20 * (outputNeuron[z] + 1) / (1 + 1);
      }
      if (z == 3) {
        OutputVals[z] = 2 * (outputNeuron[z] + 1) / 2 - 1;
      }
    }
    
    return OutputVals;
  }
}