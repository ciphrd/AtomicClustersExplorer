/**
 * UI Layer ID: 5
 *
 **/
 
int PANEL_ATOM_WIDTH = 400;
int PANEL_ATOM_HEIGHT = 400;
int PANEL_ATOM_RADIUS = 90;
int PANEL_ATOM_NB_H = 60;
int PANEL_ATOM_BUTTON_H = 50;
int PANEL_ATOM_CHARGES_SEL_W = 120;
int PANEL_ATOM_CHARGES_SEL_RAD = 10;

ParticleAttractors PANEL_ATOM_DEF_ATTR = new ParticleAttractors(new int[]{ 0, 0, 0 });

 
class PanelAtoms {
  PVector position;
  ParticleAttractors currentAtom;
  PVector atomCenter;
  int nChargesHovered;
  int atomChargeHovered;
  int atomChargeSelected = 0;
  int chargeSelHovered;
  boolean buttonHovered;
  
  public PanelAtoms () {
    position = new PVector(
      (width-PANEL_ATOM_WIDTH) / 2,
      (height-PANEL_ATOM_HEIGHT) / 2
    );
    currentAtom = PANEL_ATOM_DEF_ATTR;
    atomCenter = new PVector(
      PANEL_ATOM_RADIUS + UI_PADDING*4,
      (PANEL_ATOM_HEIGHT-20-PANEL_ATOM_BUTTON_H-PANEL_ATOM_NB_H) / 2 + 20
    );
  }
  
  // updates the current atom so that its attractors are 
  private void updateCurrentAtom (int nb) {
    // we build the types array
    int[] types = new int[nb];
    for (int i = 0; i < nb; i++) {
      types[i] = currentAtom.nb > i ? currentAtom.types[i] : 0;
    }
    
    ParticleAttractors nAtom = new ParticleAttractors(types);
    currentAtom = nAtom;
    
    if (atomChargeSelected+1 > nAtom.nb) {
      atomChargeSelected = nAtom.nb - 1; 
    }
  }
  
  public void update () {
    nChargesHovered = -1;
    atomChargeHovered = -1;
    chargeSelHovered = -1;
    buttonHovered = false;
    
    if (activeUI == 5) {
      PVector mousePanel = mouse.copy().sub(new PVector(position.x, position.y));
      
      if (activeUIEvents < 5 && mousePanel.x > 0 && mousePanel.x < PANEL_ATOM_WIDTH
        && mousePanel.y > 0 && mousePanel.y < PANEL_ATOM_HEIGHT) {
        activeUIEvents = 5;
        
        // we detect in which part of the popin we are
        if (mousePanel.y > PANEL_ATOM_HEIGHT - PANEL_ATOM_BUTTON_H - PANEL_ATOM_NB_H && mousePanel.y < PANEL_ATOM_HEIGHT - PANEL_ATOM_BUTTON_H
          && mousePanel.x < PANEL_ATOM_WIDTH - 100) {
          // we are in the charges section
          int cw = (PANEL_ATOM_WIDTH-100) / 4;
          for (int i = 0; i < 4; i++) {
            if (mousePanel.x > cw * i && mousePanel.x < cw * (i+1)) {
              nChargesHovered = i;
              break;
            }
          }
        }
        // test for the atom && the charges selection
        else if (mousePanel.y > 20 && mousePanel.y < PANEL_ATOM_HEIGHT - PANEL_ATOM_BUTTON_H - PANEL_ATOM_NB_H) {
          // x can tell if we're on the atom or on the charges
          if (mousePanel.x < PANEL_ATOM_WIDTH - PANEL_ATOM_CHARGES_SEL_W) {  // atom
            // now we can finally detect in which section of the circle we are, to know which charge is hovered
            PVector dir = mousePanel.copy().sub(atomCenter);
            if (dir.mag() < PANEL_ATOM_RADIUS + 20) {
              float da = TWO_PI / currentAtom.nb;
              float a = (atan2(dir.y, dir.x) + TWO_PI + da/2) % TWO_PI;
              atomChargeHovered = int(a/da);
            }
          }
          else { // cursor is over the charges area
            mousePanel.sub(new PVector(PANEL_ATOM_WIDTH - PANEL_ATOM_CHARGES_SEL_W/2, 65));
            
            // now test the collision with the circles
            for (int i = 0; i < attractorsManager.nbTypes; i++) {
               float y = i*(PANEL_ATOM_CHARGES_SEL_RAD*2+5);
               PVector pos = new PVector(0, y);
               pos.sub(mousePanel);
               if (pos.mag() <= PANEL_ATOM_CHARGES_SEL_RAD) {
                 chargeSelHovered = i;
                 break;
               }
            }
          }
        }
        // test for the button
        else if (mousePanel.y > PANEL_ATOM_HEIGHT - PANEL_ATOM_BUTTON_H) {
          buttonHovered = true;
        }
      }
    }
  }
  
  public void mousePressed () {
    if (activeUIEvents == 5) {
      if (nChargesHovered != -1) {
        if (nChargesHovered+1 != currentAtom.nb) {
          // update of the current atom  
          updateCurrentAtom(nChargesHovered+1);
        }
      } else if (atomChargeHovered != -1) {
        atomChargeSelected = atomChargeHovered; 
      } else if (chargeSelHovered != -1) {
        currentAtom.types[atomChargeSelected] = chargeSelHovered;
      } else if (buttonHovered) {
        int[] cp = new int[currentAtom.types.length];
        for (int i = 0; i < cp.length; i++)
          cp[i] = currentAtom.types[i];
        
        ParticleAttractors newPa = new ParticleAttractors(cp);
        attractorsManager.addAttractor(newPa);
      }
    }
  }
  
