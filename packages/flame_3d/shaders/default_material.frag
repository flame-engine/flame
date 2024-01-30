
in vec2 fragTexCoord;
in vec4 fragColor;

out vec4 oFragColor;

uniform sampler2D texture0;
// TODO(wolfen): add support of color diffusing in the default shader.
// uniform vec4 colDiffuse;

void main() {
  vec4 texelColor = texture(texture0, fragTexCoord);
  oFragColor = texelColor * vec4(1.0) * fragColor;
}
