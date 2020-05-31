/**
 * The AtomsUI can be used to display atoms on an interface
 **/
 
int ATOMS_BAR_HEIGHT = 80;
 
class AtomsUI {
  // the attractors list to display
  Particle[] particles;
  public int selected;
  int hovered;
  boolean subatomHovered;
  
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
  
  public void update () {
    hovered = -1;
    subatomHovered = false;
    // we add some events here because this is called on every frame
    if (mouse.y < 80 && activeUIEvents < 1) {
      activeUIEvents = 1;
      for (int i = 0; i < particles.length; i++) {
        float dmouse = particles[i].position.copy().sub(mouse).mag();
        boolean in = dmouse < particles[i].radius;
        if (in) {
          hovered = i;
          break;
        }
      }
      
      // we try the detection on the right icon
      if (hovered == -1) {
        if (mouse.x > width-120) {
          subatomHovered = true; 
        }
      }
    }
  }
  
  public void mousePressed () {
    if (activeUIEvents == 1) {
      if (hovered != -1) {
        selected = hovered;
      } else if (subatomHovered) {
        activeUI = activeUI != 5 ? 5 : 0; 
      }
    }
  }
  
  public void draw () {
    // the background
    noStroke();
    fill(0, 0, 0, 120);
    rect(0, 0, width, ATOMS_BAR_HEIGHT);
    
    // the line
    strokeWeight(1);
    stroke(255, 255, 255, 50);
    line(0, ATOMS_BAR_HEIGHT, width, ATOMS_BAR_HEIGHT);
    
    // the particles
    for (int i = 0; i < particles.length; i++) {
      particles[i].draw(hovered == i, selected == i, false, false); 
    }
    
    // infos
    textSize(14);
    textLeading(18);
    textAlign(LEFT, BOTTOM);
    text("Possible configurations", 10, ATOMS_BAR_HEIGHT - 3);
    textAlign(RIGHT, BOTTOM);
    if (activeUI == 5) {
      fill(0, 255, 0);
    }
    text("Subatomic particles", width - 10, ATOMS_BAR_HEIGHT - 3);
    
    // atoms types
    if (activeUI == 5) {
      stroke(0, 255, 0);
    } else if (subatomHovered) {
      stroke(255, 255, 0);
    } else {
      stroke(255, 255, 255, 60);
    }
    noFill();
    circle(width - 35, 32, 40);
    noStroke();
    float dAngle = TWO_PI / attractorsManager.nbTypes;
    for (int i = 0; i < attractorsManager.nbTypes; i++) {
      int[] col = getColorFromType(i);
      fill(col[0], col[1], col[2]);
      circle(
        cos(-dAngle*i) * 20 + width - 35,
        sin(-dAngle*i) * 20 + 32,
        9
      );
    }
  }
}
