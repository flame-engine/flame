in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

out vec2 fragTexCoord;
out vec4 fragColor;

uniform VertexInfo {
  mat4 mvp;
} vertex_info;

void main() {
  fragTexCoord = vertexTexCoord;
  fragColor = vertexColor;
  gl_Position = vertex_info.mvp * vec4(vertexPosition, 1.0);
}
