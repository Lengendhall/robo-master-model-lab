extends CharacterBody3D
var hp: int = 100
var max_hp: int = 100
var heat: float = 0.0
var ammo: int = 150
var hits: int = 0

@export_group("Movement")
@export var speed: float = 5.0
@export var jump_speed: float = 4.5
@export var gravity: float = 9.8

@export_group("Camera Control")
@export var mouse_sensitivity: float = 0.002
@export var pitch_min_deg: float = -30.0
@export var pitch_max_deg: float = 30.0

@export_group("Combat")
@export var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

@onready var aim_pivot: Node3D = $AimPivot
@onready var muzzle: Marker3D = $AimPivot/Muzzle
@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("Infantry 初始化完成")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		var target_pitch = aim_pivot.rotation.x - event.relative.y * mouse_sensitivity
		aim_pivot.rotation.x = clampf(target_pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
		
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	var forward = global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var right = global_transform.basis.x
	right.y = 0
	right = right.normalized()
	
	var direction = (forward * input_2d.y + right * input_2d.x)
	if direction.length() > 1.0:
		direction = direction.normalized()
		
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed
		
	move_and_slide()
	
	handle_actions()

func handle_actions() -> void:
	if Input.is_action_pressed("fire") and fire_timer and fire_timer.is_stopped():
		shoot()
		
	if Input.is_action_just_pressed("reset"):
		global_position = Vector3(0, 2, 0)
		velocity = Vector3.ZERO
		print(">>> 已重置位置")

@onready var main_camera: Camera3D = $AimPivot/Camera3D 

func shoot() -> void:
	if ammo <= 0:
		print("没子弹了！")
		return
		
	fire_timer.start()
	ammo -= 1
	heat = minf(heat + 5.0, 100.0)
	
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)
		

		projectile.global_position = muzzle.global_position
		
		var space_state = get_world_3d().direct_space_state
		var cam_start = main_camera.global_position
		var cam_end = cam_start - main_camera.global_transform.basis.z * 1000.0
		
		var query = PhysicsRayQueryParameters3D.create(cam_start, cam_end)
		query.collision_mask = 5 
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		
		var target_point: Vector3
		if result:
			target_point = result.position
		else:
			target_point = cam_end
			
		var fire_direction = (target_point - muzzle.global_position).normalized()
		
		projectile.velocity = fire_direction * projectile.speed
		
		print(">>> 发射抛射物！")
