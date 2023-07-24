extends Node2D

signal weapon_cahanged(new_weapon)

onready var arma_actual: Arma = $Pistol

var armas: Array = []

func _physics_process(delta):
	if not arma_actual.semi_auto and Input.is_action_pressed("shoot"):
		arma_actual.disparo()

func _ready():
	armas = get_children()
	
	for arma in armas:
		arma.hide()
	arma_actual.show()

func initialize(team: int):
	for arma in armas:
		arma.initialize(team)

func get_current_weapon() -> Arma:
	return arma_actual

func _unhandled_input(event):
	if arma_actual.semi_auto and event.is_action_released("shoot"):
		arma_actual.disparo()
	elif event.is_action_released("reload"):
		arma_actual.inicio_recargar()
	elif event.is_action_released("weapon_1"):
		switch_weapon(armas[0])
	elif event.is_action_released("weapon_2"):
		switch_weapon(armas[1])
		
func recarga():
	arma_actual.inicio_recargar()

func switch_weapon(arma: Arma):
	if arma == arma_actual:
		return
	
	arma_actual.hide()
	arma.show()
	arma_actual = arma
	emit_signal("weapon_cahanged",arma_actual)
