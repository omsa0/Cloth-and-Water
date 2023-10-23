// ==============
// Particle struct
// ==============
class Particle {
  Vec2 pos;
  Vec2 vel;
  Vec2 oldPos;
  double press, dens;
  double pressN, densN;
  boolean grabbed;

  Particle(Vec2 pos) {
    this.pos = pos;
    this.vel = new Vec2(0, 0);
    this.oldPos = pos;
    this.press = 0.0;
    this.dens = 0.0;
    this.pressN = 0.0;
    this.densN = 0.0;
    this.grabbed = false;
  }
}

// ==============
// Pair struct
// ==============
class Pair {
  Particle p1, p2;
  double q, q2, q3;

  Pair(Particle p1, Particle p2, double q) {
    this.p1 = p1;
    this.p2 = p2;
    this.q = q;
    this.q2 = q*q;
    this.q3 = q*q*q;
  }
}
