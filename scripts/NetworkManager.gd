extends Node

const Player = preload("res://scenes/player.tscn")

@onready var world = get_tree().get_current_scene()
@onready var player_manager = $"../PlayerManager"

var players = {}

const PORT = 8888
var enet_peer = ENetMultiplayerPeer.new()

func start_server():
	# upnp_setup()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

func start_client(addr):
	enet_peer.create_client(addr, PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	world.add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(world.update_health_bar)

	player.shoot.connect(player_manager.shoot)

@rpc("any_peer", "reliable")
func register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(world.update_health_bar)
	
	if node.is_in_group("player"):
		node.shoot.connect(player_manager.shoot)

func upnp_setup():
	var upnp = UPNP.new()

	var discover_result = upnp.discover()
	
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		print("UPNP Discover Failed. Error %s" % discover_result)
		return

	if not upnp.get_gateway() or not upnp.get_gateway().is_valid_gateway():
		print("UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		print("UPNP Port Mapping Failed! Error %s" % map_result)
		return

	print("UPNP Success! Join  Address: %s" % upnp.query_external_address())

	# TODO: Tidy this up, move to UI manager
	$"../../CanvasLayer/HUD/HostingLabel".text = "Hosting: %s" % upnp.query_external_address()
	$"../../CanvasLayer/HUD/UpnpLabel".show()
