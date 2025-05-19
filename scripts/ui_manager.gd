extends Control

# References to other parts of the game
var game_manager
var click_manager

# Stats
var money_label
var entity_count_label
var entity_limit_label
var entity_limit_increase = 2
var money = 2000

# Upgrades

# Clicking
var click_radius_label
var click_radius_button
var click_radius_increase = 0.5
var click_radius_cost = 20
var click_radius_cost_multiplier = 1.2

# Holding
var click_hold_enable_button
var click_hold_enable_button_disabled = false
var click_hold_enable_cost = 50
var click_hold_interval_label
var click_hold_interval_button
var click_hold_interval_button_disabled = false
var click_hold_interval_increase = 0.95
var click_hold_interval_cost = 20
var click_hold_interval_cost_multiplier = 1.2

# Auto Clicking
var auto_click_enable_button
var auto_click_interval_label
var auto_click_interval_button
var auto_click_enable_button_disabled = false
var auto_click_enable_cost = 100
var auto_click_interval_button_disabled = true
var auto_click_interval_increase = 0.95
var auto_click_interval_cost = 20
var auto_click_interval_cost_multiplier = 1.2

# Spheres
var spawn_sphere_label
var spawn_sphere_button
var increase_sphere_reward_label
var increase_sphere_reward_button
var sphere_count = 1
var spawn_sphere_cost = 100
var spawn_sphere_cost_multiplier = 1.2
var sphere_reward = 1
var sphere_reward_increase = 1
var sphere_reward_increase_cost = 10
var sphere_reward_increase_cost_multiplier = 1.2

# Cubes
var spawn_cube_label
var spawn_cube_button
var increase_cube_reward_label
var increase_cube_reward_button
var cube_count = 1
var spawn_cube_cost = 100
var spawn_cube_cost_multiplier = 1.2
var cube_reward = 2
var cube_reward_increase = 2
var cube_reward_increase_cost = 10
var cube_reward_increase_cost_multiplier = 1.2

# Increase Play Area
var increase_play_area_label
var increase_play_area_button
var increase_play_area_increase = 2
var increase_play_area_cost = 100
var increase_play_area_cost_multiplier = 1.2


func _ready() -> void:
	# Dependencies
	game_manager = get_parent()
	click_manager = $%ClickManager

	# Stats
	money_label = $%MoneyLabel
	money_label.text = str(money)
	entity_count_label = $%EntityCountLabel
	entity_count_label.text = str(game_manager.get_entity_count())
	entity_limit_label = $%EntityLimitLabel
	entity_limit_label.text = str(game_manager.get_entity_limit())

	# Clicking
	click_radius_label = $%ClickRadiusLabel
	click_radius_label.text = str(click_manager.click_radius)
	click_radius_button = $%ClickRadiusButton
	click_radius_button.text = str(click_radius_cost)

	# Holding
	click_hold_enable_button = $%ClickHoldEnableButton
	click_hold_enable_button.text = str(click_hold_enable_cost)
	click_hold_interval_label = $%ClickHoldIntervalLabel
	click_hold_interval_label.text = str(click_manager.click_hold_interval)
	click_hold_interval_button = $%ClickHoldIntervalButton
	click_hold_interval_button.text = str(click_hold_interval_cost)

	# Auto Clicking
	auto_click_enable_button = $%AutoClickEnableButton
	auto_click_enable_button.text = str(auto_click_enable_cost)
	auto_click_interval_label = $%AutoClickIntervalLabel
	auto_click_interval_label.text = str(click_manager.get_auto_click_interval())
	auto_click_interval_button = $%AutoClickIntervalButton
	auto_click_interval_button.text = str(auto_click_interval_cost)

	# Spheres
	spawn_sphere_label = $%SpawnSphereLabel
	spawn_sphere_label.text = str(sphere_count)
	spawn_sphere_button = $%SpawnSphereButton
	spawn_sphere_button.text = str(spawn_sphere_cost)
	increase_sphere_reward_label = $%IncreaseSphereRewardLabel
	increase_sphere_reward_label.text = str(sphere_reward)
	increase_sphere_reward_button = $%IncreaseSphereRewardButton
	increase_sphere_reward_button.text = str(sphere_reward_increase_cost)

	# Cubes
	spawn_cube_label = $%SpawnCubeLabel
	spawn_cube_label.text = str(cube_count)
	spawn_cube_button = $%SpawnCubeButton
	spawn_cube_button.text = str(spawn_cube_cost)
	increase_cube_reward_label = $%IncreaseCubeRewardLabel
	increase_cube_reward_label.text = str(cube_reward)
	increase_cube_reward_button = $%IncreaseCubeRewardButton
	increase_cube_reward_button.text = str(cube_reward_increase_cost)

	# Play Area
	increase_play_area_label = $%IncreasePlayAreaLabel
	increase_play_area_label.text = str(game_manager.get_play_area_size())
	increase_play_area_button = $%IncreasePlayAreaButton
	increase_play_area_button.text = str(increase_play_area_cost)

	update_labels()


