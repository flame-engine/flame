#version 460 core

in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
in vec3 fragNormal;
in vec4 fragInstanceColor;

out vec4 outColor;

uniform sampler2D albedoTexture;

uniform Material {
  vec4 albedoColor;
} material;

void main() {
  vec4 texColor = texture(albedoTexture, fragTexCoord);
  outColor = texColor * material.albedoColor * fragInstanceColor * fragColor;
}
