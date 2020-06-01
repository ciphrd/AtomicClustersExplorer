/**
 * This class is responsible for handling the particles, storing them, adding, deleting,
 * computing the forces and updating
 **/


// the number of particles at the start of the simulation
int NB_PARTICLES_START = 60;

class ParticlesManager {
  public Particle[] particles;
  
  public ParticlesManager () {
    particles = new Particle[NB_PARTICLES_START];
    
    // initialize the particles
    for (int i = 0; i < particles.length; i++) {
      particles[i] = new Particle(
        random(312) + (width-312)/2, //random(400.0)+312,
        random(312) + (height-312)/2, //random(400.0)+312,
        random(PI*2f),
        0.5,  // mass
        config.spawnRadius,  // radius
        8, // magnetic force of the attraction points
        attractorsManager.attractors[floor(random(attractorsManager.attractors.length))]  // we give it a random ParticleAttractors
      ); 
    }
  }
  
  public void computeVelocities () {    
    // the space transform to allow for pan/zoom
    PVector pan = panZoomManager.getPan();
    float scale = panZoomManager.getScale();
    pushMatrix();
    translate(pan.x, pan.y);
    scale(scale);
  
    for (int i = 0; i < particles.length; i++) {

       if (!paused && i != moved) {
         for (int j = 0; j < particles.length; j++) {
            if (i != j) {  // ignore self to self
              Particle p1 = particles[i];
              Particle p2 = particles[j];
             
              if (p1.position.copy().sub(p2.position).mag() < p1.radius * config.attractionRange) {
              
                // we go through the attraction points of the both particles
                for (int ai = 0; ai < p1.attractors.nb; ai++) {
                  for (int aj = 0; aj < p2.attractors.nb; aj++) {
                    boolean repelled = attractorsManager.areTypesRepelled(p1.attractors.types[ai], p2.attractors.types[aj]);
                    
                    // if the attractors are of the same type
                    if (p1.attractors.types[ai] == p2.attractors.types[aj] || repelled) {
                      // first we find the force between the attraction points
                      PVector p1attr = p1.getAttrWPos(ai);
                      PVector F = p2.getAttrWPos(aj).sub(p1attr);
                      float d = F.mag();
                      F.normalize();
                      if (i == selected) {
                        drawVector(F.copy().mult(50 * (repelled ? -1 : 1)), p1attr.x, p1attr.y, getColorFromType(p2.attractors.types[aj]));
                      }
                      F.mult((p1.magn*p2.magn)/(d*d));
                      F.mult(repelled ? -config.repulsionStrength : config.attractionStrength);
                      F.mult(config.magneticStrength);
                      
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
                      ca.mult(repelled ? -config.repulsionStrength : config.attractionStrength);
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
         if (particles[i].velocity.mag() > config.maxSpeed) {
           particles[i].velocity.normalize();
           particles[i].velocity.mult(config.maxSpeed);
         }
         
         // same for the angular velocity
         if (abs(particles[i].angVelocity) > 0.1) {
           particles[i].angVelocity = 0.1 * Math.signum(particles[i].angVelocity); 
         }
       } // end pause block
       
       // now the tests for the tooling
       if (mouse.y > 80 && activeUIEvents == 0 && hovered == -1) {
         float dmouse = particles[i].position.copy().sub(worldMouse).mag();
         boolean in = dmouse < particles[i].radius;
         if (in) {
           hovered = i;
         }
       }
       
       if (i == moved) {
         particles[i].position.set(worldMouse.x, worldMouse.y);
         particles[i].velocity.mult(0);
       }
    } 
    
    popMatrix();
  }
  
  public void applyCollisions () {
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
            if (vmove.mag() > MAX_COL_RESPONSE) {
               vmove.normalize();
               vmove.mult(MAX_COL_RESPONSE);
            }
            particles[i].velocity.add(vmove);
            
            // this kinda emulates the transfer of energy
            particles[j].velocity.add(vmove.mult(-config.colTransferEnergy));
          }
        }
      }
    }
  }
  
  // updates the particles position and angle, and draws them
  public void update () {
    // space transform to allow for pan / zoom
    PVector pan = panZoomManager.getPan();
    pushMatrix();
    translate(pan.x, pan.y);
    scale(panZoomManager.getScale());
    
    // now we can update 
    for (int i = 0; i < particles.length; i++) {
      if (!paused) {
        particles[i].update();
        particles[i].friction();
      }
      particles[i].draw(hovered == i, selected == i, true, true);
    }
    
    popMatrix();
  }
  
  public void addParticle (float x, float y, ParticleAttractors attractors) {
    Particle[] nPts = new Particle[particles.length+1];
    for (int i = 0; i < particles.length; i++) {
      nPts[i] = particles[i]; 
    }
    nPts[nPts.length-1] = new Particle(
      x,
      y,
      random(PI*2f),
      0.5,  // mass
      config.spawnRadius,  // radius
      8, // magnetic force of the attraction points
      attractors
    );
    particles = nPts;
  }
  
  public void deleteParticle (int idx) {
    Particle[] nPts = new Particle[particles.length-1];
    int c = 0;
    for (int i = 0; i < particles.length; i++) {
      if (idx != i) {
        nPts[c++] = particles[i]; 
      }
    }
    particles = nPts;
  }
  
  // just removes all the particles currently active
  public void reset () {
    particles = new Particle[0];
  }
}