func update_labels() -> void:
	money_label.text = str(money)
	click_radius_button.disabled = (money < click_radius_cost)
	click_hold_enable_button.disabled = (money < click_hold_enable_cost) or click_hold_enable_button_disabled
	click_hold_interval_button.disabled = (money < click_hold_interval_cost) or click_hold_interval_button_disabled
	auto_click_enable_button.disabled = (money < auto_click_enable_cost) or auto_click_enable_button_disabled
	auto_click_interval_button.disabled = (money < auto_click_interval_cost) or auto_click_interval_button_disabled
	spawn_sphere_button.disabled = (money < spawn_sphere_cost)
	increase_sphere_reward_button.disabled = (money < sphere_reward_increase_cost)
	spawn_cube_button.disabled = (money < spawn_cube_cost)
	increase_cube_reward_button.disabled = (money < cube_reward_increase_cost)
	increase_play_area_button.disabled = (money < increase_play_area_cost)
	entity_count_label.text = str(game_manager.get_entity_count())
	entity_limit_label.text = str(game_manager.get_entity_limit())


func entities_clicked(entities) -> void:
	for entity in entities:
		if entity.is_in_group("sphere"):
			money += sphere_reward
		if entity.is_in_group("cube"):
			money += cube_reward
	update_labels()


func _on_click_radius_button_pressed() -> void:
	if money >= click_radius_cost:
		money -= click_radius_cost
		click_manager.increase_click_radius(click_radius_increase)
		click_radius_label.text = str(snapped(click_manager.get_click_radius(), 0.01))
		click_radius_cost = int(click_radius_cost * click_radius_cost_multiplier)
		click_radius_button.text = str(click_radius_cost)
		update_labels()


func _on_click_hold_enable_button_pressed() -> void:
	if money >= click_hold_enable_cost and not click_hold_enable_button_disabled:
		money -= click_hold_enable_cost
		click_hold_enable_button.text = "Max"
		click_hold_enable_button_disabled = true
		click_manager.enable_click_hold()
		update_labels()


func _on_click_hold_interval_button_pressed() -> void:
	if money >= click_hold_interval_cost:
		money -= click_hold_interval_cost
		click_manager.increase_click_hold_interval(click_hold_interval_increase)
		click_hold_interval_label.text = str(snapped(click_manager.get_click_hold_interval(), 0.01))
		click_hold_interval_cost = int(click_hold_interval_cost * click_hold_interval_cost_multiplier)
		click_hold_interval_button.text = str(click_hold_interval_cost)
		update_labels()


func _on_spawn_sphere_button_pressed() -> void:
	if money >= spawn_sphere_cost and game_manager.get_entity_count() < game_manager.get_entity_limit():
		money -= spawn_sphere_cost
		sphere_count += 1
		spawn_sphere_label.text = str(sphere_count)
		spawn_sphere_cost = int(spawn_sphere_cost * spawn_sphere_cost_multiplier)
		spawn_sphere_button.text = str(spawn_sphere_cost)
		game_manager.spawn_new_entity("sphere")
		update_labels()


func _on_auto_click_enable_button_pressed() -> void:
	if money >= auto_click_enable_cost:
		money -= auto_click_enable_cost
		auto_click_enable_button.text = "Max"
		auto_click_enable_button_disabled = true
		auto_click_interval_button_disabled = false
		click_manager.enable_auto_click()
		update_labels()


func _on_auto_click_interval_button_pressed() -> void:
	if money >= auto_click_interval_cost:
		money -= auto_click_interval_cost
		click_manager.increase_auto_click_interval(auto_click_interval_increase)
		auto_click_interval_label.text = str(snapped(click_manager.get_auto_click_interval(), 0.01))
		auto_click_interval_cost = int(auto_click_interval_cost * auto_click_interval_cost_multiplier)
		auto_click_interval_button.text = str(auto_click_interval_cost)
		update_labels()


func _on_spawn_cube_button_pressed() -> void:
	if money >= spawn_cube_cost and game_manager.get_entity_count() < game_manager.get_entity_limit():
		money -= spawn_cube_cost
		cube_count += 1
		spawn_cube_label.text = str(cube_count)
		spawn_cube_cost = int(spawn_cube_cost * spawn_cube_cost_multiplier)
		spawn_cube_button.text = str(spawn_cube_cost)
		game_manager.spawn_new_entity("cube")
		update_labels()


func _on_increase_sphere_value_button_pressed() -> void:
	if money >= sphere_reward_increase_cost:
		money -= sphere_reward_increase_cost
		sphere_reward += sphere_reward_increase
		increase_sphere_reward_label.text = str(sphere_reward)
		sphere_reward_increase_cost = int(sphere_reward_increase_cost * sphere_reward_increase_cost_multiplier)
		increase_sphere_reward_button.text = str(sphere_reward_increase_cost)
		update_labels()


func _on_increase_cube_reward_button_pressed() -> void:
	if money >= cube_reward_increase_cost:
		money -= cube_reward_increase_cost
		cube_reward += cube_reward_increase
		increase_cube_reward_label.text = str(cube_reward)
		cube_reward_increase_cost = int(cube_reward_increase_cost * cube_reward_increase_cost_multiplier)
		increase_cube_reward_button.text = str(cube_reward_increase_cost)
		update_labels()


func _on_increase_play_area_button_pressed() -> void:
	if money >= increase_play_area_cost:
		money -= increase_play_area_cost
		game_manager.increase_play_area(increase_play_area_increase)
		increase_play_area_label.text = str(game_manager.get_play_area_size())
		increase_play_area_cost = int(increase_play_area_cost * increase_play_area_cost_multiplier)
		increase_play_area_button.text = str(increase_play_area_cost)
		game_manager.increase_entity_limit(entity_limit_increase)
		update_labels()
