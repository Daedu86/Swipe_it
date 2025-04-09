extends Node2D  

# 📌 Skalierungsfaktoren
var base_resolution = Vector2(1080, 1920)  # Basisauflösung für Skalierung (Full-HD)
var screen_size = Vector2.ZERO  
var is_mobile = false  # Wird auf true gesetzt, falls ein Handy erkannt wird

# 📌 Swipe-Gesten Variablen
var swipe_start_position = Vector2.ZERO  
var min_swipe_distance = 50  # Minimale Swipe-Distanz für Erkennung

# 📌 Punktestand & Spielstatus
var score = 0  
var game_running = true  
var last_wrong_word = ""  # Verhindert mehrfaches Loggen desselben Fehlers

# 📌 Wörterliste
var words = [
	{"word": "Haus", "gender": "n"}, 
	{"word": "Baum", "gender": "m"}, 
	{"word": "Auto", "gender": "n"}, 
	{"word": "Katze", "gender": "f"}, 
	{"word": "Hund", "gender": "m"}, 
	{"word": "Apfel", "gender": "m"},
	{"word": "Batterie", "gender": "f"},
	{"word": "Motor", "gender": "m"},
	{"word": "Bremsflüssigkeitsbehälter", "gender": "m"},
	{"word": "Kühlflüssigkeitsbehälter", "gender": "m"},
	{"word": "Ölmessstab", "gender": "m"},
	{"word": "Reifen", "gender": "m"},
	{"word": "Motorhaube", "gender": "f"},
	{"word": "Erste-Hilfe-Set", "gender": "n"},
	{"word": "Sicherheitsweste", "gender": "f"},
	{"word": "Warndreieck", "gender": "n"},
	{"word": "Lampe", "gender": "f"},
	{"word": "Hilfsmittel", "gender": "n"},
	{"word": "Feuerlöscher", "gender": "m"},
	{"word": "Wagenheber", "gender": "m"},
	{"word": "Radmutternschlüssel", "gender": "m"},
	{"word": "Reifenfüller", "gender": "m"},
	{"word": "Autokabel", "gender": "n"},
	{"word": "Tankdeckel", "gender": "m"},
	{"word": "Kühler", "gender": "m"},
	{"word": "Scheibenwischer", "gender": "m"}
]
var current_word = {}

# 📌 Referenzen zu Nodes
@onready var word_label_container = $WordLabelContainer
@onready var word_label = $WordLabelContainer/WordLabel
@onready var collector_m = $Collector1
@onready var collector_f = $Collector2
@onready var collector_n = $Collector3
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var confirmation_popup = $ExitDialog
@onready var ok_button = $ExitDialog/OkButton
@onready var cancel_button = $ExitDialog/CancelButton

func _ready():
	add_margin()
	print("📌 Collector-Positionen:")
	print("Collector M (männlich): ", collector_m.global_position)
	print("Collector F (weiblich): ", collector_f.global_position)
	print("Collector N (neutral): ", collector_n.global_position)
	print("📌 Wort-Position:", word_label_container.global_position)
	print("📌 Collector-Positionen:")
	print("Collector M (männlich): ", collector_m.global_position)
	print("Collector F (weiblich): ", collector_f.global_position)
	print("Collector N (neutral): ", collector_n.global_position)
	print("📌 Wort-Position:", word_label_container.global_position)
	print("📌 Collector-Positionen:")
	print("Collector M (männlich): ", collector_m.global_position)
	print("Collector F (weiblich): ", collector_f.global_position)
	print("Collector N (neutral): ", collector_n.global_position)
	screen_size = get_viewport_rect().size

	# Prüfen, ob das Spiel auf einem Handy läuft
	if OS.has_feature("mobile"):
		is_mobile = true
		print("📱 Handy erkannt! Automatische Skalierung wird angewendet.")
		adjust_for_mobile()
	else:
		print("💻 Desktop erkannt! Keine Skalierung notwendig.")

	# Versuche ExitDialog und Buttons zu finden (wird auch in _process überprüft)
	initialize_exit_dialog()

	if score_label == null:
		print("⚠️ WARNUNG: ScoreLabel wurde nicht gefunden! Überprüfe den Pfad im Szenenbaum.")
	else:
		update_score_label()

	spawn_new_word()

func update_score_label():
	if score_label:
		score_label.text = "Punkte: " + str(score)
	else:
		print("⚠️ WARNUNG: ScoreLabel nicht gefunden!")

func _input(event):
	if event is InputEventKey and event.pressed:
		var move_offset = Vector2.ZERO
		if event.keycode == KEY_UP:
			move_offset.y -= 50
		elif event.keycode == KEY_DOWN:
			move_offset.y += 50
		elif event.keycode == KEY_LEFT:
			move_offset.x -= 50
		elif event.keycode == KEY_RIGHT:
			move_offset.x += 50
		move_word(move_offset)

func move_word(direction: Vector2):
	if game_running and word_label_container:
		var new_position = word_label_container.position + direction

		# Begrenzung der Bewegung innerhalb des Bildschirms
		var container_size = Vector2(200, 50)
		new_position.x = clamp(new_position.x, 0, screen_size.x - container_size.x)
		new_position.y = clamp(new_position.y, 0, screen_size.y - container_size.y)

		word_label_container.position = new_position
		check_collision()

