extends VBoxContainer

@onready var selections = $Selections.get_children()
@onready var tabs = $Tabs/Container.get_children()

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
	tabs.remove_at(4)
	for tab in tabs:
		tab.pressed.connect(func():
			tab_switch(tab.name, tab))

func tab_switch(tab:String, tab_button):
	$Selections.visible = true
	$HiddenArea.visible = false
	
	var selected_tab = selections.filter(func(node): return node.name == tab)[0]
	if not selected_tab:
		printerr("THIS TAB DOENS'T #$&!ING EXIST!!!")
		return
	for selection in selections:
		if selection == selected_tab:
			selection.visible = true
			continue
		selection.visible = false
	for btn_tab in tabs:
		if btn_tab == tab_button: continue
		btn_tab.button_pressed = false
