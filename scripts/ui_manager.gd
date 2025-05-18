extends Control

signal upgrade_purchased(upgrade_type, level)

# References to other parts of the game
var game_manager
var click_manager

# Game score
var score = 0
var points_per_click = 1

# Upgrades
var click_radius_level = 0
var click_radius_upgrade_cost = 10
var click_radius_cost_multiplier = 2.0

# Points multiplier
var points_multiplier = 1
var points_multiplier_level = 0
var points_multiplier_cost = 20
var points_multiplier_cost_multiplier = 2.5

# UI elements (to be connected in _ready)
var score_label
var click_radius_button
var click_radius_cost_label
var points_multiplier_button
var points_multiplier_cost_label

func _ready():
	game_manager = get_parent().get_parent()  # UIManager -> UI -> MainScreen
	click_manager = game_manager.get_node("ClickManager")
	
	# Connect UI elements
	score_label = $ScoreContainer/ScoreLabel
	click_radius_button = $UpgradesContainer/ClickRadiusButton
	click_radius_cost_label = $UpgradesContainer/ClickRadiusCost
	points_multiplier_button = $UpgradesContainer/PointsMultiplierButton
	points_multiplier_cost_label = $UpgradesContainer/PointsMultiplierCost
	
	# Connect signals
	click_manager.connect("object_clicked", on_object_clicked)
	click_manager.connect("objects_clicked", on_objects_clicked)
	
	# Initialize UI
	update_score_display()
	update_upgrade_buttons()
	
	print("UI Manager initialized")

# Update the score display
func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(score)

# Update the upgrade buttons (costs and availability)
func update_upgrade_buttons():
	# Click radius upgrade
	if click_radius_cost_label:
		click_radius_cost_label.text = "Cost: " + str(click_radius_upgrade_cost)
	
	if click_radius_button:
		click_radius_button.disabled = (score < click_radius_upgrade_cost)
	
	# Points multiplier upgrade
	if points_multiplier_cost_label:
		points_multiplier_cost_label.text = "Cost: " + str(points_multiplier_cost)
	
	if points_multiplier_button:
		points_multiplier_button.disabled = (score < points_multiplier_cost)

# Handle clicking on a single object
func on_object_clicked(object):
	var points = points_per_click * points_multiplier
	increase_score(points)
	print("Got ", points, " points from clicking an object")

# Handle clicking on multiple objects at once (with radius)
func on_objects_clicked(objects):
	var total_points = 0
	for object in objects:
		var points = points_per_click * points_multiplier
		total_points += points
	
	increase_score(total_points)
	print("Got ", total_points, " points from clicking ", objects.size(), " objects")

# Increase the score and update UI
func increase_score(amount):
	score += amount
	update_score_display()
	update_upgrade_buttons()

# Purchase click radius upgrade
func _on_click_radius_button_pressed():
	if score >= click_radius_upgrade_cost:
		# Pay the cost
		score -= click_radius_upgrade_cost
		
		# Increase level
		click_radius_level += 1
		
		# Apply upgrade
		click_manager.increase_click_radius(click_radius_level)
		
		# Update cost for next upgrade
		click_radius_upgrade_cost = int(click_radius_upgrade_cost * click_radius_cost_multiplier)
		
		# Update UI
		update_score_display()
		update_upgrade_buttons()
		
		# Emit signal
		emit_signal("upgrade_purchased", "click_radius", click_radius_level)
		
		print("Upgraded click radius to level ", click_radius_level)

# Purchase points multiplier upgrade
func _on_points_multiplier_button_pressed():
	if score >= points_multiplier_cost:
		# Pay the cost
		score -= points_multiplier_cost
		
		# Increase level
		points_multiplier_level += 1
		
		# Apply upgrade (each level adds 1 to the multiplier)
		points_multiplier = 1 + points_multiplier_level
		
		# Update cost for next upgrade
		points_multiplier_cost = int(points_multiplier_cost * points_multiplier_cost_multiplier)
		
		# Update UI
		update_score_display()
		update_upgrade_buttons()
		
		# Emit signal
		emit_signal("upgrade_purchased", "points_multiplier", points_multiplier_level)
		
		print("Upgraded points multiplier to x", points_multiplier) 
