#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

uniform float u_Speed;
uniform float u_Color;

in vec2 fs_Pos;
out vec4 out_Col;

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;


//SIN DISPLACEMENT TOOLBOX FUNCTIONS
float displacement(vec3 p){
  return sin(20.f*p.x)*sin(20.f*p.y)*sin(20.f *p.z);
}

float displacement2(vec3 p){
  return sin(1.5f*p.y );
}

//Operations for intersection/ union / smooth blend

float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); }

float opSmoothIntersection( float d1, float d2, float k ) {
        float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
        return mix( d2, d1, h ) + k*h*(1.0-h); }

float opUnion( float d1, float d2 ) {  return min(d1,d2); }

float opSubtraction( float d1, float d2 ) { return max(-d1,d2); }

float opIntersection( float d1, float d2 ) { return max(d1,d2); }


//TOOLBOX FUNCTION
float sinc( float x, float k )
{
    float a = 3.14f * (k *x -1.0);
    return sin(a)/a;
}



//cube SDF with transformation
float cubeSDF(vec3 p){

  // transformation
  mat2 rot;
  rot[0][0] =cos(radians(-45.0 * u_Time / 1000.f));
  rot[0][1] =sin(radians(-45.0 * u_Time / 1000.f));
  rot[1][0] =-sin(radians(-45.0 * u_Time / 1000.f));
  rot[1][1] =cos(radians(-45.0 * u_Time / 1000.f));
  p.xz *= rot;

   vec3 d = abs(p) - vec3(1.0, 1.0, 1.0);
   float insideDistance = min(max(d.x, max(d.y, d.z)), 0.0);

   float outsideDistance = length(max(d, 0.0));

   //texturing
   float d1 = insideDistance + outsideDistance;
   float d2 = displacement(p);
   return d1 + d2;
}


//SDF For a Torus
float torusSDF( vec3 p, vec2 t )
{
  mat2 rot;
  float x = 100.f - 1.7f * u_Speed;
  rot[0][0] =cos(radians(-45.0 * u_Time / x));
  rot[0][1] =sin(radians(-45.0 * u_Time / x));
  rot[1][0] =-sin(radians(-45.0 * u_Time /x));
  rot[1][1] =cos(radians(-45.0 * u_Time /x));
  p.xz *= rot;
  rot[0][0] =cos(radians(-25.0 * u_Time / 437.f));
  rot[0][1] =sin(radians(-25.0 * u_Time / 437.f));
  rot[1][0] =-sin(radians(-25.0 * u_Time / 437.f));
  rot[1][1] =cos(radians(-25.0 * u_Time / 437.f));
  p.xy *= rot;
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y ;//+ displacement(p) / 20.f;
}

//Sphere SDF Basic
float sphereSDF(vec3 p){
  return length(p) - 1.f;
}

//Modified sphere SDF Function
float sphereSDF2(vec3 p){

  mat2 shear;
  shear[0][0] = 0.f;
  shear[0][1] =sin(radians(-45.0 * u_Time / 10.f));
  shear[1][0] =-0.f;
  shear[1][1] =cos(radians(-45.0 * u_Time / 10.f));
  p.xy *= shear;
  return length(p) - 1.f;
}


float cylSDF( vec3 p, vec3 c )
{
  return length(p.xz-c.xy)-c.z;
}

float sceneSDF(vec3 p)
{
  return cubeSDF(p);
}

//Normal shading based on the slides
vec3 estimateNormal(vec3 p) {
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}


//compute the shortest distance to the surface
float shortestDistanceToSurface(vec3 eye, vec3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++)
    {
        //float dist = sceneSDF((eye + marchingDirection * depth) / 0.7f) * 0.7f;
        float dist = cubeSDF((eye + marchingDirection * depth) / 0.7f) * 0.7f;
        float sphere = sphereSDF(eye + marchingDirection * depth);
        float torus = torusSDF(eye + marchingDirection * depth, vec2(0.5f, 0.4f));
        float small_sphere = sphereSDF((eye + marchingDirection * depth) / 0.3f) * 1.5f;
        float cyl = cylSDF((eye + marchingDirection * depth) / 0.3f, vec3(0.5, 0.5, 3.7)) * 0.5f;


        dist = opSmoothIntersection(cyl, dist, 0.4f);
        dist = opSubtraction(sphere, dist);
        dist = opUnion(dist, torus);
        dist = opSmoothUnion(dist, small_sphere, 2.f);

        if (dist < EPSILON)
        {
			       return depth;
        }
        depth += dist;
        if (depth >= end)
        {
            return end;
        }
    }
    return end;
}

//Function to compute the direction of the ray
vec3 rayDirection(float fieldOfView, const vec2 size, const vec2 fragCoord) {
    vec2 xy = gl_FragCoord.xy - size / 2.0;
    float z = size.y / tan(radians(fieldOfView) / 2.0);
    return vec3(normalize(vec3(xy, -z)));
}



//Function TOOLBOX of triangle wave
float triangle_wave(float x, float freq, float amplitude){

  return abs(mod((x * freq), amplitude - (0.5f * amplitude)));

}


//FUNCTION TOOLBOX - square wave
float square_wave(float x, float freq, float amplitude){

  return abs(mod(floor(x*freq), 2.f * amplitude));

}

//Uses above toolbox functions to compute the color
vec3 computeColor(vec3 p){

      p.z = square_wave(p.x, 100.f, 20.9f);
      p.x = triangle_wave(p.y, 2.f, 0.8f);

      return p;
}



void main() {

  float FOV = radians(45.f);

  vec3 F = u_Ref - u_Eye;

  vec3 u_Right = normalize(cross(F, u_Up));      //is this correct???

  float aspect = u_Dimensions.x / u_Dimensions.y;

  vec3 V = tan (FOV / 2.f) * u_Up;
  vec3 H = aspect * tan (FOV / 2.f) * u_Right;

  float a = gl_FragCoord.x;
  float b = gl_FragCoord.y;

  float sx = (2.f * a/u_Dimensions.x) - 1.f;
  float sy = 1.f - (2.f * b/u_Dimensions.y);
  vec3 p = u_Ref + (sx * H) + (sy * V);

  vec2 pos = vec2(sx, sy);

  vec3 dir = rayDirection(45.0, u_Dimensions.xy, gl_FragCoord.xy);

  out_Col = vec4(0.5 * (dir + vec3(1.0, 1.0, 1.0)), 1.0);   // DIR IS WORKING PROPERLY


  //-----attempting EXAMPLE HERE------
  float dist = shortestDistanceToSurface(u_Eye, dir, MIN_DIST, MAX_DIST);

  vec3 ray = u_Eye + dir * dist;
  vec3 color = estimateNormal(ray);


  //color = computeColor(color);

    if (dist > MAX_DIST - EPSILON) {
        // Didn't hit anything - BLACK
        out_Col = vec4(0.0, 0.0, 0.0, 1.0);
		return;
    }
    //color.r += u_Color;
    out_Col = vec4(color, 1.0);
}
