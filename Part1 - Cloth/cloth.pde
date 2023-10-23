// ========================================
// Usage:
// 1 - Simulation starts paused, press space to unpause
// 2 - press o to lock or unlock the obstacle 
//     when unlocked, the obstacle moves with the camera
//     when locked, the obstacle stays in its spot
//  
// NOTE - very fast obstacle movement will likely make the cloth freak out
//        obstacle may slightly clip into the cloth at low framerates (larger dt)
// ========================================

// ==============
// Node struct
// ==============
class Node {
  Vec3 pos;
  Vec3 vel;
  Vec3 last_pos;

  Node(Vec3 pos) {
    this.pos = pos;
    this.vel = new Vec3(0, 0, 0);
    this.last_pos = pos;
  }
}

// ==============
// setup
// ==============
void setup() {
  size(500, 500, P3D);
  scene_scale = width / 10.0f;
  generateMesh();
  camera = new Camera();
  camera.phi = -PI/6;
  camera.position = new PVector((float)(5.6 * scene_scale), 
                                (float)(4 * scene_scale), 
                                (float)(3 * scene_scale));
  img = loadImage("flag.jpg");
  op = new Vec3(5.6 * (float)scene_scale, 
                   5.4 * (float)scene_scale, 
                   1 * (float)scene_scale); // Obstacle initial pos (it will move with the camera)
}

// ==============
// Variables
// ==============

// Scaling factor for the scene
double scene_scale = width / 10.0f;

// Camera
Camera camera;

// Cloth Texture
PImage img;

// Nodes, top row, and mesh
int num_nodes = 60;
double link_length = 0.02;
double r = 0.02; // radius of all nodes (for obstacle collision)
Node[][] nodes = new Node[num_nodes][num_nodes];
Vec3 base_pos = new Vec3(5, 5, 0); // Where top row starts (for pinning top row down)

// Obstacle
double or = 0.3; // Obstacle Radius
Vec3 op; // Obstacle Position

// Physics Constants
Vec3 gravity = new Vec3(0, 10, 0);
double COR = 0.2;

// Physics Parameters
int relaxation_steps = 4;
int sub_steps = 10;

// ==============
// Mesh Generation
// ==============
void generateMesh() {
  for(int j = 0; j < num_nodes; j++) {
    for(int i = 0; i < num_nodes; i++) {
      Vec3 newPos = new Vec3(base_pos.x + link_length*i, base_pos.y, base_pos.z + link_length*j);
      nodes[i][j] = new Node(newPos);
    }
  }
}

// ==============
// Physics and Visualization-
// ==============
void update_physics(double dt) {
  // Semi-implicit Integration
  for(int j = 1; j < num_nodes; j++) {
    for(int i = 0; i < num_nodes; i++) {
      Node node = nodes[i][j];
      node.last_pos = new Vec3(node.pos.x, node.pos.y, node.pos.z);
      node.vel = node.vel.plus(gravity.times(dt));
      node.pos = node.pos.plus(node.vel.times(dt));
    }
  }
    
  // Constrain the distance between nodes to the link length
  //horizontal
  for (int k = 0; k < relaxation_steps; k++) {
    for(int i = 0; i < num_nodes-1; i++) { 
      for(int j = 0; j < num_nodes; j++) {
        Node node = nodes[i][j];
        Node next = nodes[i+1][j];
        Vec3 delta = next.pos.minus(node.pos);
        double delta_len = delta.length();
        double correction = delta_len - link_length;
        Vec3 delta_normalized = delta.normalized();
        node.pos = node.pos.plus(delta_normalized.times(correction / 2));
        next.pos = next.pos.minus(delta_normalized.times(correction / 2));
      }
    }
    
    //vertical
    for(int i = 0; i < num_nodes; i++) { 
      for(int j = 0; j < num_nodes-1; j++) {
        Node node = nodes[i][j];
        Node next = nodes[i][j+1];
        Vec3 delta = next.pos.minus(node.pos);
        double delta_len = delta.length();
        double correction = delta_len - link_length;
        Vec3 delta_normalized = delta.normalized();
        node.pos = node.pos.plus(delta_normalized.times(correction / 2));
        next.pos = next.pos.minus(delta_normalized.times(correction / 2));
      }
    }
    
    // Obstacle Collision
    for(int i = 0; i < num_nodes; i++) {
      for(int j = 0; j < num_nodes; j++) {
        Node node = nodes[i][j];
        float scale = (float)scene_scale;
        Vec3 opScaled = new Vec3(op.x/scale, op.y/scale, op.z/scale);
        if(node.pos.distanceTo(opScaled) < r + or) {
          Vec3 normal = (node.pos.minus(opScaled)).normalized();
          node.pos = opScaled.plus(normal.times(or+r));
          Vec3 velNormal = normal.times(dot(node.vel, normal));
          node.vel.subtract(velNormal.times(1 + COR));
        }
      }
    }
    
    // Fix the top row in place
    for(int i = 0; i < num_nodes; i++) {
      nodes[i][0].pos = new Vec3(base_pos.x + i*link_length, base_pos.y, base_pos.z);
      nodes[i][0].vel = new Vec3(0, 0, 0);
    }
  }
  
  // Update the velocities (PBD)
  for(int j = 1; j < num_nodes; j++) {
    for(int i = 0; i < num_nodes; i++) {
      Node node = nodes[i][j];
      node.vel = node.pos.minus(node.last_pos).times(1 / dt);
    }
  }
}

