class_name Shell
extends CanvasLayer
## The screens around the core loop: who is playing, title, run complete and
## the parent area. Built in code; the game scene underneath is the backdrop.

const GOLD := Color("#ffc93c")
const GREEN := Color("#2f9e5b")
const BLUE := Color("#3b6fb6")
const RED := Color("#c0443c")
const GREY := Color("#6b7385")
const PANEL := Color(0.10, 0.16, 0.30, 0.82)
const DIFF_NAMES := {"easy": "Easy", "normal": "Normal", "hard": "Hard"}

var main: Node
var store: ProfileStore
var _root: Control
var _modal: Control


func setup(m: Node, s: ProfileStore) -> void:
	main = m
	store = s
	layer = 10


## Removes whatever screen is showing.
func clear() -> void:
	close_modal()
	if _root:
		_root.queue_free()
		_root = null


# ---------- helpers ----------

func _full(parent: Node) -> Control:
	var c := Control.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(c)
	return c


func _ignore(c: Control) -> Control:
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _label(text: String, size: int, col: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.1, 0.18, 0.35, 0.8))
	l.add_theme_constant_override("outline_size", maxi(size / 10, 2))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _box(vertical: bool, gap: int = 16) -> BoxContainer:
	var b: BoxContainer = VBoxContainer.new() if vertical else HBoxContainer.new()
	b.add_theme_constant_override("separation", gap)
	b.alignment = BoxContainer.ALIGNMENT_CENTER
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


func _panel(col: Color = PANEL, pad: int = 32) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(36)
	sb.set_content_margin_all(pad)
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


func _icon(kind: String, px: float, col: Color = Color.WHITE) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(px, px)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func() -> void: Icons.draw(c, kind, c.size / 2.0, px * 0.8, col))
	return c


func _house(style: String, px: float, locked: bool = false) -> TextureRect:
	var t := TextureRect.new()
	t.texture = main.textures[Styles.art_key(style)]
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(px, px * 1.1)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if locked:
		t.modulate = Color(0.08, 0.1, 0.18, 0.85)
	return t


func _corner_gate(parent: Control) -> ParentGate:
	var g := ParentGate.new()
	g.anchor_left = 1.0
	g.anchor_right = 1.0
	g.offset_left = -(ParentGate.SIZE + 32)
	g.offset_right = -32
	g.offset_top = 32
	g.offset_bottom = 32 + ParentGate.SIZE
	g.opened.connect(main.open_parent)
	parent.add_child(g)
	return g


func _screen() -> Control:
	clear()
	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	return _root


func _center(parent: Control, vertical_top: bool = false) -> Control:
	var m := MarginContainer.new()
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 40)
	m.add_theme_constant_override("margin_right", 40)
	m.add_theme_constant_override("margin_top", 150 if vertical_top else 40)
	m.add_theme_constant_override("margin_bottom", 40)
	parent.add_child(m)
	return m


# ---------- who is playing ----------

func show_who() -> void:
	var r := _screen()
	var m := _center(r)
	var v := _box(true, 28)
	m.add_child(v)
	v.add_child(_label("Who is playing?", 68, GOLD))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 28)
	grid.add_theme_constant_override("v_separation", 28)
	var hold := CenterContainer.new()
	hold.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hold.add_child(grid)
	v.add_child(hold)
	for p in store.profiles:
		var b := Button.new()
		b.custom_minimum_size = Vector2(380, 420)
		b.focus_mode = Control.FOCUS_NONE
		for slot in ["normal", "hover", "pressed", "focus"]:
			var sb := StyleBoxFlat.new()
			sb.bg_color = PANEL if slot != "pressed" else Color(0.2, 0.3, 0.5, 0.9)
			sb.set_corner_radius_all(36)
			b.add_theme_stylebox_override(slot, sb)
		var inner := _box(true, 8)
		inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inner.add_child(_house(p["style"], 250))
		inner.add_child(_label(p["name"], 52))
		b.add_child(inner)
		var id: int = p["id"]
		b.pressed.connect(func() -> void: main.choose_profile(id))
		grid.add_child(b)
	_corner_gate(r)


# ---------- title ----------

func show_title() -> void:
	var r := _screen()
	var prof := store.current()
	var m := _center(r, true)
	var v := _box(true, 24)
	v.alignment = BoxContainer.ALIGNMENT_BEGIN
	m.add_child(v)
	v.add_child(_label("Hi, %s!" % prof["name"], 80, GOLD))
	v.add_child(_label("Tower Craft", 52))
	var best := _box(false, 12)
	best.add_child(_icon("star", 56, GOLD))
	best.add_child(_label("Best %d" % prof["best"], 52))
	v.add_child(best)
	v.add_child(_style_picker(prof))
	var play := KButton.new("Play", "play", GREEN, 520, 60)
	play.custom_minimum_size.y = 128
	play.pressed.connect(main.start_play)
	var pc := CenterContainer.new()
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(play)
	v.add_child(pc)
	if store.profiles.size() > 1:
		var sw := KButton.new("", "people", BLUE)
		sw.anchor_left = 0.0
		sw.offset_left = 32
		sw.offset_top = 32
		sw.offset_right = 32 + ParentGate.SIZE
		sw.offset_bottom = 32 + ParentGate.SIZE
		sw.pressed.connect(main.go_who)
		r.add_child(sw)
	_corner_gate(r)


