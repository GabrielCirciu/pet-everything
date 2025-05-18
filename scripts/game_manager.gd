extends Node3D

# References to child managers
var spawn_manager
var click_manager
var ui_manager

# Game state
var game_running = false
var auto_spawn_timer = 0.0
var auto_spawn_interval = 3.0  # Spawn a new sphere every 3 seconds

func _ready():
	# Initialize references to managers
	spawn_manager = $SpawnManager  # The renamed clickables_manager
	click_manager = $ClickManager
	ui_manager = $UI/UIManager
	
	# Connect signals
	spawn_manager.connect("object_spawned", on_object_spawned)
	ui_manager.connect("upgrade_purchased", on_upgrade_purchased)
	
	# Start the game
	start_game()
	print("Game initialized")

func _process(delta):
	if game_running:
		# Auto-spawn objects periodically
		auto_spawn_timer += delta
		if auto_spawn_timer >= auto_spawn_interval:
			spawn_new_object()
			auto_spawn_timer = 0.0

func start_game():
	# Initialize game state
	game_running = true
	
	# Spawn initial objects
	for i in range(5):
		spawn_new_object()
	
	print("Game started")

func spawn_new_object():
	var new_object = spawn_manager.spawn_sphere()
	print("Game manager: Spawned new object")
	return new_object

# Signal handlers
func on_object_spawned(object):
	# We could add any game-wide handling of spawned objects here
	print("Game manager: Object spawned signal received")

func on_upgrade_purchased(upgrade_type, level):
	match upgrade_type:
		"click_radius":
			print("Game manager: Click radius upgraded to level ", level)
			# Could add game-wide effects here
			
		"points_multiplier":
			print("Game manager: Points multiplier upgraded to level ", level)
			# Could add game-wide effects here
			
		_:
			print("Game manager: Unknown upgrade type: ", upgrade_type)
