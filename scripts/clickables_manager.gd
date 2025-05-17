extends Node3D

signal object_clicked(clicked_object)

# References to parent game manager
var game_manager
var camera

# Input handling
var camera_ray_length = 1000

func _ready():
	game_manager = get_parent()
	camera = game_manager.get_node("Camera3D")
	
	# Add the initial objects to their groups
	var initial_cube = $Cubes/Cube
	initial_cube.add_to_group("spawned_cubes")
	
	var initial_sphere = $Spheres/Sphere
	initial_sphere.add_to_group("spawned_spheres")

func _process(_delta):
	# Handle clicking
	if Input.is_action_just_pressed("click"):
		handle_click_detection()

func handle_click_detection():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Handle ray casting differently for orthogonal projection
	var ray_origin
	var ray_end
	
	if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		# For orthogonal projection, cast a ray from the mouse position into the scene
		ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_normal = camera.project_ray_normal(mouse_pos)
		ray_end = ray_origin + ray_normal * camera_ray_length
	else:
		# For perspective projection
		ray_origin = camera.global_position
		var camera_ray = camera.project_ray_normal(mouse_pos)
		ray_end = ray_origin + camera_ray * camera_ray_length
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		print("Clicked object: ", collider.name, " - is in cubes: ", collider.is_in_group("spawned_cubes"), " - is in spheres: ", collider.is_in_group("spawned_spheres"))
		
		# Check if the collider is one of our clickable objects
		if is_node_child_of(collider, self):
			handle_click(collider)

# Helper function to check if a node is a child of this node (directly or indirectly)
func is_node_child_of(node, parent):
	var current = node
	while current:
		if current.get_parent() == parent:
			return true
		current = current.get_parent()
	return false

# This function will be called when an object is clicked
func handle_click(clicked_object):
	emit_signal("object_clicked", clicked_object)
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(clicked_object, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
	tween.tween_property(clicked_object, "scale", Vector3(1, 1, 1), 0.1)

# Function to spawn a new cube
func spawn_cube(spawn_position = null):
	var cube_scene = preload("res://scenes/clickable_cube.tscn")
	var new_cube = cube_scene.instantiate()
	$Cubes.add_child(new_cube)
	new_cube.add_to_group("spawned_cubes")
	
	# Set position
	if spawn_position:
		new_cube.position = spawn_position
	else:
		# Random position within a reasonable range
		var random_x = randf_range(-5, 5)
		var random_z = randf_range(-5, 5)
		new_cube.position = Vector3(random_x, 0, random_z)
	
	# Add spawn animation
	new_cube.scale = Vector3(0.1, 0.1, 0.1)
	var spawn_tween = create_tween()
	spawn_tween.tween_property(new_cube, "scale", Vector3(1, 1, 1), 0.3).set_trans(Tween.TRANS_ELASTIC)
	
	return new_cube

# Function to spawn a new sphere
func spawn_sphere(spawn_position = null):
	# Create a sphere similar to the existing one
	var sphere = RigidBody3D.new()
	$Spheres.add_child(sphere)
	sphere.add_to_group("spawned_spheres")
	
	# Add collision shape
	var collision_shape = CollisionShape3D.new()
	sphere.add_child(collision_shape)
	var shape = SphereShape3D.new()
	collision_shape.shape = shape
	
	# Add mesh
	var mesh_instance = MeshInstance3D.new()
	sphere.add_child(mesh_instance)
	var sphere_mesh = SphereMesh.new()
	mesh_instance.mesh = sphere_mesh
	
	# Set position
	if spawn_position:
		sphere.position = spawn_position
	else:
		# Random position within a reasonable range
		var random_x = randf_range(-5, 5)
		var random_z = randf_range(-5, 5)
		sphere.position = Vector3(random_x, 1, random_z) # Slightly higher to avoid floor collision
	
	# Add spawn animation
	sphere.scale = Vector3(0.1, 0.1, 0.1)
	var spawn_tween = create_tween()
	spawn_tween.tween_property(sphere, "scale", Vector3(1, 1, 1), 0.3).set_trans(Tween.TRANS_ELASTIC)
	
	return sphere
