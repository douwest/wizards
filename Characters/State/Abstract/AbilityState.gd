extends State
class_name AbilityState

var character: Character

# This is an extension of state that works in a comparable way to CharacterState. The
# difference is in the lifecycle. This state is meant to be swappable, but still have type-safety
# and a reference to the character. Therefore we need a manual way to inject the reference to owner.

# Call this when the node has been added to the tree
func init(o: Character, s: StateMachine) -> void:
	state_machine = s
	character = o
	assert(character != null && state_machine != null)
