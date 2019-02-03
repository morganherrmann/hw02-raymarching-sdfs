#version 300 es
precision highp float;

// The vertex shader used to render the background of the scene

in vec4 vs_Pos;
out vec2 fs_Pos;




void main() {

  //vec3 x = sdBox( vs_Pos.xyz, vec3(0.5f, 0.6f, 0.3f));

  fs_Pos = vs_Pos.xy;
  gl_Position = vs_Pos;
}
