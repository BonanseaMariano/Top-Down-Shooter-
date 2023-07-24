extends Node2D
class_name AI

signal estado_cambiado(new_estado)

enum Estado {
	PATROL,
	ENGAGE,
	ADVANCE
}

export (bool) var should_draw_path_line := false

onready var patrol_timer = $PatrolTimer
onready var path_line = $PathLine

var estado: int = -1 setget set_estado
var actor: Actor = null
var target: KinematicBody2D = null
var arma: Arma = null
var team: int = -1

#Variables para el PATROL
var origin: Vector2 = Vector2.ZERO
var patrol_location: Vector2 = Vector2.ZERO
var patrol_location_reached: bool = false
var actor_velocity: Vector2 = Vector2.ZERO

#Variables para el ADVANCE
var next_base: Vector2 = Vector2.ZERO

var pathfinding: Pathfinding

func _ready():
	set_estado(Estado.PATROL)
	path_line.visible = should_draw_path_line
	
func _physics_process(delta):
	path_line.global_rotation = 0
	match estado:
		Estado.PATROL:
			if not patrol_location_reached:
				var path = pathfinding.get_new_path(global_position, patrol_location)
				if path.size() > 1:	
					actor_velocity = actor.velocity_towards(path[1])
					actor.rotate_towards(path[1])
					actor.move_and_slide(actor_velocity)
					set_path_line(path)
				else: 
					patrol_location_reached = true
					actor_velocity = Vector2.ZERO
					patrol_timer.start()
					path_line.clear_points()
		Estado.ENGAGE:
			path_line.clear_points()
			if target !=null and arma != null:
				var angle_to_player = actor.global_position.direction_to(target.global_position).angle()
				actor.rotate_towards(target.global_position) #Para que mire al jugador, lerp es para que sea mas natural
				if abs(actor.rotation - angle_to_player) <0.1: #Para que solo dispare cuando este mirando al jugador
					arma.disparo()
			else:
				print("Engage pero sin arma/target")
		
		Estado.ADVANCE:
			var path = pathfinding.get_new_path(global_position, next_base)
			if path.size() > 1:
				actor_velocity = actor.velocity_towards(path[1])
				actor.rotate_towards(path[1])
				actor.move_and_slide(actor_velocity)
				set_path_line(path)
			else:
				set_estado(Estado.PATROL)
				path_line.clear_points()
		
		_: #Este es como el case default de Java
			print("Error: Estado Inexistente")

func initialize(actor: KinematicBody2D, arma: Arma, team: int):
	self.actor = actor
	self.arma = arma
	self.team = team
	
	arma.connect("sin_municion", self, "handle_reload")

func set_path_line(points: Array):
	if not should_draw_path_line:
		return
	var local_points := []
	for point in points:
		if point == points[0]:
			local_points.append(Vector2.ZERO)
		else:
			local_points.append(point - global_position) 

	path_line.points = local_points
	
func set_estado(new_estado: int):
	if new_estado == estado:
		return
	
	if new_estado == Estado.PATROL:
		origin = global_position
		patrol_timer.start()
		patrol_location_reached = true
		
	elif new_estado == Estado.ADVANCE:
		if actor.has_reached_position(next_base):
			set_estado(Estado.PATROL)
		
	
	estado = new_estado
	emit_signal("estado_cambiado", estado)

func handle_reload():
	arma.inicio_recargar()

func _on_PatrolTimer_timeout():
	var patrol_range = 150
	var random_x = rand_range(-patrol_range, patrol_range)
	var random_y = rand_range(-patrol_range, patrol_range)
	patrol_location = Vector2(random_x, random_y) + origin
	patrol_location_reached = false
	


func _on_DetectionZone_body_entered(body):
	if body.has_method("get_team") and body.get_team() != team:
		set_estado(Estado.ENGAGE)
		target = body


func _on_DetectionZone_body_exited(body):
	if target and body == target:
		set_estado(Estado.ADVANCE)
		target = null
