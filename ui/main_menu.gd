extends Control

const hub_scene : String =  "uid://bkx628iow4cs5"

func _on_start_game_button_pressed() -> void:
	#Go in the proto_hub scene.
	SceneLoader.load_scene(hub_scene)


func _on_settings_button_pressed() -> void:
	print("No implemented yet hahaha")
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
