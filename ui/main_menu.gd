extends Control


func _on_start_game_button_pressed() -> void:
	#Go in the proto_hub scene.
	get_tree().change_scene_to_file("res://levels/proto_hub.tscn")


func _on_settings_button_pressed() -> void:
	print("No implemented yet hahaha")
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
