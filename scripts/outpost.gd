extends Node3D

signal hp_changed(current_hp: float, max_hp: float)
signal destroyed

@export_group("Status")
@export var max_hp: float = 100.0
var current_hp: float = 100.0
var is_dead: bool = false

@export_group("Rotation")
@export var rotate_speed: float = 1.5

@onready var rotator: Node3D = find_child("OUTPOST_A_ROTATE", true, false)
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

func _ready() -> void:
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)
	
	if anim_player:
		var anim_list = anim_player.get_animation_list()
		if anim_list.size() > 0:
			anim_player.play(anim_list[0])

func _physics_process(delta: float) -> void:
	if not is_dead and is_instance_valid(rotator):
		rotator.rotate_y(rotate_speed * delta)

func take_damage(amount: float) -> void:
	if is_dead:
		return
		
	current_hp = maxf(current_hp - amount, 0.0)
	hp_changed.emit(current_hp, max_hp)
	print("前哨站装甲受击！剩余血量: ", current_hp)
	
	if current_hp <= 0.0:
		is_dead = true
		destroyed.emit()
		print("前哨站已被摧毁！")
