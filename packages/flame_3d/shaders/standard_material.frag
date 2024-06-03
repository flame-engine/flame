#version 460 core

in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
smooth in vec3 fragNormal;

out vec4 outColor;

uniform sampler2D albedoTexture;  // Albedo texture

uniform Material {
  vec4 albedoColor;
  vec3 ambient;
  vec3 diffuse;
  vec3 specular;
  float roughness;
} material;

uniform Light {
  vec3 position;
  vec3 ambient;
  vec3 diffuse;
  vec3 specular;
} light;

uniform Camera {
  vec3 position;
} camera;

// GGX (Trowbridge-Reitz) distribution function
float GGX_D(float NdotH, float roughness) {
    float alpha = roughness * roughness;
    float alpha2 = alpha * alpha;
    float NdotH2 = NdotH * NdotH;
    float d = (NdotH2 * (alpha2 - 1.0) + 1.0);
    return alpha2 / (3.14159265359 * d * d);
}

// Schlick's approximation for the Fresnel-Schlick equation
vec3 Fresnel_Schlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

void main() {
    vec3 albedo = material.albedoColor.rgb;
    albedo = texture(albedoTexture, fragTexCoord).rgb;

    // Calculate the ambient term
    vec3 ambient = material.ambient * light.ambient * albedo;

    // Calculate the light direction and normalize it
    vec3 lightDir = normalize(light.position - fragPosition);

    // Calculate the view direction and normalize it
    vec3 viewDir = normalize(camera.position - fragPosition);

    // Calculate the normal direction
    vec3 normal = normalize(fragNormal);

    // Calculate the half-vector between the light and view directions
    vec3 halfDir = normalize(lightDir + viewDir);

    // Calculate the diffuse term
    float NdotL = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = albedo * light.diffuse * NdotL;

    // Calculate the specular term using GGX distribution and Schlick's Fresnel approximation
    float NdotH = max(dot(normal, halfDir), 0.0);
    float roughness = material.roughness;
    vec3 F0 = material.specular;
    vec3 specular = Fresnel_Schlick(NdotH, F0) * GGX_D(NdotH, roughness) / (4.0 * max(dot(normal, viewDir), 0.001) * max(dot(normal, lightDir), 0.001));

    // Combine ambient, diffuse, and specular terms to get the final color
    vec3 result = ambient + diffuse + specular;

    // Output the final color
    outColor = vec4(result, 1.0) * fragColor;
}