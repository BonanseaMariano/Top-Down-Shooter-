extends CanvasLayer

onready var health_bar = $MarginContainer/Rows/BottomRow/HealthSection/HealthBar
onready var health_tween = $MarginContainer/Rows/BottomRow/HealthSection/HealthTween
onready var current_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/CurrentAmmo
onready var max_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/MaxAmmo

var player: Player

func set_player(player: Player):
	self.player = player
	set_new_health_value(player.vida.vida)
	player.connect("player_health_changed",self,"set_new_health_value")
	
	set_weapon(player.weapon_manager.get_current_weapon())
	player.weapon_manager.connect("weapon_cahanged",self,"set_weapon")
	

func set_weapon(arma: Arma):
	#Player current ammo
	set_current_ammo(arma.municion_actual)
	#Municion maxima no tiene que cambiar, entonces no hay que hacer nada (excepto si se agregan nuevas armas)
	set_max_ammo(arma.municion_max)
	if not arma.is_connected("municion_arma_modificada",self,"set_current_ammo"):
		arma.connect("municion_arma_modificada",self,"set_current_ammo")

func set_new_health_value (new_health: int):
	var color_original = Color("#e53a3a")
	var color_hit = Color("#f79898")
	var bar_style = health_bar.get("custom_styles/fg")
	health_tween.interpolate_property(health_bar,"value",health_bar.value, new_health, 0.4, Tween.TRANS_LINEAR,Tween.EASE_IN)
	health_tween.interpolate_property(bar_style,"bg_color", color_original, color_hit, 0.2,Tween.TRANS_LINEAR, Tween.EASE_IN)
	health_tween.interpolate_property(bar_style,"bg_color", color_hit, color_original, 0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT,0.2)
	health_tween.start()
	

func set_current_ammo (new_ammo: int):
	current_ammo.text = str(new_ammo)
	
func set_max_ammo (new_max_ammo: int):
	max_ammo.text = str(new_max_ammo)
