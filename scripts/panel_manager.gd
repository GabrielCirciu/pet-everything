extends MarginContainer

var panels: Array[PanelContainer] = []

@onready var cursors_button: Button = %CursorsButton
@onready var animals_button: Button = %AnimalsButton
@onready var furnitures_button: Button = %FurnituresButton
@onready var options_button: Button = %OptionsButton
@onready var spheres_button: Button = %SpheresButton
@onready var cubes_button: Button = %CubesButton

func _ready() -> void:
	panels = [
		%CursorsPanel, %AnimalsPanel, %FurnituresPanel, %OptionsPanel, %SpheresPanel, %CubesPanel
	]
	cursors_button.pressed.connect(show_panel.bind(panels[0]))
	animals_button.pressed.connect(show_panel.bind(panels[1]))
	furnitures_button.pressed.connect(show_panel.bind(panels[2]))
	options_button.pressed.connect(show_panel.bind(panels[3]))
	spheres_button.pressed.connect(show_panel.bind(panels[4]))
	cubes_button.pressed.connect(show_panel.bind(panels[5]))
	show_panel(panels[0])
	cursors_button.grab_focus()
	
func show_panel(panel_to_show: PanelContainer) -> void:
	for panel in panels:
		panel.hide()
	panel_to_show.show()
