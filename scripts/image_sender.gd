extends Node

@onready var viewport: SubViewport = $"../VisionViewport"
@onready var vision_camera: Camera3D = $"../VisionViewport/VisionCamera"
@onready var main_camera: Camera3D = $"../AimPivot/Camera3D"

var tcp_client: StreamPeerTCP = StreamPeerTCP.new()
var is_connected: bool = false
var frame_seq: int = 0

@export var send_rate: float = 60.0asda
var time_accumulator: float = 0.0


func _ready() -> void:
	var err = tcp_client.connect_to_host("127.0.0.1", 9000)

	if err == OK:
		print(">>> 正在尝试连接 Python 视觉端...")
	else:
		print(">>> TCP 连接初始化失败，错误码：", err)


func _process(delta: float) -> void:
	if vision_camera and main_camera:
		vision_camera.global_transform = main_camera.global_transform
		vision_camera.fov = main_camera.fov

	tcp_client.poll()

	if tcp_client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		if not is_connected:
			print(">>> 成功连接 Python 视觉端！")
			is_connected = true

	elif (
		tcp_client.get_status() == StreamPeerTCP.STATUS_ERROR
		or tcp_client.get_status() == StreamPeerTCP.STATUS_NONE
	):
		if is_connected:
			print(">>> 与 Python 视觉端断开连接。")

		is_connected = false

		tcp_client = StreamPeerTCP.new()
		var err = tcp_client.connect_to_host("127.0.0.1", 9000)

		if err != OK:
			print(">>> 重新连接失败，错误码：", err)

		return

	if is_connected:
		time_accumulator += delta

		if time_accumulator >= (1.0 / send_rate):
			time_accumulator = 0.0
			capture_and_send_image()


func capture_and_send_image() -> void:
	await RenderingServer.frame_post_draw

	var image: Image = viewport.get_texture().get_image()

	if image == null:
		print(">>> 获取图像失败！")
		return

	var jpeg_data: PackedByteArray = image.save_jpg_to_buffer(0.8)
	var size: int = jpeg_data.size()

	if size <= 0 or size > 2_000_000:
		print(">>> JPEG 数据大小异常：", size)
		return

	var header: PackedByteArray = PackedByteArray()
	header.resize(20)

	var magic: PackedByteArray = "RMV1".to_ascii_buffer()

	for i in range(4):
		header.encode_u8(i, magic[i])

	header.encode_u8(4, (frame_seq >> 24) & 0xFF)
	header.encode_u8(5, (frame_seq >> 16) & 0xFF)
	header.encode_u8(6, (frame_seq >> 8) & 0xFF)
	header.encode_u8(7, frame_seq & 0xFF)


	var ts_us: int = Time.get_ticks_usec()

	for i in range(8):
		header.encode_u8(
			8 + i,
			(ts_us >> (56 - i * 8)) & 0xFF
		)

	header.encode_u8(16, (size >> 24) & 0xFF)
	header.encode_u8(17, (size >> 16) & 0xFF)
	header.encode_u8(18, (size >> 8) & 0xFF)
	header.encode_u8(19, size & 0xFF)

	var packet: PackedByteArray = PackedByteArray()
	packet.append_array(header)
	packet.append_array(jpeg_data)

	var err = tcp_client.put_data(packet)

	if err != OK:
		print(">>> 图像发送失败，错误码：", err)
		return

	frame_seq += 1
