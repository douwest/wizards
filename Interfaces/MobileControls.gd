extends HBoxContainer

#Press 

func _on_Left_pressed():
	Input.action_press("move_left")


func _on_Right_pressed():
	Input.action_press("move_right")
	

func _on_Up_pressed():
	Input.action_press("extend")


func _on_Down_pressed():
	Input.action_press("crouch")


func _on_Jump_pressed():
	Input.action_press("jump")


func _on_Block_pressed():
	Input.action_press("block")


func _on_Attack_pressed():
	Input.action_press("attack")


func _on_SpecialA_pressed():
	Input.action_press("special_1")


func _on_SpecialB_pressed():
	Input.action_press("special_2")


#Release

func _on_Left_released():
	Input.action_release("move_left")


func _on_Right_released():
	Input.action_release("move_right")


func _on_Up_released():
	Input.action_release("extend")


func _on_Down_released():
	Input.action_release("crouch")


func _on_Jump_released():
	Input.action_release("jump")


func _on_Block_released():
	Input.action_release("block")
	

func _on_Attack_released():
	Input.action_release("attack")


func _on_SpecialA_released():
	Input.action_release("special_1")


func _on_SpecialB_released():
	Input.action_release("special_2")


