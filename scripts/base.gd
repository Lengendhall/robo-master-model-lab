extends Node3D

signal hp_changed(current_hp: float, max_hp: float)
signal destroyed

@export_group("Status")
@export var max_hp: float = 100.0
var current_hp: float = 100.0
var is_dead: bool = false
var is_shielded: bool = true 

func _ready() -> void:
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)

func set_shield(state: bool) -> void:
	is_shielded = state
	if not is_shielded:
		print(">>> 基地护盾已解除！可以攻击基地了！")

func take_damage(amount: float) -> void:
	if is_dead:
		return
		
	if is_shielded:
		print(">>> 基地处于护盾保护中，攻击无效！")
		return 
		
	current_hp = maxf(current_hp - amount, 0.0)
	hp_changed.emit(current_hp, max_hp)
	print("基地受击！剩余血量: ", current_hp)
	
	if current_hp <= 0.0:
		is_dead = true
		destroyed.emit()
		print(">>> 基地已被摧毁！游戏结束！")
