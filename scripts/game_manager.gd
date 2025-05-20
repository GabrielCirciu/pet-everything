"""
Game Manager

This script is responsible for managing the game state, including:
- Spawning entities (spheres and cubes)
- Play Area upgrades (i.e. Larger area for entities, or new objects, not implemented yet)
- Managing the game loop (i.e. A Pause Menu, starting, pausing, saving, loading, etc., not implemented yet)
"""

extends Node

var entities
var environment
var camera
var ui_manager

var entity_types = {
	"sphere": preload("res://scenes/clickable_sphere.tscn"),
	"cube": preload("res://scenes/clickable_cube.tscn")
}
var play_area_size = 1
var entity_limit = 10
var entity_count = 2

var save_data = {
	"play_area_size": 1,
	"entity_limit": 10,
	"entity_count": 2,
	"money": 0,
	"entities": []
}
var save_timer = 0


func _ready():
	entities = $%Entities
	environment = $%Environment
	camera = $%Camera
	ui_manager = $%UIManager
	# load_game()
	print("Game initialized")


func _input(event):
	# Handle zoom input
	if event.is_action_pressed("camera_zoom_in") and camera.size > 10:
		camera.size -= 1.0
	elif event.is_action_pressed("camera_zoom_out") and camera.size < 100:
		camera.size += 1.0
	# Handle camera panning with rebindable button
	elif event is InputEventMouseMotion and Input.is_action_pressed("camera_pan"):
		var right = camera.global_transform.basis.x
		var up = camera.global_transform.basis.y
		var move_speed = camera.size / 1000
		camera.position -= right * event.relative.x * move_speed
		camera.position += up * event.relative.y * move_speed


func _process(delta):
	save_timer += delta
	if save_timer >= 10:
		# save_game()
		save_timer = 0


func reset_game():
	play_area_size = 1
	entity_limit = 10
	entity_count = 2
	ui_manager.money = 0
	# clear entities
	for entity in entities.get_children():
		entity.queue_free()
	# clear save data
	save_data.clear()
	# clear localStorage
	if OS.has_feature("JavaScript"):
		JavaScriptBridge.eval("""
			localStorage.removeItem('pet_everything_save');
		""")
	# spawn in a cube and sphere
	spawn_new_entity("cube")
	spawn_new_entity("sphere")
	# clear ui labels
	ui_manager.update_labels()
	# save game
	save_game()



func save_game():
	# Update save data
	save_data.play_area_size = play_area_size
	save_data.entity_limit = entity_limit
	save_data.entity_count = entity_count
	save_data.money = ui_manager.money
	# Save entities
	save_data.entities.clear()
	for entity in entities.get_children():
		var entity_data = {
			"type": "sphere" if entity.scene_file_path.ends_with("clickable_sphere.tscn") else "cube",
			"position": {
				"x": entity.position.x,
				"y": entity.position.y,
				"z": entity.position.z
			},
			"rotation": {
				"x": entity.rotation.x,
				"y": entity.rotation.y,
				"z": entity.rotation.z
			}
		}
		save_data.entities.append(entity_data)
	# Convert to JSON and save to localStorage
	var json_string = JSON.stringify(save_data)
	if OS.has_feature("JavaScript"):
		JavaScriptBridge.eval("""
			localStorage.setItem('pet_everything_save', '%s');
		""" % json_string.uri_encode())
	print("Game saved")

func load_game():
	if OS.has_feature("JavaScript"):
		var json_string = JavaScriptBridge.eval("""
			localStorage.getItem('pet_everything_save');
		""")
		
		if json_string and json_string != "null":
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				var loaded_data = json.get_data()
				# Clear existing entities
				for entity in entities.get_children():
					entity.queue_free()
				# Load game state
				play_area_size = loaded_data.play_area_size
				entity_limit = loaded_data.entity_limit
				entity_count = loaded_data.entity_count
				ui_manager.money = loaded_data.money
				# Update environment scale
				environment.scale = Vector3(play_area_size, 1, play_area_size)
				# Load entities
				for entity_data in loaded_data.entities:
					var new_entity = entity_types[entity_data.type].instantiate()
					entities.add_child(new_entity)
					new_entity.position = Vector3(
						entity_data.position.x,
						entity_data.position.y,
						entity_data.position.z
					)
					new_entity.rotation = Vector3(
						entity_data.rotation.x,
						entity_data.rotation.y,
						entity_data.rotation.z
					)
				ui_manager.update_labels()
				print("Game loaded")
				

func spawn_new_entity(entity_type):
	var new_entity = entity_types[entity_type].instantiate()
	entities.add_child(new_entity)
	new_entity.scale = Vector3(0.1, 0.1, 0.1)
	var random_x = randf_range(-play_area_size/2.0, play_area_size/2.0)
	var random_z = randf_range(-play_area_size/2.0, play_area_size/2.0)
	new_entity.position = Vector3(random_x, 3, random_z)
	var spawn_tween = create_tween()
	spawn_tween.tween_property(new_entity, "scale", Vector3(1, 1, 1), 0.1).set_trans(Tween.TRANS_BOUNCE)
	entity_count += 1


func increase_play_area(increase):
	play_area_size *= increase
	var tween_environment = create_tween()
	tween_environment.tween_property(environment, "scale", Vector3(play_area_size, 1, play_area_size), 0.2).set_trans(Tween.TRANS_QUAD)
	var direction = camera.global_transform.basis.z  # This is the forward vector
	camera.global_position = camera.global_position + (direction * 50)
	var tween_camera = create_tween()
	tween_camera.tween_property(camera, "size", camera.size * 1.65, 0.2).set_trans(Tween.TRANS_QUAD)


func increase_entity_limit(increase):
	entity_limit *= increase

func get_play_area_size():
	return play_area_size


func get_entity_count():
	return entity_count


func get_entity_limit():
	return entity_limit
