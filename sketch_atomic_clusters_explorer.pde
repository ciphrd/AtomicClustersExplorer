import java.util.Map;
import java.util.Arrays; 
import java.lang.Object;


// About the approximations due to my current collision model
// The current collision function is wrong, and due to this particles keep being moved and a flickering effect appears
// to solve it, in the Particle.update() method, I do a smoothening between current position and next position


Particle[] particles;
AtomsUI atomsUI;

float P_RADIUS = 12;

int NB_PARTICLES = 180;
float maxSpeed = 5;  // max magnitude of the velocity vectors, it gets clamped if higher
float maxCol = 8;    // max magnitude of the collisions response
int NB_TYPES = 4;

// to store informations used by the tooling
int hovered = -1;
int selected = -1;
boolean paused = false;
PImage pauseImg;
int moved = -1;
boolean dragging;
PVector lastDragPos = new PVector(0, 0);

// the position of the camera
PVector camera = new PVector(0, 0);

void setup () {
  particles = new Particle[NB_PARTICLES];
  
  // the different possible attractors for the particles
  // arg1: number of attraction points
  // arg2: a list of the types of the attraction points
  ParticleAttractors attrs1 = new ParticleAttractors(new int[]{ 0, 1 });
  ParticleAttractors attrs2 = new ParticleAttractors(new int[]{ 1, 2 });
  ParticleAttractors attrs3 = new ParticleAttractors(new int[]{ 2, 3 });
  ParticleAttractors attrs4 = new ParticleAttractors(new int[]{ 3, 0 });
  ParticleAttractors attrs5 = new ParticleAttractors(new int[]{ 0, 0, 0 });
  ParticleAttractors attrs6 = new ParticleAttractors(new int[]{ 1, 0, 0 });
  ParticleAttractors attrs7 = new ParticleAttractors(new int[]{ 2, 2, 2 });
  ParticleAttractors attrs8 = new ParticleAttractors(new int[]{ 3, 3 });
  
  ParticleAttractors[] attrs = new ParticleAttractors[]{ attrs1, attrs2, attrs3, attrs4, attrs5, attrs6, attrs7, attrs8 };
  
  for (int i = 0; i < NB_PARTICLES; i++) {
    particles[i] = new Particle(
      random(312) + 100, //random(400.0)+312,
      random(312) + 100, //random(400.0)+312,
      random(PI*2f),
      0.5,  // mass
      P_RADIUS,  // radius
      8, // magnetic force of the attraction points
      attrs[floor(random(attrs.length))]  // we give it a random ParticleAttractors from above
    ); 
  }
  
  // we create the UI to render the possible attractors
  atomsUI = new AtomsUI(attrs, NB_TYPES);
  
  // we setup the UI struff
  pauseImg = loadImage("pause.png");
  PFont PTsans;
  PTsans = createFont("PTSerif-Regular.ttf", 32);
  textFont(PTsans, 18);
  
  size(512, 512); 
}

// returns true if the types are adjacent on the repulsion circle
boolean areTypesRepelled (int t1, int t2) {
  if (t1 == t2) return false;
  if (t1 == 0 && t2 == NB_TYPES-1) return true;
  if (t2 == 0 && t1 == NB_TYPES-1) return true;
  return abs(t1-t2) == 1;
}

void drawVector (PVector V, float x, float y, int[] col) {
   stroke(col[0], col[1], col[2], 90);
   strokeWeight(2);
   pushMatrix();
   translate(x, y);
   float ang = atan2(V.y, V.x) + PI;
   line(0, 0, V.x, V.y);
   line(V.x, V.y, V.x + cos(ang+PI*.2) * 10, V.y + sin(ang+PI*.2) * 10);
   line(V.x, V.y, V.x + cos(ang-PI*.2) * 10, V.y + sin(ang-PI*.2) * 10);
   popMatrix();
}

