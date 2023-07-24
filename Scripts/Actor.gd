extends KinematicBody2D
class_name Actor

signal died

onready var collision_shape = $AI/DetectionZone/CollisionShape2D
onready var vida = $Vida
onready var ai = $AI
onready var arma: Arma = $Arma
onready var team = $Team

export (int) var speed = 100

func _ready():
	ai.initialize(self, arma, team.team)
	arma.initialize(team.team)

func rotate_towards(location: Vector2):
	rotation = lerp(rotation, global_position.direction_to(location).angle(), 0.1)

func velocity_towards(location: Vector2) -> Vector2:
	return global_position.direction_to(location) * speed

func has_reached_position(location: Vector2) -> bool:
	return global_position.distance_to(location) < 5



func get_team() -> int:
	return team.team

func handle_hit():
	vida.vida -=20
	$Hit.play()
	if vida.vida <= 0:
		die()

func die():
	emit_signal("died")
	queue_free()
