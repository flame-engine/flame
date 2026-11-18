import 'dart:async' show unawaited;

import 'package:flame/game.dart';
import 'package:flame_3d_example/showcase/showcase_diagnostics.dart';
import 'package:flame_3d_example/showcase/showcase_game.dart';
import 'package:flame_3d_example/showcase/showcase_variations.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Interactive Flutter host widget for [ShowcaseGame]: renders the 3D scene
/// with a 16-preset lab switcher, collapsible telemetry HUD, live subsystem
/// toggles, offscreen `renderToImage` preview card, and 1-tap 48-check engine
/// self-test.
class const ShowcaseView({
  final ShowcaseGame? game,
  final EdgeInsets topPadding = const EdgeInsets.all(10),
  super.key,
}) extends StatefulWidget {
  @override
  State<ShowcaseView> createState() => _ShowcaseViewState();
}

class _ShowcaseViewState() extends State<ShowcaseView> {
  late ShowcaseGame _game;
  bool _ownsGame = false;
  bool _hudExpanded = true;
  bool _runningSelfTest = false;
  ShowcaseDiagnosticReport? _report;

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      _game = widget.game!;
      _ownsGame = false;
    } else {
      _game = ShowcaseGame();
      _ownsGame = true;
    }
  }

  @override
  void dispose() {
    if (_ownsGame) {
      _game.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _runSelfTest() async {
    if (_runningSelfTest || !_game.isLoaded) {
      return;
    }
    setState(() {
      _runningSelfTest = true;
      _report = null;
    });
    final report = await ShowcaseDiagnostics.runAllChecks(
      _game,
      pumpFrame: () async {
        SchedulerBinding.instance.scheduleFrame();
        await SchedulerBinding.instance.endOfFrame;
      },
    );
    if (mounted) {
      setState(() {
        _runningSelfTest = false;
        _report = report;
      });
    }
  }

  void _toggle(void Function(ShowcaseController c) mutate) {
    mutate(_game.controller);
    _game.syncControllerState();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _game.controller;
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final statLoaded = _game.isLoaded;
        final sStats = statLoaded ? _game.staticLayer.renderStats : null;
        final dStats = statLoaded ? _game.dynamicLayer.renderStats : null;
        final sMs = statLoaded
            ? _game.staticLayer.lastRenderTime.inMicroseconds / 1000.0
            : 0.0;
        final dMs = statLoaded
            ? _game.dynamicLayer.lastRenderTime.inMicroseconds / 1000.0
            : 0.0;
        final cacheHits = statLoaded ? _game.staticLayer.cacheHitCount : 0;

        return Stack(
          fit: StackFit.expand,
          children: [
            GameWidget(game: _game),

            Positioned(
              left: widget.topPadding.left,
              top: widget.topPadding.top,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xCC0B111E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x385CE1E6)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _hudExpanded = !_hudExpanded),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _hudExpanded
                                    ? '▼ flame_3d Testbed Telemetry'
                                    : '▶ flame_3d '
                                          '(${ctrl.fps.toStringAsFixed(0)}'
                                          ' FPS)',
                                style: const TextStyle(
                                  color: Color(0xFF5CE1E6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_hudExpanded &&
                            sStats != null &&
                            dStats != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${ctrl.preset.label} — ${ctrl.preset.summary}',
                            style: const TextStyle(
                              color: Color(0xFFC4B5FD),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'FPS ${ctrl.fps.toStringAsFixed(1)}  •  '
                            'p50 ${ctrl.frameMsP50.toStringAsFixed(1)} ms  •  '
                            'p95 ${ctrl.frameMsP95.toStringAsFixed(1)} ms',
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Static  passes ${sStats.renderPasses} '
                            '(sh ${sStats.shadowPasses}) • hits $cacheHits • '
                            'draws ${sStats.drawCalls} • '
                            'inst ${sStats.instances} • '
                            'tris ${sStats.triangles} • '
                            '${sMs.toStringAsFixed(2)} ms',
                            style: const TextStyle(
                              color: Color(0xFFA7F3D0),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dynamic passes ${dStats.renderPasses} '
                            '(sh ${dStats.shadowPasses}) • '
                            'draws ${dStats.drawCalls} • '
                            'inst ${dStats.instances} • '
                            'tris ${dStats.triangles} • '
                            'ptcl ${dStats.particles} • '
                            '${dMs.toStringAsFixed(2)} ms',
                            style: const TextStyle(
                              color: Color(0xFFBAE6FD),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ctrl.lastHitSummary,
                            style: const TextStyle(
                              color: Color(0xFFFDE68A),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (ctrl.snapshotImage != null)
              Positioned(
                right: 12,
                top: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xE60B111E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'renderToImage()',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: RawImage(
                            image: ctrl.snapshotImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_report != null)
              Positioned(
                right: 12,
                bottom: 104,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 390,
                    maxHeight: 330,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xF00B111E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _report!.allPassed
                            ? const Color(0xFF34D399)
                            : const Color(0xFFF87171),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Self-Test: ${_report!.passedCount}/'
                                '${_report!.totalCount} PASS '
                                '(${_report!.elapsed.inMilliseconds} ms)',
                                style: TextStyle(
                                  color: _report!.allPassed
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFF87171),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _report = null),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '✕',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final item in _report!.results)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text(
                                        '${item.passed ? "✓" : "✗"} '
                                        '${item.title}: ${item.detail}',
                                        style: TextStyle(
                                          color: item.passed
                                              ? const Color(0xFFD1FAE5)
                                              : const Color(0xFFFECACA),
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xD90B111E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x2E94A3B8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final p in ShowcasePreset.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: _PresetPill(
                                  label: p.label,
                                  selected: ctrl.preset == p,
                                  onTap: () {
                                    if (_game.isLoaded) {
                                      unawaited(_game.selectPreset(p));
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          _Chip(
                            label: 'Retained',
                            active: ctrl.retainedStaticLayer,
                            onTap: () => _toggle(
                              (c) => c.retainedStaticLayer =
                                  !c.retainedStaticLayer,
                            ),
                          ),
                          _Chip(
                            label: 'ShadowCache',
                            active: ctrl.staticShadowCache,
                            onTap: () => _toggle(
                              (c) => c.staticShadowCache = !c.staticShadowCache,
                            ),
                          ),
                          _Chip(
                            label: 'SharedShadow',
                            active: ctrl.sharedShadowGroup,
                            onTap: () => _toggle(
                              (c) => c.sharedShadowGroup = !c.sharedShadowGroup,
                            ),
                          ),
                          _Chip(
                            label: 'Bloom',
                            active: ctrl.bloom,
                            onTap: () => _toggle((c) => c.bloom = !c.bloom),
                          ),
                          _Chip(
                            label: 'Fog',
                            active: ctrl.fog,
                            onTap: () => _toggle((c) => c.fog = !c.fog),
                          ),
                          _Chip(
                            label: 'FXAA',
                            active: ctrl.fxaa,
                            onTap: () => _toggle((c) => c.fxaa = !c.fxaa),
                          ),
                          _Chip(
                            label: 'Vignette',
                            active: ctrl.vignette,
                            onTap: () =>
                                _toggle((c) => c.vignette = !c.vignette),
                          ),
                          _Chip(
                            label: 'SSAO',
                            active: ctrl.ssao,
                            onTap: () => _toggle((c) => c.ssao = !c.ssao),
                          ),
                          _Chip(
                            label: '3D DoF',
                            active: ctrl.dof,
                            onTap: () => _toggle((c) => c.dof = !c.dof),
                          ),
                          _Chip(
                            label: 'CSM 2x',
                            active: ctrl.csm2Cascades,
                            onTap: () => _toggle(
                              (c) => c.csm2Cascades = !c.csm2Cascades,
                            ),
                          ),
                          _Chip(
                            label: 'Debug3D',
                            active: ctrl.debug3D,
                            onTap: () => _toggle((c) => c.debug3D = !c.debug3D),
                          ),
                          _Chip(
                            label: 'BVH3D',
                            active: ctrl.spatialIndex3D,
                            onTap: () => _toggle(
                              (c) => c.spatialIndex3D = !c.spatialIndex3D,
                            ),
                          ),
                          _Chip(
                            label: 'LightCull',
                            active: ctrl.prioritizeNearestLights,
                            onTap: () => _toggle(
                              (c) => c.prioritizeNearestLights =
                                  !c.prioritizeNearestLights,
                            ),
                          ),
                          _Chip(
                            label: 'Outlines',
                            active: ctrl.outlines,
                            onTap: () =>
                                _toggle((c) => c.outlines = !c.outlines),
                          ),
                          _Chip(
                            label: 'Wind',
                            active: ctrl.wind,
                            onTap: () => _toggle((c) => c.wind = !c.wind),
                          ),
                          _Chip(
                            label: 'Particles',
                            active: ctrl.particles,
                            onTap: () =>
                                _toggle((c) => c.particles = !c.particles),
                          ),
                          _Chip(
                            label: 'Decals/Ribbons',
                            active: ctrl.ribbonsAndDecals,
                            onTap: () => _toggle(
                              (c) => c.ribbonsAndDecals = !c.ribbonsAndDecals,
                            ),
                          ),
                          _Chip(
                            label: 'MSAA 4x',
                            active: ctrl.msaa4x,
                            onTap: () => _toggle((c) => c.msaa4x = !c.msaa4x),
                          ),
                          _Chip(
                            label: 'Orbit',
                            active: ctrl.autoOrbitCamera,
                            onTap: () => _toggle(
                              (c) => c.autoOrbitCamera = !c.autoOrbitCamera,
                            ),
                          ),
                          _Chip(
                            label: 'Stress 1k',
                            active: ctrl.stressInstances,
                            onTap: () => _toggle(
                              (c) => c.stressInstances = !c.stressInstances,
                            ),
                          ),
                          _ActionChip(
                            label: 'Tone:${ctrl.toneMap.name}',
                            color: const Color(0xFF34D399),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.cycleToneMap();
                              }
                            },
                          ),
                          _ActionChip(
                            label: 'Shad:${ctrl.shadowEncoding.name}',
                            color: const Color(0xFFFBBF24),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.cycleShadowEncoding();
                              }
                            },
                          ),
                          _ActionChip(
                            label: 'Fit:${ctrl.shadowFit.name}',
                            color: const Color(0xFFFBBF24),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.toggleShadowFit();
                              }
                            },
                          ),
                          _ActionChip(
                            label: 'PCF:${ctrl.shadowSoftness}',
                            color: const Color(0xFFFBBF24),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.cycleShadowSoftness();
                              }
                            },
                          ),
                          _ActionChip(
                            label: 'DRS:${ctrl.renderScale}x',
                            color: const Color(0xFFF472B6),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.toggleRenderScale();
                              }
                            },
                          ),
                          _ActionChip(
                            label: 'Clip:${ctrl.activeClip}',
                            color: const Color(0xFF818CF8),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.crossFadeNextClip(mode: ctrl.playMode);
                              }
                            },
                          ),
                          _ActionChip(
                            label: 'Mode:${ctrl.playMode.name}',
                            color: const Color(0xFF818CF8),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.cyclePlayMode();
                              }
                            },
                          ),
                          _ActionChip(
                            label: 'Spd:${ctrl.animSpeed}x',
                            color: const Color(0xFF818CF8),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.cycleAnimSpeed();
                              }
                            },
                          ),
                          _ActionChip(
                            label: _game.variationRig.crownHidden
                                ? 'Show Crown'
                                : 'Hide Crown',
                            color: const Color(0xFFC084FC),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.toggleCrownNode();
                              }
                            },
                          ),
                          _ActionChip(
                            label: 'Snapshot',
                            color: const Color(0xFF38BDF8),
                            onTap: () {
                              if (_game.isLoaded) {
                                _game.captureOffscreenSnapshot();
                              }
                            },
                          ),
                          _ActionChip(
                            label: _runningSelfTest
                                ? 'Testing...'
                                : 'Self-Test (48)',
                            color: const Color(0xFF34D399),
                            onTap: _runSelfTest,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class const _PresetPill({
  required final String label,
  required final bool selected,
  required final VoidCallback onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF312E81) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selected ? const Color(0xFFA78BFA) : const Color(0xFF334155),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF94A3B8),
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class const _Chip({
  required final String label,
  required final bool active,
  required final VoidCallback onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0E7490) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: active ? const Color(0xFF67E8F9) : const Color(0xFF475569),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFFFFFFFF) : const Color(0xFFCBD5E1),
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class const _ActionChip({
  required final String label,
  required final Color color,
  required final VoidCallback onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF172554),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
