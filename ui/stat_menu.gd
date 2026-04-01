extends Control


@onready var health : Label = $VBoxContainer/Health/Value
@onready var collect_range : Label = $VBoxContainer/CollectRange/Value
@onready var damage : Label = $VBoxContainer/Damage/Value
@onready var lamp_range : Label = $VBoxContainer/LampRange/Value
@onready var level : Label = $VBoxContainer/Level/Value
@onready var total_kills : Label = $VBoxContainer/TotalKills/Value
@onready var total_grapes : Label = $VBoxContainer/TotalGrapes/Value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update_stats(player: Player):
	health.text = str(int(player.health))

	collect_range.text = str(player.stats.get_stat("collectible_range"))
	damage.text = str(player.stats.get_stat("lamp_idle_damage_amount"))
	lamp_range.text = str(player.stats.get_stat("lamp_idle_range"))

	level.text = str(Game.cave_level+1) # (if not implemented yet)

	total_kills.text = str(int(player.stats.get_stat("enemies_killed")))
	total_grapes.text = str(int(player.stats.get_stat("grapes_collected")))
