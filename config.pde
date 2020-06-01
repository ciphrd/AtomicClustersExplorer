/**
 * Easy way to have sort of a global accessible config
 **/
 
// ui config
int UI_PADDING = 7;
int[][] CHARGE_COLORS = new int[][]{
  new int[]{ 255, 0, 0 },
  new int[]{ 0, 0, 255 },
  new int[]{ 0, 255, 0 },
  new int[]{ 255, 255, 0 },
  new int[]{ 0, 255, 255 },
  new int[]{ 255, 0, 255 },
  new int[]{ 0, 128, 255 },
  new int[]{ 80, 255, 128 },
};

// sim config
int MAX_CHARGES = 8; // maximum types of subatomic charges allowed
float MAX_COL_RESPONSE = 8;    // max magnitude of the collisions response


class Config {
  public float maxSpeed = 5.0;
  public float magneticStrength = 1.0;
  public float attractionRange = 4.0;
  public float colTransferEnergy = 0.5;
  public float attractionStrength = 1;
  public float repulsionStrength = .3;
  public float friction = 0.1;
  public float spawnRadius = 12;
}

Config config = new Config();
