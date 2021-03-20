#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D rgb;
uniform vec2 resolution;

in vec4 vertColor;
in vec4 vertTexCoord;

out vec4 fragColor;


void main() {
  vec2 uv = gl_FragCoord.xy / resolution;
  vec4 rgba = texture(rgb, uv);

  fragColor = vertColor * rgba;
}