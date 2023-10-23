//---------------
//Vec 3 Library
//---------------

// Vector Library
// Adapted from Vec2 Library by Stephen J. Guy <sjguy@umn.edu>

public class Vec3 {
  public double x, y, z;

  public Vec3(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public String toString() {
    return "(" + x + ", " + y + ", " + z + ")";
  }

  public double length() {
    return Math.sqrt(x * x + y * y + z * z);
  }

  public double lengthSqr() {
    return x * x + y * y;
  }

  public Vec3 plus(Vec3 rhs) {
    return new Vec3(x + rhs.x, y + rhs.y, z + rhs.z);
  }

  public void add(Vec3 rhs) {
    x += rhs.x;
    y += rhs.y;
  }

  public Vec3 minus(Vec3 rhs) {
    return new Vec3(x - rhs.x, y - rhs.y, z - rhs.z);
  }

  public void subtract(Vec3 rhs) {
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }

  public Vec3 times(double rhs) {
    return new Vec3(x * rhs, y * rhs, z * rhs);
  }

  public void mul(double rhs) {
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }

  public void clampToLength(double maxL) {
    double magnitude = Math.sqrt(x * x + y * y + z * z);
    if (magnitude > maxL) {
      x *= maxL / magnitude;
      y *= maxL / magnitude;
      z *= maxL / magnitude;
    }
  }

  public void setToLength(double newL) {
    double magnitude = Math.sqrt(x * x + y * y + z * z);
    x *= newL / magnitude;
    y *= newL / magnitude;
    z *= newL / magnitude;
  }

  public void normalize() {
    double magnitude = Math.sqrt(x * x + y * y + z * z);
    x /= magnitude;
    y /= magnitude;
    z /= magnitude;
  }

  public Vec3 normalized() {
    double magnitude = Math.sqrt(x * x + y * y + z * z);
    return new Vec3(x / magnitude, y / magnitude, z / magnitude);
  }

  public double distanceTo(Vec3 rhs) {
    double dx = rhs.x - x;
    double dy = rhs.y - y;
    double dz = rhs.z - z;
    return Math.sqrt(dx * dx + dy * dy + dz * dz);
  }
}

Vec3 interpolate(Vec3 a, Vec3 b, double t) {
  return a.plus((b.minus(a)).times(t));
}

double interpolate(double a, double b, double t) {
  return a + ((b - a) * t);
}

double dot(Vec3 a, Vec3 b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}

Vec3 cross(Vec3 a, Vec3 b) {
  double u1 = a.x;
  double u2 = a.y;
  double u3 = a.z;
  double v1 = b.x;
  double v2 = b.y;
  double v3 = b.z;
  return new Vec3(u2*v3 - u3*v2, u3*v1 - u1*v3, u1*v2-u2*v1);
}

Vec3 projAB(Vec3 a, Vec3 b) {
  return b.times(a.x * b.x + a.y * b.y + a.z * b.z);
}
