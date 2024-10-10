/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated July 28, 2023. Replaces all prior versions.
 *
 * Copyright (c) 2013-2023, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software or
 * otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THE
 * SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

#ifndef SPINE_CPP_LITE
#define SPINE_CPP_LITE

#include <stdint.h>

#ifdef __cplusplus
#if _WIN32
#define SPINE_CPP_LITE_EXPORT extern "C" __declspec(dllexport)
#else
#ifdef __EMSCRIPTEN__
#define SPINE_CPP_LITE_EXPORT extern "C" __attribute__((used))
#else
#define SPINE_CPP_LITE_EXPORT extern "C"
#endif
#endif
#else
#if _WIN32
#define SPINE_CPP_LITE_EXPORT __declspec(dllexport)
#else
#ifdef __EMSCRIPTEN__
#define SPINE_CPP_LITE_EXPORT __attribute__((used))
#else
#define SPINE_CPP_LITE_EXPORT
#endif
#endif
#endif

#define SPINE_OPAQUE_TYPE(name)     \
	typedef struct name##_wrapper { \
	} name##_wrapper;               \
	typedef name##_wrapper *name;

// @start: opaque_types

SPINE_OPAQUE_TYPE(spine_skeleton)
SPINE_OPAQUE_TYPE(spine_skeleton_data)
SPINE_OPAQUE_TYPE(spine_bone)
SPINE_OPAQUE_TYPE(spine_bone_data)
SPINE_OPAQUE_TYPE(spine_slot)
SPINE_OPAQUE_TYPE(spine_slot_data)
SPINE_OPAQUE_TYPE(spine_skin)
SPINE_OPAQUE_TYPE(spine_attachment)
SPINE_OPAQUE_TYPE(spine_region_attachment)
SPINE_OPAQUE_TYPE(spine_vertex_attachment)
SPINE_OPAQUE_TYPE(spine_mesh_attachment)
SPINE_OPAQUE_TYPE(spine_clipping_attachment)
SPINE_OPAQUE_TYPE(spine_bounding_box_attachment)
SPINE_OPAQUE_TYPE(spine_path_attachment)
SPINE_OPAQUE_TYPE(spine_point_attachment)
SPINE_OPAQUE_TYPE(spine_texture_region)
SPINE_OPAQUE_TYPE(spine_sequence)
SPINE_OPAQUE_TYPE(spine_constraint)
SPINE_OPAQUE_TYPE(spine_constraint_data)
SPINE_OPAQUE_TYPE(spine_ik_constraint)
SPINE_OPAQUE_TYPE(spine_ik_constraint_data)
SPINE_OPAQUE_TYPE(spine_transform_constraint)
SPINE_OPAQUE_TYPE(spine_transform_constraint_data)
SPINE_OPAQUE_TYPE(spine_path_constraint)
SPINE_OPAQUE_TYPE(spine_path_constraint_data)
SPINE_OPAQUE_TYPE(spine_physics_constraint)
SPINE_OPAQUE_TYPE(spine_physics_constraint_data)
SPINE_OPAQUE_TYPE(spine_animation_state)
SPINE_OPAQUE_TYPE(spine_animation_state_data)
SPINE_OPAQUE_TYPE(spine_animation_state_events)
SPINE_OPAQUE_TYPE(spine_event)
SPINE_OPAQUE_TYPE(spine_event_data)
SPINE_OPAQUE_TYPE(spine_track_entry)
SPINE_OPAQUE_TYPE(spine_animation)
SPINE_OPAQUE_TYPE(spine_atlas)
SPINE_OPAQUE_TYPE(spine_skeleton_data_result)
SPINE_OPAQUE_TYPE(spine_render_command)
SPINE_OPAQUE_TYPE(spine_bounds)
SPINE_OPAQUE_TYPE(spine_color)
SPINE_OPAQUE_TYPE(spine_vector)
SPINE_OPAQUE_TYPE(spine_skeleton_drawable)
SPINE_OPAQUE_TYPE(spine_skin_entry)
SPINE_OPAQUE_TYPE(spine_skin_entries)

// @end: opaque_types

typedef char utf8;

// @start: enums

typedef enum spine_blend_mode {
	SPINE_BLEND_MODE_NORMAL = 0,
	SPINE_BLEND_MODE_ADDITIVE,
	SPINE_BLEND_MODE_MULTIPLY,
	SPINE_BLEND_MODE_SCREEN
} spine_blend_mode;

typedef enum spine_mix_blend {
	SPINE_MIX_BLEND_SETUP = 0,
	SPINE_MIX_BLEND_FIRST,
	SPINE_MIX_BLEND_REPLACE,
	SPINE_MIX_BLEND_ADD
} spine_mix_blend;

typedef enum spine_event_type {
	SPINE_EVENT_TYPE_START = 0,
	SPINE_EVENT_TYPE_INTERRUPT,
	SPINE_EVENT_TYPE_END,
	SPINE_EVENT_TYPE_COMPLETE,
	SPINE_EVENT_TYPE_DISPOSE,
	SPINE_EVENT_TYPE_EVENT
} spine_event_type;

typedef enum spine_attachment_type {
	SPINE_ATTACHMENT_REGION = 0,
	SPINE_ATTACHMENT_MESH,
	SPINE_ATTACHMENT_CLIPPING,
	SPINE_ATTACHMENT_BOUNDING_BOX,
	SPINE_ATTACHMENT_PATH,
	SPINE_ATTACHMENT_POINT,
} spine_attachment_type;

typedef enum spine_constraint_type {
	SPINE_CONSTRAINT_IK,
	SPINE_CONSTRAINT_TRANSFORM,
	SPINE_CONSTRAINT_PATH
} spine_constraint_type;

typedef enum spine_inherit {
	SPINE_INHERIT_NORMAL = 0,
	SPINE_INHERIT_ONLY_TRANSLATION,
	SPINE_INHERIT_NO_ROTATION_OR_REFLECTION,
	SPINE_INHERIT_NO_SCALE,
	SPINE_INHERIT_NO_SCALE_OR_REFLECTION
} spine_inherit;

typedef enum spine_position_mode {
	SPINE_POSITION_MODE_FIXED = 0,
	SPINE_POSITION_MODE_PERCENT
} spine_position_mode;

typedef enum spine_spacing_mode {
	SPINE_SPACING_MODE_LENGTH = 0,
	SPINE_SPACING_MODE_FIXED,
	SPINE_SPACING_MODE_PERCENT,
	SPINE_SPACING_MODE_PROPORTIONAL
} spine_spacing_mode;

typedef enum spine_rotate_mode {
	SPINE_ROTATE_MODE_TANGENT = 0,
	SPINE_ROTATE_MODE_CHAIN,
	SPINE_ROTATE_MODE_CHAIN_SCALE
} spine_rotate_mode;

typedef enum spine_physics {
	SPINE_PHYSICS_NONE = 0,
	SPINE_PHYSICS_RESET,
	SPINE_PHYSICS_UPDATE,
	SPINE_PHYSICS_POSE

} spine_physics;

// @end: enums

typedef int32_t spine_bool;

// @start: function_declarations

SPINE_CPP_LITE_EXPORT int32_t spine_major_version();
SPINE_CPP_LITE_EXPORT int32_t spine_minor_version();
SPINE_CPP_LITE_EXPORT void spine_enable_debug_extension(spine_bool enable);
SPINE_CPP_LITE_EXPORT void spine_report_leaks();

SPINE_CPP_LITE_EXPORT float spine_color_get_r(spine_color color);
SPINE_CPP_LITE_EXPORT float spine_color_get_g(spine_color color);
SPINE_CPP_LITE_EXPORT float spine_color_get_b(spine_color color);
SPINE_CPP_LITE_EXPORT float spine_color_get_a(spine_color color);

SPINE_CPP_LITE_EXPORT float spine_bounds_get_x(spine_bounds bounds);
SPINE_CPP_LITE_EXPORT float spine_bounds_get_y(spine_bounds bounds);
SPINE_CPP_LITE_EXPORT float spine_bounds_get_width(spine_bounds bounds);
SPINE_CPP_LITE_EXPORT float spine_bounds_get_height(spine_bounds bounds);

SPINE_CPP_LITE_EXPORT float spine_vector_get_x(spine_vector vector);
SPINE_CPP_LITE_EXPORT float spine_vector_get_y(spine_vector vector);

