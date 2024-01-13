extends HSlider

@export var audio_bus_name := "Master"
@onready var _bus := AudioServer.get_bus_index(audio_bus_name)

func _ready():
	var value = db_to_linear(AudioServer.get_bus_volume_db(_bus))

func _on_value_changed(value: float):
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
