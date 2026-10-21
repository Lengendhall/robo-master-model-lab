extends Node3D

@export_group("Projectile Physics")
@export var speed: float = 30.0
@export var gravity: float = 9.8
@export var life_time: float = 3.0
@export var damage: int = 10

var velocity: Vector3 = Vector3.ZERO
var time_alive: float = 0.0

func _physics_process(delta: float) -> void:
	time_alive += delta
	if time_alive > life_time:
		queue_free()
		return

	var last_pos = global_position
	velocity.y -= gravity * delta
	global_position += velocity * delta
	var current_pos = global_position
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(last_pos, current_pos)
	
	query.collision_mask = 1 | 4 
	query.collide_with_areas = true 
	
	var result = space_state.intersect_ray(query)
	
	if result:
		handle_hit(result)

func handle_hit(result: Dictionary) -> void:
	var collider = result.collider
	
	print("--- 命中检测 ---")
	
	if collider is Area3D:
		if collider.is_in_group("Armor"):
			var parent = collider.get_parent()
			while parent != null:
				if parent.has_method("take_damage"):
					parent.take_damage(damage)
					break
				parent = parent.get_parent()
	else:
		print("未命中")

		
	queue_free()
