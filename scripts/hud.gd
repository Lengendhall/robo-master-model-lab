extends CanvasLayer

@onready var clock_label: Label = %ClockLabel
@onready var outpost_hp: ProgressBar = %OutpostHP
@onready var base_hp: ProgressBar = %BaseHP

@onready var minimap_area: Control = %MinimapArea
@onready var player_icon: ColorRect = %Icon_Player

@onready var hp_bar: ProgressBar = %HPBar
@onready var heat_bar: ProgressBar = %HeatBar
@onready var ammo_label: Label = %AmmoLabel


@export var map_min = Vector2(-10.0, -10.0)
@export var map_max = Vector2(10.0, 10.0)

func apply_state(snapshot: Dictionary) -> void:
	var left = maxf(float(snapshot.get("time_left", 0.0)), 0.0)
	var seconds = ceil(left)
	clock_label.text = "%02d:%02d" % [floor(seconds / 60.0), int(seconds) % 60]
	
	outpost_hp.value = snapshot.get("outpost_hp", 0)
	base_hp.value = snapshot.get("base_hp", 0)
	
	hp_bar.max_value = snapshot.get("max_hp", 100)
	hp_bar.value = snapshot.get("hp", 0)
	
	heat_bar.max_value = snapshot.get("heat_limit", 100)
	heat_bar.value = snapshot.get("heat", 0.0)
	
	ammo_label.text = "AMMO " + str(snapshot.get("ammo", 0))
	
	var pose = snapshot.get("pose", {})
	var world_x = pose.get("x", 0.0)
	var world_z = pose.get("z", 0.0)
	var yaw = pose.get("yaw", 0.0)
	
	var uv = (Vector2(world_x, world_z) - map_min) / (map_max - map_min)
	uv.x = clampf(uv.x, 0.0, 1.0)
	uv.y = clampf(uv.y, 0.0, 1.0)
	
	player_icon.position = uv * minimap_area.size - player_icon.size * 0.5
	player_icon.pivot_offset = player_icon.size * 0.5
	player_icon.rotation = -yaw 
