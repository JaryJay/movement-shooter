extends Resource
class_name ClientInput

var frame: int
var is_empty: = false

func _init(_frame: int, _is_empty: bool = false):
	frame = _frame
	is_empty = _is_empty

static func create_from(bytes: PackedByteArray) -> ClientInput:
	var arr: Array = bytes_to_var(bytes)
	var _frame: int = arr[0]
	var _is_empty: bool = arr.size() == 1
	var input: = ClientInput.new(_frame, _is_empty)
	# TODO
	return input

static func to_bytes(input: ClientInput) -> PackedByteArray:
	if input.is_empty:
		return var_to_bytes([input.frame])
	var arr: Array = [input.frame]
	return var_to_bytes(arr)

func _to_string() -> String:
	return ""
