extends Node

@onready var world = get_tree().get_current_scene()
@onready var decal_manager = $"../DecalManager"

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
