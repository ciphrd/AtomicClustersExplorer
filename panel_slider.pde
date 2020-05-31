/**
 * UI Layer ID: 3
 **/
 
boolean drawAttractionRange = false;

int SLIDERS_PANEL_WIDTH = 200;
int SLIDER_HEIGHT = 40;
int SLIDER_PADDING = 5;


String[] SLIDERS_TEXT = new String[]{
  "Max speed",
  "Magnetic strength",
  "Attraction range",
  "Col transfer energy",
  "Attraction strength",
  "RepulsionStrength",
};

float[] SLIDERS_MINS = new float[]{
  1.0,      // max speed,
  0.0,      // magnetic strength
  2.0,      // attraction range
  0.0,      // collision transfer energy
  0.0,      // attraction strength,
  0.0,      // repulsion strength
};

float[] SLIDERS_MAXS = new float[]{
  20.0,     // max speed
  4.0,      // magnetic strength
  10.0,     // attraction range
  1.2,      // collision transfer energy
  4.0,      // attraction strength
  4.0,      // repulsion strength
};


class SlidersPanel {
  int panelHeight;
  PVector position;
  PVector sliderSize;
  int hovered; // if a slider is hovered
  
  public SlidersPanel () {
    panelHeight = SLIDER_HEIGHT * SLIDERS_TEXT.length;
    position = new PVector(
      width - SLIDERS_PANEL_WIDTH,
      height - toolbar.size.y - panelHeight - 2
    );
    sliderSize = new PVector(
      SLIDERS_PANEL_WIDTH - SLIDER_PADDING*2 - 50,
      (SLIDER_HEIGHT-SLIDER_PADDING*2) / 2
    );
  }
  
  void updateConfigValue (int idx, float value) {
    switch (idx) {
      case 0:  // max speed
        config.maxSpeed = value;
        break;
      case 1:  // magnetic strength
        config.magneticStrength = value;
        break;
      case 2:  // attraction range
        config.attractionRange = value;
        break;
      case 3:  // collision transfer energy
        config.colTransferEnergy = value;
        break;
      case 4:  // attraction strength
        config.attractionStrength = value;
        break;
      case 5:  // repulsion strength
        config.repulsionStrength = value;
        break;
    }
  }
  
  float getParameterValue (int idx, float t) {
    return lerp(SLIDERS_MINS[idx], SLIDERS_MAXS[idx], t); 
  }
  
  float getConfigValue (int idx) {
    switch (idx) {
      case 0:  // max speed
        return config.maxSpeed;
      case 1:  // magnetic strength
        return config.magneticStrength;
      case 2:  // attraction range
        return config.attractionRange;
      case 3:  // collision transfer energy
        return config.colTransferEnergy;
      case 4:  // attraction strength
        return config.attractionStrength;
      case 5:  // repulsion strength
        return config.repulsionStrength;
    }
    
    return 0;
  }
  
  public void update () {
    drawAttractionRange = false;
    
    if (activeUI == 3) {
      hovered = -1;
      
      // check if the mouse is over the panel first
      if (activeUIEvents < 3 && mouse.x > position.x && mouse.y > position.y && mouse.y < position.y + panelHeight) {
        activeUIEvents = 3;
        
        // now we can check if the mouse is inside a slider
        for (int i = 0; i < SLIDERS_TEXT.length; i++) {
          PVector containerPos = new PVector(
            position.x + SLIDER_PADDING,
            position.y + i * SLIDER_HEIGHT + SLIDER_PADDING
          );
          
          if (mouse.x > containerPos.x && mouse.x < containerPos.x + sliderSize.x 
            && mouse.y > containerPos.y + sliderSize.y && mouse.y < containerPos.y + 2 * sliderSize.y) {
            hovered = i;
            break;
          }
        }
      }
      
      if (hovered == 2) drawAttractionRange = true;
      
      // if mouse is down, we can update the slider value
      if (mousePressed && hovered != -1) {
        PVector containerPos = new PVector(
          position.x + SLIDER_PADDING,
          position.y + hovered * SLIDER_HEIGHT + SLIDER_PADDING
        );
        float t = (mouse.x-containerPos.x) / sliderSize.x;
        updateConfigValue(hovered, getParameterValue(hovered, t));
      }
    }
  }
  
  public void draw () {
    if (activeUI == 3) {
      fill(0, 0, 0, 180);
      stroke(255, 255, 255, 120);
      rect(position.x, position.y, SLIDERS_PANEL_WIDTH, panelHeight);
      
      // we draw all the sliders + text one by one
      for (int i = 0; i < SLIDERS_TEXT.length; i++) {
        PVector containerPos = new PVector(
          position.x + SLIDER_PADDING,
          position.y + i * SLIDER_HEIGHT + SLIDER_PADDING
        );
        fill(255, 255, 255);
        textAlign(LEFT, TOP);
        text(SLIDERS_TEXT[i], containerPos.x, containerPos.y-4);
        
        // draw the slider
        noStroke();
        fill(128, 128, 128);
        rect(containerPos.x, containerPos.y + sliderSize.y, sliderSize.x, sliderSize.y);
        
        // inner
        fill(0, 255, 0);
        float cfgValue = getConfigValue(i);
        float t = (cfgValue - SLIDERS_MINS[i]) / (SLIDERS_MAXS[i]-SLIDERS_MINS[i]);
        rect(containerPos.x, containerPos.y + sliderSize.y, sliderSize.x * t, sliderSize.y);
        
        // value
        fill(255);
        String cfgValueStr = String.valueOf(cfgValue);
        cfgValueStr = cfgValueStr.substring(0, min(4, cfgValueStr.length()));
        text(cfgValueStr, containerPos.x + sliderSize.x + 5, containerPos.y + sliderSize.y);
      }
    }
  }
}
