extends CharacterBody2D

#region Nodes from Scene
@onready var JoyStick: Area2D = $"../Canvas/JoyStick"
@onready var UI: CanvasGroup = $"../Canvas/UI"
@onready var RayCast_UP: RayCast2D = $RayCasts/RayCast_UP
@onready var RayCast_DOWN: RayCast2D = $RayCasts/RayCast_DOWN
@onready var RayCast_RIGHT: RayCast2D = $RayCasts/RayCast_RIGHT
@onready var RayCast_LEFT: RayCast2D = $RayCasts/RayCast_LEFT
@onready var FullBody_Area: Area2D = $FullBody_Area
#endregion

#region Player Stats
var PlayerName: String
var Health: int
var MaxHealth: int
var Level: int
var XP: int
var ArmorPoints: int
#endregion

##Movement Variables##
var speed: int = 2

##Area on feet of player entered
func _on_feed_area_area_entered(area):
	UI.feed_area_entered(area)

func damage(damage: int):
	##TODO: PLay Damage Animation
	UI.manage_Equipment()
	var realDamage: int
	realDamage = damage - floori((float(damage) / 100.0) * float(ArmorPoints))
	
	Health -= realDamage
	
	UI.update_user_stats()
	
	if Health <= 0:
		death()

func death():
	var Equiped: bool = false ##TODO: Test if Revive Orb is Equiped
	if Equiped:
		Health = MaxHealth
		##TODO: Play Revive Orb animation and Destroy Orb
		return
	
	Equiped = false ##TODO: Test if Keep Inventory Orb is Equiped
	if !Equiped: #Drop and Clear Inventory
		var drop_range: int = 85
		for i in UI.Inventory.size():
			if UI.Inventory[i].item != null:
				UI.drop_item(UI.Inventory[i], position + Vector2(randf_range(-drop_range, drop_range), randf_range(-drop_range, drop_range)))
				UI.Inventory[i] = InventoryItem.new()
		for i in UI.Hotbar.size():
			if UI.Hotbar[i].item != null:
				UI.drop_item(UI.Hotbar[i], position + Vector2(randf_range(-drop_range, drop_range), randf_range(-drop_range, drop_range)))
				UI.Hotbar[i] = InventoryItem.new()
		for i in UI.Equipment.size():
			if UI.Equipment[i].item != null:
				UI.drop_item(UI.Equipment[i], position + Vector2(randf_range(-drop_range, drop_range), randf_range(-drop_range, drop_range)))
				UI.Equipment[i] = InventoryItem.new()
		UI.update_inv()
	else: ##TODO: Destroy Keep Inventory Orb
		pass
	
	##TODO: Play death Animation
	respawn()

func respawn():
	position = Vector2(0, 0)
	Health = MaxHealth

##Area of player entered
func _on_area_2d_area_entered(area):
	UI.player_area_entered(area)

##Area of player exited
func _on_area_2d_area_exited(area):
	UI.player_area_exited(area)

func _ready():
	#TODO: Delete if Load System is Ready
	PlayerName = "<Player Name>"
	Health = 100
	MaxHealth = 100
	Level = 1
	XP = 0

##Returns XP needet for the next level
func calculate_xp() -> int:
	return (Level * Level * Level * Level) + 100

func _physics_process(delta):
	velocity = JoyStick.get_velo() * (speed * 1000) * delta
	move_and_slide()
