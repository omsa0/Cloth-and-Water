// ======================================== //<>//
// Usage:
// 1 - press space to unpause
// 2 - press z to reset the simulation
// ========================================

// ==============
// setup
// ==============
void setup() {
  size(1200, 750);
}

// ==============
// Variables
// ==============

// Physics Constants
Vec2 gravity = new Vec2(0, 750);

// Physics Parameters
int sub_steps = 5;

// Obstacles
double or = 170; // Obstacle Radius, same for both
Vec2 op = new Vec2(300, 400); // Obstacle Position

Vec2 op2 = new Vec2(900, 650);

// Particle Properties
int n = 35;
int r = 35;
int maxP = n * r;
int numP = 0;
double rad = 10; //radius, same for all particles
double k_smooth_radius = 28;
double k_stiff = 1500;
double k_stiffN = 100000;
double k_rest_density = 0.2;
double grab_radius = 100;
Particle particles[] = new Particle[maxP];

// ==============
// Physics and Visualization-
// ==============
void update_physics(double dt) {
  //println("================");
  // Integrate velocity & gravity to update positions
  for (int i = 0; i < numP; i++) {
    Particle p = particles[i];
    p.vel = p.pos.minus(p.oldPos).times(1/dt); //Compute vel from positions updated via pressure forces
    p.vel = p.vel.plus(gravity.times(dt)); //Integrate velocity based on gravity
    
    // Wall collision
    if ( p.pos.y > height) { 
      p.pos.y = height;
      p.vel.y *= -0.3;
    }
    if ( p.pos.x < 0) {
      p.pos.x = 0;
      p.vel.x *= -0.3;
    }
    if ( p.pos.x > width) {
      p.pos.x = width;
      p.vel.x *= -0.3;
    }
    
    // Move grabbed particles towards mouse
    if (p.grabbed) {
      Vec2 mousePos = new Vec2(mouseX, mouseY);
      Vec2 toMouse = mousePos.minus(p.pos);
      toMouse.normalize();
      toMouse.mul(frameRate);
      p.vel = p.vel.plus(toMouse); 
    }
    
    // Obstacle 1
    if (p.pos.distanceTo(op) < rad + or) {
      Vec2 normal = (p.pos.minus(op)).normalized();
      p.pos = op.plus(normal.times(or+rad));
      Vec2 velNormal = normal.times(dot(p.vel, normal));
      p.vel.subtract(velNormal.times(1 + 0.4));
    }
    
    // Obstacle 2
    if (p.pos.distanceTo(op2) < rad + or) {
      Vec2 normal = (p.pos.minus(op2)).normalized();
      p.pos = op2.plus(normal.times(or+rad));
      Vec2 velNormal = normal.times(dot(p.vel, normal));
      p.vel.subtract(velNormal.times(1 + 0.4));
    }

    // Integrate position based on velocity
    p.oldPos = new Vec2(p.pos.x, p.pos.y);
    p.pos = p.pos.plus(p.vel.times(dt)); 
    p.dens = 0.0;
    p.densN = 0.0;
  }

  // Find all neighboring particles
  Pair pairs[] = new Pair[numP*numP];
  int currIndex = 0;
  
  for (int i = 0; i < numP; i++) {
    for (int j = i+1; j < numP; j++) {
      double dist = particles[i].pos.distanceTo(particles[j].pos);
      if (dist < k_smooth_radius && i != j) {
        double q = 1 - (dist/k_smooth_radius);
        pairs[currIndex] = new Pair(particles[i], particles[j], q);
        currIndex++;
      }
    }
  }

  // Accumulate per-particle density
  for (int i = 0; i < currIndex; i++) {
    Pair p = pairs[i];
    p.p1.dens += p.q2;
    p.p2.dens += p.q2;
    p.p1.densN += p.q3;
    p.p2.densN += p.q3;
  }

  // Compute per-particle pressure: stiffness*(density - rest_density)
  for (int i = 0; i < numP; i++) {
    Particle p = particles[i];
    p.press = k_stiff*(p.dens - k_rest_density);
    p.pressN = k_stiffN*(p.densN);
    if (p.press > 300) p.press = 300;      // maximum pressure
    if (p.pressN > 30000) p.pressN = 30000;  // maximum near pressure
    //println(p.dens, p.densN);
  }
  
  // Move particles based on pressure
  for (int i = 0; i < currIndex; i++) {
    Pair pair = pairs[i];
    Particle a = pair.p1;
    Particle b = pair.p2;
    double total_pressure = (a.press + b.press) * pair.q + (a.pressN + b.pressN) * pair.q2;
    double displace = total_pressure * (dt*dt);

    Vec2 move1 = a.pos.minus(b.pos);
    move1.normalize();
    move1 = move1.times(displace);
    a.pos.add(move1);

    Vec2 move2 = b.pos.minus(a.pos);
    move2.normalize();
    move2 = move2.times(displace);
    b.pos.add(move2);
  }
}

boolean paused = false;
void keyPressed()
{
  if (key == 'z') {
    numP = 0;
  }
  if (key == ' ') {
    paused = !paused;
  }
}

void mouseDragged() {
  Vec2 mousePos = new Vec2(mouseX, mouseY);
  for (int i = 0; i < numP; i++) {
    Particle p = particles[i];
    if (mousePos.distanceTo(p.pos) < grab_radius) {
      p.grabbed = true;
    }
  }
}

void mouseReleased() {
  for (int i = 0; i < numP; i++) {
    Particle p = particles[i];
    p.grabbed = false;
  }
}

void draw() {
  double dt = 1/frameRate;
  background(0);
  noStroke();
  
  //println("fps:", frameRate);
  if (!paused) {
    // Particle Generation
    double genRate = 300;
    double toGen_float = genRate * dt;
    int toGen = (int)toGen_float;
    double fractPart = toGen_float - toGen;
    if (random(1) < fractPart) toGen += 1;
    for (int i = 0; i < toGen; i++){
      if (numP >= maxP) break;
      particles[numP] = new Particle(new Vec2(random(50, width-50),0));
      particles[numP].vel = new Vec2(0, 0); 
      numP += 1;
    }
    
    // Physics
    for (int i = 0; i < sub_steps; i++) {
      double sim_dt = dt/sub_steps;
      if (sim_dt > 0.008) sim_dt = 0.008;
      update_physics(sim_dt);
    }
  }
  
  // Particles
  for (int i = 0; i < numP; i++) {
    Particle p = particles[i];
    float q = (float)(p.press)/300;
    float r = ((0.7-q*0.5)*255);
    float g = ((0.8-q*0.4)*255);
    float b = ((1.0-q*0.2)*255);
    fill(r, g, b, 255 - (q*255 - 200));
    circle((float)p.pos.x, (float)p.pos.y, (float)(2*rad));
  }
  
  // Obstacles
  fill(220, 200, 120);
  circle((float)op.x, (float)op.y, (float)(2*or));
  circle((float)op2.x, (float)op2.y, (float)(2*or));
}
