# Area3D loader
extends Area3D

const levels : Array = [
	"uid://d4cg0cgko5c4f",
	"uid://b7vk5ttl1r5se",
	"uid://di0da7y3m05ho"
]

var next_scene_path: String
var loading := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
#	En gros tous remplacer par le fait de call load_scene(). Mais il faut voir comment je transfert kla daata de mon joeur entre les scenes.
	if loading:
		return
	if body is Player:
		print("Go to level:", Game.cave_level)
		next_scene_path = levels[Game.cave_level]
		loading = true
		SceneLoader.load_scene(next_scene_path)
