extends CharacterBody3D

signal health_changed(health_value)
signal shoot

@onready var world = get_tree().get_current_scene()
@onready var network_manager = world.network_manager
@onready var player_manager = world.player_manager
@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D
@onready var gun_sound_player = $Camera3D/pistol/GunSoundPlayer
@onready var hit_sound_player = $HitSoundPlayer
@onready var death_sound_player = $DeathSoundPlayer
@onready var decals = $decals
@onready var username_label = $UsernameLabel

@export var username = name
@export var health = 100

const SPEED = 8.0
const JUMP_VELOCITY = 7.0
var gravity = 20.0

var mouse_sensitivity = 0.003

var paused = false

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():
		return

	#print(player_manager.players)
	username_label.hide()
	player_manager.register_with_preset_username()
	username = player_manager.local_username
	username_label.text = username

	get_node("../CanvasLayer/PauseMenu/MarginContainer/VBoxContainer/MouseSensitivitySlider").value_changed.connect(change_mouse_sensitivity)
	world.pause.connect(pause)
	world.unpause.connect(unpause)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _unhandled_input(event):
	if paused or not is_multiplayer_authority():
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2,  PI/2)
	
	if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "shoot":
		shoot_effects.rpc()
		shoot.emit()

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	if not is_on_floor(): 
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()

@rpc("call_local")
func shoot_effects():
	gun_sound_player.pitch_scale = randf_range(0.85, 1.15)
	gun_sound_player.play()
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

@rpc("any_peer", "call_local")
func receive_damage(damage):
	if multiplayer.get_remote_sender_id() != 1:
		return

	health -= damage
	hit_sound_player.play()
	
	health_changed.emit(health)

@rpc("any_peer", "call_local")
func respawn():
	if multiplayer.get_remote_sender_id() != 1:
		return
		
	death_sound_player.play()

	for decal in decals.get_children():
		decals.remove_child(decal)
	
	position = Vector3.ZERO
	health = 100
	health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")

func set_username(uname):
	username = uname
	username_label.text = username
	print(username)


#@rpc("any_peer", "call_local")
#func chat_message(message):
	#world.chat_label.text = message

func change_mouse_sensitivity(value):
	mouse_sensitivity = value / 1000

func pause():
	paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func unpause():
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
