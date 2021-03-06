extends "pawn.gd"

onready var Grid = get_parent()

var running = false

export(float) var Dash = 0.0

func _ready():
	Global.player = self
	if(Dash == 0):
		Dash = Global.backupDash
	update_look_direction(Vector2(1, 0))



func do_move(input_direction):
	$Pivot/Sprite/Sprite2.visible = false;
	var target_position = Grid.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
	else:
		bump()


func _process(_delta):
#	Global.backupDash = Dash
	if(Dash < 0):
		Dash = 0
	$ProgressBar.value = Dash
	match mycolor:
		colors.RED:
			$Pivot/Sprite.texture = load("res://textures/pawns/r.png")
		colors.GREEN:
			$Pivot/Sprite.texture = load("res://textures/pawns/g.png")
		colors.YELLOW:
			$Pivot/Sprite.texture = load("res://textures/pawns/y.png")
		colors.BLUE:
			$Pivot/Sprite.texture = load("res://textures/pawns/character.png")
	var input_direction = get_input_direction()
	#print(input_direction)
	var xset = input_direction.x != 0
	var yset = input_direction.y != 0
	var sprint_mult = 1;
	if Input.is_action_pressed("ui_sprint"):
		running = true
		sprint_mult = 4;
	else:
		running = false
	if(not (xset and yset)):
		$Pivot/Sprite/Sprite2.position = Vector2((65)*sprint_mult, 0);
	else:
		$Pivot/Sprite/Sprite2.position = Vector2((65*1.435)*sprint_mult, 0);
	if(xset or yset):
		$Pivot/Sprite/Sprite2.visible = true;
	else:
		$Pivot/Sprite/Sprite2.visible = false;
	if (not input_direction):
		return
	update_look_direction(input_direction)
	if (not Input.is_action_just_pressed("ui_accept")):
		return
	var needed = 9
	if Input.is_action_pressed("ui_sprint") and Dash > needed:
		Dash = Dash - (needed+1)
		AudioManager.get_node("Dash").play()
		for _i in range(4):
			do_move(input_direction)
	elif not Input.is_action_pressed("ui_sprint"):
		AudioManager.get_node("Walk").play()
		do_move(input_direction)
	else:
		bump()
		return
	Global.doAI()


func get_input_direction():
	if(Global.enableJoy and Global.joyIn != Vector2.ZERO):
		return Global.joyIn
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	) #* ((int(Input.is_action_pressed("ui_sprint")) * 2 ) + 1)


func update_look_direction(direction):
	$Pivot/Sprite.rotation = direction.angle()


func move_to(target_position):
	set_process(false)
	$AnimationPlayer.play("walk")

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - position).normalized()
	$Tween.interpolate_property($Pivot, "position", - move_direction * 32, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	position = target_position

	$Tween.start()

	# Stop the function execution until the animation finished
	yield($AnimationPlayer, "animation_finished")
	
	set_process(true)


func bump():
	set_process(false)
	$AnimationPlayer.play("bump")
	yield($AnimationPlayer, "animation_finished")
	set_process(true)
