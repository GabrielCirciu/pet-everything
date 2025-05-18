extends Node3D

signal object_spawned(object)

# References to parent game manager
var game_manager
var camera

# Collision layers - CLEAR DEFINITIONS
# Layer 1: Floor (0b00000001)
# Layer 2: Clickable objects (0b00000010)
# Layer 3: Walls (0b00000100)
const LAYER_FLOOR = 1
const LAYER_CLICKABLE = 2
const LAYER_WALLS = 4
const ALL_LAYERS = 0xFFFFFFFF  # All 32 bits set (for debugging)

func _ready():
	game_manager = get_parent()
	camera = game_manager.get_node("Camera3D")
	
	# Set collision layers for environment - FORCE these values regardless of scene settings
	var environment = get_node("../Enviornment")
	var floor_node = environment.get_node("Floor")
	floor_node.collision_layer = LAYER_FLOOR
	print("Forcing floor collision layer to: ", LAYER_FLOOR)
	
	var walls = environment.get_node("Walls-Invisible")
	walls.collision_layer = LAYER_WALLS
	print("Forcing walls collision layer to: ", LAYER_WALLS)
	
	# Configure all objects with proper collision settings
	for sphere in $Spheres.get_children():
		sphere.add_to_group("spawned_spheres")
		sphere.collision_layer = LAYER_CLICKABLE
		sphere.collision_mask = LAYER_FLOOR | LAYER_WALLS | LAYER_CLICKABLE  # Collide with floor, walls and other objects
		print("Updated sphere: ", sphere.name, " - collision_layer: ", sphere.collision_layer, " - collision_mask: ", sphere.collision_mask)
	
	print("Collision layers set up. Floor: ", LAYER_FLOOR, ", Clickable: ", LAYER_CLICKABLE, ", Walls: ", LAYER_WALLS)
	print("Camera projection: ", "Orthogonal" if camera.projection == Camera3D.PROJECTION_ORTHOGONAL else "Perspective")

# Function to spawn a new sphere
func spawn_sphere(spawn_position = null):
	var sphere_scene = preload("res://scenes/clickable_sphere.tscn")
	var new_sphere = sphere_scene.instantiate()
	$Spheres.add_child(new_sphere)
	new_sphere.add_to_group("spawned_spheres")
	
	# Set collision settings explicitly to ensure consistency
	new_sphere.collision_layer = LAYER_CLICKABLE
	new_sphere.collision_mask = LAYER_FLOOR | LAYER_WALLS | LAYER_CLICKABLE
	
	print("New sphere spawned with collision_layer: ", new_sphere.collision_layer, ", collision_mask: ", new_sphere.collision_mask)
	
	# Set position
	if spawn_position:
		new_sphere.position = spawn_position
	else:
		# Random position within a reasonable range
		var random_x = randf_range(-4.5, 4.5)
		var random_z = randf_range(-4.5, 4.5)
		new_sphere.position = Vector3(random_x, 3, random_z)  # Start higher to avoid floor collision issues
	
	# Add spawn animation
	new_sphere.scale = Vector3(0.1, 0.1, 0.1)
	var spawn_tween = create_tween()
	spawn_tween.tween_property(new_sphere, "scale", Vector3(1, 1, 1), 0.3).set_trans(Tween.TRANS_ELASTIC)
	
	# Emit signal that a new object was spawned
	emit_signal("object_spawned", new_sphere)
	
	return new_sphere

# Get all clickable objects currently in the scene
func get_all_clickable_objects():
	return $Spheres.get_children()
