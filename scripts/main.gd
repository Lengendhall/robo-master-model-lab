extends Node3D

@onready var hud = $HUD
@onready var infantry = $Infantry
@onready var outpost = $Outpost
@onready var base = $Base 

var time_left: float = 180.0

var outpost_hp: float = 100.0
var outpost_max_hp: float = 100.0
var base_hp: float = 100.0
var base_max_hp: float = 100.0

func _ready() -> void:
	outpost.hp_changed.connect(func(cur, max_val): 
		outpost_hp = cur
		outpost_max_hp = max_val
	)
	outpost.destroyed.connect(_on_outpost_destroyed)
	
	base.hp_changed.connect(func(cur, max_val): 
		base_hp = cur
		base_max_hp = max_val
	)
	base.destroyed.connect(_on_base_destroyed)
	
	base.set_shield(true)

func _process(delta: float) -> void:
	time_left = maxf(time_left - delta, 0.0)
	
	var snapshot = {
		"time_left": time_left,
		"outpost_hp": outpost_hp,
		"outpost_max_hp": outpost_max_hp,
		"base_hp": base_hp,
		"base_max_hp": base_max_hp,
		"hp": infantry.hp,
		"max_hp": infantry.max_hp,
		"heat": infantry.heat,
		"heat_limit": 100.0,
		"ammo": infantry.ammo,
		"hits": infantry.hits,
		"pose": {
			"x": infantry.global_position.x,
			"z": infantry.global_position.z,
			"yaw": infantry.rotation.y
		}
	}
	
	hud.apply_state(snapshot)

func register_hit():
	infantry.hits += 1

func _on_outpost_destroyed() -> void:
	print(">>> 前哨站被摧毁，解除基地护盾！")
	base.set_shield(false)

func _on_base_destroyed() -> void:
	print(">>> 游戏胜利（或失败）！停止倒计时。")
	
	base_hp = 0.0 
	var final_snapshot = {
		"time_left": time_left,
		"outpost_hp": outpost_hp,
		"outpost_max_hp": outpost_max_hp,
		"base_hp": base_hp,
		"base_max_hp": base_max_hp,
		"hp": infantry.hp,
		"max_hp": infantry.max_hp,
		"heat": infantry.heat,
		"heat_limit": 100.0,
		"ammo": infantry.ammo,
		"hits": infantry.hits,
		"pose": {
			"x": infantry.global_position.x,
			"z": infantry.global_position.z,
			"yaw": infantry.rotation.y
		}
	}
	hud.apply_state(final_snapshot) 
	
	get_tree().paused = true 
