int j;

int ghostX[];
int ghostY[];
Table ghostTab;
Table newTab;
TableRow newRow;

float omegaL;
float omegaR;
float omega[];
float dirR;
float dirL;

Robot robot;
Siec siec;

void setup() {
  
  //Wektor danych testowych
  /*
  tabela = loadTable("wektor.txt", "tsv");
  omegaR = new float[tabela.getRowCount()];
  omegaL = new float[tabela.getRowCount()];
  
  for (int i = 0; i < tabela.getRowCount(); i++) {
    omegaL[i] = tabela.getFloat(i, 0);
    omegaR[i] = tabela.getFloat(i, 1);
    //println(omegaL[i] + " " + omegaR[i]);
  }
  println(omegaL[0] + " " + omegaR[0]);
  */
  
  newTab = new Table();
  newTab.addColumn("x");
  newTab.addColumn("y");
  
  saveTable(newTab, "ghost.tsv");
  
  omega = new float[2];
  
  //Okno główne
  
  size(400, 400);
  background(127);
  fill(255);
  rectMode(CENTER);
  rect(height/2, width/2, 350, 350);
  
  //Symulacja
  robot = new Robot(height/2, width/2, 0, 0.1, 0.05);
  siec = new Siec(2, 8, 4);
}


void draw() {
  ghostTab = loadTable("ghost.tsv", "tsv, header");
  ghostX = new int[ghostTab.getRowCount()];
  ghostY = new int[ghostTab.getRowCount()];
  
  float lol[] = new float[2];
  if (j <= 1000) { lol[0] = 1100.0; lol[1] = 1300.0; }
  if (j > 1000 && j <= 2000) { lol[0] = 1000.0; lol[1] = 2000.0; }
  if (j > 2000 && j <= 3000) { lol[0] = 1200.0; lol[1] = 1300.0; }
  if (j > 3000) { j = 0; }
  siec.FeedForward(lol);
  
  println();
  println("wL = " + omegaL);
  println("dirL = " + dirL);
  println("wR = " + omegaR);
  println("dirR = " + dirR);
  
  if (dirL < 0) { omega[0] += (-1) * (3 + omegaL); } else { omega[0] = 3 + omegaL; }
  if (dirR < 0) { omega[1] += (-1) * (3 + omegaR); } else { omega[1] = 3 + omegaR; }
  
  println("omega[0] = ", omega[0]);
  println("omega[1] = ", omega[1]);
  
  robot.Step(omega);
  robot.Display();
  
  j++;
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
  
  void Step(float omega[]) {
    wl = omega[0];
    wp = omega[1];

    Xn();
    Yn();
    Phin();
    
    newRow = newTab.addRow();
    newRow.setFloat("x", xpos);
    newRow.setFloat("y", ypos);
    saveTable(newTab, "ghost.tsv");
  }
  
  void Display() {
    size(400, 400);
    background(210);
    fill(255);
    stroke(1);
    rectMode(CENTER);
    rect(height/2, width/2, 350, 350);
    
    for(TableRow row : ghostTab.rows()) {
      point(row.getInt("x"), row.getInt("y"));
    }
    
    pushMatrix();
    translate(xpos, ypos);

    rotate(radians(phi));

    fill(0);
    noStroke();
    rect(0, 0, 40, 40);
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
  
  void FeedForward(float InputVals[]) {
    int x;
    int y;
    int z;
    
    //InputVals[0] = inputL;
    //InputVals[1] = inputR;
    
    println("\nInputVals[0] = " + InputVals[0] );
    println("InputVals[1] = " + InputVals[1] );
    
    println("\nInputLayer: ", inputLayer);
    for(x = 0; x < inputLayer; x++) {
      inputNeuron[x] = ((1 + 1) * (InputVals[x] - 1000) / (4000 - 1000)) - 1;
      println("Neuron " + x + " = " + inputNeuron[x]);
    }
    
    println("\nHiddenLayer: ", hiddenLayer);
    for(y = 0; y < hiddenLayer; y++) {
      sum = 0;
      for(x = 0; x < inputLayer; x++) {
        sum += inputNeuron[x] * inputWeight[x][y];
      }
      sum += 1.0 * inputWeight[x][y];
      hiddenNeuron[y] = Tansig(sum);
      println("Neuron " + y + " = " + hiddenNeuron[y]);
    }
    
    println("\nOutputLayer: ", outputLayer);
    for(z = 0; z < outputLayer; z++) {
      sum = 0;
      for(y = 0; y < hiddenLayer; y++) {
        sum += hiddenNeuron[y] * hiddenWeight[y][z];
      }
      sum += 1.0 * hiddenWeight[y][z];
      outputNeuron[z] = sum;//Tansig(sum);  // <-- Nie wiem czemu tak?
      println("Neuron " + z + " = " + outputNeuron[z]);
      
      if (z == 0) {
        omegaL = 2 * (outputNeuron[z] + 1) / (1 + 1);
      }
      if (z == 1) {
        dirL = 2 * (outputNeuron[z] + 1) / 2 - 1;
      }
      if (z == 2) {
        omegaR = 2 * (outputNeuron[z] + 1) / (1 + 1);
      }
      if (z == 3) {
        dirR = 2 * (outputNeuron[z] + 1) / 2 - 1;
      }
      
      //println("Output " + z + " : " + OutputVals[z]);
    }
  }
}