extends Node2D

const Player = preload("res://Scenes/Player.tscn")

onready var capturable_base_manager = $CapturableBaseManager
onready var ally_ai = $AllyMapAI
onready var enemy_ai = $EnemyMapAI
onready var bala_manager = $BalaManager
onready var camera = $Camera2D
onready var gui = $GUI
onready var ground = $Ground
onready var pathfinding = $PathFinding
 
func _ready():
	randomize()
	GlobalSignals.connect("bala_disparada", bala_manager, "manejo_bala_disparada")
	
	var ally_respawns = $AllyRespawnPoints
	var enemy_respawns = $EnemyRespawnPoints
	
	pathfinding.create_navegation_map(ground)
	
	var bases = capturable_base_manager.get_capturable_bases()
	ally_ai.initialize(bases, ally_respawns.get_children(),pathfinding)
	enemy_ai.initialize(bases, enemy_respawns.get_children(),pathfinding)
	
	spawn_player()


func spawn_player():
	var player = Player.instance()
	add_child(player)
	player.set_camera_transform(camera.get_path())
	player.connect("died", self, "spawn_player")
	gui.set_player(player)
	
