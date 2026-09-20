extends Node

const PATH := "user://settings.cfg"
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

var data := {
	"vol_master": 100.0,
	"vol_music": 100.0,
	"vol_sfx": 100.0,
	"resolution": 0,
	"window_mode": 0,
	"fps_limit": 0,
	"vsync": true,
}


func _ready() -> void:
	load_settings()
	apply_all()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	for key in data:
		data[key] = cfg.get_value("settings", key, data[key])


func save_settings() -> void:
	var cfg := ConfigFile.new()
	for key in data:
		cfg.set_value("settings", key, data[key])
	var err := cfg.save(PATH)
	print("salvato: ", err, " -> ", data)


func set_value(key: String, value) -> void:
	data[key] = value
	save_settings()


func set_bus(bus_name: String, valore: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(idx, linear_to_db(valore / 100.0))
	AudioServer.set_bus_mute(idx, valore < 0.5)

func apply_all() -> void:
	set_bus("Master", data["vol_master"])
	set_bus("Music", data["vol_music"])
	set_bus("SFX", data["vol_sfx"])
	apply_video()


func apply_video() -> void:
	var size: Vector2i = RESOLUTIONS[data["resolution"]]

	match data["window_mode"]:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(size)
			var screen := DisplayServer.screen_get_size()
			DisplayServer.window_set_position((screen - size) / 2)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			size = DisplayServer.screen_get_size()
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			size = DisplayServer.screen_get_size()
			DisplayServer.window_set_size(size)
			DisplayServer.window_set_position(Vector2i.ZERO)
