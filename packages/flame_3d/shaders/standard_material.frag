
in vec2 fragTexCoord;
in vec4 fragColor;

out vec4 outColor;

uniform sampler2D albedoTexture;

uniform FragmentInfo {
  vec4 albedoColor;
} fragment_info;

void main() {
  vec4 texelColor = texture(albedoTexture, fragTexCoord);
  outColor = texelColor * fragment_info.albedoColor;
}
