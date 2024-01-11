extends Node

@onready var world = get_tree().get_current_scene()
@onready var decal = preload("res://bullet_decal.tscn")
@onready var decal_blood = preload("res://bullet_decal_blood.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_bullet_decal(raycast):
	if raycast.is_colliding():
		var col_nor = raycast.get_collision_normal()
		var col_point = raycast.get_collision_point()

		var b = decal_blood.instantiate() if raycast.get_collider().is_in_group("player") else decal.instantiate() 

		raycast.get_collider().add_child(b)
		b.global_transform.origin = col_point
		if col_nor == Vector3.DOWN:
			b.rotation_degrees.x = 90
		elif col_nor != Vector3.UP:
			b.look_at(col_point - col_nor, Vector3(0,1,0))

func shoot():
	shoot_rpc.rpc_id(1)
	print("sent RPC to server")

@rpc("any_peer", "reliable")
func shoot_rpc():
	print(multiplayer.get_remote_sender_id(), " is shooting")
	var player_id = multiplayer.get_remote_sender_id()
	var player = world.get_node_or_null(str(player_id))
	if not player:
		print("Player not found: ", player_id)
		for child in get_children():
			print(child.name)
		return
	
	var raycast = player.raycast
	
	if raycast.is_colliding():
		#add_bullet_decal(raycast)
		var hit_object = raycast.get_collider()
		if hit_object.is_in_group("player"):
			hit_object.receive_damage.rpc_id(hit_object.get_multiplayer_authority())

		add_bullet_decal(raycast)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