func _style_picker(prof: Dictionary) -> Control:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	for s in Styles.ORDER:
		grid.add_child(_style_tile(s, prof))
	var c := CenterContainer.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(grid)
	return c


func _style_tile(style: String, prof: Dictionary) -> Control:
	var open := Styles.is_unlocked(style, prof["best"])
	var chosen: bool = prof["style"] == style
	var b := Button.new()
	b.custom_minimum_size = Vector2(250, 250)
	b.focus_mode = Control.FOCUS_NONE
	b.disabled = false
	for slot in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = PANEL if open else Color(0.05, 0.08, 0.16, 0.8)
		sb.set_corner_radius_all(28)
		if chosen:
			sb.border_color = GOLD
			sb.set_border_width_all(8)
		b.add_theme_stylebox_override(slot, sb)
	var inner := _box(true, 4)
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.add_child(_house(style, 130, not open))
	if open:
		inner.add_child(_label(Styles.NAMES[style], 36))
	else:
		var row := _box(false, 6)
		row.add_child(_icon("lock", 36, Color(1, 1, 1, 0.85)))
		row.add_child(_label("Best %d" % Styles.threshold(style), 34, Color(1, 1, 1, 0.85)))
		inner.add_child(row)
	b.add_child(inner)
	if open:
		b.pressed.connect(func() -> void: main.pick_style(style))
	return b


# ---------- run complete ----------

## `result` is {score, best, recent, new_best, unlocked}.
func show_complete(result: Dictionary) -> void:
	var r := _screen()
	var dim := ColorRect.new()
	dim.color = Color(0.16, 0.31, 0.55, 0.5)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.add_child(dim)
	var cc := CenterContainer.new()
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.add_child(cc)
	var panel := _panel(PANEL, 40)
	cc.add_child(panel)
	var v := _box(true, 20)
	panel.add_child(v)
	v.add_child(_label("Score", 44))
	v.add_child(_label(str(result["score"]), 150, GOLD))
	var best := _box(false, 12)
	best.add_child(_icon("star", 52, GOLD))
	best.add_child(_label(("New best %d!" if result["new_best"] else "Best %d") % result["best"], 52))
	v.add_child(best)
	var recent: Array = result["recent"]
	if recent.size() > 0:
		v.add_child(_label("Recent", 36))
		var row := _box(false, 14)
		for i in recent.size():
			var chip := _panel(Color(1, 1, 1, 0.16), 14)
			var l := _label(str(recent[recent.size() - 1 - i]), 44, GOLD if i == 0 else Color.WHITE)
			l.custom_minimum_size.x = 64
			chip.add_child(l)
			row.add_child(chip)
		v.add_child(row)
	for s in result["unlocked"]:
		var u := _box(false, 16)
		u.add_child(_house(s, 110))
		u.add_child(_label("New style: %s!" % Styles.NAMES[s], 48, GOLD))
		v.add_child(u)
	var buttons := _box(false, 24)
	var again := KButton.new("Again", "replay", GREEN, 340, 44)
	again.pressed.connect(main.press)
	var home := KButton.new("Home", "home", BLUE, 300, 44)
	home.pressed.connect(main.go_home)
	buttons.add_child(again)
	buttons.add_child(home)
	v.add_child(buttons)


# ---------- parent area ----------

