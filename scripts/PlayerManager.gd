extends Node

signal player_connected

var players = {}
var local_username = "player"

@onready var world = get_tree().get_current_scene()
@onready var decal_manager = $"../DecalManager"

func register_with_preset_username():
	register_player.rpc_id(1, local_username)

@rpc("any_peer", "reliable", "call_remote")
func register_player(username):
	print("New player: ", username)
	var new_player_id = multiplayer.get_remote_sender_id()
	players[str(new_player_id)] = {"name": username}
	
	for child in world.get_children():
		if child.is_in_group("player") and child.name == str(new_player_id):
			child.set_username(username)

func shoot():
	shoot_rpc.rpc_id(1)

@rpc("any_peer", "reliable")
func shoot_rpc():
	if not multiplayer.is_server():
		return

	var player_id = multiplayer.get_remote_sender_id()
	var player = world.get_node_or_null(str(player_id))
	if not player:
		return
	
	var raycast = player.raycast
	
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		if hit_object.is_in_group("player"):
			hit_object.receive_damage.rpc_id(hit_object.get_multiplayer_authority())
		
		decal_manager.add_bullet_decal(raycast)
