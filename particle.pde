

// the distance of the attraction points to the center (times the radius)
float attrDistCenter = 0.6f;


int[] getColorFromType (int type) {
  return CHARGE_COLORS[type];
}

public class Particle {
  PVector position;
  PVector velocity;
  public float angle;  // the rotation arround the z axis, rad
  float angVelocity;  // the angular velocity
  float radius;
  float mass;
  float magn; // magnetique strength
  ParticleAttractors attractors;
  
  public Particle (float x, float y, float ang, float m, float rad, float magnetic, ParticleAttractors attrctrs) {
    position = new PVector(x, y);
    velocity = new PVector(0f, 0f);
    
    angle = ang;
    angVelocity = 0f;
    
    radius = rad;
    mass = m;
    magn = magnetic;
    
    attractors = attrctrs;
  }
  
  // attractor world position 
  public PVector getAttrWPos (int idx) {
    PVector ret = getAttrPos(idx);
    ret.add(position);
    return ret;
  }
  
  // attractor position relative to the center
  private PVector getAttrPos (int idx) {
    float attrAngle = attractors.getAttractorAngle(idx);
    
    return new PVector(
      cos(angle + attrAngle) * radius * attrDistCenter,
      sin(angle + attrAngle) * radius * attrDistCenter
    );
  }
  
  public void update () {
     angle+= angVelocity;
     PVector npos = position.copy().add(velocity);
     
     // TO BE REMOVED - smoothening of the position to prevent flickering
     npos.set(lerp(position.x, npos.x, .8), lerp(position.y, npos.y, .8));
     position = npos;
  }
  
  // applies the friction over the angular and linear velocity
  public void friction () {
     angVelocity*= 1 - config.friction;
     velocity.mult(1 - config.friction);
  }
  
  public void draw (boolean hovered, boolean selected, boolean drawRange, boolean drawForces) {
    noFill();
    
    // translate to the center
    pushMatrix();
    translate(position.x, position.y);
    
    // draw its axis
    stroke(50);
    strokeWeight(1);
    line(cos(angle)*radius, sin(angle)*radius, cos(angle+PI)*radius, sin(angle+PI)*radius);
    
    // draw the attraction point
    // draw the attraction points
    noStroke();
    for (int i = 0; i < attractors.nb; i++) {
      int[] col = getColorFromType(attractors.types[i]);
      fill(col[0], col[1], col[2]);
      stroke(col[0], col[1], col[2]);
      strokeWeight(4);
      PVector attrPos = getAttrPos(i);
      line(0, 0, attrPos.x, attrPos.y); 
      circle(attrPos.x, attrPos.y, 4);
    }
    
        
    // draw the center
    fill(255);
    noStroke();
    circle(0, 0, 6);
    
    
    // draw the circle
    noFill();
    if (selected) {
      stroke(0, 255, 0);
    } else if (hovered) {
      stroke(200, 200, 0); 
    } else {
      stroke(50);
    }
    strokeWeight(selected ? 3 : 2);
    circle(0, 0, radius*2f);
    
    // draw the attraction
    if (drawAttractionRange && drawRange) {
      stroke(255, 0, 0, 50);
      circle(0, 0, radius*config.attractionRange*2);
    }
    
    // we draw the velocity 
    if (selected && drawForces) drawVector(velocity.copy().div(config.maxSpeed).mult(10), 0, 0, new int[]{255, 255, 0});
    
    popMatrix();
  }
}
