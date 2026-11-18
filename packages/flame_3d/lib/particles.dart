/// GPU particles and 3D motion ribbons for `flame_3d`.
library;

export 'package:flame/particles.dart'
    show
        ColorRamp,
        EmitterBurst,
        ParticleCurve,
        ParticleRange,
        ParticleRangeExtension;

export 'src/particles/emitter_shape_3d.dart';
export 'src/particles/particle_buffer_3d.dart';
export 'src/particles/particle_emitter_3d.dart';
export 'src/particles/particle_forces_3d.dart';
export 'src/particles/particle_material.dart';
export 'src/particles/particle_presets_3d.dart';
export 'src/particles/particle_system_3d.dart';
export 'src/particles/ribbon_material_3d.dart';
export 'src/particles/ribbon_trail_3d.dart';
