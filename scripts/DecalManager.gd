extends Node

@onready var decal = preload("res://scenes/bullet_decal.tscn")
@onready var decal_blood = preload("res://scenes/bullet_decal_blood.tscn")

func add_bullet_decal(raycast):
	var collider = raycast.get_collider()
	var col_nor = raycast.get_collision_normal()
	var col_point = raycast.get_collision_point()
	
	add_bullet_decal_rpc.rpc(collider.get_path(), col_point, col_nor)

@rpc("call_local", "authority")
func add_bullet_decal_rpc(parent_path, col_point, col_nor):
	var collider = get_node(parent_path)

	var b = decal_blood.instantiate() if collider.is_in_group("player") else decal.instantiate()
	collider.add_child(b, true)

	b.global_transform.origin = col_point
	
	if col_nor == Vector3.DOWN:
		b.rotation_degrees.x = 90
	elif col_nor != Vector3.UP:
		b.look_at(col_point - col_nor, Vector3(0,1,0))
