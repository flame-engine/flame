#version 460 core

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;
in vec3 vertexNormal;

out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 fragPosition;
out vec3 fragNormal;

uniform VertexInfo {
  mat4 model;
  mat4 view;
  mat4 projection;
} vertex_info;

void main() {
    // Calculate the modelview projection matrix
    mat4 modelViewProjection = vertex_info.projection * vertex_info.view * vertex_info.model;

    // Transform the vertex position
    gl_Position = modelViewProjection * vec4(vertexPosition, 1.0);

    // Pass the interpolated values to the fragment shader
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    
    // Calculate the world-space position and normal
    fragPosition = vec3(vertex_info.model * vec4(vertexPosition, 1.0));
    fragNormal = mat3(transpose(inverse(vertex_info.model))) * vertexNormal;
}
