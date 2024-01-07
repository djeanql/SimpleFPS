extends AudioStreamPlayer3D

func _play(from_position=0.0):
	randomize()
	pitch_scale = randf_range(0.90, 1.10)
	
	self.play(from_position)
