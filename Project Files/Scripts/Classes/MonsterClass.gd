extends KinematicBody2D
class_name Monster

onready var level_manager = get_parent().get_parent().get_parent()
onready var state_machine = $AnimationTree.get("parameters/playback")

onready var corpseLootableBox = preload("res://Scenes/Object/Interactable_Object.tscn")

signal monster_died

export (int) var health = 1
export (int) var run_speed = 160
export (int) var walk_speed = 80
export (int) var charge_speed = 1000
export (int) var fall_speed = 160

export (int) var current_floor = 1

export (Array) var lootable_items:Array
export (bool) var looted:bool = false

var _dead = false
export (int) var touch_damage = 30
var touch_damage_enabled = true

var loot_drop = []

onready var monsterName = get_parent().get_parent().name+" - "+self.name
func receive_damage(incoming_damage):
	health -= incoming_damage
	print (health)
	if health <= 0:
		health = 0
		if _dead != true:
			_play_death_animation()
			die()
	save_enemy_state()

func melee_hit(damage):
	receive_damage(damage)
	save_enemy_state()

	
func die():
	$MonsterCriticalHitBox.queue_free()
	$GroundPosition.queue_free()
	$MonsterHitBox.queue_free()
	$InteractableHitBox.queue_free()
	_dead = true
	_find_level_node().monster_death(self)
	if !lootable_items.empty():
		make_lootable_body()
	
	save_enemy_state()
		
		
func _play_death_animation():
	change_animation("Death")
	pass


func _find_level_node() -> Node:
	var parent = get_parent()
	while parent != null:
		if parent.is_in_group("Level"):
			return parent
		elif parent == get_tree():
			push_warning("Tried to find Level Node from Monster, no parents reporting as \"Level\" group")
			parent = null
		else:
			parent = parent.get_parent()
	return parent


func change_animation(animationToChangeTo:String)->void:
	if state_machine.get_current_node() != animationToChangeTo:
		state_machine.travel(animationToChangeTo)



func load_enemy_state():
	var load_data = _find_level_node().load_enemy_state_in_level(monsterName)
	if !load_data.empty():
		_dead = load_data["dead"]
		health = load_data["health"]
		loot_drop = load_data["loot_drop"]
		looted = load_data["looted"]
		var new_pos =Vector2(load_data["position.x"],load_data["position.y"])
		print (new_pos)
		self.position = new_pos
		
		if _dead:
			
			$MonsterCriticalHitBox.queue_free()
			$GroundPosition.queue_free()
			$MonsterHitBox.queue_free()
			$InteractableHitBox.queue_free()
			change_animation("Dead")
			make_lootable_body()
		if _dead and lootable_items.empty():
			print("Nothing of value here: "+self.name)
	else: ### If it's not in the save file, it should be, so adds current state into memory
		save_enemy_state()

func save_enemy_state():
	var save_data = {
		"dead":_dead,
		"health":health,
		"loot_drop":loot_drop,
		"looted":looted,
		"position.x":self.position.x,
		"position.y":self.position.y,
		}
	
	_find_level_node().save_enemy_state_in_level(monsterName,save_data)

func make_lootable_body():
	if !lootable_items.empty() and !looted:
		var lootable_corpse = corpseLootableBox.instance()
		lootable_corpse.object_name = self.name+"_Corpse"
		lootable_corpse.inventory_items_to_add = lootable_items
		lootable_corpse.dialog_one_time_trigger = true
		self.add_child(lootable_corpse)
		lootable_corpse.connect("item_looted",self,"item_looted")
	pass

func item_looted():
	looted = true
	
	save_enemy_state()