SPINE_CPP_LITE_EXPORT spine_atlas spine_atlas_load(const utf8 *atlasData);
SPINE_CPP_LITE_EXPORT int32_t spine_atlas_get_num_image_paths(spine_atlas atlas);
SPINE_CPP_LITE_EXPORT utf8 *spine_atlas_get_image_path(spine_atlas atlas, int32_t index);
SPINE_CPP_LITE_EXPORT spine_bool spine_atlas_is_pma(spine_atlas atlas);
SPINE_CPP_LITE_EXPORT utf8 *spine_atlas_get_error(spine_atlas atlas);
SPINE_CPP_LITE_EXPORT void spine_atlas_dispose(spine_atlas atlas);

// @ignore
SPINE_CPP_LITE_EXPORT spine_skeleton_data_result spine_skeleton_data_load_json(spine_atlas atlas, const utf8 *skeletonData);
// @ignore
SPINE_CPP_LITE_EXPORT spine_skeleton_data_result spine_skeleton_data_load_binary(spine_atlas atlas, const uint8_t *skeletonData, int32_t length);
SPINE_CPP_LITE_EXPORT utf8 *spine_skeleton_data_result_get_error(spine_skeleton_data_result result);
SPINE_CPP_LITE_EXPORT spine_skeleton_data spine_skeleton_data_result_get_data(spine_skeleton_data_result result);
SPINE_CPP_LITE_EXPORT void spine_skeleton_data_result_dispose(spine_skeleton_data_result result);
SPINE_CPP_LITE_EXPORT spine_bone_data spine_skeleton_data_find_bone(spine_skeleton_data data, const utf8 *name);
SPINE_CPP_LITE_EXPORT spine_slot_data spine_skeleton_data_find_slot(spine_skeleton_data data, const utf8 *name);
SPINE_CPP_LITE_EXPORT spine_skin spine_skeleton_data_find_skin(spine_skeleton_data data, const utf8 *name);
SPINE_CPP_LITE_EXPORT spine_event_data spine_skeleton_data_find_event(spine_skeleton_data data, const utf8 *name);
SPINE_CPP_LITE_EXPORT spine_animation spine_skeleton_data_find_animation(spine_skeleton_data data, const utf8 *name);
SPINE_CPP_LITE_EXPORT spine_ik_constraint_data spine_skeleton_data_find_ik_constraint(spine_skeleton_data data, const utf8 *name);
SPINE_CPP_LITE_EXPORT spine_transform_constraint_data spine_skeleton_data_find_transform_constraint(spine_skeleton_data data, const utf8 *name);
SPINE_CPP_LITE_EXPORT spine_path_constraint_data spine_skeleton_data_find_path_constraint(spine_skeleton_data data, const utf8 *name);
SPINE_CPP_LITE_EXPORT spine_physics_constraint_data spine_skeleton_data_find_physics_constraint(spine_skeleton_data data, const utf8 *name);
// @optiona;
SPINE_CPP_LITE_EXPORT const utf8 *spine_skeleton_data_get_name(spine_skeleton_data data);
// OMITTED setName()
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_bones(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_bone_data *spine_skeleton_data_get_bones(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_slots(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_slot_data *spine_skeleton_data_get_slots(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_skins(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_skin *spine_skeleton_data_get_skins(spine_skeleton_data data);
// @optional
SPINE_CPP_LITE_EXPORT spine_skin spine_skeleton_data_get_default_skin(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT void spine_skeleton_data_set_default_skin(spine_skeleton_data data, spine_skin skin);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_events(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_event_data *spine_skeleton_data_get_events(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_animations(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_animation *spine_skeleton_data_get_animations(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_ik_constraints(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_ik_constraint_data *spine_skeleton_data_get_ik_constraints(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_transform_constraints(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_transform_constraint_data *spine_skeleton_data_get_transform_constraints(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_path_constraints(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_path_constraint_data *spine_skeleton_data_get_path_constraints(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_data_get_num_physics_constraints(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT spine_physics_constraint_data *spine_skeleton_data_get_physics_constraints(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT float spine_skeleton_data_get_x(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT void spine_skeleton_data_set_x(spine_skeleton_data data, float x);
SPINE_CPP_LITE_EXPORT float spine_skeleton_data_get_y(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT void spine_skeleton_data_set_y(spine_skeleton_data data, float y);
SPINE_CPP_LITE_EXPORT float spine_skeleton_data_get_width(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT void spine_skeleton_data_set_width(spine_skeleton_data data, float width);
SPINE_CPP_LITE_EXPORT float spine_skeleton_data_get_height(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT void spine_skeleton_data_set_height(spine_skeleton_data data, float height);
SPINE_CPP_LITE_EXPORT const utf8 *spine_skeleton_data_get_version(spine_skeleton_data data);
// OMITTED setVersion() 
// @ignore
SPINE_CPP_LITE_EXPORT const utf8 *spine_skeleton_data_get_hash(spine_skeleton_data data);
// OMITTED setHash()
SPINE_CPP_LITE_EXPORT const utf8 *spine_skeleton_data_get_images_path(spine_skeleton_data data);
// OMITTED setImagesPath()
SPINE_CPP_LITE_EXPORT const utf8 *spine_skeleton_data_get_audio_path(spine_skeleton_data data);
// OMITTED setAudioPath()
SPINE_CPP_LITE_EXPORT float spine_skeleton_data_get_fps(spine_skeleton_data data);
// OMITTED setFps()
SPINE_CPP_LITE_EXPORT float spine_skeleton_data_get_reference_scale(spine_skeleton_data data);
SPINE_CPP_LITE_EXPORT void spine_skeleton_data_dispose(spine_skeleton_data data);

// @ignore
SPINE_CPP_LITE_EXPORT spine_skeleton_drawable spine_skeleton_drawable_create(spine_skeleton_data skeletonData);
// @ignore
SPINE_CPP_LITE_EXPORT spine_render_command spine_skeleton_drawable_render(spine_skeleton_drawable drawable);
SPINE_CPP_LITE_EXPORT void spine_skeleton_drawable_dispose(spine_skeleton_drawable drawable);
SPINE_CPP_LITE_EXPORT spine_skeleton spine_skeleton_drawable_get_skeleton(spine_skeleton_drawable drawable);
SPINE_CPP_LITE_EXPORT spine_animation_state spine_skeleton_drawable_get_animation_state(spine_skeleton_drawable drawable);
SPINE_CPP_LITE_EXPORT spine_animation_state_data spine_skeleton_drawable_get_animation_state_data(spine_skeleton_drawable drawable);
SPINE_CPP_LITE_EXPORT spine_animation_state_events spine_skeleton_drawable_get_animation_state_events(spine_skeleton_drawable drawable);

// @ignore
SPINE_CPP_LITE_EXPORT float *spine_render_command_get_positions(spine_render_command command);
// @ignore
SPINE_CPP_LITE_EXPORT float *spine_render_command_get_uvs(spine_render_command command);
// @ignore
SPINE_CPP_LITE_EXPORT int32_t *spine_render_command_get_colors(spine_render_command command);
// @ignore
SPINE_CPP_LITE_EXPORT int32_t *spine_render_command_get_dark_colors(spine_render_command command);
SPINE_CPP_LITE_EXPORT int32_t spine_render_command_get_num_vertices(spine_render_command command);
SPINE_CPP_LITE_EXPORT uint16_t *spine_render_command_get_indices(spine_render_command command);
SPINE_CPP_LITE_EXPORT int32_t spine_render_command_get_num_indices(spine_render_command command);
SPINE_CPP_LITE_EXPORT int32_t spine_render_command_get_atlas_page(spine_render_command command);
SPINE_CPP_LITE_EXPORT spine_blend_mode spine_render_command_get_blend_mode(spine_render_command command);
SPINE_CPP_LITE_EXPORT spine_render_command spine_render_command_get_next(spine_render_command command);

SPINE_CPP_LITE_EXPORT const utf8 *spine_animation_get_name(spine_animation animation);
// OMITTED getTimelines()
// OMITTED hasTimeline()
SPINE_CPP_LITE_EXPORT float spine_animation_get_duration(spine_animation animation);
// OMITTED setDuration()

SPINE_CPP_LITE_EXPORT spine_skeleton_data spine_animation_state_data_get_skeleton_data(spine_animation_state_data stateData);
SPINE_CPP_LITE_EXPORT float spine_animation_state_data_get_default_mix(spine_animation_state_data stateData);
SPINE_CPP_LITE_EXPORT void spine_animation_state_data_set_default_mix(spine_animation_state_data stateData, float defaultMix);
SPINE_CPP_LITE_EXPORT void spine_animation_state_data_set_mix(spine_animation_state_data stateData, spine_animation from, spine_animation to, float duration);
SPINE_CPP_LITE_EXPORT float spine_animation_state_data_get_mix(spine_animation_state_data stateData, spine_animation from, spine_animation to);
SPINE_CPP_LITE_EXPORT void spine_animation_state_data_set_mix_by_name(spine_animation_state_data stateData, const utf8 *fromName, const utf8 *toName, float duration);
SPINE_CPP_LITE_EXPORT float spine_animation_state_data_get_mix_by_name(spine_animation_state_data stateData, const utf8 *fromName, const utf8 *toName);
SPINE_CPP_LITE_EXPORT void spine_animation_state_data_clear(spine_animation_state_data stateData);

SPINE_CPP_LITE_EXPORT void spine_animation_state_update(spine_animation_state state, float delta);
SPINE_CPP_LITE_EXPORT void spine_animation_state_apply(spine_animation_state state, spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_animation_state_clear_tracks(spine_animation_state state);
SPINE_CPP_LITE_EXPORT void spine_animation_state_clear_track(spine_animation_state state, int32_t trackIndex);
SPINE_CPP_LITE_EXPORT int32_t spine_animation_state_get_num_tracks(spine_animation_state state);
SPINE_CPP_LITE_EXPORT spine_track_entry spine_animation_state_set_animation_by_name(spine_animation_state state, int32_t trackIndex, const utf8 *animationName, spine_bool loop);
SPINE_CPP_LITE_EXPORT spine_track_entry spine_animation_state_set_animation(spine_animation_state state, int32_t trackIndex, spine_animation animation, spine_bool loop);
SPINE_CPP_LITE_EXPORT spine_track_entry spine_animation_state_add_animation_by_name(spine_animation_state state, int32_t trackIndex, const utf8 *animationName, spine_bool loop, float delay);
SPINE_CPP_LITE_EXPORT spine_track_entry spine_animation_state_add_animation(spine_animation_state state, int32_t trackIndex, spine_animation animation, spine_bool loop, float delay);
SPINE_CPP_LITE_EXPORT spine_track_entry spine_animation_state_set_empty_animation(spine_animation_state state, int32_t trackIndex, float mixDuration);
SPINE_CPP_LITE_EXPORT spine_track_entry spine_animation_state_add_empty_animation(spine_animation_state state, int32_t trackIndex, float mixDuration, float delay);
SPINE_CPP_LITE_EXPORT void spine_animation_state_set_empty_animations(spine_animation_state state, float mixDuration);
// @optional
SPINE_CPP_LITE_EXPORT spine_track_entry spine_animation_state_get_current(spine_animation_state state, int32_t trackIndex);
SPINE_CPP_LITE_EXPORT spine_animation_state_data spine_animation_state_get_data(spine_animation_state state);
SPINE_CPP_LITE_EXPORT float spine_animation_state_get_time_scale(spine_animation_state state);
SPINE_CPP_LITE_EXPORT void spine_animation_state_set_time_scale(spine_animation_state state, float timeScale);
// OMITTED setListener()
// OMITTED setListener()
// OMITTED disableQueue()
// OMITTED enableQueue()
// OMITTED setManualTrackEntryDisposal()
// OMITTED getManualTrackEntryDisposal()
// @ignore
SPINE_CPP_LITE_EXPORT void spine_animation_state_dispose_track_entry(spine_animation_state state, spine_track_entry entry);

SPINE_CPP_LITE_EXPORT int32_t spine_animation_state_events_get_num_events(spine_animation_state_events events);
SPINE_CPP_LITE_EXPORT spine_event_type spine_animation_state_events_get_event_type(spine_animation_state_events events, int32_t index);
SPINE_CPP_LITE_EXPORT spine_track_entry spine_animation_state_events_get_track_entry(spine_animation_state_events events, int32_t index);
// @optional
SPINE_CPP_LITE_EXPORT spine_event spine_animation_state_events_get_event(spine_animation_state_events events, int32_t index);
SPINE_CPP_LITE_EXPORT void spine_animation_state_events_reset(spine_animation_state_events events);

SPINE_CPP_LITE_EXPORT int32_t spine_track_entry_get_track_index(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT spine_animation spine_track_entry_get_animation(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT spine_track_entry spine_track_entry_get_previous(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT spine_bool spine_track_entry_get_loop(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_loop(spine_track_entry entry, spine_bool loop);
SPINE_CPP_LITE_EXPORT spine_bool spine_track_entry_get_hold_previous(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_hold_previous(spine_track_entry entry, spine_bool holdPrevious);
SPINE_CPP_LITE_EXPORT spine_bool spine_track_entry_get_reverse(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_reverse(spine_track_entry entry, spine_bool reverse);
SPINE_CPP_LITE_EXPORT spine_bool spine_track_entry_get_shortest_rotation(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_shortest_rotation(spine_track_entry entry, spine_bool shortestRotation);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_delay(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_delay(spine_track_entry entry, float delay);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_track_time(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_track_time(spine_track_entry entry, float trackTime);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_track_end(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_track_end(spine_track_entry entry, float trackEnd);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_animation_start(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_animation_start(spine_track_entry entry, float animationStart);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_animation_end(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_animation_end(spine_track_entry entry, float animationEnd);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_animation_last(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_animation_last(spine_track_entry entry, float animationLast);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_animation_time(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_time_scale(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_time_scale(spine_track_entry entry, float timeScale);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_alpha(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_alpha(spine_track_entry entry, float alpha);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_event_threshold(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_event_threshold(spine_track_entry entry, float eventThreshold);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_alpha_attachment_threshold(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_alpha_attachment_threshold(spine_track_entry entry, float attachmentThreshold);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_mix_attachment_threshold(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_mix_attachment_threshold(spine_track_entry entry, float attachmentThreshold);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_mix_draw_order_threshold(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_mix_draw_order_threshold(spine_track_entry entry, float drawOrderThreshold);
// @optional
SPINE_CPP_LITE_EXPORT spine_track_entry spine_track_entry_get_next(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT spine_bool spine_track_entry_is_complete(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_mix_time(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_mix_time(spine_track_entry entry, float mixTime);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_mix_duration(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_mix_duration(spine_track_entry entry, float mixDuration);
SPINE_CPP_LITE_EXPORT spine_mix_blend spine_track_entry_get_mix_blend(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_set_mix_blend(spine_track_entry entry, spine_mix_blend mixBlend);
// @optional
SPINE_CPP_LITE_EXPORT spine_track_entry spine_track_entry_get_mixing_from(spine_track_entry entry);
// @optional
SPINE_CPP_LITE_EXPORT spine_track_entry spine_track_entry_get_mixing_to(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT void spine_track_entry_reset_rotation_directions(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT float spine_track_entry_get_track_complete(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT spine_bool spine_track_entry_was_applied(spine_track_entry entry);
SPINE_CPP_LITE_EXPORT spine_bool spine_track_entry_is_next_ready(spine_track_entry entry);
// OMITTED setListener()
// OMITTED setListener()

SPINE_CPP_LITE_EXPORT void spine_skeleton_update_cache(spine_skeleton skeleton);
// OMITTED printUpdateCache()
SPINE_CPP_LITE_EXPORT void spine_skeleton_update_world_transform(spine_skeleton skeleton, spine_physics physics);
SPINE_CPP_LITE_EXPORT void spine_skeleton_update_world_transform_bone(spine_skeleton skeleton, spine_physics physics, spine_bone parent);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_to_setup_pose(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_bones_to_setup_pose(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_slots_to_setup_pose(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_bone spine_skeleton_find_bone(spine_skeleton skeleton, const utf8 *boneName);
SPINE_CPP_LITE_EXPORT spine_slot spine_skeleton_find_slot(spine_skeleton skeleton, const utf8 *slotName);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_skin_by_name(spine_skeleton skeleton, const utf8 *skinName);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_skin(spine_skeleton skeleton, spine_skin skin);
// @optional
SPINE_CPP_LITE_EXPORT spine_attachment spine_skeleton_get_attachment_by_name(spine_skeleton skeleton, const utf8 *slotName, const utf8 *attachmentName);
// @optional
SPINE_CPP_LITE_EXPORT spine_attachment spine_skeleton_get_attachment(spine_skeleton skeleton, int32_t slotIndex, const utf8 *attachmentName);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_attachment(spine_skeleton skeleton, const utf8 *slotName, const utf8 *attachmentName);
SPINE_CPP_LITE_EXPORT spine_ik_constraint spine_skeleton_find_ik_constraint(spine_skeleton skeleton, const utf8 *constraintName);
SPINE_CPP_LITE_EXPORT spine_transform_constraint spine_skeleton_find_transform_constraint(spine_skeleton skeleton, const utf8 *constraintName);
SPINE_CPP_LITE_EXPORT spine_path_constraint spine_skeleton_find_path_constraint(spine_skeleton skeleton, const utf8 *constraintName);
SPINE_CPP_LITE_EXPORT spine_physics_constraint spine_skeleton_find_physics_constraint(spine_skeleton skeleton, const utf8 *constraintName);
SPINE_CPP_LITE_EXPORT spine_bounds spine_skeleton_get_bounds(spine_skeleton skeleton);
// @optional
SPINE_CPP_LITE_EXPORT spine_bone spine_skeleton_get_root_bone(spine_skeleton skeleton);
// @optional
SPINE_CPP_LITE_EXPORT spine_skeleton_data spine_skeleton_get_data(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_get_num_bones(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_bone *spine_skeleton_get_bones(spine_skeleton skeleton);
// OMITTED getUpdateCacheList()
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_get_num_slots(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_slot *spine_skeleton_get_slots(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_get_num_draw_order(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_slot *spine_skeleton_get_draw_order(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_get_num_ik_constraints(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_ik_constraint *spine_skeleton_get_ik_constraints(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_get_num_transform_constraints(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_transform_constraint *spine_skeleton_get_transform_constraints(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_get_num_path_constraints(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_path_constraint *spine_skeleton_get_path_constraints(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT int32_t spine_skeleton_get_num_physics_constraints(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_physics_constraint *spine_skeleton_get_physics_constraints(spine_skeleton skeleton);
// @optional
SPINE_CPP_LITE_EXPORT spine_skin spine_skeleton_get_skin(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT spine_color spine_skeleton_get_color(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_color(spine_skeleton skeleton, float r, float g, float b, float a);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_position(spine_skeleton skeleton, float x, float y);
SPINE_CPP_LITE_EXPORT float spine_skeleton_get_x(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_x(spine_skeleton skeleton, float x);
SPINE_CPP_LITE_EXPORT float spine_skeleton_get_y(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_y(spine_skeleton skeleton, float y);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_scale(spine_skeleton skeleton, float scaleX, float scaleY);
SPINE_CPP_LITE_EXPORT float spine_skeleton_get_scale_x(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_scale_x(spine_skeleton skeleton, float scaleX);
SPINE_CPP_LITE_EXPORT float spine_skeleton_get_scale_y(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_scale_y(spine_skeleton skeleton, float scaleY);
SPINE_CPP_LITE_EXPORT float spine_skeleton_get_time(spine_skeleton skeleton);
SPINE_CPP_LITE_EXPORT void spine_skeleton_set_time(spine_skeleton skeleton, float time);
SPINE_CPP_LITE_EXPORT void spine_skeleton_update(spine_skeleton skeleton, float delta);

SPINE_CPP_LITE_EXPORT const utf8 *spine_event_data_get_name(spine_event_data event);
SPINE_CPP_LITE_EXPORT int32_t spine_event_data_get_int_value(spine_event_data event);
SPINE_CPP_LITE_EXPORT void spine_event_data_set_int_value(spine_event_data event, int32_t value);
SPINE_CPP_LITE_EXPORT float spine_event_data_get_float_value(spine_event_data event);
SPINE_CPP_LITE_EXPORT void spine_event_data_set_float_value(spine_event_data event, float value);
SPINE_CPP_LITE_EXPORT const utf8 *spine_event_data_get_string_value(spine_event_data event);
SPINE_CPP_LITE_EXPORT void spine_event_data_set_string_value(spine_event_data event, const utf8 *value);
SPINE_CPP_LITE_EXPORT const utf8 *spine_event_data_get_audio_path(spine_event_data event);
// OMITTED setAudioPath()
SPINE_CPP_LITE_EXPORT float spine_event_data_get_volume(spine_event_data event);
SPINE_CPP_LITE_EXPORT void spine_event_data_set_volume(spine_event_data event, float volume);
SPINE_CPP_LITE_EXPORT float spine_event_data_get_balance(spine_event_data event);
SPINE_CPP_LITE_EXPORT void spine_event_data_set_balance(spine_event_data event, float balance);

SPINE_CPP_LITE_EXPORT spine_event_data spine_event_get_data(spine_event event);
SPINE_CPP_LITE_EXPORT float spine_event_get_time(spine_event event);
SPINE_CPP_LITE_EXPORT int32_t spine_event_get_int_value(spine_event event);
SPINE_CPP_LITE_EXPORT void spine_event_set_int_value(spine_event event, int32_t value);
SPINE_CPP_LITE_EXPORT float spine_event_get_float_value(spine_event event);
SPINE_CPP_LITE_EXPORT void spine_event_set_float_value(spine_event event, float value);
SPINE_CPP_LITE_EXPORT const utf8 *spine_event_get_string_value(spine_event event);
SPINE_CPP_LITE_EXPORT void spine_event_set_string_value(spine_event event, const utf8 *value);
SPINE_CPP_LITE_EXPORT float spine_event_get_volume(spine_event event);
SPINE_CPP_LITE_EXPORT void spine_event_set_volume(spine_event event, float volume);
SPINE_CPP_LITE_EXPORT float spine_event_get_balance(spine_event event);
SPINE_CPP_LITE_EXPORT void spine_event_set_balance(spine_event event, float balance);

SPINE_CPP_LITE_EXPORT int32_t spine_slot_data_get_index(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT const utf8 *spine_slot_data_get_name(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT spine_bone_data spine_slot_data_get_bone_data(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT spine_color spine_slot_data_get_color(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT void spine_slot_data_set_color(spine_slot_data slot, float r, float g, float b, float a);
SPINE_CPP_LITE_EXPORT spine_color spine_slot_data_get_dark_color(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT void spine_slot_data_set_dark_color(spine_slot_data slot, float r, float g, float b, float a);
SPINE_CPP_LITE_EXPORT spine_bool spine_slot_data_get_has_dark_color(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT void spine_slot_data_set_has_dark_color(spine_slot_data slot, spine_bool hasDarkColor);
SPINE_CPP_LITE_EXPORT const utf8 *spine_slot_data_get_attachment_name(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT void spine_slot_data_set_attachment_name(spine_slot_data slot, const utf8 *attachmentName);
SPINE_CPP_LITE_EXPORT spine_blend_mode spine_slot_data_get_blend_mode(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT void spine_slot_data_set_blend_mode(spine_slot_data slot, spine_blend_mode blendMode);
SPINE_CPP_LITE_EXPORT spine_bool spine_slot_data_is_visible(spine_slot_data slot);
SPINE_CPP_LITE_EXPORT void spine_slot_data_set_visible(spine_slot_data slot, spine_bool visible);
// OMITTED getPath()/setPath()

SPINE_CPP_LITE_EXPORT void spine_slot_set_to_setup_pose(spine_slot slot);
SPINE_CPP_LITE_EXPORT spine_slot_data spine_slot_get_data(spine_slot slot);
SPINE_CPP_LITE_EXPORT spine_bone spine_slot_get_bone(spine_slot slot);
SPINE_CPP_LITE_EXPORT spine_skeleton spine_slot_get_skeleton(spine_slot slot);
SPINE_CPP_LITE_EXPORT spine_color spine_slot_get_color(spine_slot slot);
SPINE_CPP_LITE_EXPORT void spine_slot_set_color(spine_slot slot, float r, float g, float b, float a);
SPINE_CPP_LITE_EXPORT spine_color spine_slot_get_dark_color(spine_slot slot);
SPINE_CPP_LITE_EXPORT void spine_slot_set_dark_color(spine_slot slot, float r, float g, float b, float a);
SPINE_CPP_LITE_EXPORT spine_bool spine_slot_has_dark_color(spine_slot slot);
// @optional
SPINE_CPP_LITE_EXPORT spine_attachment spine_slot_get_attachment(spine_slot slot);
SPINE_CPP_LITE_EXPORT void spine_slot_set_attachment(spine_slot slot, spine_attachment attachment);
// OMITTED getDeform()
SPINE_CPP_LITE_EXPORT int32_t spine_slot_get_sequence_index(spine_slot slot);
SPINE_CPP_LITE_EXPORT void spine_slot_set_sequence_index(spine_slot slot, int32_t sequenceIndex);

SPINE_CPP_LITE_EXPORT int32_t spine_bone_data_get_index(spine_bone_data data);
SPINE_CPP_LITE_EXPORT const utf8 *spine_bone_data_get_name(spine_bone_data data);
// @optional
SPINE_CPP_LITE_EXPORT spine_bone_data spine_bone_data_get_parent(spine_bone_data data);
SPINE_CPP_LITE_EXPORT float spine_bone_data_get_length(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_length(spine_bone_data data, float length);
SPINE_CPP_LITE_EXPORT float spine_bone_data_get_x(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_x(spine_bone_data data, float x);
SPINE_CPP_LITE_EXPORT float spine_bone_data_get_y(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_y(spine_bone_data data, float y);
SPINE_CPP_LITE_EXPORT float spine_bone_data_get_rotation(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_rotation(spine_bone_data data, float rotation);
SPINE_CPP_LITE_EXPORT float spine_bone_data_get_scale_x(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_scale_x(spine_bone_data data, float scaleX);
SPINE_CPP_LITE_EXPORT float spine_bone_data_get_scale_y(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_scale_y(spine_bone_data data, float scaleY);
SPINE_CPP_LITE_EXPORT float spine_bone_data_get_shear_x(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_shear_x(spine_bone_data data, float shearx);
SPINE_CPP_LITE_EXPORT float spine_bone_data_get_shear_y(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_shear_y(spine_bone_data data, float shearY);
SPINE_CPP_LITE_EXPORT spine_inherit spine_bone_data_get_inherit(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_inherit(spine_bone_data data, spine_inherit inherit);
SPINE_CPP_LITE_EXPORT spine_bool spine_bone_data_get_is_skin_required(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_is_skin_required(spine_bone_data data, spine_bool isSkinRequired);
SPINE_CPP_LITE_EXPORT spine_color spine_bone_data_get_color(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_color(spine_bone_data data, float r, float g, float b, float a);
SPINE_CPP_LITE_EXPORT spine_bool spine_bone_data_is_visible(spine_bone_data data);
SPINE_CPP_LITE_EXPORT void spine_bone_data_set_visible(spine_bone_data data, spine_bool isVisible);
// Omitted getIcon()/setIcon()

SPINE_CPP_LITE_EXPORT void spine_bone_set_is_y_down(spine_bool yDown);
SPINE_CPP_LITE_EXPORT spine_bool spine_bone_get_is_y_down();
SPINE_CPP_LITE_EXPORT void spine_bone_update(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_update_world_transform(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_update_world_transform_with(spine_bone bone, float x, float y, float rotation, float scaleX, float scaleY, float shearX, float shearY);
SPINE_CPP_LITE_EXPORT void spine_bone_update_applied_transform(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_to_setup_pose(spine_bone bone);
SPINE_CPP_LITE_EXPORT spine_vector spine_bone_world_to_local(spine_bone bone, float worldX, float worldY);
SPINE_CPP_LITE_EXPORT spine_vector spine_bone_world_to_parent(spine_bone bone, float worldX, float worldY);
SPINE_CPP_LITE_EXPORT spine_vector spine_bone_local_to_world(spine_bone bone, float localX, float localY);
SPINE_CPP_LITE_EXPORT spine_vector spine_bone_parent_to_world(spine_bone bone, float localX, float localY);
SPINE_CPP_LITE_EXPORT float spine_bone_world_to_local_rotation(spine_bone bone, float worldRotation);
SPINE_CPP_LITE_EXPORT float spine_bone_local_to_world_rotation(spine_bone bone, float localRotation);
SPINE_CPP_LITE_EXPORT void spine_bone_rotate_world(spine_bone bone, float degrees);
SPINE_CPP_LITE_EXPORT float spine_bone_get_world_to_local_rotation_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT float spine_bone_get_world_to_local_rotation_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT spine_bone_data spine_bone_get_data(spine_bone bone);
SPINE_CPP_LITE_EXPORT spine_skeleton spine_bone_get_skeleton(spine_bone bone);
// @optional
SPINE_CPP_LITE_EXPORT spine_bone spine_bone_get_parent(spine_bone bone);
SPINE_CPP_LITE_EXPORT int32_t spine_bone_get_num_children(spine_bone bone);
SPINE_CPP_LITE_EXPORT spine_bone *spine_bone_get_children(spine_bone bone);
SPINE_CPP_LITE_EXPORT float spine_bone_get_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_x(spine_bone bone, float x);
SPINE_CPP_LITE_EXPORT float spine_bone_get_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_y(spine_bone bone, float y);
SPINE_CPP_LITE_EXPORT float spine_bone_get_rotation(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_rotation(spine_bone bone, float rotation);
SPINE_CPP_LITE_EXPORT float spine_bone_get_scale_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_scale_x(spine_bone bone, float scaleX);
SPINE_CPP_LITE_EXPORT float spine_bone_get_scale_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_scale_y(spine_bone bone, float scaleY);
SPINE_CPP_LITE_EXPORT float spine_bone_get_shear_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_shear_x(spine_bone bone, float shearX);
SPINE_CPP_LITE_EXPORT float spine_bone_get_shear_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_shear_y(spine_bone bone, float shearY);
SPINE_CPP_LITE_EXPORT float spine_bone_get_applied_rotation(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_applied_rotation(spine_bone bone, float rotation);
SPINE_CPP_LITE_EXPORT float spine_bone_get_a_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_a_x(spine_bone bone, float x);
SPINE_CPP_LITE_EXPORT float spine_bone_get_a_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_a_y(spine_bone bone, float y);
SPINE_CPP_LITE_EXPORT float spine_bone_get_a_scale_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_a_scale_x(spine_bone bone, float scaleX);
SPINE_CPP_LITE_EXPORT float spine_bone_get_a_scale_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_a_scale_y(spine_bone bone, float scaleY);
SPINE_CPP_LITE_EXPORT float spine_bone_get_a_shear_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_a_shear_x(spine_bone bone, float shearX);
SPINE_CPP_LITE_EXPORT float spine_bone_get_a_shear_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_a_shear_y(spine_bone bone, float shearY);
SPINE_CPP_LITE_EXPORT float spine_bone_get_a(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_a(spine_bone bone, float a);
SPINE_CPP_LITE_EXPORT float spine_bone_get_b(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_b(spine_bone bone, float b);
SPINE_CPP_LITE_EXPORT float spine_bone_get_c(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_c(spine_bone bone, float c);
SPINE_CPP_LITE_EXPORT float spine_bone_get_d(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_d(spine_bone bone, float d);
SPINE_CPP_LITE_EXPORT float spine_bone_get_world_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_world_x(spine_bone bone, float worldX);
SPINE_CPP_LITE_EXPORT float spine_bone_get_world_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_world_y(spine_bone bone, float worldY);
SPINE_CPP_LITE_EXPORT float spine_bone_get_world_rotation_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT float spine_bone_get_world_rotation_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT float spine_bone_get_world_scale_x(spine_bone bone);
SPINE_CPP_LITE_EXPORT float spine_bone_get_world_scale_y(spine_bone bone);
SPINE_CPP_LITE_EXPORT spine_bool spine_bone_get_is_active(spine_bone bone);
SPINE_CPP_LITE_EXPORT void spine_bone_set_is_active(spine_bone bone, spine_bool isActive);
SPINE_CPP_LITE_EXPORT spine_inherit spine_bone_get_inherit(spine_bone data);
SPINE_CPP_LITE_EXPORT void spine_bone_set_inherit(spine_bone data, spine_inherit inherit);

SPINE_CPP_LITE_EXPORT const utf8 *spine_attachment_get_name(spine_attachment attachment);
SPINE_CPP_LITE_EXPORT spine_attachment_type spine_attachment_get_type(spine_attachment attachment);
// @ignore
SPINE_CPP_LITE_EXPORT spine_attachment spine_attachment_copy(spine_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_attachment_dispose(spine_attachment attachment);

SPINE_CPP_LITE_EXPORT spine_vector spine_point_attachment_compute_world_position(spine_point_attachment attachment, spine_bone bone);
SPINE_CPP_LITE_EXPORT float spine_point_attachment_compute_world_rotation(spine_point_attachment attachment, spine_bone bone);
SPINE_CPP_LITE_EXPORT float spine_point_attachment_get_x(spine_point_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_point_attachment_set_x(spine_point_attachment attachment, float x);
SPINE_CPP_LITE_EXPORT float spine_point_attachment_get_y(spine_point_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_point_attachment_set_y(spine_point_attachment attachment, float y);
SPINE_CPP_LITE_EXPORT float spine_point_attachment_get_rotation(spine_point_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_point_attachment_set_rotation(spine_point_attachment attachment, float rotation);
SPINE_CPP_LITE_EXPORT spine_color spine_point_attachment_get_color(spine_point_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_point_attachment_set_color(spine_point_attachment attachment, float r, float g, float b, float a);

SPINE_CPP_LITE_EXPORT void spine_region_attachment_update_region(spine_region_attachment attachment);
// @ignore
SPINE_CPP_LITE_EXPORT void spine_region_attachment_compute_world_vertices(spine_region_attachment attachment, spine_slot slot, float *worldVertices);
SPINE_CPP_LITE_EXPORT float spine_region_attachment_get_x(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_region_attachment_set_x(spine_region_attachment attachment, float x);
SPINE_CPP_LITE_EXPORT float spine_region_attachment_get_y(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_region_attachment_set_y(spine_region_attachment attachment, float y);
SPINE_CPP_LITE_EXPORT float spine_region_attachment_get_rotation(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_region_attachment_set_rotation(spine_region_attachment attachment, float rotation);
SPINE_CPP_LITE_EXPORT float spine_region_attachment_get_scale_x(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_region_attachment_set_scale_x(spine_region_attachment attachment, float scaleX);
SPINE_CPP_LITE_EXPORT float spine_region_attachment_get_scale_y(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_region_attachment_set_scale_y(spine_region_attachment attachment, float scaleY);
SPINE_CPP_LITE_EXPORT float spine_region_attachment_get_width(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_region_attachment_set_width(spine_region_attachment attachment, float width);
SPINE_CPP_LITE_EXPORT float spine_region_attachment_get_height(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_region_attachment_set_height(spine_region_attachment attachment, float height);
SPINE_CPP_LITE_EXPORT spine_color spine_region_attachment_get_color(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_region_attachment_set_color(spine_region_attachment attachment, float r, float g, float b, float a);
SPINE_CPP_LITE_EXPORT const utf8 *spine_region_attachment_get_path(spine_region_attachment attachment);
// OMITTED setPath()
// @optional
SPINE_CPP_LITE_EXPORT spine_texture_region spine_region_attachment_get_region(spine_region_attachment attachment);
// OMITTED setRegion()
// @optional
SPINE_CPP_LITE_EXPORT spine_sequence spine_region_attachment_get_sequence(spine_region_attachment attachment);
// OMITTED setSequence()
SPINE_CPP_LITE_EXPORT int32_t spine_region_attachment_get_num_offset(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT float *spine_region_attachment_get_offset(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT int32_t spine_region_attachment_get_num_uvs(spine_region_attachment attachment);
SPINE_CPP_LITE_EXPORT float *spine_region_attachment_get_uvs(spine_region_attachment attachment);

SPINE_CPP_LITE_EXPORT int32_t spine_vertex_attachment_get_world_vertices_length(spine_vertex_attachment attachment);
// @ignore
SPINE_CPP_LITE_EXPORT void spine_vertex_attachment_compute_world_vertices(spine_vertex_attachment attachment, spine_slot slot, float *worldVertices);
// OMITTED getId()
SPINE_CPP_LITE_EXPORT int32_t spine_vertex_attachment_get_num_bones(spine_vertex_attachment attachment);
SPINE_CPP_LITE_EXPORT int32_t *spine_vertex_attachment_get_bones(spine_vertex_attachment attachment);
SPINE_CPP_LITE_EXPORT int32_t spine_vertex_attachment_get_num_vertices(spine_vertex_attachment attachment);
SPINE_CPP_LITE_EXPORT float *spine_vertex_attachment_get_vertices(spine_vertex_attachment attachment);
// @optional
SPINE_CPP_LITE_EXPORT spine_attachment spine_vertex_attachment_get_timeline_attachment(spine_vertex_attachment timelineAttachment);
SPINE_CPP_LITE_EXPORT void spine_vertex_attachment_set_timeline_attachment(spine_vertex_attachment attachment, spine_attachment timelineAttachment);
// OMITTED copyTo()

SPINE_CPP_LITE_EXPORT void spine_mesh_attachment_update_region(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT int32_t spine_mesh_attachment_get_hull_length(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_mesh_attachment_set_hull_length(spine_mesh_attachment attachment, int32_t hullLength);
SPINE_CPP_LITE_EXPORT int32_t spine_mesh_attachment_get_num_region_uvs(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT float *spine_mesh_attachment_get_region_uvs(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT int32_t spine_mesh_attachment_get_num_uvs(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT float *spine_mesh_attachment_get_uvs(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT int32_t spine_mesh_attachment_get_num_triangles(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT uint16_t *spine_mesh_attachment_get_triangles(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT spine_color spine_mesh_attachment_get_color(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_mesh_attachment_set_color(spine_mesh_attachment attachment, float r, float g, float b, float a);
SPINE_CPP_LITE_EXPORT const utf8 *spine_mesh_attachment_get_path(spine_mesh_attachment attachment);
// OMITTED setPath()
SPINE_CPP_LITE_EXPORT spine_texture_region spine_mesh_attachment_get_region(spine_mesh_attachment attachment);
// OMITTED setRegion()
// @optional
SPINE_CPP_LITE_EXPORT spine_sequence spine_mesh_attachment_get_sequence(spine_mesh_attachment attachment);
// OMITTED setSequence()
// @optional
SPINE_CPP_LITE_EXPORT spine_mesh_attachment spine_mesh_attachment_get_parent_mesh(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_mesh_attachment_set_parent_mesh(spine_mesh_attachment attachment, spine_mesh_attachment parentMesh);
SPINE_CPP_LITE_EXPORT int32_t spine_mesh_attachment_get_num_edges(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT uint16_t *spine_mesh_attachment_get_edges(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT float spine_mesh_attachment_get_width(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_mesh_attachment_set_width(spine_mesh_attachment attachment, float width);
SPINE_CPP_LITE_EXPORT float spine_mesh_attachment_get_height(spine_mesh_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_mesh_attachment_set_height(spine_mesh_attachment attachment, float height);
// OMITTED newLinkedMesh()

// @optional
SPINE_CPP_LITE_EXPORT spine_slot_data spine_clipping_attachment_get_end_slot(spine_clipping_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_clipping_attachment_set_end_slot(spine_clipping_attachment attachment, spine_slot_data endSlot);
SPINE_CPP_LITE_EXPORT spine_color spine_clipping_attachment_get_color(spine_clipping_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_clipping_attachment_set_color(spine_clipping_attachment attachment, float r, float g, float b, float a);

SPINE_CPP_LITE_EXPORT spine_color spine_bounding_box_attachment_get_color(spine_bounding_box_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_bounding_box_attachment_set_color(spine_bounding_box_attachment attachment, float r, float g, float b, float a);

SPINE_CPP_LITE_EXPORT int32_t spine_path_attachment_get_num_lengths(spine_path_attachment attachment);
SPINE_CPP_LITE_EXPORT float *spine_path_attachment_get_lengths(spine_path_attachment attachment);
SPINE_CPP_LITE_EXPORT spine_bool spine_path_attachment_get_is_closed(spine_path_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_path_attachment_set_is_closed(spine_path_attachment attachment, spine_bool isClosed);
SPINE_CPP_LITE_EXPORT spine_bool spine_path_attachment_get_is_constant_speed(spine_path_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_path_attachment_set_is_constant_speed(spine_path_attachment attachment, spine_bool isConstantSpeed);
SPINE_CPP_LITE_EXPORT spine_color spine_path_attachment_get_color(spine_path_attachment attachment);
SPINE_CPP_LITE_EXPORT void spine_path_attachment_set_color(spine_path_attachment attachment, float r, float g, float b, float a);

SPINE_CPP_LITE_EXPORT void spine_skin_set_attachment(spine_skin skin, int32_t slotIndex, const utf8 *name, spine_attachment attachment);
// @optional
SPINE_CPP_LITE_EXPORT spine_attachment spine_skin_get_attachment(spine_skin skin, int32_t slotIndex, const utf8 *name);
SPINE_CPP_LITE_EXPORT void spine_skin_remove_attachment(spine_skin skin, int32_t slotIndex, const utf8 *name);
// OMITTED findNamesForSlot()
// OMITTED findAttachmentsForSlot()
// OMITTED getColor()
SPINE_CPP_LITE_EXPORT const utf8 *spine_skin_get_name(spine_skin skin);
SPINE_CPP_LITE_EXPORT void spine_skin_add_skin(spine_skin skin, spine_skin other);
SPINE_CPP_LITE_EXPORT void spine_skin_copy_skin(spine_skin skin, spine_skin other);
SPINE_CPP_LITE_EXPORT spine_skin_entries spine_skin_get_entries(spine_skin skin);
SPINE_CPP_LITE_EXPORT int32_t spine_skin_entries_get_num_entries(spine_skin_entries entries);
SPINE_CPP_LITE_EXPORT spine_skin_entry spine_skin_entries_get_entry(spine_skin_entries entries, int32_t index);
SPINE_CPP_LITE_EXPORT void spine_skin_entries_dispose(spine_skin_entries entries);
SPINE_CPP_LITE_EXPORT int32_t spine_skin_entry_get_slot_index(spine_skin_entry entry);
SPINE_CPP_LITE_EXPORT utf8 *spine_skin_entry_get_name(spine_skin_entry entry);
SPINE_CPP_LITE_EXPORT spine_attachment spine_skin_entry_get_attachment(spine_skin_entry entry);
SPINE_CPP_LITE_EXPORT int32_t spine_skin_get_num_bones(spine_skin skin);
SPINE_CPP_LITE_EXPORT spine_bone_data *spine_skin_get_bones(spine_skin skin);
SPINE_CPP_LITE_EXPORT int32_t spine_skin_get_num_constraints(spine_skin skin);
SPINE_CPP_LITE_EXPORT spine_constraint_data *spine_skin_get_constraints(spine_skin skin);
// @ignore
SPINE_CPP_LITE_EXPORT spine_skin spine_skin_create(const utf8 *name);
SPINE_CPP_LITE_EXPORT void spine_skin_dispose(spine_skin skin);

SPINE_CPP_LITE_EXPORT spine_constraint_type spine_constraint_data_get_type(spine_constraint_data data);
SPINE_CPP_LITE_EXPORT const utf8 *spine_constraint_data_get_name(spine_constraint_data data);
SPINE_CPP_LITE_EXPORT uint64_t spine_constraint_data_get_order(spine_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_constraint_data_set_order(spine_constraint_data data, uint64_t order);
SPINE_CPP_LITE_EXPORT spine_bool spine_constraint_data_get_is_skin_required(spine_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_constraint_data_set_is_skin_required(spine_constraint_data data, spine_bool isSkinRequired);

SPINE_CPP_LITE_EXPORT int32_t spine_ik_constraint_data_get_num_bones(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT spine_bone_data *spine_ik_constraint_data_get_bones(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT spine_bone_data spine_ik_constraint_data_get_target(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_data_set_target(spine_ik_constraint_data data, spine_bone_data target);
SPINE_CPP_LITE_EXPORT int32_t spine_ik_constraint_data_get_bend_direction(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_data_set_bend_direction(spine_ik_constraint_data data, int32_t bendDirection);
SPINE_CPP_LITE_EXPORT spine_bool spine_ik_constraint_data_get_compress(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_data_set_compress(spine_ik_constraint_data data, spine_bool compress);
SPINE_CPP_LITE_EXPORT spine_bool spine_ik_constraint_data_get_stretch(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_data_set_stretch(spine_ik_constraint_data data, spine_bool stretch);
SPINE_CPP_LITE_EXPORT spine_bool spine_ik_constraint_data_get_uniform(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_data_set_uniform(spine_ik_constraint_data data, spine_bool uniform);
SPINE_CPP_LITE_EXPORT float spine_ik_constraint_data_get_mix(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_data_set_mix(spine_ik_constraint_data data, float mix);
SPINE_CPP_LITE_EXPORT float spine_ik_constraint_data_get_softness(spine_ik_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_data_set_softness(spine_ik_constraint_data data, float softness);

SPINE_CPP_LITE_EXPORT void spine_ik_constraint_update(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT int32_t spine_ik_constraint_get_order(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_ik_constraint_data spine_ik_constraint_get_data(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT int32_t spine_ik_constraint_get_num_bones(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_bone *spine_ik_constraint_get_bones(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_bone spine_ik_constraint_get_target(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_set_target(spine_ik_constraint constraint, spine_bone target);
SPINE_CPP_LITE_EXPORT int32_t spine_ik_constraint_get_bend_direction(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_set_bend_direction(spine_ik_constraint constraint, int32_t bendDirection);
SPINE_CPP_LITE_EXPORT spine_bool spine_ik_constraint_get_compress(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_set_compress(spine_ik_constraint constraint, spine_bool compress);
SPINE_CPP_LITE_EXPORT spine_bool spine_ik_constraint_get_stretch(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_set_stretch(spine_ik_constraint constraint, spine_bool stretch);
SPINE_CPP_LITE_EXPORT float spine_ik_constraint_get_mix(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_set_mix(spine_ik_constraint constraint, float mix);
SPINE_CPP_LITE_EXPORT float spine_ik_constraint_get_softness(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_set_softness(spine_ik_constraint constraint, float softness);
SPINE_CPP_LITE_EXPORT spine_bool spine_ik_constraint_get_is_active(spine_ik_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_ik_constraint_set_is_active(spine_ik_constraint constraint, spine_bool isActive);
// OMITTED setToSetupPose()

SPINE_CPP_LITE_EXPORT int32_t spine_transform_constraint_data_get_num_bones(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT spine_bone_data *spine_transform_constraint_data_get_bones(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT spine_bone_data spine_transform_constraint_data_get_target(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_target(spine_transform_constraint_data data, spine_bone_data target);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_mix_rotate(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_mix_rotate(spine_transform_constraint_data data, float mixRotate);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_mix_x(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_mix_x(spine_transform_constraint_data data, float mixX);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_mix_y(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_mix_y(spine_transform_constraint_data data, float mixY);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_mix_scale_x(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_mix_scale_x(spine_transform_constraint_data data, float mixScaleX);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_mix_scale_y(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_mix_scale_y(spine_transform_constraint_data data, float mixScaleY);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_mix_shear_y(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_mix_shear_y(spine_transform_constraint_data data, float mixShearY);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_offset_rotation(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_offset_rotation(spine_transform_constraint_data data, float offsetRotation);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_offset_x(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_offset_x(spine_transform_constraint_data data, float offsetX);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_offset_y(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_offset_y(spine_transform_constraint_data data, float offsetY);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_offset_scale_x(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_offset_scale_x(spine_transform_constraint_data data, float offsetScaleX);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_offset_scale_y(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_offset_scale_y(spine_transform_constraint_data data, float offsetScaleY);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_data_get_offset_shear_y(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_offset_shear_y(spine_transform_constraint_data data, float offsetShearY);
SPINE_CPP_LITE_EXPORT spine_bool spine_transform_constraint_data_get_is_relative(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_is_relative(spine_transform_constraint_data data, spine_bool isRelative);
SPINE_CPP_LITE_EXPORT spine_bool spine_transform_constraint_data_get_is_local(spine_transform_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_data_set_is_local(spine_transform_constraint_data data, spine_bool isLocal);

SPINE_CPP_LITE_EXPORT void spine_transform_constraint_update(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT int32_t spine_transform_constraint_get_order(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_transform_constraint_data spine_transform_constraint_get_data(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT int32_t spine_transform_constraint_get_num_bones(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_bone *spine_transform_constraint_get_bones(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_bone spine_transform_constraint_get_target(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_set_target(spine_transform_constraint constraint, spine_bone target);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_get_mix_rotate(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_set_mix_rotate(spine_transform_constraint constraint, float mixRotate);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_get_mix_x(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_set_mix_x(spine_transform_constraint constraint, float mixX);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_get_mix_y(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_set_mix_y(spine_transform_constraint constraint, float mixY);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_get_mix_scale_x(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_set_mix_scale_x(spine_transform_constraint constraint, float mixScaleX);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_get_mix_scale_y(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_set_mix_scale_y(spine_transform_constraint constraint, float mixScaleY);
SPINE_CPP_LITE_EXPORT float spine_transform_constraint_get_mix_shear_y(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_set_mix_shear_y(spine_transform_constraint constraint, float mixShearY);
SPINE_CPP_LITE_EXPORT spine_bool spine_transform_constraint_get_is_active(spine_transform_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_transform_constraint_set_is_active(spine_transform_constraint constraint, spine_bool isActive);

// OMITTED setToSetupPose()

SPINE_CPP_LITE_EXPORT int32_t spine_path_constraint_data_get_num_bones(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT spine_bone_data *spine_path_constraint_data_get_bones(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT spine_slot_data spine_path_constraint_data_get_target(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_target(spine_path_constraint_data data, spine_slot_data target);
SPINE_CPP_LITE_EXPORT spine_position_mode spine_path_constraint_data_get_position_mode(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_position_mode(spine_path_constraint_data data, spine_position_mode positionMode);
SPINE_CPP_LITE_EXPORT spine_spacing_mode spine_path_constraint_data_get_spacing_mode(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_spacing_mode(spine_path_constraint_data data, spine_spacing_mode spacingMode);
SPINE_CPP_LITE_EXPORT spine_rotate_mode spine_path_constraint_data_get_rotate_mode(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_rotate_mode(spine_path_constraint_data data, spine_rotate_mode rotateMode);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_data_get_offset_rotation(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_offset_rotation(spine_path_constraint_data data, float offsetRotation);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_data_get_position(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_position(spine_path_constraint_data data, float position);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_data_get_spacing(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_spacing(spine_path_constraint_data data, float spacing);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_data_get_mix_rotate(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_mix_rotate(spine_path_constraint_data data, float mixRotate);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_data_get_mix_x(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_mix_x(spine_path_constraint_data data, float mixX);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_data_get_mix_y(spine_path_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_data_set_mix_y(spine_path_constraint_data data, float mixY);

SPINE_CPP_LITE_EXPORT void spine_path_constraint_update(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT int32_t spine_path_constraint_get_order(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_path_constraint_data spine_path_constraint_get_data(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT int32_t spine_path_constraint_get_num_bones(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_bone *spine_path_constraint_get_bones(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT spine_slot spine_path_constraint_get_target(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_set_target(spine_path_constraint constraint, spine_slot target);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_get_position(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_set_position(spine_path_constraint constraint, float position);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_get_spacing(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_set_spacing(spine_path_constraint constraint, float spacing);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_get_mix_rotate(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_set_mix_rotate(spine_path_constraint constraint, float mixRotate);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_get_mix_x(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_set_mix_x(spine_path_constraint constraint, float mixX);
SPINE_CPP_LITE_EXPORT float spine_path_constraint_get_mix_y(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_set_mix_y(spine_path_constraint constraint, float mixY);
SPINE_CPP_LITE_EXPORT spine_bool spine_path_constraint_get_is_active(spine_path_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_path_constraint_set_is_active(spine_path_constraint constraint, spine_bool isActive);
// OMITTED setToSetupPose()

SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_bone(spine_physics_constraint_data data, spine_bone_data bone);
SPINE_CPP_LITE_EXPORT spine_bone_data spine_physics_constraint_data_get_bone(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_x(spine_physics_constraint_data data, float x);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_x(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_y(spine_physics_constraint_data data, float y);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_y(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_rotate(spine_physics_constraint_data data, float rotate);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_rotate(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_scale_x(spine_physics_constraint_data data, float scaleX);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_scale_x(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_shear_x(spine_physics_constraint_data data, float shearX);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_shear_x(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_limit(spine_physics_constraint_data data, float limit);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_limit(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_step(spine_physics_constraint_data data, float step);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_step(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_inertia(spine_physics_constraint_data data, float inertia);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_inertia(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_strength(spine_physics_constraint_data data, float strength);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_strength(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_damping(spine_physics_constraint_data data, float damping);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_damping(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_mass_inverse(spine_physics_constraint_data data, float massInverse);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_mass_inverse(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_wind(spine_physics_constraint_data data, float wind);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_wind(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_gravity(spine_physics_constraint_data data, float gravity);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_gravity(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_mix(spine_physics_constraint_data data, float mix);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_data_get_mix(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_inertia_global(spine_physics_constraint_data data, spine_bool inertiaGlobal);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_data_is_inertia_global(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_strength_global(spine_physics_constraint_data data, spine_bool strengthGlobal);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_data_is_strength_global(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_damping_global(spine_physics_constraint_data data, spine_bool dampingGlobal);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_data_is_damping_global(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_mass_global(spine_physics_constraint_data data, spine_bool massGlobal);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_data_is_mass_global(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_wind_global(spine_physics_constraint_data data, spine_bool windGlobal);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_data_is_wind_global(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_gravity_global(spine_physics_constraint_data data, spine_bool gravityGlobal);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_data_is_gravity_global(spine_physics_constraint_data data);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_data_set_mix_global(spine_physics_constraint_data data, spine_bool mixGlobal);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_data_is_mix_global(spine_physics_constraint_data data);

SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_bone(spine_physics_constraint constraint, spine_bone bone);
SPINE_CPP_LITE_EXPORT spine_bone spine_physics_constraint_get_bone(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_inertia(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_inertia(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_strength(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_strength(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_damping(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_damping(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_mass_inverse(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_mass_inverse(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_wind(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_wind(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_gravity(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_gravity(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_mix(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_mix(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_reset(spine_physics_constraint constraint, spine_bool value);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_get_reset(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_ux(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_ux(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_uy(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_uy(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_cx(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_cx(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_cy(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_cy(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_tx(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_tx(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_ty(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_ty(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_x_offset(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_x_offset(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_x_velocity(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_x_velocity(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_y_offset(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_y_offset(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_y_velocity(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_y_velocity(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_rotate_offset(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_rotate_offset(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_rotate_velocity(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_rotate_velocity(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_scale_offset(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_scale_offset(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_scale_velocity(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_scale_velocity(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_active(spine_physics_constraint constraint, spine_bool value);
SPINE_CPP_LITE_EXPORT spine_bool spine_physics_constraint_is_active(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_remaining(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_remaining(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_set_last_time(spine_physics_constraint constraint, float value);
SPINE_CPP_LITE_EXPORT float spine_physics_constraint_get_last_time(spine_physics_constraint constraint);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_reset_fully(spine_physics_constraint constraint);
// Omitted setToSetupPose()
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_update(spine_physics_constraint data, spine_physics physics);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_translate(spine_physics_constraint data, float x, float y);
SPINE_CPP_LITE_EXPORT void spine_physics_constraint_rotate(spine_physics_constraint data, float x, float y, float degrees);


// OMITTED copy()
SPINE_CPP_LITE_EXPORT void spine_sequence_apply(spine_sequence sequence, spine_slot slot, spine_attachment attachment);
SPINE_CPP_LITE_EXPORT const utf8 *spine_sequence_get_path(spine_sequence sequence, const utf8 *basePath, int32_t index);
SPINE_CPP_LITE_EXPORT int32_t spine_sequence_get_id(spine_sequence sequence);
SPINE_CPP_LITE_EXPORT void spine_sequence_set_id(spine_sequence sequence, int32_t id);
SPINE_CPP_LITE_EXPORT int32_t spine_sequence_get_start(spine_sequence sequence);
SPINE_CPP_LITE_EXPORT void spine_sequence_set_start(spine_sequence sequence, int32_t start);
SPINE_CPP_LITE_EXPORT int32_t spine_sequence_get_digits(spine_sequence sequence);
SPINE_CPP_LITE_EXPORT void spine_sequence_set_digits(spine_sequence sequence, int32_t digits);
SPINE_CPP_LITE_EXPORT int32_t spine_sequence_get_setup_index(spine_sequence sequence);
SPINE_CPP_LITE_EXPORT void spine_sequence_set_setup_index(spine_sequence sequence, int32_t setupIndex);
SPINE_CPP_LITE_EXPORT int32_t spine_sequence_get_num_regions(spine_sequence sequence);
SPINE_CPP_LITE_EXPORT spine_texture_region *spine_sequence_get_regions(spine_sequence sequence);

SPINE_CPP_LITE_EXPORT void *spine_texture_region_get_texture(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_texture(spine_texture_region textureRegion, void *texture);
SPINE_CPP_LITE_EXPORT float spine_texture_region_get_u(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_u(spine_texture_region textureRegion, float u);
SPINE_CPP_LITE_EXPORT float spine_texture_region_get_v(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_v(spine_texture_region textureRegion, float v);
SPINE_CPP_LITE_EXPORT float spine_texture_region_get_u2(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_u2(spine_texture_region textureRegion, float u2);
SPINE_CPP_LITE_EXPORT float spine_texture_region_get_v2(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_v2(spine_texture_region textureRegion, float v2);
SPINE_CPP_LITE_EXPORT int32_t spine_texture_region_get_degrees(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_degrees(spine_texture_region textureRegion, int32_t degrees);
SPINE_CPP_LITE_EXPORT float spine_texture_region_get_offset_x(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_offset_x(spine_texture_region textureRegion, float offsetX);
SPINE_CPP_LITE_EXPORT float spine_texture_region_get_offset_y(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_offset_y(spine_texture_region textureRegion, float offsetY);
SPINE_CPP_LITE_EXPORT int32_t spine_texture_region_get_width(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_width(spine_texture_region textureRegion, int32_t width);
SPINE_CPP_LITE_EXPORT int32_t spine_texture_region_get_height(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_height(spine_texture_region textureRegion, int32_t height);
SPINE_CPP_LITE_EXPORT int32_t spine_texture_region_get_original_width(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_original_width(spine_texture_region textureRegion, int32_t originalWidth);
SPINE_CPP_LITE_EXPORT int32_t spine_texture_region_get_original_height(spine_texture_region textureRegion);
SPINE_CPP_LITE_EXPORT void spine_texture_region_set_original_height(spine_texture_region textureRegion, int32_t originalHeight);

// @end: function_declarations

#endif
