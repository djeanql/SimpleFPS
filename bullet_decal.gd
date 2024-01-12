extends Node3D

var col_point
var col_nor

#func place():
	#print(global_transform.origin)
	#print(col_point)
#
	#global_transform.origin = col_point
	#if col_nor == Vector3.DOWN:
		#rotation_degrees.x = 90
	#elif col_nor != Vector3.UP:
		#look_at(col_point - col_nor, Vector3(0,1,0))

func _on_timer_timeout():
	queue_free()

#func _enter_tree():
	#place()
