extends Node2D


enum BaseCaptureStartOrder {
	FIRST,
	LAST
}

export (BaseCaptureStartOrder) var base_capture_start_order
export (Team.TeamName) var team_name = Team.TeamName.NEUTRAL
export (PackedScene) var unit = null
export (int) var max_units_alive = 4

var capturable_bases: Array = []
var respawn_ponts: Array = []
var next_spawn_to_use: int = 0
var pathfinding:Pathfinding 

var target_base: CapturableBase = null

onready var team = $Team
onready var unit_container = $UnitContainer
onready var respawn_timer = $RespawnTimer

func initialize(capturable_bases: Array, respawn_points: Array, pathfinding: Pathfinding):
	if capturable_bases.size() == 0 or respawn_points.size() == 0 or unit == null:
		push_error("Forgot to properly initialize our Map AI")
		return
		
	team.team = team_name
	self.pathfinding = pathfinding
	self.respawn_ponts = respawn_points
	for respawn in respawn_points:
		spawn_units(respawn.global_position)
	
	
	self.capturable_bases = capturable_bases
	
	for base in capturable_bases:
		base.connect("base_captured", self, "handle_base_captured")
	
	check_for_next_capturable_base()
		

func handle_base_captured(_new_team: int):
	check_for_next_capturable_base()

func check_for_next_capturable_base():
	var next_base = get_next_capturable_base()
	if next_base != null:
		target_base = next_base
		assing_next_capturable_base_to_units(next_base)

func get_next_capturable_base():
	#Asume base capture start order is first
	var list_of_bases = range(capturable_bases.size()) 
	
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_bases = range(capturable_bases.size() - 1, -1, -1)
	
	for i in list_of_bases:
		var base: CapturableBase = capturable_bases[i]
		if team.team != base.team.team: 
			return base
			
	return null

func assing_next_capturable_base_to_units(base: CapturableBase):
	for unit in unit_container.get_children():
		set_unit_ai_to_advance_to_next_base(unit)
		

func spawn_units(spawn_location: Vector2):
	var unit_instance = unit.instance()
	unit_container.add_child(unit_instance)
	unit_instance.global_position = spawn_location
	unit_instance.connect("died", self, "handle_unit_death")
	unit_instance.ai.pathfinding = pathfinding
	set_unit_ai_to_advance_to_next_base(unit_instance)

func set_unit_ai_to_advance_to_next_base(unit: Actor):
	if target_base != null:
		var ai: AI = unit.ai
		ai.next_base = target_base.get_random_position_within_capture_radious()
		ai.set_estado(AI.Estado.ADVANCE)

func handle_unit_death():
	$Mori.play()
	if respawn_timer.is_stopped() and unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()

func _on_RespawnTimer_timeout():
	var respawn = respawn_ponts[next_spawn_to_use]
	spawn_units(respawn.global_position)
	next_spawn_to_use += 1
	if next_spawn_to_use == respawn_ponts.size():
		next_spawn_to_use = 0
		
	if unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()
