class_name Goal extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		AudioManager.play_sound(AudioManager.goal)
		body.win()
