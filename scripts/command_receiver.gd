extends Node

# ============================================================
# 一、TCP 配置
# ============================================================

const SERVER_HOST: String = "127.0.0.1"
const SERVER_PORT: int = 9001

const RECONNECT_INTERVAL: float = 2.0
const MAX_RECEIVE_BUFFER: int = 65536

var tcp_client: StreamPeerTCP = StreamPeerTCP.new()

var is_connected: bool = false

# 缓存尚未组成完整 JSON 行的数据
var receive_buffer: PackedByteArray = PackedByteArray()

var reconnect_timer: float = 0.0


# ============================================================
# 二、初始化
# ============================================================

func _ready() -> void:
	print("[命令接收] 节点已启动")

	connect_to_python()


# ============================================================
# 三、连接 Python
# ============================================================

func connect_to_python() -> void:
	tcp_client = StreamPeerTCP.new()

	receive_buffer.clear()

	var err: Error = tcp_client.connect_to_host(
		SERVER_HOST,
		SERVER_PORT
	)

	if err == OK:
		print(
			"[命令接收] 正在连接 Python：",
			SERVER_HOST,
			":",
			SERVER_PORT
		)

	else:
		print(
			"[命令接收] 连接初始化失败，错误码：",
			err
		)


# ============================================================
# 四、每帧检查连接状态
# ============================================================

func _process(delta: float) -> void:
	tcp_client.poll()

	var status: int = tcp_client.get_status()

	if status == StreamPeerTCP.STATUS_CONNECTED:
		reconnect_timer = 0.0

		if not is_connected:
			is_connected = true

			print("[命令接收] 已连接 Python！")

		receive_messages()

	elif (
		status == StreamPeerTCP.STATUS_ERROR
		or status == StreamPeerTCP.STATUS_NONE
	):
		if is_connected:
			print("[命令接收] 与 Python 的连接已断开")

		is_connected = false

		receive_buffer.clear()

		reconnect_timer += delta

		if reconnect_timer >= RECONNECT_INTERVAL:
			reconnect_timer = 0.0

			print("[命令接收] 正在尝试重新连接...")

			connect_to_python()


# ============================================================
# 五、接收 TCP 数据
# ============================================================

func receive_messages() -> void:
	var available: int = tcp_client.get_available_bytes()

	if available <= 0:
		return

	# 防止异常数据导致缓存无限增长
	if receive_buffer.size() + available > MAX_RECEIVE_BUFFER:
		print("[命令接收] 接收缓存超出限制，清空缓存")

		receive_buffer.clear()

		return

	var result: Array = tcp_client.get_data(available)

	var err: int = result[0]

	if err != OK:
		print("[命令接收] 读取失败，错误码：", err)

		return

	var received_data: PackedByteArray = result[1]

	receive_buffer.append_array(received_data)

	# 一次 TCP 接收可能包含多条消息，
	# 也可能只包含半条消息。
	# 因此按照换行符拆分完整 JSON。
	while true:
		var newline_index: int = receive_buffer.find(10)

		if newline_index < 0:
			break

		var line: PackedByteArray = receive_buffer.slice(
			0,
			newline_index
		)

		receive_buffer = receive_buffer.slice(
			newline_index + 1
		)

		if line.is_empty():
			continue

		handle_command(line)


# ============================================================
# 六、解析 JSON 命令
# ============================================================

func handle_command(data: PackedByteArray) -> void:
	var json_text: String = data.get_string_from_utf8()

	var json := JSON.new()

	var err: Error = json.parse(json_text)

	if err != OK:
		print(
			"[命令接收] JSON 解析失败：",
			json.get_error_message()
		)

		return

	var command = json.data

	if typeof(command) != TYPE_DICTIONARY:
		print("[命令接收] 收到的消息不是 JSON 对象")

		return

	var found: bool = bool(
		command.get("found", false)
	)

	var color: String = str(
		command.get("color", "")
	)

	var x: float = float(
		command.get("x", -1.0)
	)

	var y: float = float(
		command.get("y", -1.0)
	)

	var yaw: float = float(
		command.get("yaw", 0.0)
	)

	var pitch: float = float(
		command.get("pitch", 0.0)
	)

	var fire: bool = bool(
		command.get("fire", false)
	)
