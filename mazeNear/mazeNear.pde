/******************************************
 mazeNear
 
 Description:
 Simulation of a given maze where the algorithm,
 which is an application-specific modification of
 the A*-algorithm, searches for the closest unknown
 field in the maze and outputs a list containing
 the directions to this point.
 https://en.wikipedia.org/wiki/A*_search_algorithm
 
 Control:
 Click to set a field/wall as known or unknown.
 Press any key to select the field under the cursor
 as the new starting point.
 
 Solution: 
 The 'path' array contains the info the red
 solution line is based on. The cardinal points
 /directions are represented as numbers 1-4.
 
 by Jarno Burggräf
 
 ******************************************/

//Maze size
int fx=21;
int fy=21;
//Arrays for internal mapping
byte[][] field = new byte[fx][fy];                //stores '1' for every visited field
boolean[][] vwalls = new boolean[fx][fy];         //stores 'true' vertical walls
boolean[][] hwalls = new boolean[fx][fy];         //stores 'true' for horizontal walls
//Arrays for pathfinding algorithm
boolean[][] known;                                //these fields are potential solutions
boolean[][] checked;                              //these fields are no solutions, but the surrounding fields may be
byte[][] last = new byte[fx][fy];                 //pointers needed to find out the shortest path
byte[] path = new byte[20];                       //used as a stack: highest element indicates the next step towards the destination
byte mousex, mousey, nextx, nexty, currentx, currenty;
byte startx = -1;
byte starty = -1;
byte foundx = -1;
byte foundy = -1;
int p = 40;
boolean running;
byte loopCounter;

void setup() {
  size(840, 840);
  frameRate(20);
  setupMaze();
}

void draw() {
  background(200);
  noStroke();
  fill(255);

  drawField();
  drawPath();
  drawWalls();
}

//  USER CONTROL INPUT
void mousePressed() {                                        //user controlled maze creation
  mousex=byte(mouseX/p);
  mousey=byte(mouseY/p);
  if (mouseX%p>35) vwalls[mousex+1][mousey]^= true;
  else if (mouseX%p<5) vwalls[mousex][mousey]^= true;
  else if (mouseY%p>35) hwalls[mousex][mousey+1]^= true;
  else if (mouseY%p<5) hwalls[mousex][mousey]^= true;
  else if (field[mousex][mousey]==0)field[mousex][mousey]=1;
  else field[mousex][mousey]=0;
}
void keyPressed() {                                        //user controlled simulation start
  startx=byte(mouseX/p);
  starty=byte(mouseY/p);
  path = new byte[20];
  last = new byte[fx][fy];
  known = new boolean[fx][fy];
  checked = new boolean[fx][fy];
  checked[startx][starty]= true;
  known[startx][starty]= true;
  running = true;
  loopCounter=1;
  //actual algorithm that searches for the closest unknown location
  while (running) {
    for (int i=0; i<fx; i++) {
      for (int j=0; j<fy; j++) {
        if (checked[i][j]) {
          if (!known[i][j-1] && !hwalls[i][j]) {
            known[i][j-1]=true;
            last[i][j-1]=3;
          } 
          if (!known[i+1][j] && !vwalls[i+1][j]) {
            known[i+1][j]=true;
            last[i+1][j]=4;
          } 
          if (!known[i][j+1] && !hwalls[i][j+1]) {
            known[i][j+1]=true;
            last[i][j+1]=1;
          } 
          if (!known[i-1][j] && !vwalls[i][j]) {
            known[i-1][j]=true;
            last[i-1][j]=2;
          }
        }
      }
    }
    for (byte i=0; i<fx; i++) {
      for (byte j=0; j<fy; j++) {
        if (known[i][j]&&!checked[i][j]) {
          checked[i][j]=true;
          if (field[i][j]==0) {
            println("new destination found!");
            foundx=i;
            foundy=j;
            path = new byte[20];
            makePath(i, j, 0);
            printArray(path);
            println("terminated after ", loopCounter, " iterations!");
            j=100;
            i=100;
            running = false;
          }
        }
      }
    }
    loopCounter++;
    if (loopCounter>20) {
      running = false;
      println("FORCED TERMINATION: There might be a solution, but it would be useless as the path array wouldn't be able to save it.");
    }
  }
}
// recursive function tracking back the path to the found destination
void makePath(byte x, byte y, int pos) {
  if (!(x==startx && y==starty)) {
    path[pos]=byte ((last[x][y]+1)%4+1);
    switch (last[x][y]) {
    case 1: 
      makePath(byte(x), byte(y-1), pos+1);
      break;
    case 2: 
      makePath(byte(x+1), byte(y), pos+1);
      break;
    case 3: 
      makePath(byte(x), byte(y+1), pos+1);
      break;
    case 4: 
      makePath(byte(x-1), byte(y), pos+1);
      break;
    }
  }
}
// FIELD SETUP --- SIMULATION ONLY
void setupMaze() {
  field[10][10] = 1;
  field[11][10] = 1;
  field[11][9] = 1;
  field[12][10] = 1;
  field[13][10] = 1;
  field[13][9] = 1;
  vwalls[10][10] = true;
  vwalls[11][9] = true;
  vwalls[12][9] = true;
  hwalls[10][10] = true;
  hwalls[11][9] = true;
  hwalls[12][10] = true;
  hwalls[10][11] = true;
  hwalls[11][11] = true;
  hwalls[12][11] = true;
  hwalls[13][11] = true;
  vwalls[14][10] = true;
  hwalls[13][9] = true;
}
// DRAW FUNCTIONS
void drawField() {
  for (int i=0; i<fx; i++) {
    for (int j=0; j<fy; j++) {
      if (field[i][j]==1) rect(p*i, p*j, p, p);
      if (last[i][j]!=0) {
        fill(0, 255, 0); 
        rect(p*i, p*j, p, p);
        fill(255);
      }
    }
  }
  fill(255, 0, 0);
  if (startx>=0)rect(p*startx, p*starty, p, p);
}

void drawPath() {    //this reads the path and outputs a red line
  currentx=startx;
  currenty=starty;
  nextx=currentx;
  nexty=currenty;
  stroke(255, 0, 0);
  fill(255, 0, 0);
  for (int i = 19; i>=0; i--) {
    switch (path[i]) {
    case 0: 
      break;
    case 1: 
      nexty=byte(currenty-1);
      break;
    case 2: 
      nextx=byte(currentx+1);
      break;
    case 3: 
      nexty=byte(currenty+1);
      break;
    case 4: 
      nextx=byte(currentx-1);
      break;
    }
    line(currentx*p+20, currenty*p+20, nextx*p+20, nexty*p+20);
    currentx=nextx;
    currenty=nexty;
  }
  if (path[0] != 0)ellipse(foundx*p+p/2, foundy*p+p/2, 10, 10);
}

void drawWalls() {
  stroke(0);
  fill(0);
  for (int i=0; i<fx; i++) {
    for (int j=0; j<fy; j++) {
      if (vwalls[i][j])line(p*i, p*j, p*i, p*j+p);
      if (hwalls[i][j])line(p*i, p*j, p*i+p, p*j);
      if (last[i][j]>0)text(last[i][j], p*i+10, p*j+20);
    }
  }
}
