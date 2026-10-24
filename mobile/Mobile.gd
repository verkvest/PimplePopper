extends Node

## Maps the display safe area into the stretched viewport and insets full-rect UI.


func insets() -> Rect2:
	var visible := get_tree().root.get_visible_rect()
	var window := DisplayServer.window_get_size()
	if window.x <= 0 or window.y <= 0:
		return visible
	var safe := DisplayServer.get_display_safe_area()
	var scale := visible.size / Vector2(window)
	return Rect2(Vector2(safe.position) * scale, Vector2(safe.size) * scale)


func fit(control: Control, bleed: Array = []) -> void:
	if control == null:
		return
	var visible := get_tree().root.get_visible_rect()
	var safe := insets()
	var left := maxf(safe.position.x - visible.position.x, 0.0)
	var top := maxf(safe.position.y - visible.position.y, 0.0)
	var right := maxf((visible.position.x + visible.size.x) - (safe.position.x + safe.size.x), 0.0)
	var bottom := maxf((visible.position.y + visible.size.y) - (safe.position.y + safe.size.y), 0.0)
	if control.anchor_left <= 0.01 and control.anchor_top <= 0.01 and control.anchor_right >= 0.99 and control.anchor_bottom >= 0.99:
		control.offset_left = left
		control.offset_top = top
		control.offset_right = -right
		control.offset_bottom = -bottom
	for node in bleed:
		if node is Control:
			node.offset_left -= left
			node.offset_top -= top
			node.offset_right += right
			node.offset_bottom += bottom
