extends Area2D

@export var max_health:int
@export var health = 20

@onready var raycast = $RayCast
@onready var conveyor_body = $Body

var SPEED:float = 300

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

@export var held:bool = false

@export var item:CharacterBody2D
@export var item_incoming:CharacterBody2D
var item_moving:bool = true

@export var output_conveyor = null

func _ready() -> void:
	$Body.frame = GameManager.conveyor_frame
	max_health = health

func get_disabled() -> bool:
	if destroy_time == max_destroy_time and held == false:
		return false
	return true

func _on_body_frame_changed() -> void:
	if held:
		GameManager.conveyor_frame = $Body.frame

func _physics_process(delta: float) -> void:
	if raycast.is_colliding() and item:
		var next_conveyer = raycast.get_collider()
		output_conveyor = next_conveyer
		if next_conveyer and next_conveyer.is_in_group("Conveyor") and next_conveyer.held == false and (next_conveyer.item == null and (next_conveyer.item_incoming == null or next_conveyer.item_incoming == item)):
			item.global_position = item.global_position.move_toward(next_conveyer.global_position, SPEED*delta*GameManager.time_scale)
			next_conveyer.item_incoming = item
			item_moving = true
			if item.global_position == next_conveyer.global_position:
				next_conveyer.item = item
				next_conveyer.item_incoming = null
				item = null
		elif next_conveyer and next_conveyer.is_in_group("Container") and next_conveyer.held == false:
			if "inputItem" in next_conveyer and not item.itemType in next_conveyer.inputItem.keys()[0]:
				if "inputItem" in next_conveyer and next_conveyer.inputItem.size() >= 2 and not item.itemType in next_conveyer.inputItem.keys()[1]:
					item_moving = false
					return
				elif "inputItem" in next_conveyer and next_conveyer.inputItem.size() == 1:
					item_moving = false
					return
			var inventory_size = 0
			for value in next_conveyer.inventory.values():
				inventory_size += value
			if inventory_size >= next_conveyer.inventory_size: #and not ("inputItem" in next_conveyer and item.itemType == next_conveyer.inputItem.keys()[1]):
				if "inputItem" in next_conveyer and next_conveyer.inputItem.size() == 2 and item.itemType == next_conveyer.inputItem.keys()[1]:
					var inventory_2_size = 0
					if "inventory_2" in next_conveyer:
						for value in next_conveyer.inventory_2.values():
							inventory_2_size += value
					if inventory_2_size >= next_conveyer.inventory_size:
						item_moving = false
						return
				else:
					item_moving = false
					return
			if "inputItem" in next_conveyer and next_conveyer.inputItem.size() == 2 and item.itemType == next_conveyer.inputItem.keys()[1]:
				var inventory_2_size = 0
				if "inventory_2" in next_conveyer:
					for value in next_conveyer.inventory_2.values():
						inventory_2_size += value
				if inventory_2_size >= next_conveyer.inventory_size:
					item_moving = false
					return
			item.global_position = item.global_position.move_toward(global_position + Vector2.UP.rotated(rotation)*64, SPEED*delta*GameManager.time_scale)
			item_moving = true
			if item.global_position == (global_position + Vector2.UP.rotated(rotation)*64):
				if "inventory_2" in next_conveyer:
					if next_conveyer.inputItem.size() == 2 and item.itemType == next_conveyer.inputItem.keys()[1]:
						if not (item.itemType in next_conveyer.inventory_2.keys()):
							next_conveyer.inventory_2[item.itemType] = 0
						next_conveyer.inventory_2[item.itemType] += 1
						next_conveyer.inventory_2 = next_conveyer.inventory_2
						item.queue_free()
						item = null
						return
				if not (item.itemType in next_conveyer.inventory.keys()):
					next_conveyer.inventory[item.itemType] = 0
				next_conveyer.inventory[item.itemType] += 1
				next_conveyer.inventory = next_conveyer.inventory
				item.queue_free()
				item = null
		else:
			item_moving = false

func take_damage(damage: int) -> void:
	if !held:
		health -= damage
		if health < 1:
			GameManager.screen_shake.emit(0.1, 6)
			queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if item:
			item.queue_free()
		elif item_incoming:
			item_incoming.queue_free()
