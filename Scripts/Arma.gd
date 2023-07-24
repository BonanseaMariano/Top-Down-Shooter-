extends Node2D
class_name Arma

signal municion_arma_modificada(new_ammo_count)
signal sin_municion

export (PackedScene) var Bala
export (int)var municion_max: int = 5
export (bool) var semi_auto: bool = true

var team: int = -1
var municion_actual: int = municion_max setget set_municion_actual


onready var Fin_del_arma = $FinDelArma
onready var Enfriamiento = $Enfriamiento
onready var Animacion = $AnimationPlayer
onready var flash = $Flash

func _physics_process(delta):
	pass

func _ready():
	flash.hide()
	municion_actual = municion_max

func initialize(team: int):
	self.team = team

func inicio_recargar():
	Animacion.play("Recarga")
	
func _stop_recargar(): #el _ al comienzo del nombre de la funcion indica que es una funcion "privada"
	municion_actual = municion_max
	emit_signal("municion_arma_modificada",municion_actual)

func set_municion_actual(nueva_mucion: int):
	var municion_real = clamp(nueva_mucion, 0 ,municion_max)
	if municion_real != municion_actual:
		municion_actual = municion_real
		if municion_actual == 0:
			emit_signal("sin_municion")
		
		emit_signal("municion_arma_modificada",municion_actual)
	

func disparo():
	if municion_actual != 0 and Enfriamiento.is_stopped() and !Animacion.is_playing() and Bala !=null:
		var bala_instance = Bala.instance()
		var direction = (Fin_del_arma.global_position - global_position).normalized() 
		GlobalSignals.emit_signal("bala_disparada", bala_instance, team, Fin_del_arma.global_position, direction)
		$Disparo.play()
		Enfriamiento.start()
		Animacion.play("Flash")
		set_municion_actual(municion_actual - 1)
		