func check_collision():
	if not game_running:
		return

	var correct_collector = null
	var correct_collector_name = ""

	match current_word["gender"]:
		"m":
			correct_collector = collector_m
			correct_collector_name = "Collector M (männlich)"
		"f":
			correct_collector = collector_f
			correct_collector_name = "Collector F (weiblich)"
		"n":
			correct_collector = collector_n
			correct_collector_name = "Collector N (neutral)"

	# Richtige Zuweisung
	if correct_collector and word_label_container.position.distance_to(correct_collector.global_position) < 50:
		score += 1
		print("✅ Korrekt! ", current_word["word"], " ist ", current_word["gender"], " | Punktestand: ", score)
		update_score_label()
		spawn_new_word()
		return  

	# Falsche Zuweisung mit richtiger Collector-Angabe
	for collector in [collector_m, collector_f, collector_n]:
		if collector != correct_collector and word_label_container.position.distance_to(collector.global_position) < 50:
			var wrong_collector_name = ""
			if collector == collector_m:
				wrong_collector_name = "Collector M (männlich)"
			elif collector == collector_f:
				wrong_collector_name = "Collector F (weiblich)"
			elif collector == collector_n:
				wrong_collector_name = "Collector N (neutral)"

			print("❌ Falsch! ", current_word["word"], " gehört nicht zu ", wrong_collector_name, 
				  " sondern zu ", correct_collector_name, " | Kein Punkt")
			spawn_new_word()
			return

func initialize_exit_dialog():
	confirmation_popup = get_node_or_null("ExitDialog")
	if confirmation_popup:
		print("✅ ExitDialog gefunden!")
		
		ok_button = confirmation_popup.get_node_or_null("OkButton")  # Korrekte Schreibweise
		cancel_button = confirmation_popup.get_node_or_null("CancelButton")

		if ok_button:
			print("✅ OkButton gefunden!")
			if not ok_button.is_connected("pressed", Callable(self, "confirm_exit")):
				ok_button.connect("pressed", Callable(self, "confirm_exit"))
				print("🔗 OK-Button mit confirm_exit() verbunden!")
		else:
			print("⚠️ WARNUNG: OkButton nicht gefunden! Überprüfe den Namen im Szenenbaum.")

		if cancel_button:
			print("✅ CancelButton gefunden!")
			if not cancel_button.is_connected("pressed", Callable(self, "cancel_exit")):
				cancel_button.connect("pressed", Callable(self, "cancel_exit"))
				print("🔗 Cancel-Button mit cancel_exit() verbunden!")
		else:
			print("⚠️ WARNUNG: CancelButton nicht gefunden! Überprüfe den Namen im Szenenbaum.")
	else:
		print("⚠️ WARNUNG: ExitDialog nicht gefunden! Überprüfe den Szenenbaum.")

func _process(_delta):
	# Falls ExitDialog später geladen wurde, versuche es erneut zu finden
	if confirmation_popup == null:
		initialize_exit_dialog()

func adjust_for_mobile():
	var scale_factor = screen_size / base_resolution
	$CanvasLayer.scale = scale_factor  # UI-Elemente skalieren
	scale = scale_factor  # Gesamte Szene skalieren

func spawn_new_word():
	if not game_running:
		return

	if word_label == null or word_label_container == null:
		print("⚠️ WARNUNG: word_label oder word_label_container ist NULL!")
		return

	current_word = words[randi() % words.size()]
	word_label.text = current_word["word"]
	word_label_container.position = Vector2(screen_size.x / 2, screen_size.y / 2)
	word_label.show()
	word_label_container.show()

func add_margin():
	var margin_rect = ColorRect.new()
	margin_rect.color = Color(1, 1, 1)  # Weißer Rand
	margin_rect.size = Vector2(screen_size.x, screen_size.y)
	margin_rect.position = Vector2(0, 0)
	margin_rect.anchor_left = 0.0
	margin_rect.anchor_top = 0.0
	margin_rect.anchor_right = 1.0
	margin_rect.anchor_bottom = 1.0
	margin_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(margin_rect)

func stop_game():
	print("🛑 Spiel pausiert! Warte auf Entscheidung...")
	game_running = false  
	get_tree().paused = true  # Spiel pausieren

	# ABER: ExitDialog muss weiter funktionieren!
	if confirmation_popup:
		confirmation_popup.show()
		confirmation_popup.process_mode = Node.PROCESS_MODE_ALWAYS  # Sorgt dafür, dass die UI weiter funktioniert
		print("✅ Exit-Dialog geöffnet. UI bleibt aktiv.")
	else:
		print("⚠️ WARNUNG: confirmation_popup ist NULL!")

func cancel_exit():
	print("🔄 TEST: Cancel wurde geklickt!")  # Sollte in der Konsole erscheinen

	if confirmation_popup:
		confirmation_popup.hide()
		print("✅ TEST: Exit-Dialog geschlossen.")
	else:
		print("⚠️ WARNUNG: confirmation_popup ist NULL!")

	game_running = true  

	# Warten auf den nächsten Frame, damit Godot die Pause zurücksetzen kann
	await get_tree().process_frame  

	# **PAUSE ENTFERNEN**
	get_tree().paused = false  
	print("🎮 TEST: SPIELSTATUS nach Cancel:", "LÄUFT" if not get_tree().paused else "PAUSIERT")

	# Falls das Spiel immer noch pausiert ist, erzwinge die Fortsetzung
	if get_tree().paused:
		print("⚠️ Achtung! Spiel bleibt pausiert. Erzwinge Deaktivierung...")
		await get_tree().process_frame  
		get_tree().paused = false  
		print("✅ SPIELSTATUS ERZWUNGEN: LÄUFT")
