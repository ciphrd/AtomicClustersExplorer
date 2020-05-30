/**
 * The attractors manager handles the available attractors, is responsible for the creation aswell
 **/


// This is where the default atoms are defined (defining their attractors is a way to define an atom
ParticleAttractors attrs1 = new ParticleAttractors(new int[]{ 0, 1 });
ParticleAttractors attrs2 = new ParticleAttractors(new int[]{ 1, 2 });
ParticleAttractors attrs3 = new ParticleAttractors(new int[]{ 2, 3 });
ParticleAttractors attrs4 = new ParticleAttractors(new int[]{ 3, 0 });
ParticleAttractors attrs5 = new ParticleAttractors(new int[]{ 0, 0, 0 });
ParticleAttractors attrs6 = new ParticleAttractors(new int[]{ 1, 0, 0 });
ParticleAttractors attrs7 = new ParticleAttractors(new int[]{ 2, 2, 2 });
ParticleAttractors attrs8 = new ParticleAttractors(new int[]{ 3, 3 });

ParticleAttractors[] defaultAttractors = new ParticleAttractors[]{ attrs1, attrs2, attrs3, attrs4, attrs5, attrs6, attrs7, attrs8 };




class AttractorsManager {
  public ParticleAttractors[] attractors;
  public int nbTypes;
  
  public AttractorsManager () {
    // we initialize the attractors with the default ones
    attractors = defaultAttractors;
    
    // find the number of attractors by finding the maximum value in the default attractors
    int maxt = 0;
    for (int i = 0; i < attractors.length; i++) {
      for (int j = 0; j < attractors[i].types.length; j++) {
        maxt = max(maxt, attractors[i].types[j]+1);
      }
    }
    nbTypes = maxt;
  }
  
  // returns true if the types are adjacent on the repulsion circle
  public boolean areTypesRepelled (int t1, int t2) {
    if (t1 == t2) return false;
    if (t1 == 0 && t2 == nbTypes-1) return true;
    if (t2 == 0 && t1 == nbTypes-1) return true;
    return abs(t1-t2) == 1;
  }
}
