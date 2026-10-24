extends Control

const BODY := """[b]Pustle[/b] is a mobile port of Pimple Popper by Crazy Marvin.

The game code, art, sound, and videos are under the MIT License.
Copyright (c) 2020 Crazy Marvin.
Programmer: Jordan Motta. Artist: Alex Rendon. Project lead: Marvin Meißner.
https://github.com/Crazy-Marvin/PimplePopper

[b]Fonts[/b] (SIL Open Font License 1.1)
• Outfit by The Outfit Project Authors — UI text. Replaces Noir Pro.
• Exo 2 by The Exo 2 Project Authors — buttons. Replaces Prototype.
• Lilita One by Juan Montoreano — the Pustle wordmark.
Full license texts ship in assets/fonts/OFL-Outfit.txt, OFL-Exo2.txt, and OFL-LilitaOne.txt.
Airstrike (Iconian), Prototype, and Noir Pro were removed because their licenses do not clearly allow redistribution.

[b]Icons[/b]
Several interface icons are from Icons8 (https://icons8.com) and need that attribution.

[b]Engine[/b]
Godot Engine, MIT License. https://godotengine.org
Copyright (c) 2014-present Godot Engine contributors. Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
"""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBox/Scroll/Body.text = BODY
	$Panel/VBox/Close.pressed.connect(queue_free)
