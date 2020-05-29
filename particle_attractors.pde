/**
 * The attractions is simply a list of groups.
 * Particles can have up to 5 attraction points, distrubted evenly along a circle of a radius smaller than the particle radius.
 * Each attraction point belongs to a certain type
 **/
 
class ParticleAttractors {
  public int nb;
  public int[] types;
  float deltaAngle; // the angle distance between the points
  
  public ParticleAttractors (int[] _types) {
    nb = _types.length;
    types = _types;
    deltaAngle = TWO_PI / nb;
  }
  
  /**
   * returns the angle of the attractor at a given index
   **/
  public float getAttractorAngle (int idx) {
    return idx * deltaAngle;
  }
}
