/**
 * UI Layer ID: 2
 * The toolbar is the component displayed in the bottom.
 * The buttons can open associated panels.
 *
 **/
 

PImage slidersImg;
PImage atomsImg;
PImage keyboardImg;
PImage[] icons;

int TOOLBAR_ITEM_WIDTH = 32;
int TOOLBAR_MARGIN_ITEMS = 7;
int TOOLBAR_BORDER_MARGIN = 10;

class Toolbar {
  public int active;
  public PVector size;
  int hovered = -1;
  
  public Toolbar () {
    // we first load the icons
    slidersImg = loadImage("controls.png");
    atomsImg = loadImage("atoms.png");
    keyboardImg = loadImage("keyboard.png");
    icons = new PImage[]{ slidersImg, atomsImg, keyboardImg };
    active = -1;
    size = getToolbarSize();
  }
  
  private void setActiveUIFromToolbarID (int id) {
    switch (id) {
      case 0:
        activeUI = 3;
        break;
      case 1:
        activeUI = 5;
        break;
      case 2:
        activeUI = 6;
        break;
      default:
        activeUI = 0;
        break;
    }
  }
  
  PVector getCircleCoord (int idx) {
    return new PVector(
      width - TOOLBAR_ITEM_WIDTH / 2 - TOOLBAR_BORDER_MARGIN - (TOOLBAR_ITEM_WIDTH + TOOLBAR_BORDER_MARGIN)*idx,
      height - TOOLBAR_ITEM_WIDTH / 2 - TOOLBAR_BORDER_MARGIN
    );
  }
  
  PVector getIconCoord (int idx) {
    return new PVector(
      width - TOOLBAR_BORDER_MARGIN - 26 - (TOOLBAR_ITEM_WIDTH + TOOLBAR_BORDER_MARGIN)*idx, // because image is 20px, 32-20 = 12, to center 6
      height - TOOLBAR_BORDER_MARGIN - 26
    );
  }
  
  PVector getToolbarSize () {
    return new PVector(
      (TOOLBAR_ITEM_WIDTH + TOOLBAR_MARGIN_ITEMS) * icons.length + TOOLBAR_BORDER_MARGIN * 2,
      TOOLBAR_ITEM_WIDTH + TOOLBAR_BORDER_MARGIN * 2
    );
  }
  
  void mousePressed () {
    if (hovered != -1) {
      active = active == hovered ? -1 : hovered;
      setActiveUIFromToolbarID(active);
    }
  }
  
  public void update () {
    // reset stuff
    hovered = -1;
    
    // at first we detect if the mouse is in the toolbar
    if (activeUIEvents < 2 && mouse.x > width - size.x && mouse.y > height - size.y) {
      activeUIEvents = 2;
      // here we can test if the mouse is inside an item
      for (int i = 0; i < icons.length; i++) {
        PVector coord = getCircleCoord(i);
        if (mouse.copy().sub(coord).mag() <= TOOLBAR_ITEM_WIDTH/2 + 2) {
          hovered = i;
          break;
        }
      }
    }
  }
  
  public void draw () {
    fill(0, 0, 0, 180);
    
    // background
    stroke(255, 255, 255, 120);
    rect(width - size.x, height - size.y, size.x, size.y);
    
    for (int i = 0; i < icons.length; i++) {
      PVector coord = getCircleCoord(i);
      
      // we set the color based on the state of the item
      if (active == i) stroke(0, 255, 0, 180);
      else if (hovered == i) stroke(255, 255, 0, 180);
      else stroke(255, 255, 255, 180);
      
      circle(coord.x, coord.y, TOOLBAR_ITEM_WIDTH);
      coord = getIconCoord(i);
      image(icons[i], coord.x, coord.y);
    }
  }
}
