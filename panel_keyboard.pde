/**
 * UI Layer ID: 6
 * Displays the keyboard shortcuts
 **/


int PANEL_KB_WIDTH = 700;
int PANEL_KB_ENTRY_H = 30;
int PANEL_NB_COL1_W = 130;

String[] PANEL_KB_SHORTCUTS = new String[]{
  "MOUSE_LEFT",
  "MOUSE_RIGHT",
  "MOUSE_WHEEL",
  "SPACE",
  "DEL",
  "ENTER",
  "a",
  "d",
  "r",
};

String[] PANEL_KB_INTEL = new String[]{
  "On atom: select / Otherwise: add selected toolbar atom",
  "Move atom under cursor, left click to release",
  "Adjust zoom level",
  "Pause/Start simulation",
  "Delete selected atom",
  "Delete all atoms",
  "Add many selected toolbar atoms",
  "Deselect the selected atom",
  "Rotate selected atom",
};


class PanelKeyboard {
  int panelHeight;
  PVector position;
  
  public PanelKeyboard () {
    panelHeight = 40 + PANEL_KB_ENTRY_H * PANEL_KB_SHORTCUTS.length;
    position = new PVector(
      (width - PANEL_KB_WIDTH) / 2,
      (height - panelHeight) / 2
    );
  }
  
  public void update () {
    if (activeUI == 6) {
      if (activeUIEvents < 6 && mouse.x > position.x && mouse.x < position.x + PANEL_KB_WIDTH
        && mouse.y > position.y && mouse.y < position.y + panelHeight) {
        activeUIEvents = 6;
      }
    }
  }
  
  public void draw () {
    if (activeUI == 6) {
      pushMatrix();
      translate(position.x, position.y);
      
      fill(0, 0, 0, 210);
      stroke(255, 255, 255, 120);
      rect(0, 0, PANEL_KB_WIDTH, panelHeight);
      
      fill(255);
      textAlign(CENTER, TOP);
      text("Keyboard / mouse controls", PANEL_KB_WIDTH / 2, 10);
      
      // now we can draw the controls
      translate(0, 40);
      textAlign(LEFT, CENTER);
      strokeWeight(1);
      stroke(50);
      for (int i = 0; i < PANEL_KB_SHORTCUTS.length; i++) {
        text(PANEL_KB_SHORTCUTS[i], UI_PADDING, (i+.5) * PANEL_KB_ENTRY_H);
        text(PANEL_KB_INTEL[i] , UI_PADDING + PANEL_NB_COL1_W, (i+.5) * PANEL_KB_ENTRY_H);
        line(1, i * PANEL_KB_ENTRY_H, PANEL_KB_WIDTH-2, i * PANEL_KB_ENTRY_H);
      }
      
      // vertical separator
      line(
        UI_PADDING + PANEL_NB_COL1_W - UI_PADDING,
        0, 
        UI_PADDING + PANEL_NB_COL1_W - UI_PADDING, 
        panelHeight - 40
      );
      
      popMatrix();
    }
  }
}
