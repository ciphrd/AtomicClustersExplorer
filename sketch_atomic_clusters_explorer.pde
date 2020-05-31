/**
 * @author ciphrd <https://instagram.com/ciphrd>
 * @license MIT
 * 
 * Hey, just a quick note, if you fork this project and improve the tool, feel free to add your @pseudo
 * to the title of the window, in the setup() function. Let's have the community leave a trace :)
 *
 * This software was made to explore the Atomic Clusters system.
 * I wrote an article to explain the idea, the rules and the implementation behind this system:
 *
 * The architecture of this software is... approximative. Let's say it serves it purpose: just a fun
 * tool to see how the system works and what can be done with it.
 *
 * TODO: zoom (des push matrix consécustifs)
 **/

import java.util.Map;
import java.util.Arrays; 
import java.lang.Object;



AttractorsManager attractorsManager;
ParticlesManager pManager;
AtomsUI atomsUI;
Toolbar toolbar;
SlidersPanel slidersPanel;
ChargesPanel chargesPanel;
PanelAtoms panelAtoms;


// so the events works in "cascade"
// when the mouse is detected over a block, it sets this value to the ID that corresponds to the block
// detection is applied from the UI the most in front to the last
// if the mouse is detected at a point in the cascade, elements below won't perform their events
// 0 corresponds to the element the most in the back
// ------ 
// MAP of the UI
// 0 - Particles world layer
// 1 - Atoms bar on top
// 2 - Bottom toolbar
// 3 - Sliders layers
// 4 - Charges editor
// 5 - Atoms editor
// 6 - Keyboard shortcuts
int activeUI = 0;
int activeUIEvents = 0;

float P_RADIUS = 12;

float maxSpeed = 5;  // max magnitude of the velocity vectors, it gets clamped if higher
float maxCol = 8;    // max magnitude of the collisions response

// to store informations used by the tooling
int hovered = -1;
int selected = -1;
boolean paused = false;
PImage pauseImg;
int moved = -1;
boolean dragging;
PVector dragStart = new PVector(0,0);
PVector lastDragPos = new PVector(0, 0);
PVector mouse = new PVector();

// the position of the camera
PVector camera = new PVector(0, 0);

void setup () {
  attractorsManager = new AttractorsManager();
  pManager = new ParticlesManager();
  
  // we create the UI components
  atomsUI = new AtomsUI();
  toolbar = new Toolbar();
  slidersPanel = new SlidersPanel();
  chargesPanel = new ChargesPanel();
  panelAtoms = new PanelAtoms();
  
  
  // we setup the UI struff
  pauseImg = loadImage("pause.png");
  PFont PTsans;
  PTsans = createFont("RobotoMono-Regular.ttf", 32);
  textFont(PTsans, 18);
  
  size(1280, 720); 
  surface.setTitle("Atomic Clusters explorer - @ciphrd");
  //surface.setResizable(true);
}

void draw () {
  // we reset
  background(0);
  activeUIEvents = 0;
  hovered = -1;
  
  mouse.set(mouseX, mouseY);
  handleEvents();
  
  pManager.computeVelocities();
  
  // we compute the collisions and then we update/draw the particles
  if (!paused) {
    // collision detection 
    pManager.applyCollisions();
  }
  pManager.update();
  
  // we add rotation to the selected particle if r is pressed
  if (selected != -1 && keyPressed && key == 'r') {
    pManager.particles[selected].angle+= 0.2; 
  }

  drawUI();
}


void handleEvents () {
  // we need to execute this in the right order, from front in UI to back
  panelAtoms.update();
  chargesPanel.update();
  slidersPanel.update();
  toolbar.update();
  atomsUI.update();
  
  if (keyPressed && key == 'a' && atomsUI.selected != -1) {
    pManager.addParticle(mouseX-camera.x, mouseY-camera.y, attractorsManager.attractors[atomsUI.selected]);
  }
  
  if (mouseButton == LEFT && activeUIEvents == 0) {
    if (dragging) {
      camera.add(mouse.copy().sub(lastDragPos));
      lastDragPos = mouse.copy();
    }
    
    // we handle the drag control
    if (hovered == -1 && !dragging) {
      dragging = true;
      lastDragPos.set(mouseX, mouseY);
      dragStart.set(mouseX, mouseY);
    }
  } else {
     dragging = false; 
  }
}


void drawUI () {
  atomsUI.draw();
  toolbar.draw();
  slidersPanel.draw();
  chargesPanel.draw();
  panelAtoms.draw();
  if (paused) image(pauseImg, 15, height - 45, 32, 32);
}



void keyPressed () {
  if (key == ' ') {
    paused = !paused; 
  }
  if (key == DELETE && selected != -1) {
    pManager.deleteParticle(selected);
    selected = -1;
  }
  if (key == ENTER) {
    pManager.reset();
  }
}

void mousePressed () {
  // if a particle is being moved, we stop it
  moved = -1;
  
  chargesPanel.mousePressed();
  toolbar.mousePressed();
  atomsUI.mousePressed();
  panelAtoms.mousePressed();
  
  if (mouseButton == RIGHT && moved == -1) {
    moved = hovered;
  }
}

void mouseClicked () {
  if (activeUIEvents == 0) {
    if (moved == -1) {
      selected = hovered;
    }
    if (hovered == -1 && dragStart.sub(mouse).mag() == 0 && atomsUI.selected != -1) {
      pManager.addParticle(mouseX-camera.x, mouseY-camera.y, attractorsManager.attractors[atomsUI.selected]);
    }
  }
}

void mouseWheel (MouseEvent event) {
  float c = event.getCount();
}
