#version 460 core

in vec4 fragColor;

out vec4 outColor;

void main() {
  float alpha = clamp(fragColor.a, 0.0, 1.0);
  outColor = vec4(fragColor.rgb * alpha, alpha);
}
