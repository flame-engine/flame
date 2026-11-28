// Hashed alpha test from Wyman & McGuire 2017, "Hashed Alpha Testing":
// https://cwyman.org/papers/i3d17_hashedAlpha.pdf (Listing 1, no LoD fade-in).
// Pass the bind-pose object-space position, so the pattern stays on the surface.

// 2D hash from McGuire 2016, quoted in the W&M paper Section 5.1.
float _hash2(vec2 v) {
  return fract(
    1.0e4 * sin(17.0 * v.x + 0.1 * v.y) *
            (0.1 + abs(sin(13.0 * v.y + v.x)))
  );
}

// 3D hash: paper's recipe of applying the 2D hash recursively.
float _hash3(vec3 v) {
  return _hash2(vec2(_hash2(v.xy), v.z));
}

float _hashedAlphaThreshold(vec3 objectPos, float scale) {
  // Per-fragment derivatives of position give the surface's screen-space
  // stretch. `maxDeriv` is the worst-case length-per-pixel, used to choose
  // an appropriate noise frequency.
  float maxDeriv = max(length(dFdx(objectPos)), length(dFdy(objectPos)));
  float pixScale = 1.0 / max(scale * maxDeriv, 1e-6);

  // Snap to the two nearest power-of-two scales and lerp between them.
  // The log2/exp2 pair quantizes the scale so neighbouring fragments
  // sample the same noise cell unless they truly cross a scale boundary.
  vec2 pixScales = vec2(
    exp2(floor(log2(pixScale))),
    exp2(ceil(log2(pixScale)))
  );

  vec2 alpha2 = vec2(
    _hash3(floor(pixScales.x * objectPos)),
    _hash3(floor(pixScales.y * objectPos))
  );

  float lerpFactor = fract(log2(pixScale));
  float x = mix(alpha2.x, alpha2.y, lerpFactor);

  // Piecewise CDF that maps the lerped value back to a uniform distribution
  // in [0, 1]. Without this the lerp biases the distribution and the dither
  // washes out for partial-alpha regions.
  float a = max(min(lerpFactor, 1.0 - lerpFactor), 1e-6);
  vec3 cases = vec3(
    (x * x) / (2.0 * a * (1.0 - a)),
    (x - 0.5 * a) / (1.0 - a),
    1.0 - ((1.0 - x) * (1.0 - x) / (2.0 * a * (1.0 - a)))
  );

  float threshold = (x < (1.0 - a))
    ? ((x < a) ? cases.x : cases.y)
    : cases.z;

  return clamp(threshold, 1e-6, 1.0);
}

void alphaDiscard(
  float alpha,
  vec3 objectPos,
  float scissorThreshold,
  float hashScale
) {
  if (scissorThreshold > 0.0) {
    if (alpha < scissorThreshold) {
      discard;
    }
  } else if (hashScale > 0.0) {
    float threshold = _hashedAlphaThreshold(objectPos, hashScale);
    if (alpha < threshold) {
      discard;
    }
  }
}
