extends Area2D

@onready var raycast = $RayCast

@export var held:bool = false

var SPEED:float = 200

@export var item:CharacterBody2D
@export var item_moving:bool

func _ready() -> void:
	$Body.frame = GameManager.conveyor_frame

func _on_body_frame_changed() -> void:
	if held:
		GameManager.conveyor_frame = $Body.frame

#func _physics_process(delta: float) -> void:
	#moving_body.constant_linear_velocity = Vector2.UP.rotated(rotation) * SPEED * delta

func _physics_process(delta: float) -> void:
	if raycast.is_colliding() and item:
		var next_conveyer = raycast.get_collider()
		if next_conveyer and next_conveyer.is_in_group("Conveyor") and next_conveyer.held == false and next_conveyer.item == null:
			item.global_position = item.global_position.move_toward(next_conveyer.global_position, SPEED*delta)
			item_moving = true
			if item.global_position == next_conveyer.global_position:
				next_conveyer.item = item
				item = null
		elif next_conveyer and next_conveyer.is_in_group("Container"):
			var inventory_size = 0
			for value in next_conveyer.inventory.values():
				if value is int:
					inventory_size += 0
			if inventory_size >= next_conveyer.inventory_size: return
			item.global_position = item.global_position.move_toward(next_conveyer.global_position, SPEED*delta)
			item_moving = true
			if item.global_position == next_conveyer.global_position:
				next_conveyer.inventory["ore"] += 1
				print(next_conveyer.inventory)
				item.queue_free()
				item = null

#func _process(delta: float) -> void:
	#if item and not held:
		#next_conveyor = raycast.get_collider()
		#print(next_conveyor)
		#if not next_conveyor or not next_conveyor.item: return
		##var direction = Vector2.UP.rotated(rotation)
		#item.velocity.move_toward(next_conveyor.global_position, SPEED*delta)
		#print(item.velocity)
		#item.velocity = direction * SPEED * delta
		#item.velocity.clamp(Vector2(-SPEED, -SPEED), Vector2(SPEED, SPEED))

#func _on_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Ore") and not held:
		#if body.is_on_conveyor == false:
			#item = body
			#body.is_on_conveyor = true
