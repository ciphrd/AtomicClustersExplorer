/**
 * UI Layer ID: 5
 * Can edit the number of charges of the universe
 *
 * Could be reworked into sub classes but hey
 **/


int CHARGES_PANEL_WIDTH = 400;
int CHARGES_PANEL_HEIGHT = 80;
int CHARGES_PANEL_C_RADIUS = 25;
int CHARGES_PANEL_PADDING = 25;

int[] CHARGES_PANEL_C1 = new int[]{ 255, 255, 255 };
int[] CHARGES_PANEL_C2 = new int[]{ 0, 255, 0 };


class ChargesPanel {
  PVector position;
  int chargeWidth;
  int hovered;

  public ChargesPanel () {
    position = new PVector(
      (width - CHARGES_PANEL_WIDTH) / 2, 
      (height - CHARGES_PANEL_HEIGHT) / 2
    );
    chargeWidth = (CHARGES_PANEL_WIDTH-CHARGES_PANEL_PADDING) / MAX_CHARGES;
  }
  
  private void drawCharge (int idx) {
    PVector center = new PVector(
      chargeWidth * idx + CHARGES_PANEL_PADDING + CHARGES_PANEL_C_RADIUS/2,
      48
    );
    int[] col = getColorFromType(idx);
    fill(col[0], col[1], col[2]);
    noStroke();
    circle(center.x, center.y, CHARGES_PANEL_C_RADIUS);
  }

  private void drawRange (int nb, int[] col) {
    stroke(col[0], col[1], col[2]);
    noFill();
    rect(
      10,
      25,
      chargeWidth * nb + 5,
      45
    );
  }

  public void update () {
    hovered = -1;
    if (activeUI == 5) {
      // at first we detect if the mouse is in the toolbar
      if (activeUIEvents < 5 && mouse.x > position.x && mouse.x < position.x + CHARGES_PANEL_WIDTH
        && mouse.y > position.y && mouse.y < position.y + CHARGES_PANEL_HEIGHT) {
        activeUIEvents = 5;
        
        // we try fo find which one is hovered
        PVector pos = new PVector();
        for (int i = 0; i < MAX_CHARGES; i++) {
          fill(255, 0, 0);
          pos.set(
            position.x + i * chargeWidth + 14,
            position.y + 25
          );
          if (mouse.x > pos.x && mouse.x < pos.x + chargeWidth +1 && mouse.y > pos.y && mouse.y < pos.y + 45) {
            hovered = i;
            break;
          }
        }
      }
    }
  }

  public void draw () {
    if (activeUI == 5) { // if it is selected in the menu 
      pushMatrix();
      translate(position.x, position.y);
      
      // the background/border of the popin
      fill(0, 0, 0, 210);
      stroke(255, 255, 255, 120);
      rect(0, 0, CHARGES_PANEL_WIDTH, CHARGES_PANEL_HEIGHT);

      fill(255);
      textAlign(LEFT, TOP);
      text("Subatomic particles - set the number available in this universe", UI_PADDING, 3);
      for (int i = 0; i < MAX_CHARGES; i++) {
        drawCharge(i); 
      }
      // the current number of charges displayed
      drawRange(attractorsManager.nbTypes, CHARGES_PANEL_C1);
      if (hovered != -1) drawRange(hovered+1, CHARGES_PANEL_C2);
      
      popMatrix();
    }
  }
  
  public void mousePressed () {
    if (activeUI == 5 && hovered != -1) { 
      attractorsManager.nbTypes = hovered + 1;
    }
  }
}
