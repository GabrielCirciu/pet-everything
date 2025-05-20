extends Node

# References
var camera
var entities
var ui_manager
var mouse_pos

# Clicking
var camera_ray_length = 100  # How far can the camera see, 100 is good for now, might need to be bigger
var click_radius = 0.5  # Start with small radius clicking
var click_held_down = false
var click_hold_enabled = false
var click_hold_interval = 0.2  # Clicks every 0.2 seconds
var click_hold_timer = 0.0
var auto_click_enabled = false
var auto_click_position = Vector2(0, 0)
var auto_click_interval = 0.2  # Clicks every 0.2 seconds
var auto_click_timer = 0.0


func _ready():
	camera = $%Camera
	entities = $%Entities
	ui_manager = $%UIManager


func _process(delta):
	if Input.is_action_just_pressed("click"):
		click_held_down = true
		mouse_pos = get_viewport().get_mouse_position()
		handle_click_detection(mouse_pos)
	if Input.is_action_just_released("click"):
		click_held_down = false
		click_hold_timer = 0.0
	if click_held_down and click_hold_enabled:
		click_hold_timer += delta
		if click_hold_timer > click_hold_interval:
			mouse_pos = get_viewport().get_mouse_position()
			handle_click_detection(mouse_pos)
			click_hold_timer = 0.0
	if auto_click_enabled:
		auto_click_timer += delta
		if auto_click_timer > auto_click_interval:
			auto_click()
			auto_click_timer = 0.0


func handle_click_detection(click_position):
	# Grabs all vectors needed for the entity finder
	var ray_origin = camera.project_ray_origin(click_position)
	var ray_normal = camera.project_ray_normal(click_position).normalized()
	# Finds where the click ray hits the floor (floor is at (x,0,z))
	var floor_plane = Plane(Vector3.UP, 0)
	var floor_point = floor_plane.intersects_ray(ray_origin, ray_normal)
	# Finds all entities in the click radius
	var entities_in_click_area = get_entities_in_click_area(floor_point)
	if entities_in_click_area.size() > 0:
		for entity in entities_in_click_area:
			provide_click_feedback(entity)
		ui_manager.entities_clicked(entities_in_click_area)


func get_entities_in_click_area(floor_point):
	var entities_in_click_area = []
	# For orthographic camera, always use the camera's basis
	# The camera is looking down its -Z axis, so we want to point back along +Z
	var camera_direction_vector = camera.global_transform.basis.z
	# Check each entity
	var clickable_entities = entities.get_children()
	for entity in clickable_entities:
		if entity.is_in_group("spawned_entities"):
			# Get the vector from floor point to entity center
			var floor_to_entity_vector = entity.global_position - floor_point
			# Project (which is just rotation tbh) the vector onto the direction to camera
			var projection = floor_to_entity_vector.dot(camera_direction_vector)
			# Move the point to line up with the entity
			var projected_point = floor_point + camera_direction_vector * projection
			# Get the perpendicular distance from the object to the cylinder axis
			var perpendicular_vector = entity.global_position - projected_point
			var radial_distance = perpendicular_vector.length()
			# If within this distance, include it
			if radial_distance < click_radius:
				entities_in_click_area.append(entity)
	return entities_in_click_area


func provide_click_feedback(entity):
	var tween = create_tween()
	tween.tween_property(entity, "scale", Vector3(1.5, 0.5, 1.5), 0.1)
	tween.tween_property(entity, "scale", Vector3(1, 1, 1), 0.1) 


func auto_click():
	# Random position on screen based on get_viewport()
	auto_click_position = Vector2(
		randf_range(0 + get_viewport().get_window().size.x/5.0,
		get_viewport().get_window().size.x - get_viewport().get_window().size.x/5.0),
		randf_range(0 + get_viewport().get_window().size.y/5.0,
		get_viewport().get_window().size.y - get_viewport().get_window().size.y/5.0))
	handle_click_detection(auto_click_position)


func increase_click_radius(click_radius_value):
	click_radius += click_radius_value


func enable_click_hold():
	click_hold_enabled = true


func increase_click_hold_interval(click_hold_interval_increase):
	click_hold_interval *= click_hold_interval_increase


func enable_auto_click():
	auto_click_enabled = true


func increase_auto_click_interval(auto_click_interval_increase):
	auto_click_interval *= auto_click_interval_increase


func get_click_radius():
	return click_radius


func get_click_hold_interval():
	return click_hold_interval


func get_auto_click_interval():
	return auto_click_interval
