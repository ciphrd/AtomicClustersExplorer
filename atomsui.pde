/**
 * The AtomsUI can be used to display atoms on an interface
 **/
 
class AtomsUI {
  // the attractors list to display
  Particle[] particles;
  public int selected;
  
  public AtomsUI () {
    particles = createParticlesFromAttractors();
    selected = -1;
  }
  
  private Particle[] createParticlesFromAttractors () {
    Particle[] pts = new Particle[attractorsManager.attractors.length];
    
    // loop through the attractors to create UI particles from the data
    for (int i = 0; i < attractorsManager.attractors.length; i++) {
      pts[i] = new Particle(
        i * 42 + 28,
        30,
        0,    // angle
        0.5,  // mass
        18,  // radius
        12, // magnetic force of the attraction points
        attractorsManager.attractors[i]
      ); 
    }
    
    return pts;
  }
  
  public void draw () {
    // we add some events here because this is called on every frame
    if (mouse.y < 80) {
      int hover = -1;
      for (int i = 0; i < particles.length; i++) {
        float dmouse = particles[i].position.copy().sub(mouse).mag();
        boolean in = dmouse < particles[i].radius;
        if (in) {
          hover = i;
        }
      }
      
      if (mousePressed) {
        selected = hover; 
      }
    }
    
    // the background
    noStroke();
    fill(0, 0, 0, 120);
    rect(0, 0, 512, 80);
    
    // the line
    strokeWeight(1);
    stroke(255, 255, 255, 50);
    line(0, 80, 512, 80);
    
    // the particles
    for (int i = 0; i < particles.length; i++) {
      particles[i].draw(false, selected == i); 
    }
    
    // infos
    textSize(14);
    textLeading(18);
    textAlign(LEFT, BOTTOM);
    text("Possible configurations", 10, 77);
    text("Subatomic particles", 380, 77);
    
    // atoms types
    stroke(255, 255, 255, 60);
    circle(480, 32, 40);
    noStroke();
    float dAngle = TWO_PI / attractorsManager.nbTypes;
    for (int i = 0; i < attractorsManager.nbTypes; i++) {
      int[] col = getColorFromType(i);
      fill(col[0], col[1], col[2]);
      circle(
        cos(dAngle*i) * 20 + 480,
        sin(dAngle*i) * 20 + 32,
        9
      );
    }
  }
}
