extends Node3D

# Game state variables
var score: float = 100
var score_per_click: float = 1
var cube_click_multiplier: float = 1.0
var sphere_click_multiplier: float = 2.0
var score_per_second: float = 0
var auto_clicker_cost: int = 10
var auto_clicker_count: int = 0
var spawn_cube_cost: int = 50
var spawn_sphere_cost: int = 100

# Node references
@onready var camera = $Camera3D
@onready var score_label = $UI/VBoxContainer/ScoreLabel
@onready var score_per_second_label = $UI/VBoxContainer/ScorePerSecondLabel
@onready var auto_clicker_button = $UI/VBoxContainer/UpgradesContainer/AutoClickerButton
@onready var spawn_cube_button = $UI/VBoxContainer/UpgradesContainer/SpawnCubeButton
@onready var spawn_sphere_button = $UI/VBoxContainer/UpgradesContainer/SpawnSphereButton
@onready var clickables_manager = $Clickables

func _ready():
	# Connect signals
	auto_clicker_button.pressed.connect(_on_auto_clicker_button_pressed)
	spawn_cube_button.pressed.connect(_on_spawn_cube_button_pressed)
	spawn_sphere_button.pressed.connect(_on_spawn_sphere_button_pressed)
	$GameTimer.timeout.connect(_on_game_timer_timeout)
	clickables_manager.object_clicked.connect(_on_object_clicked)
	
func _process(_delta):
	# Update UI
	score_label.text = "Score: " + str(int(score))
	score_per_second_label.text = "Score per second: " + str(score_per_second)
	auto_clicker_button.text = "Buy Auto Clicker (Cost: " + str(auto_clicker_cost) + ")"
	spawn_cube_button.text = "Spawn New Cube (Cost: " + str(spawn_cube_cost) + ")"
	spawn_sphere_button.text = "Spawn New Sphere (Cost: " + str(spawn_sphere_cost) + ")"

func _on_object_clicked(clicked_object):
	var click_value = score_per_click
	
	# Apply different multipliers based on object type
	if clicked_object.is_in_group("spawned_cubes"):
		click_value *= cube_click_multiplier
		print("Cube clicked! +" + str(click_value) + " score")
	elif clicked_object.is_in_group("spawned_spheres"):
		click_value *= sphere_click_multiplier
		print("Sphere clicked! +" + str(click_value) + " score")
	
	score += click_value

func _on_auto_clicker_button_pressed():
	if score >= auto_clicker_cost:
		score -= auto_clicker_cost
		auto_clicker_count += 1
		score_per_second += 1
		auto_clicker_cost = int(auto_clicker_cost * 1.1)  # Increase cost by 10%

func _on_spawn_cube_button_pressed():
	if score >= spawn_cube_cost:
		score -= spawn_cube_cost
		score_per_second += 10
		spawn_cube_cost = int(spawn_cube_cost * 1.1)  # Increase cost by 10%
		
		# Spawn new cube using the clickables_manager
		clickables_manager.spawn_cube()

func _on_spawn_sphere_button_pressed():
	if score >= spawn_sphere_cost:
		score -= spawn_sphere_cost
		score_per_second += 25  # Spheres give more passive income
		spawn_sphere_cost = int(spawn_sphere_cost * 1.15)  # Increase cost by 15%
		
		# Spawn new sphere using the clickables_manager
		clickables_manager.spawn_sphere()

func _on_game_timer_timeout():
	score += score_per_second