boolean paused = true;
boolean lock = true;

void keyPressed()
{
  camera.HandleKeyPressed();
  if (key == ' ') {
    paused = !paused;
  }
  if (key == 'z') {
    generateMesh();
  }
  if (key == 'o') {
    lock = !lock;
    println("lock =",lock);
  }
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

void draw() {
  double dt = 1/frameRate; 
  background(255);
  noStroke();
  lightFalloff(2, 0.0, 2);
  specular(120, 120, 180);
  shininess(5);
  ambientLight(255,255,255);
  lightSpecular(255,255,255);
  directionalLight(140, 140, 110, 1, 1, 1);
  directionalLight(140, 140, 110, 0, 1, -1);
  directionalLight(50, 50, 50, 0, -1, 0);

  //pointLight(0, 0, 255,(float) op.x,(float) op.y,(float) op.z);
  
  // Camera movement
  camera.Update(1.0/frameRate);
  
  println("fps:", frameRate);
  if (!paused) {
    for (int i = 0; i < sub_steps; i++) {
      update_physics(dt / sub_steps);
    }
  }
  
  // for reference on where the origin is
  sphere((float)(0.2 * scene_scale));
  
  // Ground Plane as a reference for height
  fill(90, 0, 0);
  stroke(0);
  pushMatrix();
  translate((float)(5 * scene_scale), (float)(10 * scene_scale), 0);
  box((float)(10 * scene_scale), 0, (float)(2 * scene_scale));
  popMatrix();
  
  // make obstacle move with camera
  if(!lock) {
    float theta = camera.theta;
    float phi = camera.phi;
    float t = theta + PI / 2;
    float p = phi + PI / 2;
    Vec3 forwardDir = new Vec3( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
    forwardDir.normalize();
    Vec3 cp = new Vec3(camera.position.x, camera.position.y, camera.position.z);
    op = cp.plus(forwardDir.times(2 * scene_scale));
  }
  
  // Obstacle for cloth
  fill(0, 0, 200);
  noStroke();
  pushMatrix();
  translate((float)(op.x), (float)(op.y), (float)(op.z));
  sphere((float)(or * scene_scale));
  popMatrix();
  
  // Texture
  fill(200);
  noStroke();
  for(int i = 0; i < num_nodes-1; i++) {
    for(int j = 0; j < num_nodes-1; j++) {
      beginShape();
      texture(img);
      Node tl = nodes[i][j];
      Node tr = nodes[i+1][j];
      Node bl = nodes[i][j+1];
      Node br = nodes[i+1][j+1];
      
      vertex((float)(tl.pos.x * scene_scale), 
             (float)(tl.pos.y * scene_scale), 
             (float)(tl.pos.z * scene_scale), img.width/num_nodes * i, img.height/num_nodes * j);
      vertex((float)(br.pos.x * scene_scale), 
             (float)(br.pos.y * scene_scale), 
             (float)(br.pos.z * scene_scale), img.width/num_nodes * (i+1), img.height/num_nodes * (j+1));
      vertex((float)(bl.pos.x * scene_scale), 
             (float)(bl.pos.y * scene_scale), 
             (float)(bl.pos.z * scene_scale), img.width/num_nodes * (i), img.height/num_nodes * (j+1));
      endShape();
      
      beginShape();
      texture(img);
      vertex((float)(tl.pos.x * scene_scale), 
             (float)(tl.pos.y * scene_scale), 
             (float)(tl.pos.z * scene_scale), img.width/num_nodes * i, img.height/num_nodes * j);
      vertex((float)(tr.pos.x * scene_scale), 
             (float)(tr.pos.y * scene_scale), 
             (float)(tr.pos.z * scene_scale), img.width/num_nodes * (i+1), img.height/num_nodes * j);
      vertex((float)(br.pos.x * scene_scale), 
             (float)(br.pos.y * scene_scale), 
             (float)(br.pos.z * scene_scale), img.width/num_nodes * (i+1), img.height/num_nodes * (j+1));
      endShape();
    }
  }
}
