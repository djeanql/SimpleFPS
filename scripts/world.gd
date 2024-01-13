extends Node

signal pause
signal unpause

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var username_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/UsernameEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var hosting_label = $CanvasLayer/HUD/HostingLabel

@onready var network_manager = $Managers/NetworkManager
@onready var player_manager = $Managers/PlayerManager

var pause_menu_open = false

func _process(_delta):
	DisplayServer.window_set_title("Simple FPS" + " | fps: " + str(Engine.get_frames_per_second()))

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		if not pause_menu_open:
			$CanvasLayer/PauseMenu.show()
			pause_menu_open = true
			pause.emit()
		else:
			$CanvasLayer/PauseMenu.hide()
			pause_menu_open = false
			unpause.emit()

func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	hosting_label.show()
	
	network_manager.start_server()

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	var address = "localhost" if not address_entry.text else address_entry.text
	var username = "player" if not username_entry.text else username_entry.text
	
	player_manager.local_username = username

	network_manager.start_client(address)

func _on_mouse_sensitivity_slider_value_changed(_value):
	get_tree().call_group("player", "change_mouse_sensitivity")

func _on_resume_button_pressed():
	$CanvasLayer/PauseMenu.hide()
	pause_menu_open = false
	unpause.emit()

# TODO: Move this to UIManager
func update_health_bar(health_value):
	health_bar.value = health_value

func _on_exit_button_pressed():
	get_tree().quit()
