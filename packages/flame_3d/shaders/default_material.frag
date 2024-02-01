
in vec2 fragTexCoord;
in vec4 fragColor;

out vec4 outColor;

uniform sampler2D texture0;

uniform FragmentInfo {
  vec4 colorDiffuse;
} fragment_info;

void main() {
  vec4 texelColor = texture(texture0, fragTexCoord);
  outColor = texelColor * fragment_info.colorDiffuse * fragColor;
}
