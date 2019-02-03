#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;

float sceneSDF(vec3 p)
{
return length(p)- 01.f;
}

float shortestDistanceToSurface(vec3 eye, vec3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = sceneSDF(eye + marchingDirection * depth);
        if (dist < EPSILON) {
			return depth;
        }
        depth += dist;
        if (depth >= end) {
            return end;
        }
    }
    return end;
}



void main() {

  float FOV = radians(45.f);

  vec3 F = u_Ref - u_Eye;

  vec3 u_Right = cross(F, u_Up);      //is this correct???

  float aspect = u_Dimensions.x / u_Dimensions.y;

  vec3 V = tan (FOV / 2.f) * u_Up;
  vec3 H = aspect * tan (FOV / 2.f) * u_Right;

  float a = gl_FragCoord.x;
  float b = gl_FragCoord.y;

  float sx = (2.f * a/u_Dimensions.x) - 1.f;
  float sy = 1.f - (2.f * b/u_Dimensions.y);
  vec3 p = u_Ref + (sx * H) + (sy * V);

  vec2 pos = vec2(sx, sy);
  vec3 dir = normalize(p - u_Eye);

  //float x = sdBox(dir.xyz, vec3(0.5f, 0.6f, 0.3f));

  out_Col = vec4(0.5 * (dir + vec3(1.0, 1.0, 1.0)), 1.0);
  float dist = shortestDistanceToSurface(u_Eye, dir, MIN_DIST, MAX_DIST);

    if (dist > MAX_DIST - EPSILON) {
        // Didn't hit anything
        out_Col = vec4(0.0, 0.0, 0.0, 1.0);
		return;
    }

    out_Col = vec4(1.0, 0.0, 0.0, 1.0);




//  out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.5 * (sin(u_Time * 3.14159 * 0.01) + 1.0), 1.0);
}