void draw () {
  // we reset
  background(0);
  hovered = -1;
  
  pushMatrix();
  translate(camera.x, camera.y);
  
  // useful
  PVector mouse = new PVector(mouseX, mouseY);
  PVector mouseT = mouse.copy().sub(camera);
  
  for (int i = 0; i < particles.length; i++) {
    
     if (!paused && i != moved) {
       for (int j = 0; j < particles.length; j++) {
          if (i != j) {  // ignore self to self
            Particle p1 = particles[i];
            Particle p2 = particles[j];
            
            if (p1.position.copy().sub(p2.position).mag() < P_RADIUS * 4) {
            
              // we go through the attraction points of the both particles
              for (int ai = 0; ai < p1.attractors.nb; ai++) {
                for (int aj = 0; aj < p2.attractors.nb; aj++) {
                  boolean repelled = areTypesRepelled(p1.attractors.types[ai], p2.attractors.types[aj]);
                  
                  // if the attractors are of the same type
                  if (p1.attractors.types[ai] == p2.attractors.types[aj] || repelled) {
                    // first we find the force between the attraction points
                    PVector p1attr = p1.getAttrWPos(ai);
                    PVector F = p2.getAttrWPos(aj).sub(p1attr);
                    float d = F.mag();
                    F.normalize();
                    if (i == selected) {
                      drawVector(F.copy().mult(50), p1attr.x, p1attr.y, getColorFromType(p1.attractors.types[ai]));
                    }
                    F.mult((p1.magn*p2.magn)/(d*d));
                    F.mult(repelled ? -.3 : 1);
                    
                    // we compute the torque
                    float theta = atan2(F.y, F.x) + PI - (p1.angle + p1.attractors.getAttractorAngle(ai));
                    float torq = (attrDistCenter * p1.radius) * F.mag() * sin(-theta);
                    
                    // from which we can find the angular momentum
                    float am = 2.0 * torq / (p1.mass*p1.radius*p1.radius);
                    p1.angVelocity+= am;
                    
                    // now we update the translation motion
                    PVector ca = p2.getAttrWPos(aj).sub(p1.position);
                    ca.normalize();
                    ca.mult(F.mag() - abs(F.mag() * sin(-theta)));
                    ca.mult(repelled ? -.3 : 1);
                    p1.velocity.add(ca);
                  } 
                }
              }
            }
          
            // just add a bit of repulsion between particles
            /*
            PVector dir = p1.position.copy().sub(p2.position);
            float d = dir.mag();
            dir.normalize();
            
            float repF = 0;
            if (d < 40) {
              repF = (1 - d/40) * 1.5;
            }
            PVector rep = dir.mult(repF);
            p1.velocity.add(rep);
            */
          }
       }
       
       // small attraction to the center
       // particles[i].velocity.add(particles[i].position.copy().sub(new PVector(width/2, height/2)).mult(-0.0005));
       
       // if the velocity of a particle is greater than a threshold we cut it
       if (particles[i].velocity.mag() > maxSpeed) {
         particles[i].velocity.normalize();
         particles[i].velocity.mult(maxSpeed);
       }
       
       // same for the angular velocity
       if (abs(particles[i].angVelocity) > 0.1) {
         particles[i].angVelocity = 0.1 * Math.signum(particles[i].angVelocity); 
       }
     } // end pause block
     
     // now the tests for the tooling
     if (mouse.y > 80 ) {
       float dmouse = particles[i].position.copy().sub(mouseT).mag();
       boolean in = dmouse < particles[i].radius;
       if (in) {
         hovered = i;
       }
     }
     
     if (i == moved) {
       particles[i].position.set(mouseT.x, mouseT.y);
       particles[i].velocity.mult(0);
     }
  }
  
  if (mouseButton == LEFT) {
    selected = hovered;
    
    if (dragging) {
      camera.add(mouse.copy().sub(lastDragPos).mult(.5));
      lastDragPos = mouse;
    }
    
    // we handle the drag control
    if (hovered == -1 && !dragging) {
      dragging = true;
      lastDragPos.set(mouseX, mouseY);
    }
  } else {
     dragging = false; 
  }
  
  if (mouseButton == RIGHT && moved == -1) {
    moved = hovered;
  }
  
  if (mousePressed) {
    moved = -1; 
  }
  
  if (!paused) {
    // collision detection 
    collisions();
  }
    
  // now we can update 
  for (int i = 0; i < particles.length; i++) {
    if (!paused) {
      particles[i].update();
      particles[i].friction();
    }
    particles[i].draw(hovered == i, selected == i, true);
  }
  
  // we add rotation to the selected particle if r is pressed
  if (selected != -1 && keyPressed && key == 'r') {
    particles[selected].angle+= 0.2; 
  }
  
  popMatrix();
  
  // draw the UI
  atomsUI.draw();
  drawUI();
}


void drawUI () {
  if (paused) image(pauseImg, 15, 460, 32, 32);
}



void collisions () {  
  for (int i = 0; i < particles.length; i++) {
    for (int j = 0; j < particles.length; j++) {
      // first, we compute the positions after the application of the velocity
      PVector pos1end = particles[i].position.copy().add(particles[i].velocity);
      PVector dirend = pos1end.copy().sub(particles[j].position);
      float dend = dirend.mag();  // distance at the end of position update 
      dirend.normalize();
      
      if (i != j) { // prevents self to self collision
        // is there a collision between the 2 particles after the update ?
        if (dend < particles[i].radius + particles[j].radius) {          
          // for how much distance is the particle within the other ?
          float din = particles[i].radius + particles[j].radius - dend;
          
          // dirend is the vector between the particles center
          PVector vmove = dirend.copy().mult(din/* * particles[i].velocity.mag()*/);
          if (vmove.mag() > maxCol) {
             vmove.normalize();
             vmove.mult(maxCol);
          }
          particles[i].velocity.add(vmove);
          
          // this kinda emulates the transfer of energy
          particles[j].velocity.add(vmove.mult(-0.5));
        }
      }
    }
  }  
}


void keyPressed () {
  if (key == ' ') {
    paused = !paused; 
  }
  if (key == DELETE && selected != -1) {
    deleteParticle(selected);
    selected = -1;
  }
  if (key == 'a' && atomsUI.selected != -1) {
    addParticle(mouseX-camera.x, mouseY-camera.y, atomsUI.attractors[atomsUI.selected]);
  }
  if (key == ENTER) {
    particles = new Particle[0]; 
  }
}

void addParticle (float x, float y, ParticleAttractors attractors) {
  Particle[] nPts = new Particle[particles.length+1];
  for (int i = 0; i < particles.length; i++) {
    nPts[i] = particles[i]; 
  }
  nPts[nPts.length-1] = new Particle(
    x,
    y,
    random(PI*2f),
    0.5,  // mass
    P_RADIUS,  // radius
    8, // magnetic force of the attraction points
    attractors
  );
  particles = nPts;
}

void deleteParticle (int idx) {
   Particle[] nPts = new Particle[particles.length-1];
   int c = 0;
   for (int i = 0; i < particles.length; i++) {
     if (idx != i) {
       nPts[c++] = particles[i]; 
     }
   }
   particles = nPts;
}
