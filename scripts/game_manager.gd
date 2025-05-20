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
var entity_types = {
	"sphere": preload("res://scenes/clickable_sphere.tscn"),
	"cube": preload("res://scenes/clickable_cube.tscn")
}
var play_area_size = 1
var entity_limit = 10
var entity_count = 2


func _ready():
	entities = $%Entities
	environment = $%Environment
	camera = $%Camera
	print("Game initialized")


func _input(event):
	# Handle zoom input
	if event.is_action_pressed("camera_zoom_in"):
		camera.size -= 1.0
	elif event.is_action_pressed("camera_zoom_out"):
		camera.size += 1.0
	# Handle camera panning with rebindable button
	elif event is InputEventMouseMotion and Input.is_action_pressed("camera_pan"):
		var right = camera.global_transform.basis.x
		var up = camera.global_transform.basis.y
		var move_speed = camera.size / 1000
		camera.position -= right * event.relative.x * move_speed
		camera.position += up * event.relative.y * move_speed


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