func show_parent() -> void:
	var r := _screen()
	var bg := ColorRect.new()
	bg.color = Color("#1d2a44")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.add_child(bg)
	var m := _center(r)
	m.mouse_filter = Control.MOUSE_FILTER_PASS
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	m.add_child(scroll)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 22)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(v)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 20)
	var title := _label("Parents", 60, GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	head.add_child(title)
	var done := KButton.new("Done", "check", GREEN, 260, 40)
	done.pressed.connect(main.close_parent)
	head.add_child(done)
	v.add_child(head)

	v.add_child(_section("Players"))
	for p in store.profiles:
		v.add_child(_profile_row(p))
	if store.can_add():
		var add := KButton.new("Add player", "plus", BLUE, 400, 38)
		add.pressed.connect(func() -> void:
			_ask_text("New player", "", func(t: String) -> void:
				store.add_profile(t)
				store.save()
				show_parent()))
		v.add_child(add)

	v.add_child(_section("Sound"))
	v.add_child(_toggle("Music", "music_on", "music"))
	v.add_child(_toggle("Sound", "sound_on", "sound"))
	v.add_child(_toggle("Voice", "voice_on", "voice"))
	v.add_child(_section("Rest"))
	v.add_child(_toggle("Break", "break_reminder", "clock"))
	v.add_child(_section("Scores"))
	var reset := KButton.new("Reset scores", "replay", RED, 460, 38)
	reset.pressed.connect(func() -> void:
		_ask_confirm("Reset all scores?", func() -> void:
			store.reset_progress()
			store.save()
			show_parent()))
	v.add_child(reset)


func _section(t: String) -> Label:
	var l := _label(t, 40, Color(1, 1, 1, 0.7))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return l


func _profile_row(p: Dictionary) -> Control:
	var id: int = p["id"]
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var name_btn := KButton.new(p["name"], "pencil", GREY, 380, 38)
	name_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_btn.pressed.connect(func() -> void:
		_ask_text("Name", p["name"], func(t: String) -> void:
			store.rename(id, t)
			store.save()
			show_parent()))
	row.add_child(name_btn)
	var diff := KButton.new(DIFF_NAMES[p["difficulty"]], "bars", BLUE, 250, 34)
	diff.pressed.connect(func() -> void:
		var i := ProfileStore.DIFFICULTIES.find(p["difficulty"])
		store.set_difficulty(id, ProfileStore.DIFFICULTIES[(i + 1) % ProfileStore.DIFFICULTIES.size()])
		store.save()
		show_parent())
	row.add_child(diff)
	var del := KButton.new("", "trash", RED)
	del.disabled = store.profiles.size() <= 1
	del.pressed.connect(func() -> void:
		_ask_confirm("Delete %s?" % p["name"], func() -> void:
			store.delete_profile(id)
			store.save()
			show_parent()))
	row.add_child(del)
	return row


func _toggle(label: String, key: String, icon: String) -> Control:
	# Sound keys live in GameSettings (shared with audio); the break reminder in the profile store.
	var on := _get_toggle(key)
	var b := KButton.new("%s  %s" % [label, "On" if on else "Off"], icon, GREEN if on else GREY, 400, 38)
	b.pressed.connect(func() -> void:
		var now := not _get_toggle(key)
		_set_toggle(key, now)
		b.text = "%s  %s" % [label, "On" if now else "Off"]
		b.set_color(GREEN if now else GREY))
	return b


func _get_toggle(key: String) -> bool:
	return store.settings[key] if store.settings.has(key) else main.settings.get(key)


func _set_toggle(key: String, v: bool) -> void:
	if store.settings.has(key):
		store.settings[key] = v
		store.save()
	else:
		main.settings.set(key, v)
		main.settings.save()
		if main.audio:
			main.audio.apply_settings()


# ---------- modal dialogs (parent area only) ----------

func close_modal() -> void:
	if _modal:
		_modal.queue_free()
		_modal = null


func _open_modal(title: String) -> VBoxContainer:
	close_modal()
	_modal = ColorRect.new()
	(_modal as ColorRect).color = Color(0, 0, 0, 0.6)
	_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_modal)
	var cc := CenterContainer.new()
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_modal.add_child(cc)
	var panel := _panel(Color("#2a3b5f"), 40)
	panel.custom_minimum_size.x = 760
	cc.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 28)
	panel.add_child(v)
	v.add_child(_label(title, 56))
	return v


func _ask_text(title: String, initial: String, done: Callable) -> void:
	var v := _open_modal(title)
	var le := LineEdit.new()
	le.text = initial
	le.max_length = ProfileStore.MAX_NAME
	le.custom_minimum_size.y = 96
	le.add_theme_font_size_override("font_size", 52)
	le.alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(le)
	var row := _box(false, 24)
	var ok := KButton.new("OK", "check", GREEN, 260, 40)
	ok.pressed.connect(func() -> void:
		var t := le.text
		close_modal()
		done.call(t))
	var no := KButton.new("Back", "x", GREY, 260, 40)
	no.pressed.connect(close_modal)
	row.add_child(ok)
	row.add_child(no)
	v.add_child(row)
	le.grab_focus()


func _ask_confirm(title: String, done: Callable) -> void:
	var v := _open_modal(title)
	var row := _box(false, 24)
	var ok := KButton.new("Yes", "check", RED, 260, 40)
	ok.pressed.connect(func() -> void:
		close_modal()
		done.call())
	var no := KButton.new("No", "x", GREY, 260, 40)
	no.pressed.connect(close_modal)
	row.add_child(ok)
	row.add_child(no)
	v.add_child(row)
