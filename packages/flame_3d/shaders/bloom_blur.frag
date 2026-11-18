#version 460 core

// 5-tap Kawase blur kernel (center + 4 half-texel-offset diagonal taps).

in vec2 fragUv;

out vec4 outColor;

uniform sampler2D sourceTexture;

uniform BloomBlur {
  // xy: offset in UV units (`texelSize * (iteration + 0.5) * radius`).
  vec4 offset;
} blur;

void main() {
  vec2 o = blur.offset.xy;
  vec3 sum = texture(sourceTexture, fragUv).rgb * 0.25;
  sum += texture(sourceTexture, fragUv + vec2(-o.x, -o.y)).rgb * 0.1875;
  sum += texture(sourceTexture, fragUv + vec2( o.x, -o.y)).rgb * 0.1875;
  sum += texture(sourceTexture, fragUv + vec2(-o.x,  o.y)).rgb * 0.1875;
  sum += texture(sourceTexture, fragUv + vec2( o.x,  o.y)).rgb * 0.1875;
  outColor = vec4(sum, 1.0);
}