  public void draw () {
    if (activeUI == 5) {
      pushMatrix();
      translate(position.x, position.y);
      
      fill(0, 0, 0, 210);
      stroke(255, 255, 255, 120);
      rect(0, 0, PANEL_ATOM_WIDTH, PANEL_ATOM_HEIGHT);
      
      fill(255);
      textAlign(LEFT, TOP);
      text("Create a new atom and add it to the toolbar", UI_PADDING, 3);
      
      drawAtom();
      drawChargesNumber();
      drawChargeSelection();
      drawButton();
      
      popMatrix();
    }
  }
  
  private void drawAtom () {
    pushMatrix();
    translate(atomCenter.x, atomCenter.y);
    
    noFill();
    stroke(128);
    strokeWeight(4);
    circle(0, 0, PANEL_ATOM_RADIUS*2);
    
    // now the attractors
    PVector pos = new PVector(0, 0);
    int[] col;
    for (int i = 0; i < currentAtom.nb; i++) {
      float a = currentAtom.getAttractorAngle(i);
      col = getColorFromType(currentAtom.types[i]);
      pos.set(
        cos(a) * PANEL_ATOM_RADIUS,
        sin(a) * PANEL_ATOM_RADIUS
      );
      // draw the line
      strokeWeight(7);
      stroke(col[0], col[1], col[2]);
      line(0, 0, pos.x, pos.y);
      
      strokeWeight(4);
      if (atomChargeSelected == i) {
        stroke(0, 255, 0);
      } else if (atomChargeHovered == i) {
        stroke(255, 255, 0); 
      } else {
        stroke(128);
      }
      fill(col[0], col[1], col[2]);
      circle(
        pos.x,
        pos.y,
        30
      );
      if (atomChargeSelected == i) {
        noFill();
        stroke(0);
        strokeWeight(1);
        circle(
          pos.x,
          pos.y,
          30
        );
      }
    }
    
    // and finally the center
    noStroke();
    fill(255);
    circle(0, 0, 40);
    
    popMatrix();
  }
  
  private void drawCharge (int idx, boolean active, boolean hovered) {
    pushMatrix();
    translate((PANEL_ATOM_WIDTH-100) / 4 * (idx+.5), PANEL_ATOM_NB_H / 2);
    
    noFill();
    strokeWeight(2);
    if (active) 
      stroke(0, 255, 0);
    else if (hovered)
      stroke(255, 255, 0);
    else
      stroke(128);
    circle(0, 0, 40);
    
    // now we draw the charges
    float da = TWO_PI / (idx+1);
    noStroke();
    if (active) 
      fill(0, 255, 0);
    else if (hovered)
      fill(255, 255, 0);
    else
      fill(128);
    for (int i = 0; i < idx+1; i++) {
      float a = da * i;
      circle(cos(a)*20, sin(a)*20, 11);
    }
    
    popMatrix();
  }
  
  private void drawChargesNumber () {
    pushMatrix();
    translate(0, PANEL_ATOM_HEIGHT - PANEL_ATOM_BUTTON_H - PANEL_ATOM_NB_H);
    
    stroke(50);
    strokeWeight(1);
    line(0, -UI_PADDING, PANEL_ATOM_WIDTH, -UI_PADDING);
    
    for (int i = 0; i < 4; i++) {
      drawCharge(i, i == currentAtom.nb-1, i == nChargesHovered); 
    }
    
    fill(255);
    textAlign(LEFT, CENTER);
    text("Number of\ncharges", PANEL_ATOM_WIDTH-90, PANEL_ATOM_NB_H/2);
    
    popMatrix();
  }
  
  private void drawChargeSelection () {
    pushMatrix();
    translate(PANEL_ATOM_WIDTH - PANEL_ATOM_CHARGES_SEL_W/2, 65);
    
    int[] col;
    for (int i = 0; i < 8; i++) {
      col = getColorFromType(i);
      int alpha = 255;
      strokeWeight(3);
      if (i+1 > attractorsManager.nbTypes) {
        strokeWeight(0);
        alpha = 30;
      }
      if (i == currentAtom.types[atomChargeSelected]) {
        stroke(0, 255, 0);
      } else {
        stroke(128, 128, 128, alpha);
      }
      fill(col[0], col[1], col[2], alpha);
      circle(0, i*(PANEL_ATOM_CHARGES_SEL_RAD*2+5), PANEL_ATOM_CHARGES_SEL_RAD*2);
      if (i == currentAtom.types[atomChargeSelected]) {
        noFill();
        stroke(0);
        strokeWeight(1);
        circle(
          0,
          i*(PANEL_ATOM_CHARGES_SEL_RAD*2+5),
          PANEL_ATOM_CHARGES_SEL_RAD*2
        );
      }
    }
    
    popMatrix();
  }
  
  private void drawButton () {
    if (buttonHovered) {
      fill(0, 200, 80);
    } else { 
      fill(0, 128, 50);
    }
    noStroke();
    rect(0, PANEL_ATOM_HEIGHT - PANEL_ATOM_BUTTON_H + UI_PADDING, PANEL_ATOM_WIDTH, PANEL_ATOM_BUTTON_H - UI_PADDING);
    
    fill(255);
    textAlign(CENTER, CENTER);
    text("Add ATOM to the atoms bar", PANEL_ATOM_WIDTH/2, PANEL_ATOM_HEIGHT - (PANEL_ATOM_BUTTON_H - UI_PADDING/2) / 2);
  }
}
