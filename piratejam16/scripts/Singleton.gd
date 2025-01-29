extends Node



var player_position = Vector2(-25,20)
var current_player_hp := 0
var current_player_strenght := 0
var current_player_dex := 0

#not implemented, not sure if needed
var current_character = null

var player_died = false

var max_attack_cooldown := 10.0

var basic_attack_angle := PI/4 #45°, taken in both directions so 90° total
var basic_character_range := 50

var necromancy_range := 200
var game_lost := false

var staff_instance = null

# Enemies that are valid for summoning by the player in the final boss battle
var boss_summon_list = []

func player_damage(strenght):
	current_player_hp -= strenght
	if current_player_hp <=0:
		current_player_hp = 0
		player_died = true
