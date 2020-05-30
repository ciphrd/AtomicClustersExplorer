// just some utility functions

void drawVector (PVector V, float x, float y, int[] col) {
   stroke(col[0], col[1], col[2], 90);
   strokeWeight(2);
   pushMatrix();
   translate(x, y);
   float ang = atan2(V.y, V.x) + PI;
   line(0, 0, V.x, V.y);
   line(V.x, V.y, V.x + cos(ang+PI*.2) * 10, V.y + sin(ang+PI*.2) * 10);
   line(V.x, V.y, V.x + cos(ang-PI*.2) * 10, V.y + sin(ang-PI*.2) * 10);
   popMatrix();
}
