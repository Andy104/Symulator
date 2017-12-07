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
  robot = new Robot(30, 20, height/2-80, width/2-80, -2, 0.1, 0.05);
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
    if (omega[0] < 3.5) { omega[0] = 3; }
    else if (omega[0] >= 3.5 && omega[0] < 4.5) { omega[0] = 4; }
    else if (omega[0] >= 4.5) { omega[0] = 5; }
  } else if (omega[2] < 0) {
    if (omega[0] < 3.5) { omega[0] = -3; }
    else if (omega[0] >= 3.5 && omega[0] < 4.5) { omega[0] = -4; }
    else if (omega[0] >= 4.5) { omega[0] = -5; }
  }
  if (omega[3] >= 0) {
    if (omega[1] < 3.5) { omega[1] = 3; }
    else if (omega[1] >= 3.5 && omega[1] < 4.5) { omega[1] = 4; }
    else if (omega[1] >= 4.5) { omega[1] = 5; }
  } else if (omega[3] < 0) {
    if (omega[1] < 3.5) { omega[1] = -3; }
    else if (omega[1] >= 3.5 && omega[1] < 4.5) { omega[1] = -4; }
    else if (omega[1] >= 4.5) { omega[1] = -5; }
  }
  
  omega[0] /= 4;
  omega[1] /= 4;
  //println(omega[0], omega[1]);
  
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
        if ((int)pos.x +3 >= row.getInt("x") &&(int)pos.x -3 <= row.getInt("x") && (int)pos.y +3 >= row.getInt("y") && (int)pos.y -3 <= row.getInt("y")) {
          col.x = col.x-0.4;
          col.y = col.y;
        }
      }
      if (dir == 'l') {
        if ((int)pos.x +3 >= row.getInt("x") &&(int)pos.x -3 <= row.getInt("x") && (int)pos.y +3 >= row.getInt("y") && (int)pos.y -3 <= row.getInt("y")) {
          col.x = col.x-0.4;
          col.y = col.y;
        }
      }
    }
    return col;
  }
  
  void GenerateSignals() {
    dR = CollisionDetection(rrot, 'r');
    dL = CollisionDetection(lrot, 'l');
    //println("GenerateSignal", dR.x, dR.y, dL.x, -dL.y);
    
    d1.x = b.x - a.x;
    d1.y = -b.y + a.y;
    d2.x = dL.x - cL.x;
    d2.y = -dL.y + cL.y;
    dd = d1.x*d2.x-d1.y*d2.y;
    l2 = (d1.x*d1.x+d1.y*d1.y)*(d2.x*d2.x+d2.y*d2.y);
    angle = acos(dd/sqrt(l2));
    signal[1] = (1900 - 1500)*(degrees(angle) - 120) / (75 - 120) + 1500 + random(-50.0);

    d1.x = b.x - a.x;
    d1.y = -b.y + a.y;
    d2.x = dR.x - cR.x;
    d2.y = -dR.y + cR.y;
    dd = d1.x*d2.x-d1.y*d2.y;
    l2 = (d1.x*d1.x+d1.y*d1.y)*(d2.x*d2.x+d2.y*d2.y);
    angle = acos(dd/sqrt(l2));
    signal[0] = (1900 - 1500)*(degrees(angle) - 120) / (75 - 120) + 1500 + random(-50.0);

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
  { -0.454512109914736, -2.382215605562247, 6.090167014179015, 5.700755711897299, 5.090570236291049, -4.084955404002233, -5.620588191449418, 2.611526654433665 },
  { 8.375535749878196, 2.893159533461307, 0.673550129764684, 0.261290023014269, 0.796853049382166, 1.147367347637792, -0.614049002479692, 0.842932256950842 },
  { -0.226100670019585, 0.805667539607018, -0.755128347652538, -0.635627631814640, 0.099757930995300, -0.730011070949842, -3.813486106911570, 2.364019101002252 }
  };
  float hiddenWeight[][] = {
  { -0.063325925605889, -0.288363883771032, 0.693937887913942, 0.693945059409193 },
  { 0.064057470869886, -0.535123160973171, -0.775805799351880, -0.775794914515106 },
  { 0.944440069296792, -1.111596189063857, -1.471815876085993, -1.471958362195871 },
  { -0.886123527366445, 1.558834198945437, 0.077242734810675, 0.077425107884098 },
  { -0.568610777468602, -0.614072926632399, 2.474171082220285, 2.474135658954908 },
  { 0.108590302466931, -0.056767826815087, 1.090749141279165, 1.090749131829550 },
  { 0.665088047256768, -0.347975015422364, 0.721931721120446, 0.721891122466033 },
  { 0.468727766483958, -0.750530576566738, 1.590241108777221, 1.590174954281911 },
  { -0.181042775186012, 0.213336278405742, 0.046052586013943, 0.046073885287945 }
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
    inputNeuron[0] = ((1 + 1) * (InputVals[0] - 1500) / (2100 - 1500)) - 1;
    inputNeuron[1] = ((1 + 1) * (InputVals[1] - 1500) / (2000 - 1500)) - 1;
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
        OutputVals[z] = 2 * (outputNeuron[z] + 1) / 2 + 3;
      }
      if (z == 1) {
        OutputVals[z] = 2 * (outputNeuron[z] + 1) / 2 + 3;
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