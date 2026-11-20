extends VBoxContainer

@onready var selections = $Selections.get_children()
@onready var tabs = $Tabs/Container.get_children()

@onready var tooltip = $"../Tooltip"
@onready var tooltip_label = $"../Tooltip/Label"

@onready var camera = $"../../../Player/Camera2D"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Delete") or event.is_action_pressed("Place"):
		$Selections.visible = false
		$HiddenArea.visible = true
		for btn_tab in tabs:
			btn_tab.button_pressed = false

func _ready() -> void:
	tabs[4].pressed.connect(func():
		camera.building_object = null
		Input.action_press("Delete")
		)
	for tab in tabs as Array[Button]:
		tab.pressed.connect(func():
			tab_switch(tab.name, tab))
		tab.mouse_entered.connect(func():
			tooltip_label.text = tab.editor_description
			tooltip.size.x = 0
			tooltip.size = tooltip.size
			if tab.editor_description and (not get_node("Selections/%s" % [tab.name]).visible or not $Selections.visible):
				if is_mouse_over_control(tab):
					tooltip.global_position = tab.global_position+Vector2(tooltip.size.x/4, tab.size.y)
					if tab.name == "Base":
						tooltip.global_position = tab.global_position+Vector2(-tooltip.size.x/2, tab.size.y)
					tooltip.visible = true)
		tab.mouse_exited.connect(func():
			tooltip.visible = false)
	$Selections.visible = false
	$HiddenArea.visible = true

func tab_switch(tab:String, tab_button):
	$Selections.visible = true
	$HiddenArea.visible = false
	
	var selected_tab = selections.filter(func(node): return node.name == tab)[0]
	if not selected_tab:
		printerr("THIS TAB DOENS'T [#$&!]ING EXIST!!!")
		return
	if not tab_button.button_pressed:
		$Selections.visible = false
		$HiddenArea.visible = true
		selected_tab.visible = false
		return
	tooltip.visible = false
	for selection in selections:
		if selection == selected_tab:
			selection.visible = true
			continue
		selection.visible = false
	for btn_tab in tabs:
		if btn_tab == tab_button: continue
		btn_tab.button_pressed = false

func is_mouse_over_control(control_node: Control) -> bool:
	var mouse_pos = get_global_mouse_position()
	return control_node.get_global_rect().has_point(mouse_pos)
