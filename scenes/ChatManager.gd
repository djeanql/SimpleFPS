extends Node

@onready var chat_label = $"../../CanvasLayer/HUD/ChatLabel"

@rpc("authority")
func send_message(message):
	chat_label.text = message

func _process(delta):
	pass
