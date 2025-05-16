extends Node3D

# Game state variables
var score: float = 100
var score_per_click: float = 1
var score_per_second: float = 0
var auto_clicker_cost: int = 10
var auto_clicker_count: int = 0
var spawn_cube_cost: int = 50

# Node references
@onready var score_label = $UI/VBoxContainer/ScoreLabel
@onready var score_per_second_label = $UI/VBoxContainer/ScorePerSecondLabel
@onready var auto_clicker_button = $UI/VBoxContainer/UpgradesContainer/AutoClickerButton
@onready var spawn_cube_button = $UI/VBoxContainer/UpgradesContainer/SpawnCubeButton
@onready var clickable_object = $ClickableObject
@onready var camera = $Camera3D
@onready var spawned_cubes = $SpawnedCubes

# Preload the cube scene
var cube_scene = preload("res://scenes/clickable_cube.tscn")

# Input handling
var mouse_position = Vector2()
var camera_ray_length = 1000

func _ready():
	# Connect signals
	auto_clicker_button.pressed.connect(_on_auto_clicker_button_pressed)
	spawn_cube_button.pressed.connect(_on_spawn_cube_button_pressed)
	$GameTimer.timeout.connect(_on_game_timer_timeout)
	
	# Load saved game
	# load_game()

func _process(_delta):
	# Update UI
	score_label.text = "Score: " + str(int(score))
	score_per_second_label.text = "Score per second: " + str(score_per_second)
	auto_clicker_button.text = "Buy Auto Clicker (Cost: " + str(auto_clicker_cost) + ")"
	spawn_cube_button.text = "Spawn New Cube (Cost: " + str(spawn_cube_cost) + ")"
	
	# Handle clicking
	if Input.is_action_just_pressed("click"):
		var space_state = get_world_3d().direct_space_state
		var mouse_pos = get_viewport().get_mouse_position()
		var camera_ray = camera.project_ray_normal(mouse_pos)
		var ray_origin = camera.global_position
		var ray_end = ray_origin + camera_ray * camera_ray_length
		
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result = space_state.intersect_ray(query)
		
		if result:
			if result.collider == clickable_object or result.collider.is_in_group("spawned_cube"):
				_on_object_clicked(result.collider)

func _on_object_clicked(clicked_object):
	score += score_per_click
	# save_game()
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(clicked_object, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
	tween.tween_property(clicked_object, "scale", Vector3(1, 1, 1), 0.1)

func _on_auto_clicker_button_pressed():
	if score >= auto_clicker_cost:
		score -= auto_clicker_cost
		auto_clicker_count += 1
		score_per_second += 1
		auto_clicker_cost = int(auto_clicker_cost * 1.1)  # Increase cost by 10%
		save_game()

func _on_spawn_cube_button_pressed():
	if score >= spawn_cube_cost:
		score -= spawn_cube_cost
		score_per_second += 10
		spawn_cube_cost = int(spawn_cube_cost * 1.1)  # Increase cost by 10%
		
		# Spawn new cube at random position
		var new_cube = cube_scene.instantiate()
		spawned_cubes.add_child(new_cube)
		new_cube.add_to_group("spawned_cube")
		
		# Random position within a reasonable range
		var random_x = randf_range(-5, 5)
		var random_z = randf_range(-5, 5)
		new_cube.position = Vector3(random_x, 0, random_z)
		
		# Add spawn animation
		new_cube.scale = Vector3(0.1, 0.1, 0.1)
		var spawn_tween = create_tween()
		spawn_tween.tween_property(new_cube, "scale", Vector3(1, 1, 1), 0.3).set_trans(Tween.TRANS_ELASTIC)
		
		# save_game()

func _on_game_timer_timeout():
	score += score_per_second
	# save_game()

func save_game():
	var save_data = {
		"score": score,
		"score_per_click": score_per_click,
		"score_per_second": score_per_second,
		"auto_clicker_cost": auto_clicker_cost,
		"auto_clicker_count": auto_clicker_count,
		"spawn_cube_cost": spawn_cube_cost
	}
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_var(save_data)

func load_game():
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = save_file.get_var()
		
		score = save_data.score
		score_per_click = save_data.score_per_click
		score_per_second = save_data.score_per_second
		auto_clicker_cost = save_data.auto_clicker_cost
		auto_clicker_count = save_data.auto_clicker_count
		spawn_cube_cost = save_data.get("spawn_cube_cost", 50)  # Default value for backward compatibility 
