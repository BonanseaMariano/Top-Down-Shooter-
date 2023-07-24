extends Area2D
class_name Bala #Esto es nomas de prueba para que salga el autocompletado cuando llamo las funciones de bala de otro lado

export (int) var speed = 10
onready var kill_timer = $KillTimer
var direction := Vector2.ZERO
var team: int =-1

func _ready():
	kill_timer.start()
	
func _physics_process(delta):
	if direction != Vector2.ZERO:
		var velocidad = direction * speed
		global_position += velocidad

func set_direction(dire: Vector2):
	direction = dire
	rotation += dire.angle()

func _on_KillTimer_timeout():
	queue_free()


func _on_Bala_body_entered(body):
	if body.has_method("handle_hit"):
		if body.has_method("get_team") and body.get_team() != team:
			body.handle_hit()
	queue_free() 
