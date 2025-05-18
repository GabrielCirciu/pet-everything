extends Node3D

signal object_clicked(clicked_object)
signal objects_clicked(objects)

# References to other managers
var game_manager
var spawner
var camera

# Input handling
var camera_ray_length = 1000

# Auto-click feature
var is_mouse_held = false
var click_timer = 0.0
var click_interval = 0.2  # 5 clicks per second

# Area click feature
var click_radius = 0.0  # Start with no radius clicking
var base_radius = 1.0   # Base radius
var radius_growth_factor = 0.5  # How much radius increases per level

# Collision layer constants (must match spawner)
const LAYER_FLOOR = 1
const LAYER_CLICKABLE = 2
const LAYER_WALLS = 4

func _ready():
	game_manager = get_parent()
	camera = game_manager.get_node("Camera3D")
	spawner = game_manager.get_node("SpawnManager")  # Assuming the renamed node
	print("Click manager initialized")

func _process(delta):
	# Handle single click when button is first pressed
	if Input.is_action_just_pressed("click"):
		print("Click detected!")
		is_mouse_held = true
		handle_click_detection()
		
	# Handle mouse release
	if Input.is_action_just_released("click"):
		is_mouse_held = false
		click_timer = 0.0
		
	# Handle auto-clicking when mouse is held down
	if is_mouse_held:
		click_timer += delta
		if click_timer >= click_interval:
			handle_click_detection()
			click_timer = 0.0  # Reset the timer after click

func handle_click_detection():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	print("Click position: ", mouse_pos)
	
	# Cast a ray from the camera through the mouse position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_normal = camera.project_ray_normal(mouse_pos).normalized()
	var ray_end = ray_origin + ray_normal * camera_ray_length
	
	# Get a point on the ray (for click position reference)
	var click_position = get_click_position_on_floor(ray_origin, ray_normal, space_state)
	
	# Detect objects based on click radius
	if click_radius > 0:
		# Area click mode - get all objects in cylinder
		var objects_in_cylinder = get_objects_in_cylinder(ray_origin, ray_normal, click_radius)
		
		if objects_in_cylinder.size() > 0:
			# Highlight all objects
			for obj in objects_in_cylinder:
				provide_click_feedback(obj)
				
			# Emit signal for all clicked objects
			emit_signal("objects_clicked", objects_in_cylinder)
			print("Clicked ", objects_in_cylinder.size(), " objects")
		else:
			print("No objects found in click area")
	else:
		# Direct hit mode - single object
		var object_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		object_query.collide_with_bodies = true
		object_query.collision_mask = LAYER_CLICKABLE
		var object_result = space_state.intersect_ray(object_query)
		
		if object_result and is_clickable_object(object_result.collider):
			var clicked_object = object_result.collider
			provide_click_feedback(clicked_object)
			emit_signal("object_clicked", clicked_object)
			print("Clicked object: ", clicked_object.name)
		else:
			print("No direct hit on object")

# Helper to find where the click ray hits the floor
func get_click_position_on_floor(ray_origin, ray_normal, space_state):
	var ray_end = ray_origin + ray_normal * camera_ray_length
	
	# First try hitting the floor directly
	var floor_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	floor_query.collide_with_bodies = true
	floor_query.collision_mask = LAYER_FLOOR
	var floor_result = space_state.intersect_ray(floor_query)
	
	if floor_result:
		return floor_result.position
	
	# Try using plane intersection with the floor
	var floor_plane = Plane(Vector3.UP, 0)  # y=0 plane
	var intersection = floor_plane.intersects_ray(ray_origin, ray_normal)
	
	if intersection:
		return intersection
	
	# Orthogonal camera special case: Project mouse position to world space
	if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var viewport_size = get_viewport().size
		var view_width = camera.size
		var view_height = view_width * (viewport_size.y / viewport_size.x)
		
		# Calculate relative position in viewport (0-1)
		var mouse_pos = get_viewport().get_mouse_position()
		var rel_x = mouse_pos.x / viewport_size.x
		var rel_y = mouse_pos.y / viewport_size.y
		
		# Convert to world space coordinates
		var camera_basis = camera.global_transform.basis
		var camera_origin = camera.global_transform.origin
		
		# Calculate offsets from camera center
		var offset_x = (rel_x - 0.5) * view_width
		var offset_y = (0.5 - rel_y) * view_height  # Y is inverted
		
		# Project point forward from camera
		var point = camera_origin
		point += camera_basis.x * offset_x   # Right/left
		point += camera_basis.y * offset_y   # Up/down
		
		# Cast down to find the floor
		var down_origin = point + camera_basis.z * -5  # Start above
		var down_end = point + camera_basis.z * 10     # End below
		
		var down_query = PhysicsRayQueryParameters3D.create(down_origin, down_end)
		down_query.collision_mask = LAYER_FLOOR
		var down_result = space_state.intersect_ray(down_query)

		if down_result:
			return down_result.position
		
		# Last resort: use a fixed Y coordinate
		return Vector3(point.x, 0, point.z)
	
	# Default fallback
	return Vector3.ZERO

# Get all objects that intersect with a cylinder along the given ray
func get_objects_in_cylinder(ray_origin, ray_direction, cylinder_radius):
	var objects_in_cylinder = []
	
	# Check each sphere
	var clickable_objects = spawner.get_all_clickable_objects()
	for object in clickable_objects:
		if object.is_in_group("spawned_spheres"):
			# Get the vector from ray origin to sphere center
			var to_object = object.global_position - ray_origin
			
			# Project this vector onto the ray direction to find closest point
			var projection = to_object.dot(ray_direction)
			var closest_point_on_ray = ray_origin + ray_direction * projection
			
			# Find the perpendicular distance from the object center to the ray
			var perpendicular_distance = (object.global_position - closest_point_on_ray).length()
			
			# If within cylinder radius, include it
			if perpendicular_distance <= cylinder_radius:
				objects_in_cylinder.append(object)
	
	return objects_in_cylinder

# Increase the click radius based on level
func increase_click_radius(level):
	if level <= 0:
		click_radius = 0.0  # Disable radius clicking
	else:
		click_radius = base_radius + (level - 1) * radius_growth_factor
	
	print("Click radius increased to level ", level, " (", click_radius, " units)")
	return click_radius

# Helper function to check if a node is a clickable object
func is_clickable_object(node):
	return node.is_in_group("spawned_spheres")

# Provide visual feedback for a clicked object
func provide_click_feedback(object):
	# Scale animation for feedback
	var tween = create_tween()
	tween.tween_property(object, "scale", Vector3(0.9, 0.9, 0.9), 0.1)
	tween.tween_property(object, "scale", Vector3(1, 1, 1), 0.1) 