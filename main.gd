extends Node2D

const SCREEN_WIDTH := 1280.0
const SCREEN_HEIGHT := 720.0

const FIELD_LEFT := 40.0
const FIELD_RIGHT := 1240.0
const FIELD_TOP := 80.0
const FIELD_BOTTOM := 640.0

const GOAL_TOP_Y := 280.0
const GOAL_BOTTOM_Y := 440.0
const GOAL_CENTER_Y := 360.0

const PLAYER_SPEED := 200.0
const SPRINT_SPEED := 270.0
const POSITION_SPEED := 80.0

const RED_SPEED := 120.0
const RED_RETURN_SPEED := 90.0
const RED_CHASE_DISTANCE := 300.0
const RED_ATTACK_SPEED := 145.0

const PASS_SPEED := 480.0
const SHOT_SPEED := 750.0
const HALF_DURATION := 45.0

# Variables de Estado General
var current_half := 1
var match_elapsed_time := 0.0
var game_state := "MENU" 
var game_mode := "LIGA"
var league_campaign_type := ""
var is_second_half := false

# Lógica de Localía y Sorteo
var player_starts_left := true
var player_won_coin_toss := false
var coin_toss_phase := "IDLE"
var chosen_side : int = 0
var toss_timer := 0.0

# Flags del Árbitro
var is_diablito_referee := false
var is_mate_referee := false

var title_texture: Texture2D
var show_champion_screen := false
var champion_bg_texture: Texture2D
var champion_team_name := ""
var champion_registered := false
var champions_history: Array[Dictionary] = []
const CHAMPIONS_SAVE_PATH := "user://champions.cfg"
var showing_champions_history := false

var menu_input_cooldown := 0.0

var is_restarting := false
var restart_timer := 0.0

var is_charging_tackle := false
var tackle_power := 0.0
var tackle_power_dir := 1.0

var foul_card_text := ""
var foul_card_timer := 0.0

var referee_position := Vector2(640, 360)

# ============================================================
# CONTROLES TÁCTILES / JOYSTICK VIRTUAL
# ============================================================
var touch_joystick_center := Vector2(160, 560)
var touch_joystick_pos := Vector2(160, 560)
var touch_joystick_active := false
var touch_joystick_index := -1
var touch_dir := Vector2.ZERO

var btn_pass_rect := Rect2(Vector2(980, 520), Vector2(80, 80))
var btn_shot_rect := Rect2(Vector2(1100, 440), Vector2(80, 80))
var btn_switch_rect := Rect2(Vector2(1100, 560), Vector2(80, 80))
var btn_tackle_rect := Rect2(Vector2(980, 400), Vector2(80, 80))

const PRIMERA_DIVISION_OPTIONS: Array[Dictionary] = [
	{"name": "boca", "pattern": "horizontal_3", "colors": [Color("#002B49"), Color("#FFD100"), Color("#002B49")]},
	{"name": "river", "pattern": "diagonal_stripe", "colors": [Color("#FFFFFF"), Color("#D90429")]},
	{"name": "racing", "pattern": "vertical_stripes", "colors": [Color("#FFFFFF"), Color("#75D6FF")]},
	{"name": "independiente", "pattern": "solid", "colors": [Color("#D90429")]},
	{"name": "velez", "pattern": "velez_v", "colors": [Color("#FFFFFF"), Color("#002B49")]},
	{"name": "ferro", "pattern": "solid", "colors": [Color("#006400")]},
	{"name": "colon", "pattern": "two_blocks_vert", "colors": [Color("#111111"), Color("#D90429")]},
	{"name": "union", "pattern": "vertical_stripes", "colors": [Color("#FFFFFF"), Color("#D90429")]},
	{"name": "newells", "pattern": "two_blocks_vert", "colors": [Color("#D90429"), Color("#111111")]},
	{"name": "central", "pattern": "vertical_stripes", "colors": [Color("#FFD100"), Color("#002B49")]},
	{"name": "estudiantes", "pattern": "vertical_stripes", "colors": [Color("#FFFFFF"), Color("#D90429")]},
	{"name": "gimnasia", "pattern": "horizontal_3", "colors": [Color("#FFFFFF"), Color("#002B49"), Color("#FFFFFF")]},
	{"name": "lanus", "pattern": "solid", "colors": [Color("#7209B7")]},
	{"name": "banfield", "pattern": "vertical_stripes", "colors": [Color("#FFFFFF"), Color("#38B000")]},
	{"name": "huracan", "pattern": "huracan_h", "colors": [Color("#FFFFFF"), Color("#D90429")]},
	{"name": "san lorenzo", "pattern": "vertical_stripes", "colors": [Color("#D90429"), Color("#002B49")]}
]

const LIGA_B_OPTIONS: Array[Dictionary] = [
	{"name": "independiente rivadavia", "pattern": "vertical_stripes", "colors": [Color("#003b7a"), Color("#ffffff")]},
	{"name": "argentinos juniors", "pattern": "solid", "colors": [Color("#d90429")]},
	{"name": "belgrano", "pattern": "solid", "colors": [Color("#75d6ff")]},
	{"name": "instituto", "pattern": "vertical_stripes", "colors": [Color("#ffffff"), Color("#d90429")]},
	{"name": "barracas central", "pattern": "vertical_stripes", "colors": [Color("#ffffff"), Color("#d90429")]},
	{"name": "talleres (c)", "pattern": "vertical_stripes", "colors": [Color("#002b49"), Color("#ffffff")]},
	{"name": "tigre", "pattern": "vertical_stripes", "colors": [Color("#002b49"), Color("#d90429")]},
	{"name": "sarmiento", "pattern": "solid", "colors": [Color("#38b000")]},
	{"name": "defensa y justicia", "pattern": "vertical_stripes", "colors": [Color("#fff02f"), Color("#38b000")]},
	{"name": "gimnasia (m)", "pattern": "vertical_stripes", "colors": [Color("#002b49"), Color("#ffffff")]},
	{"name": "central córdoba (sde)", "pattern": "vertical_stripes", "colors": [Color("#111111"), Color("#ffffff")]},
	{"name": "platense", "pattern": "solid", "colors": [Color("#6b3e26")]},
	{"name": "atlético tucumán", "pattern": "vertical_stripes", "colors": [Color("#75d6ff"), Color("#ffffff")]},
	{"name": "deportivo riestra", "pattern": "vertical_stripes", "colors": [Color("#111111"), Color("#ffffff")]},
	{"name": "aldosivi", "pattern": "vertical_stripes", "colors": [Color("#fff02f"), Color("#38b000")]},
	{"name": "estudiantes (rc)", "pattern": "vertical_stripes", "colors": [Color("#75d6ff"), Color("#ffffff")]}
]

const LIGA_C_OPTIONS: Array[Dictionary] = [
	{"name": "tristán suárez", "pattern": "vertical_stripes", "colors": [Color("#002b49"), Color("#75d6ff")]},
	{"name": "deportivo morón", "pattern": "diagonal_stripe", "colors": [Color("#ffffff"), Color("#d90429")]},
	{"name": "gimnasia (jujuy)", "pattern": "vertical_stripes", "colors": [Color("#75d6ff"), Color("#ffffff")]},
	{"name": "atlanta", "pattern": "vertical_stripes", "colors": [Color("#fff02f"), Color("#002b49")]},
	{"name": "almirante brown", "pattern": "vertical_stripes", "colors": [Color("#fff02f"), Color("#111111")]},
	{"name": "midland", "pattern": "solid", "colors": [Color("#ffffff")]},
	{"name": "godoy cruz", "pattern": "vertical_stripes", "colors": [Color("#002b49"), Color("#ffffff")]},
	{"name": "gimnasia y tiro", "pattern": "vertical_stripes", "colors": [Color("#75d6ff"), Color("#ffffff")]},
	{"name": "temperley", "pattern": "solid", "colors": [Color("#75d6ff")]},
	{"name": "deportivo madryn", "pattern": "vertical_stripes", "colors": [Color("#111111"), Color("#fff02f")]},
	{"name": "atlético rafaela", "pattern": "vertical_stripes", "colors": [Color("#75d6ff"), Color("#ffffff")]},
	{"name": "deportivo maipú", "pattern": "vertical_stripes", "colors": [Color("#d90429"), Color("#111111")]},
	{"name": "estudiantes (ba)", "pattern": "vertical_stripes", "colors": [Color("#111111"), Color("#ffffff")]},
	{"name": "ciudad de bolívar", "pattern": "solid", "colors": [Color("#75d6ff")]},
	{"name": "los andes", "pattern": "vertical_stripes", "colors": [Color("#d90429"), Color("#ffffff")]},
	{"name": "quilmes", "pattern": "solid", "colors": [Color("#ffffff")]}
]

const SEGUNDA_DIVISION_OPTIONS: Array[Dictionary] = [
	{"name": "unión de olmos", "pattern": "solid", "colors": [Color("#1b4d3e")]},
	{"name": "las malvinas", "pattern": "solid", "colors": [Color("#333333")]},
	{"name": "napoli argentino", "pattern": "vertical_stripes", "colors": [Color("#1e90ff"), Color("#ffffff")]},
	{"name": "villa corina", "pattern": "solid", "colors": [Color("#ff8c00")]},
	{"name": "tiro federal (rosario)", "pattern": "vertical_stripes", "colors": [Color("#ffffff"), Color("#ff0000")]},
	{"name": "adiur (rosario)", "pattern": "solid", "colors": [Color("#008080")]},
	{"name": "echesortu (rosario)", "pattern": "solid", "colors": [Color("#4169e1")]},
	{"name": "sonder (rosario)", "pattern": "solid", "colors": [Color("#800080")]},
	{"name": "deportivo mandiyú", "pattern": "solid", "colors": [Color("#008000")]},
	{"name": "atlantic sportsmen club", "pattern": "solid", "colors": [Color("#ffd700")]},
	{"name": "deportivo union central", "pattern": "vertical_stripes", "colors": [Color("#ffffff"), Color("#0000ff")]},
	{"name": "el luchador", "pattern": "solid", "colors": [Color("#b22222")]},
	{"name": "morning star", "pattern": "solid", "colors": [Color("#ffd700")]},
	{"name": "edison", "pattern": "solid", "colors": [Color("#4682b4")]},
	{"name": "lux", "pattern": "solid", "colors": [Color("#2e8b57")]},
	{"name": "estrella de paz", "pattern": "solid", "colors": [Color("#ffffff")]}
]

var active_color_options: Array[Dictionary] = []
var player_team_name := "boca"
var player_team_pattern := "horizontal_3"
var player_team_colors: Array = [Color("#002B49"), Color("#FFD100"), Color("#002B49")]
var selected_color_idx := 0

const FORMATION_NAMES: Array[String] = ["4-3-3", "4-4-2", "4-2-3-1", "3-5-2", "3-4-3"]
var selected_formation := "4-3-3"
var opponent_formation := "4-4-2"
var opponent_formation_revealed := false
var formation_notice_timer := 0.0

var pending_kickoff_team := "home"

var camera_shake_intensity := 0.0
var camera_offset := Vector2.ZERO
var confetti_list: Array[Dictionary] = []
var celebration_active := false
var celebration_timer := 0.0
const CELEBRATION_DURATION := 4.0

var stamina_bar_value := 50.0 
var accumulated_stars := 0
var pause_selected_player := 0
var pause_star_allocation := 0
var player_boost_until := 0.0
var player_boost_multiplier := 1.0
var player_kick_multiplier := 1.0
var player_boost_stars := 0
var player_stars: Array[int] = []

var league_fixtures: Array[Dictionary] = []
var current_fixture_index := 0
var all_match_results: Array[Dictionary] = []

var first_division_teams: Array[Dictionary] = []
var second_division_teams: Array[Dictionary] = []
var league_b_teams: Array[Dictionary] = []
var league_c_teams: Array[Dictionary] = []
var current_division := 1
var league_season_number := 0
var selected_team_original_division := 1
var season_transition_target_division := 1
var season_event_queue: Array[String] = []
var season_event_text := ""
var season_event_timer := 0.0
const SEASON_EVENT_DURATION := 4.0
const LEAGUE_SAVE_PATH := "user://league_save.cfg"
var save_feedback_text := ""
var save_feedback_timer := 0.0

var match_stats := {}
var show_fixture_screen := false
var show_match_results_screen := false
var post_match_state := ""

var fixture_timer := 0.0
const FIXTURE_MIN_TIME := 1.5
var fixture_scroll_offset := 0

var standings: Array[Dictionary] = []
var league_match_result_applied := false

var copa_rounds: Array[Dictionary] = []
var copa_round_index := 0 
var copa_all_teams: Array[String] = []
var copa_player_eliminated := false

# ============================================================
# MODO PELÍCULA - LOS ADORADORES DE LA ESTRELLA
# ============================================================

const MOVIE_SAVE_PATH := "user://movie_save.cfg"
const MOVIE_UFO_AFTER_SECONDS := 8.0
const MOVIE_TEXT_SPEED := 0.028
const MOVIE_CYAN := Color("#75d6ff")
const MOVIE_RED := Color("#d90429")

var movie_stage := 0
var movie_match_index := 0
var movie_phase := "IDLE"
var movie_timer := 0.0
var movie_saved_stage := -1
var movie_random_competition := ""
var movie_random_date := ""
var movie_random_opponent := "gimnasia"
var movie_message := ""
var movie_final_sequence := 0
var movie_match_interrupted := false
var movie_intro_match := false
var movie_release_progress := 1.0
var movie_result_won := false
var movie_result_opponent := ""
var movie_result_can_save := false
var movie_result_context := ""
var movie_load_error := false
var movie_goal_font: Font = null
var movie_title_font: Font = null

var movie_circle_progress := 0.0
var movie_circle_drawing := false

var movie_dialog_pages: Array[String] = []
var movie_dialog_index := 0
var movie_dialog_char_index := 0
var movie_dialog_accumulator := 0.0
var movie_dialog_finished := false

const MOVIE_MATCHES: Array[Dictionary] = [
	{"province":"Jujuy","team":"gimnasia (jujuy)"},
	{"province":"Jujuy","team":"altos hornos zapla"},
	{"province":"Salta","team":"gimnasia y tiro"},
	{"province":"Salta","team":"central norte"},
	{"province":"Salta","team":"juventud antoniana"},
	{"province":"Formosa","team":"sportivo patria"},
	{"province":"Formosa","team":"san martín de formosa"},
	{"province":"Formosa","team":"sol de américa"},
	{"province":"Formosa","team":"1° de mayo"},
	{"province":"Formosa","team":"defensores de formosa"},
	{"province":"Misiones","team":"guaraní antonio franco"},
	{"province":"Misiones","team":"crucero del norte"},
	{"province":"Misiones","team":"bartolomé mitre"},
	{"province":"Misiones","team":"club atlético candelaria"},
	{"province":"Misiones","team":"jorge gibson brown"},
	{"province":"Corrientes","team":"boca unidos"},
	{"province":"Corrientes","team":"deportivo mandiyú"},
	{"province":"Corrientes","team":"huracán corrientes"},
	{"province":"Corrientes","team":"sportivo ferroviario"},
	{"province":"Corrientes","team":"samuel w. robinson"},
	{"province":"Chaco","team":"chaco for ever"},
	{"province":"Chaco","team":"sarmiento resistencia"},
	{"province":"Chaco","team":"don orione"},
	{"province":"Chaco","team":"central norte"},
	{"province":"Chaco","team":"fontana"},
	{"province":"Santiago del Estero","team":"central córdoba"},
	{"province":"Santiago del Estero","team":"mitre"},
	{"province":"Santiago del Estero","team":"güemes"},
	{"province":"Santiago del Estero","team":"sarmiento de la banda"},
	{"province":"Santiago del Estero","team":"unión santiago"},
	{"province":"Tucumán","team":"atlético tucumán"},
	{"province":"Tucumán","team":"san martín de tucumán"},
	{"province":"Tucumán","team":"concepción fc"},
	{"province":"Tucumán","team":"san jorge"},
	{"province":"Tucumán","team":"almirante brown de lules"},
	{"province":"Catamarca","team":"san lorenzo de alem"},
	{"province":"Catamarca","team":"villa cubas"},
	{"province":"Catamarca","team":"atlético policial"},
	{"province":"Catamarca","team":"unión aconquija"},
	{"province":"Catamarca","team":"club atlético sarmiento"},
	{"province":"La Rioja","team":"andino sport club"},
	{"province":"La Rioja","team":"américo tesorieri"},
	{"province":"La Rioja","team":"rioja juniors"},
	{"province":"La Rioja","team":"defensores de la boca"},
	{"province":"La Rioja","team":"club atlético chilecito"},
	{"province":"San Juan","team":"san martín de san juan"},
	{"province":"San Juan","team":"sportivo desamparados"},
	{"province":"San Juan","team":"juventud alianza"},
	{"province":"San Juan","team":"trinidad"},
	{"province":"San Juan","team":"sportivo peñarol"},
	{"province":"Mendoza","team":"godoy cruz"},
	{"province":"Mendoza","team":"independiente rivadavia"},
	{"province":"Mendoza","team":"gimnasia y esgrima de mendoza"},
	{"province":"Mendoza","team":"san martín de mendoza"},
	{"province":"Mendoza","team":"huracán las heras"},
	{"province":"San Luis","team":"sportivo estudiantes"},
	{"province":"San Luis","team":"juventud unida universitario"},
	{"province":"San Luis","team":"jorge newbery"},
	{"province":"San Luis","team":"defensores de potrero de los funes"},
	{"province":"San Luis","team":"alianza futbolística"},
	{"province":"Córdoba","team":"talleres"},
	{"province":"Córdoba","team":"belgrano"},
	{"province":"Córdoba","team":"instituto"},
	{"province":"Córdoba","team":"racing de córdoba"},
	{"province":"Córdoba","team":"estudiantes de río cuarto"},
	{"province":"Santa Fe","team":"rosario central"},
	{"province":"Santa Fe","team":"newell's old boys"},
	{"province":"Santa Fe","team":"colón de santa fe"},
	{"province":"Santa Fe","team":"unión de santa fe"},
	{"province":"Santa Fe","team":"atlético de rafaela"},
	{"province":"Entre Ríos","team":"patronato"},
	{"province":"Entre Ríos","team":"gimnasia y esgrima de concepción del uruguay"},
	{"province":"Entre Ríos","team":"atlético paraná"},
	{"province":"Entre Ríos","team":"juventud unida de gualeguaychú"},
	{"province":"Entre Ríos","team":"defensores de pronunciamiento (depro)"},
	{"province":"CABA","team":"boca juniors"},
	{"province":"CABA","team":"river plate"},
	{"province":"CABA","team":"san lorenzo de almagro"},
	{"province":"CABA","team":"huracán"},
	{"province":"CABA","team":"argentinos juniors"},
	{"province":"Provincia de Buenos Aires","team":"racing club"},
	{"province":"Provincia de Buenos Aires","team":"independiente"},
	{"province":"Provincia de Buenos Aires","team":"estudiantes de la plata"},
	{"province":"Provincia de Buenos Aires","team":"gimnasia y esgrima la plata"},
	{"province":"Provincia de Buenos Aires","team":"banfield"},
	{"province":"La Pampa","team":"ferro carril oeste de general pico"},
	{"province":"La Pampa","team":"all boys de santa rosa"},
	{"province":"La Pampa","team":"atlético santa rosa"},
	{"province":"La Pampa","team":"costa brava"},
	{"province":"La Pampa","team":"alvear fbc"},
	{"province":"Neuquén","team":"deportivo rincón"},
	{"province":"Neuquén","team":"alianza de cutral có"},
	{"province":"Neuquén","team":"club atlético independiente"},
	{"province":"Neuquén","team":"centenario"},
	{"province":"Neuquén","team":"pacífico"},
	{"province":"Río Negro","team":"club cipolletti"},
	{"province":"Río Negro","team":"sol de mayo"},
	{"province":"Río Negro","team":"deportivo roca"},
	{"province":"Río Negro","team":"cruz del sur"},
	{"province":"Río Negro","team":"argentinos del norte"},
	{"province":"Chubut","team":"guillermo brown"},
	{"province":"Chubut","team":"deportivo madryn"},
	{"province":"Chubut","team":"comisión de actividades infantiles (cai)"},
	{"province":"Chubut","team":"huracán de comodoro rivadavia"},
	{"province":"Chubut","team":"jorge newbery"},
	{"province":"Santa Cruz","team":"atlético boxing club"},
	{"province":"Santa Cruz","team":"bancruz"},
	{"province":"Santa Cruz","team":"boca río gallegos"},
	{"province":"Santa Cruz","team":"huracán de gobernador gregores"},
	{"province":"Santa Cruz","team":"san lorenzo de río gallegos"},
	{"province":"Tierra del Fuego","team":"camioneros"},
	{"province":"Tierra del Fuego","team":"los cuervos del fin del mundo"},
	{"province":"Tierra del Fuego","team":"lasserre fc"},
	{"province":"Tierra del Fuego","team":"club atlético educación fueguina (caef)"},
	{"province":"Tierra del Fuego","team":"real madrid de río grande"}
]

const MOVIE_PROVINCES := [
	"Jujuy","Salta","Formosa","Misiones","Corrientes","Chaco","Santiago del Estero",
	"Tucumán","Catamarca","La Rioja","San Juan","Mendoza","San Luis","Córdoba",
	"Santa Fe","Entre Ríos","CABA","Provincia de Buenos Aires","La Pampa",
	"Neuquén","Río Negro","Chubut","Santa Cruz","Tierra del Fuego"
]

func _movie_reset_dialog(pages: Array[String]) -> void:
	movie_dialog_pages = pages
	movie_dialog_index = 0
	movie_dialog_char_index = 0
	movie_dialog_accumulator = 0.0
	movie_dialog_finished = false
	movie_timer = 0.0

func _movie_current_dialog_text() -> String:
	if movie_dialog_pages.is_empty() or movie_dialog_index >= movie_dialog_pages.size():
		return ""
	return movie_dialog_pages[movie_dialog_index]

func _movie_update_dialog(delta: float) -> void:
	if movie_dialog_finished:
		return
	var full_text := _movie_current_dialog_text()
	if movie_dialog_char_index >= full_text.length():
		movie_dialog_finished = true
		return
	movie_dialog_accumulator += delta
	while movie_dialog_accumulator >= MOVIE_TEXT_SPEED:
		movie_dialog_accumulator -= MOVIE_TEXT_SPEED
		movie_dialog_char_index += 1
		if movie_dialog_char_index >= full_text.length():
			movie_dialog_char_index = full_text.length()
			movie_dialog_finished = true
			break

func _movie_dialog_enter() -> void:
	if not movie_dialog_finished:
		movie_dialog_char_index = _movie_current_dialog_text().length()
		movie_dialog_finished = true
		return
	movie_dialog_index += 1
	if movie_dialog_index >= movie_dialog_pages.size():
		_movie_on_dialog_complete()
	else:
		movie_dialog_char_index = 0
		movie_dialog_accumulator = 0.0
		movie_dialog_finished = false

func _movie_start_dialog(pages: Array[String], next_phase: String) -> void:
	_movie_reset_dialog(pages)
	movie_phase = next_phase
	game_state = "MOVIE"

func _movie_on_dialog_complete() -> void:
	match movie_phase:
		"INVASION":
			movie_phase = "STAR"
			movie_timer = 2.5
			movie_circle_progress = 0.0
			movie_circle_drawing = true
		"BRIEF":
			_movie_start_match(String(MOVIE_MATCHES[movie_match_index]["team"]))
		"STAR_TITLE":
			movie_phase = "MAP"
			movie_timer = 0.0
		"WIN_TEXT":
			movie_phase = "MAP"
			movie_timer = 0.0
		"LOSS":
			game_mode = "LIGA"
			game_state = "MENU"
			movie_phase = "IDLE"
			movie_timer = 0.0
		"LOSS_FIN":
			game_mode = "LIGA"
			game_state = "MENU"
			movie_phase = "IDLE"
		"FALKLANDS_TEXT":
			_movie_start_dialog([
				"PARTIDO: SELECCIÓN ARGENTINA VS. KELPERS",
				"Si ganás, el alcalde kelper deberá permitir el paso de los argentinos."
			], "KELPERS_BRIEF")
		"KELPERS_BRIEF":
			player_team_name = "selección argentina"
			active_color_options = [{"name":"kelpers","pattern":"solid","colors":[Color("#ffffff")]}]
			_reset_match_state()
			movie_phase = "KELPERS_MATCH"
			game_state = "PLAYING"
		"KELPERS_WIN":
			_movie_start_dialog([
				"El alcalde kelper aplaude a regañadientes la valentía de los argentinos y accede a proveerlos de recursos y transporte para ir a luchar contra los Adoradores de la Estrella."
			], "FINAL_BRIEF")
		"FINAL_BRIEF":
			player_team_name = "selección argentina"
			active_color_options = [{"name":"adoradores de la estrella","pattern":"solid","colors":[Color("#ffffff")]}]
			_reset_match_state()
			movie_phase = "FINAL_MATCH"
			game_state = "PLAYING"
		"FINAL_LOSS":
			game_mode = "LIGA"
			game_state = "MENU"
			movie_phase = "IDLE"
			movie_timer = 0.0
		"VICTORY_SLOGAN":
			_movie_start_dialog(["Fin", "★ ★ ★"], "VICTORY_FIN")
		"VICTORY_FIN":
			game_mode = "LIGA"
			game_state = "MENU"
		_:
			pass

func _movie_start_match(team_name: String) -> void:
	var data := _get_team_data(team_name)
	var colors: Array = data.get("colors", [Color("#ffffff")])
	var pattern := String(data.get("pattern", "solid"))
	
	if movie_phase == "MATCH" or movie_phase == "BRIEF":
		var dark_colors: Array = []
		for c in colors:
			if c is Color:
				var dark_c := Color(
					c.r * 0.3,
					c.g * 0.3,
					c.b * 0.3,
					c.a
				)
				dark_colors.append(dark_c)
		colors = dark_colors if dark_colors.size() > 0 else [Color("#111111")]
	
	active_color_options = [{"name":team_name, "pattern":pattern, "colors":colors}]
	movie_intro_match = false
	_reset_match_state()
	movie_phase = "MATCH"
	movie_timer = 0.0
	movie_match_interrupted = false
	game_state = "PLAYING"

func _movie_start_falklands() -> void:
	_movie_start_dialog([
		"Los kelpers están asediados por los Adoradores de la Estrella.",
		"Las islas son el último reducto de resistencia de los invasores del espacio. Los isleños pierden todos los partidos que los extraterrestres imponen como desafío.",
		"Por cada partido que pierden, los 11 jugadores son enviados a campos de concentración. El alcalde kelper está desesperado.",
		"No quiere admitirlo, pero los argentinos son la última esperanza de luchar contra esta amenaza intergaláctica. Aun así, no quiere argentinos en las islas que él gobierna."
	], "FALKLANDS_TEXT")

func _movie_on_enter() -> void:
	match movie_phase:
		"UFO":
			_movie_start_dialog([
				"La Argentina está siendo invadida y esclavizada.",
				"Una raza de alienígenas, Los Adoradores de la Estrella, ha tomado el control del país.",
				"No respetan ninguna regla más que las del fútbol.",
				"¡Para salvar a Argentina hay que ganarles en todo el país!",
				"¿Estás listo para salvar a la patria?"
			], "INVASION")
		"STAR":
			_movie_start_dialog(["LA INVASION DE LOS ADORADORES DE LA ESTRELLA"], "STAR_TITLE")
		"MAP":
			if movie_match_index < MOVIE_MATCHES.size():
				var team := String(MOVIE_MATCHES[movie_match_index]["team"]).capitalize()
				_movie_start_dialog(["¡Hay que pelear!", "¡Hay que liberar a " + team + " de los Adoradores de la Estrella!"], "BRIEF")
			else:
				_movie_start_falklands()
		"MOVIE_RESULTS":
			if movie_result_won:
				movie_result_can_save = false
				if movie_result_context == "MATCH":
					_movie_advance_after_win()
				elif movie_result_context == "KELPERS_MATCH":
					_movie_start_dialog(["El alcalde kelper aplaude a regañadientes la valentía de los argentinos y accede a proveerlos de recursos y transporte para ir a luchar contra los Adoradores de la Estrella."], "KELPERS_WIN")
				elif movie_result_context == "FINAL_MATCH":
					movie_phase = "VICTORY_MAP"
					movie_timer = 5.0
					confetti_list.clear()
			else:
				movie_result_can_save = false
				if movie_result_context == "FINAL_MATCH":
					_movie_start_dialog(["Los adoradores de la estrella, envalentonados por la victoria, articulan un ataque masivo a gran escala en todo el continente. Todo está perdido."], "FINAL_LOSS")
				elif movie_result_context == "KELPERS_MATCH":
					_movie_start_dialog(["Los Kelpers han vencido. Los Adoradores de la Estrella han pactado con los isleños. Prometen venganza contra los argentinos."], "LOSS")
				else:
					_movie_start_dialog(["Argentina ha caído bajo las garras de los Adoradores de la Estrella. Todo está perdido."], "LOSS")
		"MOVIE_RESULT_WIN_TEXT":
			if movie_match_index >= MOVIE_MATCHES.size():
				_movie_start_falklands()
			else:
				movie_phase = "MAP"
				movie_timer = 0.0
		"KELPERS_BRIEF":
			pass
		"FINAL_BRIEF":
			pass
		"LOAD_ERROR":
			movie_load_error = false
			movie_phase = "IDLE"
			game_state = "MOVIE_MENU"
			menu_input_cooldown = 0.4
		"VICTORY_MAP":
			_movie_start_dialog([
				"¡NUNCA NUNCA NUNCA DUDES DEL CORAZÓN DE UN ARGENTINO!",
				"Gracias por jugar."
			], "VICTORY_SLOGAN")
		"LOSS_FIN":
			game_mode = "LIGA"
			game_state = "MENU"
		_:
			pass

func _movie_advance_after_win() -> void:
	var defeated_team := String(MOVIE_MATCHES[movie_match_index]["team"]).capitalize()
	var defeated_lower := defeated_team.to_lower()
	movie_match_index += 1
	movie_stage = movie_match_index
	movie_release_progress = 0.0
	if defeated_lower == "altos hornos zapla":
		movie_message = "¡Liberaste a Altos Hornos Zapla de las garras de los invasores! El presidente del club te lo agradece eternamente."
	else:
		movie_message = "¡Liberaste a " + defeated_team + " de las garras de los invasores! ¡Que viva el fútbol, viva la patria! Hay que seguir luchando."
	if movie_match_index >= MOVIE_MATCHES.size():
		_movie_start_falklands()
	else:
		_movie_start_dialog([movie_message], "WIN_TEXT")

func _goal_scorer_name() -> String:
	if last_scoring_team == player_team_name:
		return "TÚ"
	elif last_scoring_team == _get_current_opponent():
		return _get_current_opponent().capitalize()
	return "DESCONOCIDO"

func _movie_begin_new() -> void:
	game_mode = "PELICULA"
	movie_stage = 0
	movie_match_index = 0
	movie_saved_stage = -1
	movie_final_sequence = 0
	movie_match_interrupted = false
	movie_intro_match = true
	movie_random_competition = ["Liga Argentina", "Copa Argentina", "Torneo Federal", "Primera Nacional"].pick_random()
	movie_random_date = "%02d/%02d/20%02d" % [randi_range(1, 28), randi_range(1, 12), randi_range(24, 26)]
	movie_random_opponent = "gimnasia"
	movie_phase = "OPENING_MATCH"
	movie_timer = 0.0
	_reset_match_state()
	game_state = "PLAYING"

func _movie_load() -> void:
	var config := ConfigFile.new()
	if not FileAccess.file_exists(MOVIE_SAVE_PATH) or config.load(MOVIE_SAVE_PATH) != OK or not bool(config.get_value("movie", "valid_save", false)):
		movie_load_error = true
		movie_phase = "LOAD_ERROR"
		game_state = "MOVIE"
		movie_timer = 0.0
		return
	movie_load_error = false
	movie_match_index = clamp(int(config.get_value("movie", "match_index", 0)), 0, MOVIE_MATCHES.size())
	movie_stage = movie_match_index
	player_team_name = String(config.get_value("movie", "team_name", player_team_name))
	player_team_pattern = String(config.get_value("movie", "team_pattern", player_team_pattern))
	var saved_colors = config.get_value("movie", "team_colors", player_team_colors)
	if saved_colors is Array:
		player_team_colors = saved_colors
	movie_saved_stage = movie_stage
	game_mode = "PELICULA"
	movie_intro_match = false
	_reset_match_state()
	movie_phase = "MATCH"
	movie_timer = 0.0
	game_state = "PLAYING"

func _movie_save() -> void:
	var config := ConfigFile.new()
	config.set_value("movie", "match_index", movie_match_index)
	config.set_value("movie", "stage", movie_stage)
	config.set_value("movie", "team_name", player_team_name)
	config.set_value("movie", "team_pattern", player_team_pattern)
	config.set_value("movie", "team_colors", player_team_colors)
	config.set_value("movie", "valid_save", true)
	var err := config.save(MOVIE_SAVE_PATH)
	save_feedback_text = "PARTIDA DE PELÍCULA GUARDADA" if err == OK else "ERROR AL GUARDAR PELÍCULA"
	save_feedback_timer = 2.0

func _movie_start_random_match() -> void:
	var gimnasia_data := _get_team_data("gimnasia")
	if gimnasia_data.is_empty():
		gimnasia_data = {"name":"gimnasia", "pattern":"horizontal_3", "colors":[Color("#ffffff"), Color("#002b49"), Color("#ffffff")]}
	active_color_options = [gimnasia_data]
	_reset_match_state()
	movie_phase = "OPENING_MATCH"
	movie_intro_match = true
	movie_timer = 0.0
	movie_match_interrupted = false
	game_state = "PLAYING"

func _movie_match_finished() -> void:
	movie_result_opponent = _get_current_opponent()
	movie_result_won = home_score > away_score
	movie_result_can_save = true
	movie_result_context = movie_phase
	movie_phase = "MOVIE_RESULTS"
	game_state = "MOVIE"
	movie_timer = 0.0
	if movie_result_won:
		movie_message = "VICTORIA"
	else:
		movie_message = "DERROTA"

func _movie_draw_black_text(text: String, color := Color.WHITE, size := 26) -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color.BLACK, true)
	draw_string(ThemeDB.fallback_font, Vector2(100, 210), text, HORIZONTAL_ALIGNMENT_CENTER, 1080, size, color)

func _movie_draw_title_typewriter() -> void:
	var title := "LA INVASION DE LOS ADORADORES DE LA ESTRELLA"
	var chars := int(movie_dialog_char_index)
	var shown := title.substr(0, min(chars, title.length()))
	var pulse := 42.0 + 3.0 * sin(Time.get_ticks_msec() * 0.006)
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#070204"), true)
	
	_draw_movie_star(Vector2(640, 330), 105.0)
	
	if movie_circle_drawing:
		movie_circle_progress += 0.012
		if movie_circle_progress >= 1.0:
			movie_circle_progress = 1.0
			movie_circle_drawing = false
		
		var angle := movie_circle_progress * TAU
		draw_arc(Vector2(640, 330), 130.0, 0, angle, 64, MOVIE_RED, 4.0, true)
	
	if movie_title_font != null:
		draw_string(movie_title_font, Vector2(80, 570), shown, HORIZONTAL_ALIGNMENT_CENTER, 1120, pulse, Color("#ff2020"))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(80, 570), shown, HORIZONTAL_ALIGNMENT_CENTER, 1120, pulse, Color("#ff2020"))

func _movie_draw_typewriter() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color.BLACK, true)
	var full_text := _movie_current_dialog_text()
	var shown := full_text.substr(0, movie_dialog_char_index)
	draw_multiline_string(ThemeDB.fallback_font, Vector2(110, 250), shown, HORIZONTAL_ALIGNMENT_CENTER, 1060, 25, -1, Color.WHITE)
	if movie_dialog_finished:
		draw_string(ThemeDB.fallback_font, Vector2(0, 650), "[ENTER] / TOCA CONTINUAR", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_WIDTH, 15, MOVIE_CYAN)
	else:
		draw_string(ThemeDB.fallback_font, Vector2(0, 650), "[ENTER] / TOCA MOSTRAR TEXTO", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_WIDTH, 15, Color("#777777"))

func _movie_province_shape(index: int, center: Vector2, scale: float) -> PackedVector2Array:
	var seed_value := float(index + 1)
	var pts := PackedVector2Array()
	var count := 8
	for i in range(count):
		var a := TAU * float(i) / float(count) - PI / 2.0
		var rx := 1.0 + 0.18 * sin(seed_value * 1.7 + float(i))
		var ry := 0.72 + 0.16 * cos(seed_value * 1.1 + float(i) * 0.8)
		pts.append(center + Vector2(cos(a) * 70.0 * rx * scale, sin(a) * 95.0 * ry * scale))
	return pts

func _movie_draw_map(final_map: bool = false) -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#05070a"), true)
	draw_string(ThemeDB.fallback_font, Vector2(0, 48), "ARGENTINA RESISTE", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_WIDTH, 30, MOVIE_CYAN)
	var active_province := -1
	if not final_map and movie_match_index < MOVIE_MATCHES.size():
		active_province = MOVIE_PROVINCES.find(String(MOVIE_MATCHES[movie_match_index]["province"]))
	var cols := 6
	for i in range(MOVIE_PROVINCES.size()):
		var row := i / cols
		var col := i % cols
		var center := Vector2(155.0 + col * 195.0, 115.0 + row * 135.0)
		var liberated := final_map or i < active_province
		var active := not final_map and i == active_province
		var color := MOVIE_CYAN if liberated else (MOVIE_RED if active else Color("#343943"))
		if not final_map and movie_match_index > 0 and i == active_province - 1:
			color = MOVIE_RED.lerp(MOVIE_CYAN, movie_release_progress)
		var shape := _movie_province_shape(i, center, 0.62)
		if active:
			var pulse := 1.0 + 0.10 * sin(Time.get_ticks_msec() * 0.01)
			shape = _movie_province_shape(i, center, 0.62 * pulse)
		draw_colored_polygon(shape, color)
		draw_polyline(PackedVector2Array([shape[0],shape[1],shape[2],shape[3],shape[4],shape[5],shape[6],shape[7],shape[0]]), Color("#11151c"), 2.0, true)
		draw_string(ThemeDB.fallback_font, center + Vector2(-85, 58), MOVIE_PROVINCES[i], HORIZONTAL_ALIGNMENT_CENTER, 170, 12, Color.WHITE if active else color)
	draw_string(ThemeDB.fallback_font, Vector2(0, 665), "PARTIDOS GANADOS: %d / %d" % [movie_match_index, MOVIE_MATCHES.size()], HORIZONTAL_ALIGNMENT_CENTER, SCREEN_WIDTH, 14, Color("#fff02f"))
	draw_string(ThemeDB.fallback_font, Vector2(0, 695), "[ENTER] / TOCA CONTINUAR    |    [S] GUARDAR", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_WIDTH, 14, Color.WHITE)

func _draw_movie() -> void:
	match movie_phase:
		"UFO":
			draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color.BLACK, true)
			var ufo_y_offset := sin(Time.get_ticks_msec() * 0.002) * 15.0
			var ufo_center := Vector2(640, 220 + ufo_y_offset)
			draw_circle(ufo_center, 42, Color("#8b9198"), true)
			_draw_ellipse_movie(Vector2(640, 240 + ufo_y_offset), Vector2(125, 28), Color("#d9e0e8", 0.85))
			var light_on := int(Time.get_ticks_msec() * 0.003) % 2 == 0
			if light_on:
				draw_circle(Vector2(580, 230 + ufo_y_offset), 6, Color("#ff4444"), true)
				draw_circle(Vector2(700, 230 + ufo_y_offset), 6, Color("#44ff44"), true)
			draw_string(ThemeDB.fallback_font, Vector2(0, 390), "¿QUÉ ES ESO EN EL CIELO?", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_WIDTH, 25, Color.WHITE)
		"INVASION", "BRIEF", "WIN_TEXT", "FALKLANDS_TEXT", "KELPERS_BRIEF", "KELPERS_WIN", "FINAL_BRIEF", "LOSS", "FINAL_LOSS", "MOVIE_RESULT_WIN_TEXT", "VICTORY_SLOGAN", "VICTORY_FIN":
			_movie_draw_typewriter()
		"STAR":
			draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color.BLACK, true)
			_draw_movie_star(Vector2(640, 340), 155.0)
		"STAR_TITLE":
			_movie_draw_title_typewriter()
		"MAP":
			_movie_draw_map()
		"MOVIE_RESULTS":
			_movie_draw_movie_results()
		"LOAD_ERROR":
			_movie_draw_load_error()
		"VICTORY_MAP":
			_movie_draw_map(true)
			_draw_confetti()
		"VICTORY_SLOGAN", "VICTORY_FIN":
			_movie_draw_typewriter()
		_: 
			_movie_draw_black_text("PELÍCULA", Color.WHITE, 28)

func _movie_draw_load_error() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#05070a"), true)
	var panel := Rect2(Vector2(270, 175), Vector2(740, 370))
	draw_rect(panel, Color("#0e131d"), true)
	draw_rect(panel, MOVIE_RED, false, 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(300, 275), "NO HAY PARTIDA GUARDADA", HORIZONTAL_ALIGNMENT_CENTER, 680, 32, MOVIE_RED)
	draw_string(ThemeDB.fallback_font, Vector2(330, 340), "No existe ninguna partida de Película guardada.", HORIZONTAL_ALIGNMENT_CENTER, 620, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(330, 415), "[ENTER] / TOCA VOLVER AL MENÚ", HORIZONTAL_ALIGNMENT_CENTER, 620, 17, MOVIE_CYAN)
	draw_string(ThemeDB.fallback_font, Vector2(330, 455), "[ESC] VOLVER", HORIZONTAL_ALIGNMENT_CENTER, 620, 15, Color("#888a8f"))

func _movie_draw_movie_results() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#05070a"), true)
	draw_rect(Rect2(Vector2(170, 70), Vector2(940, 580)), Color("#0e131d"), true)
	draw_rect(Rect2(Vector2(170, 70), Vector2(940, 580)), MOVIE_CYAN, false, 3.0)
	var verdict := "VICTORIA" if movie_result_won else "DERROTA"
	var verdict_color := Color("#55dd77") if movie_result_won else MOVIE_RED
	draw_string(ThemeDB.fallback_font, Vector2(220, 130), verdict, HORIZONTAL_ALIGNMENT_CENTER, 840, 38, verdict_color)
	
	var home_team_display := _display_home_team()
	var away_team_display := _display_away_team()
	if game_mode == "PELICULA" and movie_phase == "MATCH" and not movie_intro_match:
		if home_team_display == _get_current_opponent():
			home_team_display = "Dark " + home_team_display
		if away_team_display == _get_current_opponent():
			away_team_display = "Dark " + away_team_display
	
	draw_string(ThemeDB.fallback_font, Vector2(220, 180), "%s  %d - %d  %s" % [home_team_display.capitalize(), _display_home_score(), _display_away_score(), away_team_display.capitalize()], HORIZONTAL_ALIGNMENT_CENTER, 840, 23, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(300, 235), "RESULTADOS Y ESTADÍSTICAS", HORIZONTAL_ALIGNMENT_CENTER, 680, 18, MOVIE_CYAN)
	var rows := [
		["Pases", "passes"], ["Corner", "corners"], ["Lateral", "throw_ins"],
		["Tiro libre", "free_kicks"], ["Foul", "fouls"], ["Penal", "penalties"],
		["Llegadas al arco", "shots"], ["Amarillas", "yellow_cards"], ["Rojas", "red_cards"]
	]
	var y := 270
	for row in rows:
		var vals: Array = match_stats.get(row[1], [0, 0])
		draw_string(ThemeDB.fallback_font, Vector2(330, y), row[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(720, y), str(vals[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#fff02f"))
		draw_string(ThemeDB.fallback_font, Vector2(820, y), str(vals[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
		y += 30
	var save_text := "[S] GUARDAR" if movie_result_can_save else "GUARDADO"
	draw_string(ThemeDB.fallback_font, Vector2(240, 610), save_text + "    |    [ENTER] / TOCA CONTINUAR", HORIZONTAL_ALIGNMENT_CENTER, 800, 15, Color("#fff02f"))
	if save_feedback_timer > 0.0 and not save_feedback_text.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(240, 580), save_feedback_text, HORIZONTAL_ALIGNMENT_CENTER, 800, 14, MOVIE_CYAN)

func _draw_movie_star(center: Vector2, radius: float) -> void:
	var pts := PackedVector2Array()
	for i in range(5):
		var a := PI / 2.0 + i * TAU / 5.0
		pts.append(center + Vector2(cos(a), sin(a)) * radius)
	var pentagram := PackedVector2Array([pts[0], pts[2], pts[4], pts[1], pts[3], pts[0]])
	draw_polyline(pentagram, MOVIE_RED, 5.0, true)

func _draw_ellipse_movie(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(48):
		var a := TAU * float(i) / 48.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)

# ============================================================
# VARIABLES DEL JUEGO
# ============================================================

var home_score := 0
var away_score := 0
var goal_minute := 0  
var last_scoring_team := ""
var last_touch_team := "home"

var penalty_turn := 0
var home_penalties := 0
var away_penalties := 0
var penalty_state := "AIMING"
var penalty_shooter := "home"
var penalty_target_y := GOAL_CENTER_Y
var aim_direction := 1
var penalty_kicker_pos := Vector2.ZERO
var penalty_keeper_pos := Vector2.ZERO
var penalty_keeper_user_y := GOAL_CENTER_Y
var penalty_ai_wait := 0.0

var player_position := Vector2(640, 360)
var last_direction := Vector2.RIGHT
var selected_player := 3 

var ball_position := Vector2(640, 360)
var ball_velocity := Vector2.ZERO
var ball_owned := true
var ball_owner_team := "home"
var red_carrier_index := -1

var pass_cooldown := 0.0
var shot_cooldown := 0.0
var switch_cooldown := 0.0
var ai_shot_cooldown := 0.0
var tackle_cooldown := 0.0

var base_home_players := [
	Vector2(100, 360),
	Vector2(250, 200), Vector2(250, 310), Vector2(250, 410), Vector2(250, 520),
	Vector2(450, 180), Vector2(450, 290), Vector2(450, 430), Vector2(450, 540),
	Vector2(580, 290), Vector2(580, 430)
]

var base_away_players := [
	Vector2(1180, 360),
	Vector2(1030, 200), Vector2(1030, 310), Vector2(1030, 410), Vector2(1030, 520),
	Vector2(830, 180), Vector2(830, 290), Vector2(830, 430), Vector2(830, 540),
	Vector2(700, 290), Vector2(700, 430)
]

var home_players: Array = []
var away_players: Array = []
var home_targets: Array = []
var away_targets: Array = []

func _ready() -> void:
	if ResourceLoader.exists("res://portada.png"):
		title_texture = load("res://portada.png")
		
	if ResourceLoader.exists("res://ruta_a_tu_imagen/campeon.png"):
		champion_bg_texture = load("res://ruta_a_tu_imagen/campeon.png")
		
	for font_path in [
		"res://fonts/UnifrakturCook-Bold.ttf",
		"res://fonts/UnifrakturMaguntia-Regular.ttf",
		"res://UnifrakturCook-Bold.ttf",
		"res://UnifrakturMaguntia-Regular.ttf"
	]:
		if ResourceLoader.exists(font_path):
			movie_goal_font = load(font_path)
			break
	if movie_goal_font == null:
		var system_gothic := SystemFont.new()
		system_gothic.font_names = PackedStringArray(["UnifrakturCook", "UnifrakturMaguntia", "Old English Text MT"])
		movie_goal_font = system_gothic

	for font_path in [
		"res://fonts/Impact.ttf",
		"res://Impact.ttf"
	]:
		if ResourceLoader.exists(font_path):
			movie_title_font = load(font_path)
			break
	if movie_title_font == null:
		var system_impact := SystemFont.new()
		system_impact.font_names = PackedStringArray(["Impact", "Anton", "Arial Black"])
		movie_title_font = system_impact

	_initialize_division_rosters()
	_set_active_division(1)
	_load_champions_history()
	_initialize_standings()
	_setup_formations()
	if home_players.size() > 0:
		selected_player = min(5, home_players.size() - 1)
		player_position = home_players[selected_player]
	queue_redraw()

func _load_champions_history() -> void:
	champions_history.clear()
	var config := ConfigFile.new()
	if config.load(CHAMPIONS_SAVE_PATH) != OK:
		return
	var saved_history = config.get_value("champions", "history", [])
	if saved_history is Array:
		for entry in saved_history:
			if entry is Dictionary:
				champions_history.append(entry)

func _save_champions_history() -> void:
	var config := ConfigFile.new()
	config.set_value("champions", "history", champions_history)
	config.save(CHAMPIONS_SAVE_PATH)

func _register_champion(competition: String, division: int, team_name: String) -> void:
	if team_name.is_empty():
		return
	var division_name := _division_name(division) if division >= 1 and division <= 4 else "TODAS LAS DIVISIONES"
	champions_history.append({
		"competition": competition,
		"division": division_name,
		"season": league_season_number,
		"champion": team_name
	})
	_save_champions_history()

func _get_champions_history_for_display() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in champions_history:
		result.append(entry)
	result.reverse()
	return result

func _initialize_division_rosters() -> void:
	first_division_teams = _duplicate_team_array(PRIMERA_DIVISION_OPTIONS)
	league_b_teams = _duplicate_team_array(LIGA_B_OPTIONS)
	league_c_teams = _duplicate_team_array(LIGA_C_OPTIONS)
	second_division_teams = _duplicate_team_array(SEGUNDA_DIVISION_OPTIONS)

func _duplicate_team_array(source: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for team in source:
		result.append(team.duplicate(true))
	return result

func _all_available_teams() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for source in [first_division_teams, league_b_teams, league_c_teams, second_division_teams]:
		for team in source:
			result.append(team.duplicate(true))
	return result

func _division_name(div: int) -> String:
	match div:
		1: return "LIGA A"
		2: return "LIGA B"
		3: return "LIGA C"
		_: return "LIGA D"

func _base_teams_for_division(div: int) -> Array[Dictionary]:
	match div:
		1: return _duplicate_team_array(first_division_teams)
		2: return _duplicate_team_array(league_b_teams)
		3: return _duplicate_team_array(league_c_teams)
		_: return _duplicate_team_array(second_division_teams)

func _get_team_data(team_name: String) -> Dictionary:
	for team in _all_available_teams():
		if String(team["name"]) == team_name:
			return team
	return {}

func _get_team_original_division(team_name: String) -> int:
	for div in range(1, 5):
		for team in _base_teams_for_division(div):
			if String(team["name"]) == team_name:
				return div
	return 1

func _set_active_division(div: int, force_player_into_division: bool = false) -> void:
	current_division = clamp(div, 1, 4)
	active_color_options = _base_teams_for_division(current_division)
	if force_player_into_division and not player_team_name.is_empty():
		var already_present := false
		for team in active_color_options:
			if String(team["name"]) == player_team_name:
				already_present = true
				break
		if not already_present:
			var player_data := _get_team_data(player_team_name)
			if not player_data.is_empty():
				if active_color_options.size() >= 16:
					active_color_options[0] = player_data.duplicate(true)
				else:
					active_color_options.append(player_data.duplicate(true))

func _build_standings_for_teams(teams: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for team_dict in teams:
		var t_name := String(team_dict["name"])
		result.append({
			"name": t_name,
			"pts": 0, "pj": 0, "pg": 0, "pe": 0, "pp": 0,
			"gf": 0, "gc": 0, "dg": 0,
			"recent": [],
			"is_player": (t_name == player_team_name)
		})
	result.sort_custom(func(a, b):
		return String(a["name"]).naturalnocasecmp_to(String(b["name"])) < 0
	)
	return result

func _start_league_season_for_division(div: int) -> void:
	_set_active_division(div, true)
	league_fixtures.clear()
	current_fixture_index = 0
	all_match_results.clear()
	standings = _build_standings_for_teams(active_color_options)
	_generate_league_fixture()
	_reset_match_state()

func _apply_match_result_to_table(table: Array[Dictionary], team_name: String, gf: int, gc: int) -> void:
	for team in table:
		if String(team["name"]) != team_name:
			continue
		team["pj"] = int(team["pj"]) + 1
		team["gf"] = int(team["gf"]) + gf
		team["gc"] = int(team["gc"]) + gc
		team["dg"] = int(team["gf"]) - int(team["gc"])
		var res := "D"
		if gf > gc:
			team["pts"] = int(team["pts"]) + 3
			team["pg"] = int(team["pg"]) + 1
			res = "W"
		elif gf == gc:
			team["pts"] = int(team["pts"]) + 1
			team["pe"] = int(team["pe"]) + 1
		else:
			team["pp"] = int(team["pp"]) + 1
			res = "L"
		var recent: Array = team["recent"]
		recent.append(res)
		while recent.size() > 5:
			recent.pop_front()
		team["recent"] = recent
		return

func _find_player_position_in_standings() -> int:
	for i in range(standings.size()):
		if String(standings[i]["name"]) == player_team_name:
			return i
	return -1

func _handle_league_season_end() -> void:
	if standings.is_empty():
		game_state = "MENU"
		return
	champion_team_name = String(standings[0]["name"])
	_register_champion("LIGA", current_division, champion_team_name)
	var pos := _find_player_position_in_standings()
	season_event_queue.clear()
	season_transition_target_division = current_division

	if pos == 0:
		season_event_queue.append("CAMPEON")
		if current_division > 1:
			season_event_queue.append("ASCENSO")
			season_transition_target_division = current_division - 1
	elif pos == standings.size() - 1 and current_division < 4:
		season_event_queue.append("DESCENSO")
		season_transition_target_division = current_division + 1

	if season_event_queue.is_empty():
		_start_next_league_season(current_division)
	else:
		_start_next_season_event()

func _start_next_season_event() -> void:
	if not season_event_queue.is_empty():
		season_event_text = season_event_queue.pop_front()
		season_event_timer = SEASON_EVENT_DURATION
		game_state = "SEASON_EVENT"
		return

	season_event_text = ""
	if game_mode == "LIGA":
			_start_next_league_season(season_transition_target_division)
	elif game_mode == "COPA":
		if copa_round_index < copa_rounds.size():
			_open_next_fixture()
		else:
			game_state = "MENU"

func _start_next_league_season(div: int) -> void:
	league_season_number += 1
	current_division = clamp(div, 1, 4)
	_start_league_season_for_division(current_division)
	_save_league_game()
	_open_next_fixture()

func _save_league_game() -> void:
	if game_mode != "LIGA":
		return
	var config := ConfigFile.new()
	config.set_value("game", "mode", game_mode)
	config.set_value("game", "campaign", league_campaign_type)
	config.set_value("game", "division", current_division)
	config.set_value("game", "season", league_season_number)
	config.set_value("game", "team_name", player_team_name)
	config.set_value("game", "team_pattern", player_team_pattern)
	config.set_value("game", "team_colors", player_team_colors)
	var saved_fixture_index := current_fixture_index
	if game_state == "POST_MATCH_TRANSITION" and league_match_result_applied:
		saved_fixture_index = min(current_fixture_index + 1, league_fixtures.size())
	config.set_value("game", "fixture_index", saved_fixture_index)
	config.set_value("game", "fixtures", league_fixtures)
	config.set_value("game", "standings", standings)
	config.set_value("game", "results", all_match_results)
	var err := config.save(LEAGUE_SAVE_PATH)
	save_feedback_text = "PARTIDA GUARDADA" if err == OK else "ERROR AL GUARDAR"
	save_feedback_timer = 2.0

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item.duplicate(true))
	return result

func _load_league_game() -> void:
	var config := ConfigFile.new()
	if config.load(LEAGUE_SAVE_PATH) != OK:
		save_feedback_text = "NO HAY PARTIDA GUARDADA"
		save_feedback_timer = 2.0
		return
	game_mode = "LIGA"
	league_campaign_type = String(config.get_value("game", "campaign", "ASICOP"))
	current_division = int(config.get_value("game", "division", 1))
	league_season_number = int(config.get_value("game", "season", 1))
	player_team_name = String(config.get_value("game", "team_name", "boca"))
	player_team_pattern = String(config.get_value("game", "team_pattern", "solid"))
	player_team_colors = config.get_value("game", "team_colors", [Color("#ffffff")])
	current_fixture_index = int(config.get_value("game", "fixture_index", 0))
	league_fixtures = _to_dictionary_array(config.get_value("game", "fixtures", []))
	standings = _to_dictionary_array(config.get_value("game", "standings", []))
	all_match_results = _to_dictionary_array(config.get_value("game", "results", []))
	_set_active_division(current_division, true)
	_reset_match_state()
	menu_input_cooldown = 0.4
	if current_fixture_index >= league_fixtures.size():
		_handle_league_season_end()
	else:
		_open_next_fixture()

func _initialize_standings() -> void:
	standings.clear()
	for team_dict in active_color_options:
		var t_name = team_dict["name"]
		standings.append({
			"name": t_name,
			"pts": 0, "pj": 0, "pg": 0, "pe": 0, "pp": 0,
			"gf": 0, "gc": 0, "dg": 0,
			"recent": [],
			"is_player": (t_name == player_team_name)
		})
	standings.sort_custom(func(a, b):
		return a["name"].naturalnocasecmp_to(b["name"]) < 0
	)

func _confirm_formation_selection() -> void:
	if game_mode == "PELICULA":
		_movie_begin_new()
	else:
		_initialize_standings()
		_start_new_match(game_mode)

func _formation_positions(formation: String, left_side: bool) -> Array:
	var x_goal: float = FIELD_LEFT + 45.0 if left_side else FIELD_RIGHT - 45.0
	var direction: float = 1.0 if left_side else -1.0
	var rows: Array = []
	match formation:
		"4-3-3":
			rows = [[0.0], [0.24, 0.41, 0.59, 0.76], [0.30, 0.50, 0.70], [0.22, 0.50, 0.78]]
		"4-4-2":
			rows = [[0.0], [0.22, 0.41, 0.59, 0.78], [0.22, 0.41, 0.59, 0.78], [0.38, 0.62]]
		"4-2-3-1":
			rows = [[0.0], [0.22, 0.41, 0.59, 0.78], [0.38, 0.62], [0.22, 0.50, 0.78], [0.50]]
		"3-5-2":
			rows = [[0.0], [0.30, 0.50, 0.70], [0.18, 0.34, 0.50, 0.66, 0.82], [0.38, 0.62]]
		"3-4-3":
			rows = [[0.0], [0.30, 0.50, 0.70], [0.22, 0.41, 0.59, 0.78], [0.22, 0.50, 0.78]]
	var result: Array = [Vector2(x_goal, GOAL_CENTER_Y)]
	var depth_count: int = rows.size() - 1
	for row_index in range(1, rows.size()):
		var depth: float = float(row_index) / float(depth_count)
		var x: float = x_goal + direction * (120.0 + depth * 430.0)
		for y_ratio in rows[row_index]:
			result.append(Vector2(x, lerp(FIELD_TOP + 35.0, FIELD_BOTTOM - 35.0, float(y_ratio))))
	while result.size() < 11:
		result.append(Vector2(x_goal + direction * 300.0, GOAL_CENTER_Y))
	return result.slice(0, 11)

func _setup_formations() -> void:
	home_players.clear()
	away_players.clear()
	var home_left: bool = player_starts_left != is_second_half
	var home_formation_positions: Array = _formation_positions(selected_formation, home_left)
	var away_formation_positions: Array = _formation_positions(opponent_formation, not home_left)
	for p in home_formation_positions:
		home_players.append(p)
	for p in away_formation_positions:
		away_players.append(p)
	home_targets = home_players.duplicate()
	away_targets = away_players.duplicate()
	selected_player = clamp(selected_player, 0, home_players.size() - 1)
	player_position = home_players[selected_player]

func _handle_coin_toss() -> void:
	coin_toss_phase = "TOSSING"
	toss_timer = 1.5

func _process_coin_toss(delta: float) -> void:
	if coin_toss_phase == "TOSSING":
		toss_timer -= delta
		if toss_timer <= 0.0:
			player_won_coin_toss = bool(randi() % 2)
			if player_won_coin_toss:
				coin_toss_phase = "CHOOSING"
			else:
				chosen_side = randi() % 2
				player_starts_left = (chosen_side == 1)
				coin_toss_phase = "IDLE"
				_start_match_after_toss()
	elif coin_toss_phase == "CHOOSING":
		if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A) or touch_dir.x < -0.3:
			chosen_side = 0
			player_starts_left = true
			coin_toss_phase = "IDLE"
			_start_match_after_toss()
		elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D) or touch_dir.x > 0.3:
			chosen_side = 1
			player_starts_left = false
			coin_toss_phase = "IDLE"
			_start_match_after_toss()

func _start_match_after_toss() -> void:
	_setup_formations()
	_reset_after_goal("home")
	game_state = "PLAYING"
	menu_input_cooldown = 0.5

func _reset_match_state() -> void:
	opponent_formation = FORMATION_NAMES[randi_range(0, FORMATION_NAMES.size() - 1)]
	opponent_formation_revealed = false
	formation_notice_timer = 5.0
	league_match_result_applied = false
	_reset_match_stats()
	home_score = 0
	away_score = 0
	
	player_won_coin_toss = false
	coin_toss_phase = "IDLE"
	chosen_side = 0
	
	current_half = 1
	is_second_half = false
	match_elapsed_time = 0.0
	ball_owned = true
	ball_owner_team = "home"
	last_touch_team = "home"
	ball_position = Vector2(640, 360)
	ball_velocity = Vector2.ZERO
	red_carrier_index = -1
	player_stars.resize(home_players.size())
	for i in range(player_stars.size()):
		player_stars[i] = 0
	
	is_diablito_referee = (game_mode == "PELICULA" and movie_phase == "MATCH")
	is_mate_referee = (player_team_name == "river")
	
	_setup_formations()
	if home_players.size() > 0:
		selected_player = min(5, home_players.size() - 1)
		player_position = home_players[selected_player]

func _reset_match_stats() -> void:
	match_stats = {
		"passes": [0, 0], "corners": [0, 0], "throw_ins": [0, 0],
		"free_kicks": [0, 0], "fouls": [0, 0], "penalties": [0, 0],
		"shots": [0, 0], "yellow_cards": [0, 0], "red_cards": [0, 0]
	}

func _stat_add(stat_name: String, team: String) -> void:
	if match_stats.has(stat_name):
		var vals: Array = match_stats[stat_name]
		if team == "home":
			vals[0] += 1
		elif team == "away":
			vals[1] += 1

func _start_new_match(mode: String) -> void:
	game_mode = mode
	champion_team_name = ""
	champion_registered = false
	showing_champions_history = false

	if game_mode == "LIGA":
		league_season_number += 1
		current_division = 1 if league_campaign_type == "ASICOP" else 4
		_start_league_season_for_division(current_division)
	elif game_mode == "COPA":
		copa_rounds.clear()
		copa_round_index = 0
		all_match_results.clear()
		_generate_copa_bracket()

	_reset_match_state()
	_handle_coin_toss()
	game_state = "COIN_TOSS"

func _open_next_fixture() -> void:
	if game_mode == "LIGA" and current_fixture_index < league_fixtures.size():
		show_fixture_screen = true
		fixture_timer = 0.0
		fixture_scroll_offset = 0
		game_state = "FIXTURE_SCREEN"
	elif game_mode == "COPA" and copa_round_index < copa_rounds.size():
		show_fixture_screen = true
		fixture_timer = 0.0
		fixture_scroll_offset = 0
		game_state = "FIXTURE_SCREEN"
	else:
		_handle_coin_toss()
		game_state = "COIN_TOSS"

func _generate_league_fixture() -> void:
	league_fixtures.clear()
	var all_teams = []
	for t in active_color_options:
		all_teams.append(t["name"])
	all_teams.shuffle()

	var total_teams = all_teams.size()
	var total_rounds = total_teams - 1
	var matches_per_round = total_teams / 2
	var list_copy = all_teams.duplicate()

	for r in range(total_rounds):
		var round_matches = []
		for i in range(matches_per_round):
			var local = list_copy[0] if (i == 0) else list_copy[i]
			var visitor = list_copy[total_teams - 1 - i]
			if local and visitor:
				round_matches.append({"home": local, "away": visitor})
		league_fixtures.append({"round": r + 1, "matches": round_matches})
		
		var last = list_copy.pop_back()
		list_copy.insert(1, last)

func _display_home_team() -> String:
	var opponent := _get_current_opponent()
	var home := player_team_name if player_starts_left else opponent
	if game_mode == "PELICULA" and movie_phase == "MATCH" and not movie_intro_match:
		if home == opponent and opponent != "kelpers" and opponent != "adoradores de la estrella":
			home = "Dark " + home
	return home

func _display_away_team() -> String:
	var opponent := _get_current_opponent()
	var away := opponent if player_starts_left else player_team_name
	if game_mode == "PELICULA" and movie_phase == "MATCH" and not movie_intro_match:
		if away == opponent and opponent != "kelpers" and opponent != "adoradores de la estrella":
			away = "Dark " + away
	return away

func _display_home_score() -> int:
	return home_score if player_starts_left else away_score

func _display_away_score() -> int:
	return away_score if player_starts_left else home_score

func _get_current_opponent() -> String:
	if game_mode == "PELICULA":
		if movie_phase == "MATCH" and movie_match_index < MOVIE_MATCHES.size():
			return String(MOVIE_MATCHES[movie_match_index]["team"])
		if movie_phase == "FINAL_MATCH":
			return "adoradores de la estrella"
		if movie_phase == "KELPERS_MATCH":
			return "kelpers"
		return movie_random_opponent
	if game_mode == "COPA":
		if copa_round_index < copa_rounds.size():
			var matches_list = copa_rounds[copa_round_index]["matches"]
			for m in matches_list:
				if m["is_player_match"]:
					if m["home"] == player_team_name:
						return m["away"]
					else:
						return m["home"]
		return "sin rival"
	else:
		if current_fixture_index >= league_fixtures.size():
			return "sin rival"
		var round_data = league_fixtures[current_fixture_index]
		for m in round_data["matches"]:
			if m["home"] == player_team_name:
				return m["away"]
			elif m["away"] == player_team_name:
				return m["home"]
		return "sin rival"

func _generate_copa_bracket() -> void:
	copa_rounds.clear()
	copa_all_teams.clear()
	for t in _all_available_teams():
		copa_all_teams.append(String(t["name"]))

	copa_all_teams.erase(player_team_name)
	copa_all_teams.shuffle()
	copa_all_teams.insert(0, player_team_name)
	var pool := copa_all_teams.duplicate()

	var r64: Array[Dictionary] = []
	for i in range(0, 64, 2):
		var h: String = pool[i]
		var a: String = pool[i + 1]
		r64.append({"home": h, "away": a, "is_player_match": (h == player_team_name or a == player_team_name)})

	copa_rounds.append({"name": "32AVOS DE FINAL", "matches": r64})
	copa_rounds.append({"name": "16AVOS DE FINAL", "matches": []})
	copa_rounds.append({"name": "8VOS DE FINAL", "matches": []})
	copa_rounds.append({"name": "4TOS DE FINAL", "matches": []})
	copa_rounds.append({"name": "SEMIFINAL", "matches": []})
	copa_rounds.append({"name": "FINAL", "matches": []})

func _advance_post_match() -> void:
	if switch_cooldown > 0.0:
		return
	switch_cooldown = 0.3
	if post_match_state == "SHOW_RESULTS":
		show_match_results_screen = true
		if game_mode == "LIGA":
			post_match_state = "SHOW_STANDINGS"
		else:
			post_match_state = "ADVANCE_MATCH"
	elif post_match_state == "SHOW_STANDINGS":
		show_match_results_screen = false
		post_match_state = "ADVANCE_MATCH"
	elif post_match_state == "ADVANCE_MATCH":
		show_match_results_screen = false
		if game_mode == "LIGA":
			current_fixture_index += 1
			if current_fixture_index >= league_fixtures.size():
				_handle_league_season_end()
			else:
				_save_league_game()
				_open_next_fixture()
		elif game_mode == "COPA":
			if copa_player_eliminated:
				copa_player_eliminated = false
				game_state = "GAME_OVER"
				return
			copa_round_index += 1
			if copa_round_index < copa_rounds.size():
				season_event_queue = ["CLASIFICASTE"]
				season_transition_target_division = current_division
				_start_next_season_event()
			else:
				_register_champion("COPA", 0, champion_team_name)
				season_event_queue = ["CAMPEON"]
				_start_next_season_event()

func _process(delta: float) -> void:
	_update_effects(delta)
	_update_cooldowns(delta)

	if menu_input_cooldown > 0.0:
		menu_input_cooldown -= delta

	if formation_notice_timer > 0.0:
		formation_notice_timer -= delta
	if foul_card_timer > 0.0:
		foul_card_timer -= delta
	if save_feedback_timer > 0.0:
		save_feedback_timer -= delta

	if game_state == "COIN_TOSS":
		_process_coin_toss(delta)
		return

	if game_state == "MOVIE":
		if movie_phase in ["INVASION", "BRIEF", "WIN_TEXT", "FALKLANDS_TEXT", "KELPERS_BRIEF", "KELPERS_WIN", "FINAL_BRIEF", "FINAL_LOSS", "LOSS", "MOVIE_RESULT_WIN_TEXT", "VICTORY_SLOGAN", "VICTORY_FIN", "STAR_TITLE"]:
			_movie_update_dialog(delta)
			if Input.is_key_pressed(KEY_ENTER) and switch_cooldown <= 0.0:
				_movie_dialog_enter()
				switch_cooldown = 0.25
		elif movie_phase == "LOAD_ERROR":
			if (Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_ESCAPE)) and switch_cooldown <= 0.0:
				_movie_on_enter()
				switch_cooldown = 0.3
		elif movie_phase == "MOVIE_RESULTS":
			if Input.is_key_pressed(KEY_S) and switch_cooldown <= 0.0 and movie_result_can_save:
				_movie_save()
				switch_cooldown = 0.35
			elif Input.is_key_pressed(KEY_ENTER) and switch_cooldown <= 0.0:
				_movie_on_enter()
				switch_cooldown = 0.25
		elif movie_phase == "MAP":
			if Input.is_key_pressed(KEY_ENTER) and switch_cooldown <= 0.0:
				_movie_on_enter()
				switch_cooldown = 0.25
			elif Input.is_key_pressed(KEY_S) and switch_cooldown <= 0.0 and movie_match_index > 0:
				_movie_save()
				switch_cooldown = 0.35
		elif movie_phase in ["UFO", "STAR", "VICTORY_MAP"]:
			movie_timer -= delta
			if movie_timer <= 0.0:
				_movie_on_enter()
		queue_redraw()
		return

	if game_state == "MATCH_PAUSE":
		if menu_input_cooldown <= 0.0:
			if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or touch_dir.x < -0.3:
				pause_selected_player = (pause_selected_player - 1 + max(1, home_players.size())) % max(1, home_players.size())
				selected_player = pause_selected_player
				menu_input_cooldown = 0.18
			elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or touch_dir.x > 0.3:
				pause_selected_player = (pause_selected_player + 1) % max(1, home_players.size())
				selected_player = pause_selected_player
				menu_input_cooldown = 0.18
			elif Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or touch_dir.y < -0.3:
				pause_star_allocation = min(accumulated_stars, pause_star_allocation + 1)
				menu_input_cooldown = 0.18
			elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or touch_dir.y > 0.3:
				pause_star_allocation = max(0, pause_star_allocation - 1)
				menu_input_cooldown = 0.18
			elif Input.is_key_pressed(KEY_ENTER):
				_use_pause_stars()
				menu_input_cooldown = 0.3
			elif Input.is_key_pressed(KEY_ESCAPE):
				game_state = "PLAYING"
				menu_input_cooldown = 0.3
			elif Input.is_key_pressed(KEY_Q):
				game_state = "MENU"
				menu_input_cooldown = 0.5
		queue_redraw()
		return

	if game_state == "MENU":
		if menu_input_cooldown <= 0.0:
			if Input.is_key_pressed(KEY_1):
				game_mode = "LIGA"
				menu_input_cooldown = 0.4
				game_state = "SELECT_CAMPAIGN"
			elif Input.is_key_pressed(KEY_2):
				game_mode = "COPA"
				active_color_options = _all_available_teams()
				selected_color_idx = 0
				menu_input_cooldown = 0.4
				game_state = "SELECT_COLOR"
			elif Input.is_key_pressed(KEY_3):
				showing_champions_history = true
				menu_input_cooldown = 0.4
				game_state = "CHAMPIONS_HISTORY"
			elif Input.is_key_pressed(KEY_4):
				game_mode = "PELICULA"
				menu_input_cooldown = 0.4
				game_state = "MOVIE_MENU"

	elif game_state == "MOVIE_MENU":
		if menu_input_cooldown <= 0.0:
			if Input.is_key_pressed(KEY_1):
				active_color_options = _all_available_teams()
				selected_color_idx = 0
				menu_input_cooldown = 0.4
				game_state = "SELECT_COLOR"
			elif Input.is_key_pressed(KEY_2):
				menu_input_cooldown = 0.4
				_movie_load()
			elif Input.is_key_pressed(KEY_ESCAPE):
				menu_input_cooldown = 0.3
				game_state = "MENU"

	elif game_state == "SELECT_CAMPAIGN":
		if menu_input_cooldown <= 0.0:
			if Input.is_key_pressed(KEY_1):
				league_campaign_type = "ASICOP"
				active_color_options = _all_available_teams()
				selected_color_idx = 0
				menu_input_cooldown = 0.4
				game_state = "SELECT_COLOR"
			elif Input.is_key_pressed(KEY_2):
				league_campaign_type = "HAMBRE"
				active_color_options = _all_available_teams()
				selected_color_idx = 0
				menu_input_cooldown = 0.4
				game_state = "SELECT_COLOR"
			elif Input.is_key_pressed(KEY_3):
				_load_league_game()

	elif game_state == "SELECT_COLOR":
		_process_color_selection()

	elif game_state == "SELECT_FORMATION":
		if menu_input_cooldown <= 0.0:
			for formation_index in range(FORMATION_NAMES.size()):
				var formation_key: Key = KEY_1
				match formation_index:
					0: formation_key = KEY_1
					1: formation_key = KEY_2
					2: formation_key = KEY_3
					3: formation_key = KEY_4
					4: formation_key = KEY_5
				if Input.is_key_pressed(formation_key):
					selected_formation = FORMATION_NAMES[formation_index]
					_confirm_formation_selection()
					break
			if game_state == "SELECT_FORMATION" and (Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)):
				_confirm_formation_selection()
			elif Input.is_key_pressed(KEY_ESCAPE):
				game_state = "SELECT_COLOR"
			menu_input_cooldown = 0.18

	elif game_state == "FIXTURE_SCREEN":
		fixture_timer += delta
		if game_mode == "LIGA":
			if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W) or touch_dir.y < -0.3:
				fixture_scroll_offset = max(0, fixture_scroll_offset - 1)
			elif Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S) or touch_dir.y > 0.3:
				fixture_scroll_offset = min(max(0, league_fixtures.size() - 5), fixture_scroll_offset + 1)

		if fixture_timer >= FIXTURE_MIN_TIME and Input.is_key_pressed(KEY_ENTER):
			show_fixture_screen = false
			_reset_match_state()
			_handle_coin_toss()
			game_state = "COIN_TOSS"
			menu_input_cooldown = 0.5
			return

	elif game_state == "HALF_TIME_BANNER":
		if menu_input_cooldown <= 0.0 and (Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE)):
			menu_input_cooldown = 0.4
			_start_second_half()

	elif game_state == "POST_MATCH_TRANSITION":
		if game_mode == "LIGA" and Input.is_key_pressed(KEY_S) and switch_cooldown <= 0.0:
			_save_league_game()
			switch_cooldown = 0.3
		if Input.is_key_pressed(KEY_ENTER) and switch_cooldown <= 0.0:
			_advance_post_match()

	elif game_state == "SEASON_EVENT":
		season_event_timer -= delta
		if season_event_timer <= 0.0 or (Input.is_key_pressed(KEY_ENTER) and switch_cooldown <= 0.0):
			switch_cooldown = 0.25
			_start_next_season_event()

	elif game_state == "CHAMPION_SCREEN":
		pass

	elif game_state == "CHAMPIONS_HISTORY":
		if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_ESCAPE):
			showing_champions_history = false
			menu_input_cooldown = 0.3
			game_state = "MENU"

	elif game_state == "STANDINGS":
		if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_ESCAPE):
			game_state = "MENU"

	elif game_state == "PLAYING":
		if Input.is_key_pressed(KEY_ENTER) and switch_cooldown <= 0.0 and not celebration_active and menu_input_cooldown <= 0.0:
			_enter_match_pause()
			switch_cooldown = 0.35
			return
		if game_mode == "PELICULA" and movie_phase == "OPENING_MATCH":
			movie_timer += delta
			if not movie_match_interrupted and movie_timer >= MOVIE_UFO_AFTER_SECONDS:
				movie_match_interrupted = true
				movie_phase = "UFO"
				movie_timer = 3.0
				game_state = "MOVIE"
				queue_redraw()
				return
		if celebration_active:
			_update_celebration_timer(delta)
		else:
			_update_match_timer(delta)
			_check_player_switch()
			_move_player(delta)
			_process_tackle_input(delta)
			_process_direct_steal_input()
			_update_ai_positioning(delta)
			_update_referee(delta)
			_update_ball(delta)
			_update_stamina_bar(delta)
			_check_out_of_bounds_and_goals()

	elif game_state == "PENALTIES":
		if celebration_active:
			_update_celebration_timer(delta)
		else:
			_process_penalties(delta)

	elif game_state == "GAME_OVER":
		if Input.is_key_pressed(KEY_ENTER): 
			if game_mode == "LIGA":
				game_state = "STANDINGS"
			else:
				game_state = "MENU"

	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if game_state == "PLAYING":
				if btn_pass_rect.has_point(event.position):
					_pass_ball()
				elif btn_shot_rect.has_point(event.position):
					_shoot_ball()
				elif btn_switch_rect.has_point(event.position):
					_switch_to_nearest_player()
				elif btn_tackle_rect.has_point(event.position):
					is_charging_tackle = true
				elif event.position.x < SCREEN_WIDTH / 2.0:
					touch_joystick_active = true
					touch_joystick_index = event.index
					touch_joystick_center = event.position
					touch_joystick_pos = event.position

			elif game_state == "MENU":
				var opt1 = Rect2(Vector2(470, 385), Vector2(340, 55))
				var opt2 = Rect2(Vector2(470, 450), Vector2(340, 55))
				var opt3 = Rect2(Vector2(470, 515), Vector2(340, 55))
				var opt4 = Rect2(Vector2(470, 580), Vector2(340, 55))
				if opt1.has_point(event.position):
					game_mode = "LIGA"
					menu_input_cooldown = 0.4
					game_state = "SELECT_CAMPAIGN"
				elif opt2.has_point(event.position):
					game_mode = "COPA"
					active_color_options = _all_available_teams()
					selected_color_idx = 0
					menu_input_cooldown = 0.4
					game_state = "SELECT_COLOR"
				elif opt3.has_point(event.position):
					showing_champions_history = true
					menu_input_cooldown = 0.4
					game_state = "CHAMPIONS_HISTORY"
				elif opt4.has_point(event.position):
					game_mode = "PELICULA"
					menu_input_cooldown = 0.4
					game_state = "MOVIE_MENU"

			elif game_state == "SELECT_CAMPAIGN":
				var camp1 = Rect2(Vector2(330, 190), Vector2(620, 80))
				var camp2 = Rect2(Vector2(330, 285), Vector2(620, 80))
				var camp3 = Rect2(Vector2(330, 380), Vector2(620, 80))
				if camp1.has_point(event.position):
					league_campaign_type = "ASICOP"
					active_color_options = _all_available_teams()
					selected_color_idx = 0
					menu_input_cooldown = 0.4
					game_state = "SELECT_COLOR"
				elif camp2.has_point(event.position):
					league_campaign_type = "HAMBRE"
					active_color_options = _all_available_teams()
					selected_color_idx = 0
					menu_input_cooldown = 0.4
					game_state = "SELECT_COLOR"
				elif camp3.has_point(event.position):
					_load_league_game()

			elif game_state == "MOVIE_MENU":
				var m_opt1 = Rect2(Vector2(330, 250), Vector2(620, 50))
				var m_opt2 = Rect2(Vector2(330, 310), Vector2(620, 50))
				var m_opt3 = Rect2(Vector2(330, 370), Vector2(620, 50))
				if m_opt1.has_point(event.position):
					active_color_options = _all_available_teams()
					selected_color_idx = 0
					menu_input_cooldown = 0.4
					game_state = "SELECT_COLOR"
				elif m_opt2.has_point(event.position):
					menu_input_cooldown = 0.4
					_movie_load()
				elif m_opt3.has_point(event.position):
					menu_input_cooldown = 0.3
					game_state = "MENU"

			elif game_state == "SELECT_COLOR":
				var page_size := 16
				var page := int(selected_color_idx / page_size)
				var page_start := page * page_size
				var page_end: int = min(page_start + page_size, int(active_color_options.size()))
				var start_y := 170
				var col_x1 := 280
				var col_x2 := 640
				var item_selected := false

				for i in range(page_start, page_end):
					var local_i := i - page_start
					var x = col_x1 if local_i < 8 else col_x2
					var y = start_y + (local_i % 8) * 50
					var item_rect = Rect2(Vector2(x, y), Vector2(340, 42))
					if item_rect.has_point(event.position):
						selected_color_idx = i
						var selected_team = active_color_options[selected_color_idx]
						player_team_name = String(selected_team["name"])
						selected_team_original_division = _get_team_original_division(player_team_name)
						player_team_pattern = String(selected_team["pattern"])
						player_team_colors = selected_team["colors"]
						switch_cooldown = 0.4
						item_selected = true
						selected_formation = "4-3-3"
						game_state = "SELECT_FORMATION"
						break
				
				if not item_selected:
					if event.position.x < 240:
						selected_color_idx = (selected_color_idx - page_size + active_color_options.size()) % active_color_options.size()
					elif event.position.x > 1040:
						selected_color_idx = (selected_color_idx + page_size) % active_color_options.size()

			elif game_state == "SELECT_FORMATION":
				for formation_index in range(FORMATION_NAMES.size()):
					var formation_rect := Rect2(Vector2(330, 190 + formation_index * 72), Vector2(620, 56))
					if formation_rect.has_point(event.position):
						selected_formation = FORMATION_NAMES[formation_index]
						_confirm_formation_selection()
						break

			elif game_state == "MATCH_PAUSE":
				var btn_prev = Rect2(Vector2(260, 440), Vector2(230, 40))
				var btn_next = Rect2(Vector2(510, 440), Vector2(230, 40))
				var btn_star_add = Rect2(Vector2(260, 485), Vector2(230, 40))
				var btn_star_sub = Rect2(Vector2(510, 485), Vector2(230, 40))
				var btn_resume = Rect2(Vector2(260, 530), Vector2(230, 40))
				var btn_exit = Rect2(Vector2(510, 530), Vector2(230, 40))

				if btn_prev.has_point(event.position):
					pause_selected_player = (pause_selected_player - 1 + max(1, home_players.size())) % max(1, home_players.size())
					selected_player = pause_selected_player
				elif btn_next.has_point(event.position):
					pause_selected_player = (pause_selected_player + 1) % max(1, home_players.size())
					selected_player = pause_selected_player
				elif btn_star_add.has_point(event.position):
					pause_star_allocation = min(accumulated_stars, pause_star_allocation + 1)
				elif btn_star_sub.has_point(event.position):
					pause_star_allocation = max(0, pause_star_allocation - 1)
				elif btn_resume.has_point(event.position):
					_use_pause_stars()
				elif btn_exit.has_point(event.position):
					game_state = "MENU"

			elif game_state == "HALF_TIME_BANNER":
				menu_input_cooldown = 0.4
				_start_second_half()

			elif game_state == "POST_MATCH_TRANSITION":
				if switch_cooldown <= 0.0:
					var save_btn_rect = Rect2(Vector2(260, 585), Vector2(200, 45))
					if game_mode == "LIGA" and save_btn_rect.has_point(event.position):
						_save_league_game()
						switch_cooldown = 0.3
					else:
						_advance_post_match()

			elif game_state == "FIXTURE_SCREEN":
				if fixture_timer >= FIXTURE_MIN_TIME:
					show_fixture_screen = false
					_reset_match_state()
					_handle_coin_toss()
					game_state = "COIN_TOSS"
					menu_input_cooldown = 0.5

			elif game_state == "SEASON_EVENT":
				if switch_cooldown <= 0.0:
					switch_cooldown = 0.25
					_start_next_season_event()

			elif game_state == "CHAMPION_SCREEN":
				game_state = "MENU"
				show_champion_screen = false
				queue_redraw()

			elif game_state == "GAME_OVER":
				if game_mode == "LIGA":
					game_state = "STANDINGS"
				else:
					game_state = "MENU"

			elif game_state == "CHAMPIONS_HISTORY" or game_state == "STANDINGS":
				showing_champions_history = false
				menu_input_cooldown = 0.3
				game_state = "MENU"

			else:
				Input.action_press("ui_accept")

		else:
			if event.index == touch_joystick_index:
				touch_joystick_active = false
				touch_joystick_index = -1
				touch_dir = Vector2.ZERO
			if is_charging_tackle:
				_execute_player_tackle(tackle_power)
				is_charging_tackle = false
				tackle_power = 0.0

	elif event is InputEventScreenDrag:
		if event.index == touch_joystick_index and touch_joystick_active:
			touch_joystick_pos = event.position
			var diff = touch_joystick_pos - touch_joystick_center
			var max_dist := 60.0
			if diff.length() > max_dist:
				diff = diff.normalized() * max_dist
				touch_joystick_pos = touch_joystick_center + diff
			touch_dir = diff / max_dist

	if game_state == "CHAMPION_SCREEN":
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				game_state = "MENU"
				show_champion_screen = false
				queue_redraw()

func _enter_match_pause() -> void:
	pause_selected_player = clamp(selected_player, 0, max(0, home_players.size() - 1))
	pause_star_allocation = 0
	game_state = "MATCH_PAUSE"

func _use_pause_stars() -> void:
	if accumulated_stars <= 0 or pause_star_allocation <= 0:
		return
	var amount: int = min(pause_star_allocation, accumulated_stars) as int
	accumulated_stars -= amount
	if selected_player < player_stars.size():
		player_stars[selected_player] += amount
	
	player_boost_stars = 0
	pause_star_allocation = 0
	selected_player = clamp(pause_selected_player, 0, max(0, home_players.size() - 1))
	if selected_player < home_players.size():
		player_position = home_players[selected_player]
	game_state = "PLAYING"

func _update_stamina_bar(delta: float) -> void:
	var field_center_x := 640.0
	var distance_from_center = ball_position.x - field_center_x
	var dominance_factor = -distance_from_center * 0.015
	
	if ball_owned:
		if ball_owner_team == "home":
			dominance_factor += 10.0
		else:
			dominance_factor -= 10.0

	stamina_bar_value += dominance_factor * delta
	stamina_bar_value = clamp(stamina_bar_value, 0.0, 100.0)

	if stamina_bar_value >= 100.0:
		accumulated_stars += 1
		foul_card_text = "¡DOMINIO TOTAL! ¡ESTRELLA OTORGADA AL LOCAL!"
		foul_card_timer = 2.0
		stamina_bar_value = 50.0
	elif stamina_bar_value <= 0.0:
		foul_card_text = "¡EL VISITANTE DOMINA EL PULSO!"
		foul_card_timer = 2.0
		stamina_bar_value = 50.0

func _process_direct_steal_input() -> void:
	if tackle_cooldown > 0.0: return
	if Input.is_key_pressed(KEY_N):
		if ball_owned and ball_owner_team == "away" and red_carrier_index != -1 and red_carrier_index < away_players.size():
			var red_pos: Vector2 = away_players[red_carrier_index]
			if player_position.distance_to(red_pos) <= 35.0:
				ball_owned = true
				ball_owner_team = "home"
				last_touch_team = "home"
				red_carrier_index = -1
				tackle_cooldown = 0.4
				foul_card_text = "¡QUITE DIRECTO LIMPIO!"
				foul_card_timer = 1.2

func _process_tackle_input(delta: float) -> void:
	if tackle_cooldown > 0.0: return
	if Input.is_key_pressed(KEY_L):
		is_charging_tackle = true
		tackle_power += tackle_power_dir * 180.0 * delta
		if tackle_power >= 100.0:
			tackle_power = 100.0
			tackle_power_dir = -1.0
		elif tackle_power <= 0.0:
			tackle_power = 0.0
			tackle_power_dir = 1.0
	else:
		if is_charging_tackle and not touch_joystick_active:
			_execute_player_tackle(tackle_power)
			is_charging_tackle = false
			tackle_power = 0.0
			tackle_power_dir = 1.0

func _execute_player_tackle(power: float) -> void:
	tackle_cooldown = 0.6
	if power > 95.0:
		_stat_add("red_cards", "home")
		foul_card_text = "¡ROJA Y EXPULSIÓN POR ENTRADA BRUTAL! (" + str(int(power)) + "%)"
		foul_card_timer = 3.0
		_eject_player("home", selected_player)
		_trigger_foul(player_position, "away")
	elif power > 70.0:
		_stat_add("yellow_cards", "home")
		foul_card_text = "¡TARJETA AMARILLA POR TACKLE EXCESIVO! (" + str(int(power)) + "%)"
		foul_card_timer = 3.0
		_trigger_foul(player_position, "away")
	else:
		foul_card_text = "TACKLE LIMPIO (" + str(int(power)) + "%)"
		foul_card_timer = 1.5
		if ball_owned and ball_owner_team == "away" and red_carrier_index != -1 and red_carrier_index < away_players.size():
			if player_position.distance_to(away_players[red_carrier_index]) < 35.0:
				ball_owned = true
				ball_owner_team = "home"
				last_touch_team = "home"
				red_carrier_index = -1

func _eject_player(team: String, index: int) -> void:
	if team == "home":
		if home_players.size() > 1 and index >= 0 and index < home_players.size():
			home_players.remove_at(index)
			home_targets.remove_at(index)
			player_stars.remove_at(index)
			selected_player = min(selected_player, home_players.size() - 1)
			player_position = home_players[selected_player]
	else:
		if away_players.size() > 1 and index >= 0 and index < away_players.size():
			away_players.remove_at(index)
			away_targets.remove_at(index)
			if red_carrier_index == index: red_carrier_index = -1

func _check_out_of_bounds_and_goals() -> void:
	var check_pos: Vector2 = ball_position

	# La autoría del gol depende del lado real de cada equipo, no solo del tiempo.
	# Esto también respeta el sorteo inicial y el cambio de lado del entretiempo.
	var home_attacks_right: bool = (player_starts_left != is_second_half)
	if check_pos.x <= FIELD_LEFT + 5.0 and check_pos.y >= GOAL_TOP_Y and check_pos.y <= GOAL_BOTTOM_Y:
		if home_attacks_right:
			_away_scores()
		else:
			_home_scores()
		return
	elif check_pos.x >= FIELD_RIGHT - 5.0 and check_pos.y >= GOAL_TOP_Y and check_pos.y <= GOAL_BOTTOM_Y:
		if home_attacks_right:
			_home_scores()
		else:
			_away_scores()
		return

	if ball_position.y < FIELD_TOP or ball_position.y > FIELD_BOTTOM:
		var clamp_y := FIELD_TOP + 5.0 if ball_position.y < FIELD_TOP else FIELD_BOTTOM - 5.0
		var spot := Vector2(clamp(ball_position.x, FIELD_LEFT + 10.0, FIELD_RIGHT - 10.0), clamp_y)
		var taker := "away" if last_touch_team == "home" else "home"
		_stat_add("throw_ins", taker)
		_trigger_restart(spot, taker)
		return

	if ball_position.x < FIELD_LEFT or ball_position.x > FIELD_RIGHT:
		var is_left_out := ball_position.x < FIELD_LEFT
		var defending_team := "home" if ((is_left_out and not is_second_half) or (not is_left_out and is_second_half)) else "away"
		
		if last_touch_team == defending_team:
			var corner_x := FIELD_LEFT + 5.0 if is_left_out else FIELD_RIGHT - 5.0
			var corner_y := FIELD_TOP + 5.0 if ball_position.y < GOAL_CENTER_Y else FIELD_BOTTOM - 5.0
			var attacking_team := "away" if defending_team == "home" else "home"
			_stat_add("corners", attacking_team)
			_trigger_restart(Vector2(corner_x, corner_y), attacking_team)
		else:
			var gk_x := FIELD_LEFT + 50.0 if is_left_out else FIELD_RIGHT - 50.0
			_trigger_restart(Vector2(gk_x, GOAL_CENTER_Y), defending_team)
		return

func _trigger_restart(spot: Vector2, team: String) -> void:
	ball_position = spot
	ball_velocity = Vector2.ZERO
	ball_owned = true
	ball_owner_team = team
	last_touch_team = team
	if team == "home":
		if home_players.size() > 0:
			player_position = spot + Vector2(-15, 0)
			home_players[selected_player] = player_position
	else:
		if away_players.size() > 0:
			red_carrier_index = min(5, away_players.size() - 1)
			away_players[red_carrier_index] = spot + Vector2(15, 0)

func _trigger_foul(foul_position: Vector2, victim_team: String) -> void:
	camera_shake_intensity = 12.0
	var offender := "away" if victim_team == "home" else "home"
	_stat_add("fouls", offender)
	_trigger_restart(foul_position, victim_team)

func _process_color_selection() -> void:
	if switch_cooldown > 0.0: return

	var changed := false
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or touch_dir.x > 0.3:
		selected_color_idx = (selected_color_idx + 1) % active_color_options.size()
		changed = true
	elif Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or touch_dir.x < -0.3:
		selected_color_idx = (selected_color_idx - 1 + active_color_options.size()) % active_color_options.size()
		changed = true

	if changed:
		switch_cooldown = 0.2

	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
		var selected_team = active_color_options[selected_color_idx]
		player_team_name = String(selected_team["name"])
		selected_team_original_division = _get_team_original_division(player_team_name)
		player_team_pattern = String(selected_team["pattern"])
		player_team_colors = selected_team["colors"]
		switch_cooldown = 0.4
		selected_formation = "4-3-3"
		game_state = "SELECT_FORMATION"

func _update_effects(delta: float) -> void:
	if camera_shake_intensity > 0.0:
		camera_shake_intensity = max(0.0, camera_shake_intensity - delta * 24.0)
		camera_offset = Vector2(randf_range(-camera_shake_intensity, camera_shake_intensity), randf_range(-camera_shake_intensity, camera_shake_intensity))
	else:
		camera_offset = Vector2.ZERO

	var i := confetti_list.size() - 1
	while i >= 0:
		var c = confetti_list[i]
		c["pos"] += c["vel"] * delta
		c["vel"].y += 180.0 * delta
		c["rot"] += c["rot_speed"] * delta
		if c["pos"].y > SCREEN_HEIGHT + 20.0:
			confetti_list.remove_at(i)
		i -= 1

func _trigger_goal_celebration() -> void:
	camera_shake_intensity = 20.0
	confetti_list.clear()
	celebration_active = true
	celebration_timer = CELEBRATION_DURATION
	
	if current_half == 2:
		goal_minute = int(45.0 + match_elapsed_time)
	else:
		goal_minute = int(match_elapsed_time)
	goal_minute = clamp(goal_minute, 1, 90)

	var base_col = player_team_colors[0] if player_team_colors.size() > 0 else Color.WHITE
	var colors := [base_col, Color("#df4141"), Color("#fff02f"), Color("#ffffff"), Color("#00aaff")]
	for i in range(180):
		var from_left := i % 2 == 0
		var spawn_pos := Vector2(randf_range(-20, 60), randf_range(-20, 40)) if from_left else Vector2(randf_range(SCREEN_WIDTH - 60, SCREEN_WIDTH + 20), randf_range(-20, 40))
		var dir := Vector2(randf_range(350, 650), randf_range(-450, -120)) if from_left else Vector2(randf_range(-650, -350), randf_range(-450, -120))
		
		confetti_list.append({
			"pos": spawn_pos,
			"vel": dir,
			"rot": randf() * TAU,
			"rot_speed": randf_range(-8.0, 8.0),
			"color": colors.pick_random(),
			"size": Vector2(randf_range(6, 12), randf_range(6, 12))
		})

func _update_celebration_timer(delta: float) -> void:
	celebration_timer -= delta
	if celebration_timer <= 0.0:
		celebration_active = false
		_reset_after_goal(pending_kickoff_team)

func _update_match_timer(delta: float) -> void:
	match_elapsed_time += delta * (45.0 / HALF_DURATION)
	if match_elapsed_time >= 45.0:
		match_elapsed_time = 45.0
		if current_half == 1:
			game_state = "HALF_TIME_BANNER"
			foul_card_timer = 4.0 
		elif current_half == 2:
			_finish_match()

func _start_second_half() -> void:
	current_half = 2
	is_second_half = true
	match_elapsed_time = 0.0
	_setup_formations()
	_reset_after_goal("away")
	game_state = "PLAYING"
	menu_input_cooldown = 0.8

func _finish_match() -> void:
	if game_mode == "PELICULA":
		_movie_match_finished()
		return
	if game_mode == "LIGA":
		_calculate_end_game()
		return

	if home_score == away_score:
		_start_penalties()
		return

	copa_player_eliminated = home_score < away_score
	_calculate_end_game()

func _calculate_end_game() -> void:
	game_state = "POST_MATCH_TRANSITION"
	post_match_state = "SHOW_RESULTS"
	if game_mode == "LIGA": 
		_update_league_data()
	elif game_mode == "COPA":
		_update_copa_data()

func _update_league_data() -> void:
	if game_mode != "LIGA":
		return
	if current_fixture_index >= league_fixtures.size():
		return
	if league_match_result_applied:
		return

	all_match_results.clear()
	var round_data: Dictionary = league_fixtures[current_fixture_index]
	var current_opponent := _get_current_opponent()

	var player_gf: int = home_score
	var player_gc: int = away_score

	var player_is_home := false
	for m in round_data["matches"]:
		if m["home"] == player_team_name:
			player_is_home = true
			current_opponent = String(m["away"])
			break
		elif m["away"] == player_team_name:
			player_is_home = false
			current_opponent = String(m["home"])
			break

	if player_is_home:
		all_match_results.append({
			"home": player_team_name,
			"away": current_opponent,
			"hg": player_gf,
			"ag": player_gc
		})
	else:
		all_match_results.append({
			"home": current_opponent,
			"away": player_team_name,
			"hg": player_gc,
			"ag": player_gf
		})

	_apply_match_result(player_team_name, player_gf, player_gc)
	_apply_match_result(current_opponent, player_gc, player_gf)

	for m in round_data["matches"]:
		var t_a: String = String(m["home"])
		var t_b: String = String(m["away"])

		if t_a == player_team_name or t_b == player_team_name:
			continue

		var g_a: int = randi_range(0, 3)
		var g_b: int = randi_range(0, 3)

		_apply_match_result(t_a, g_a, g_b)
		_apply_match_result(t_b, g_b, g_a)

		all_match_results.append({
			"home": t_a,
			"away": t_b,
			"hg": g_a,
			"ag": g_b
		})

	standings.sort_custom(func(a, b):
		if int(a["pts"]) != int(b["pts"]):
			return int(a["pts"]) > int(b["pts"])
		if int(a["dg"]) != int(b["dg"]):
			return int(a["dg"]) > int(b["dg"])
		if int(a["gf"]) != int(b["gf"]):
			return int(a["gf"]) > int(b["gf"])
		return String(a["name"]).naturalnocasecmp_to(String(b["name"])) < 0
	)

	league_match_result_applied = true
	post_match_state = "SHOW_RESULTS"

func _update_copa_data() -> void:
	all_match_results.clear()

	if copa_round_index < 0 or copa_round_index >= copa_rounds.size():
		return

	var current_round = copa_rounds[copa_round_index]
	var winners: Array[String] = []
	var player_match_found := false
	var player_won_match := false

	for m in current_round["matches"]:
		var h_score: int = 0
		var a_score: int = 0
		var winner_team := ""

		if m["is_player_match"]:
			player_match_found = true

			var player_score: int = home_score
			var opponent_score: int = away_score
			var player_is_home := String(m["home"]) == player_team_name

			if player_is_home:
				h_score = player_score
				a_score = opponent_score
				winner_team = String(m["home"]) if player_score > opponent_score else String(m["away"])
			else:
				h_score = opponent_score
				a_score = player_score
				winner_team = String(m["home"]) if opponent_score > player_score else String(m["away"])

			all_match_results.append({
				"home": m["home"],
				"away": m["away"],
				"hg": h_score,
				"ag": a_score
			})

			player_won_match = winner_team == player_team_name
		else:
			h_score = randi_range(0, 3)
			a_score = randi_range(0, 3)

			if h_score == a_score:
				a_score += 1

			all_match_results.append({
				"home": m["home"],
				"away": m["away"],
				"hg": h_score,
				"ag": a_score
			})

			winner_team = String(m["home"]) if h_score > a_score else String(m["away"])

		winners.append(winner_team)

	if player_match_found and not player_won_match:
		copa_player_eliminated = true
		champion_team_name = ""
		post_match_state = "SHOW_RESULTS"
		return

	var next_round_idx := copa_round_index + 1
	if next_round_idx >= copa_rounds.size() and winners.size() > 0:
		champion_team_name = winners[0]

	if next_round_idx < copa_rounds.size():
		var next_matches: Array[Dictionary] = []
		for i in range(0, winners.size(), 2):
			if i + 1 < winners.size():
				var h := winners[i]
				var a := winners[i + 1]
				next_matches.append({
					"home": h,
					"away": a,
					"is_player_match": (h == player_team_name or a == player_team_name)
				})
		copa_rounds[next_round_idx]["matches"] = next_matches

	post_match_state = "SHOW_RESULTS"

func _apply_match_result(team_name: String, gf: int, gc: int) -> void:
	for team in standings:
		if String(team["name"]) != team_name:
			continue

		var goals_for: int = gf
		var goals_against: int = gc

		team["pj"] = int(team["pj"]) + 1
		team["gf"] = int(team["gf"]) + goals_for
		team["gc"] = int(team["gc"]) + goals_against
		team["dg"] = int(team["gf"]) - int(team["gc"])

		var res_char := "D"

		if goals_for > goals_against:
			team["pts"] = int(team["pts"]) + 3
			team["pg"] = int(team["pg"]) + 1
			res_char = "W"
		elif goals_for == goals_against:
			team["pts"] = int(team["pts"]) + 1
			team["pe"] = int(team["pe"]) + 1
			res_char = "D"
		else:
			team["pp"] = int(team["pp"]) + 1
			res_char = "L"

		var recent: Array = team["recent"]
		recent.append(res_char)
		while recent.size() > 5:
			recent.pop_front()

		team["recent"] = recent
		return

func _update_cooldowns(delta: float) -> void:
	if pass_cooldown > 0.0: pass_cooldown -= delta
	if shot_cooldown > 0.0: shot_cooldown -= delta
	if switch_cooldown > 0.0: switch_cooldown -= delta
	if ai_shot_cooldown > 0.0: ai_shot_cooldown -= delta
	if tackle_cooldown > 0.0: tackle_cooldown -= delta

func _switch_to_nearest_player() -> void:
	if home_players.is_empty():
		return
	var best_player: int = selected_player
	var best_distance: float = INF
	for i in range(home_players.size()):
		if i == selected_player:
			continue
		var distance_to_ball: float = home_players[i].distance_to(ball_position)
		if distance_to_ball < best_distance:
			best_distance = distance_to_ball
			best_player = i
	selected_player = best_player
	player_position = home_players[selected_player]
	switch_cooldown = 0.25

func _check_player_switch() -> void:
	if not Input.is_key_pressed(KEY_SPACE) or switch_cooldown > 0.0:
		return
	_switch_to_nearest_player()

func _move_player(delta: float) -> void:
	if home_players.size() == 0: return

	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): direction.y -= 1.0
	if Input.is_key_pressed(KEY_S): direction.y += 1.0
	if Input.is_key_pressed(KEY_A): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D): direction.x += 1.0

	if touch_joystick_active and touch_dir.length() > 0.1:
		direction = touch_dir

	if direction.length() > 0.0:
		direction = direction.normalized()
		last_direction = direction
		var speed := SPRINT_SPEED if Input.is_key_pressed(KEY_SHIFT) else PLAYER_SPEED
		player_position += direction * speed * delta

	player_position.x = clamp(player_position.x, FIELD_LEFT - 40.0, FIELD_RIGHT + 40.0)
	player_position.y = clamp(player_position.y, FIELD_TOP - 30.0, FIELD_BOTTOM + 30.0)
	
	if selected_player < home_players.size():
		home_players[selected_player] = player_position

func _update_ai_positioning(delta: float) -> void:
	for i in range(home_players.size()):
		if i == selected_player:
			continue
		if i >= home_targets.size():
			continue
		var home_target: Vector2 = home_targets[i]
		var home_attacks_right: bool = (player_starts_left != is_second_half)
		var home_attack_direction: float = 1.0 if home_attacks_right else -1.0
		var ball_progress: float = (ball_position.x - FIELD_LEFT) / (FIELD_RIGHT - FIELD_LEFT)
		var role_offset: float = float(i % 3 - 1) * 32.0
		if ball_owned and ball_owner_team == "home":
			# Apoyo ofensivo dinámico: escalonamiento, desmarques y amplitud.
			home_target.x += home_attack_direction * (65.0 + ball_progress * 35.0)
			home_target.y += clamp((ball_position.y - home_target.y) * 0.30, -95.0, 95.0)
			home_target.y += role_offset
			if home_players[i].distance_to(ball_position) < 175.0:
				home_target.x -= home_attack_direction * 45.0
				home_target.y += -38.0 if home_players[i].y > ball_position.y else 38.0
		elif not ball_owned or ball_owner_team == "away":
			# Bloque defensivo que bascula hacia el balón sin amontonarse.
			var shift_x: float = clamp((ball_position.x - home_target.x) * 0.22, -115.0, 115.0)
			var shift_y: float = clamp((ball_position.y - home_target.y) * 0.28, -100.0, 100.0)
			home_target += Vector2(shift_x, shift_y)
			if home_players[i].distance_to(ball_position) < 245.0:
				home_target = home_target.move_toward(ball_position, 65.0)
		home_target.x = clamp(home_target.x, FIELD_LEFT + 15.0, FIELD_RIGHT - 15.0)
		home_target.y = clamp(home_target.y, FIELD_TOP + 15.0, FIELD_BOTTOM - 15.0)
		home_players[i] = home_players[i].move_toward(home_target, POSITION_SPEED * delta)

	if away_players.is_empty(): return
	var closest_red := 0
	var closest_distance := INF
	for i in range(away_players.size()):
		var distance: float = away_players[i].distance_to(ball_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_red = i

	var is_dark_ai := game_mode == "PELICULA" and movie_phase == "MATCH"

	if tackle_cooldown <= 0.0 and ball_owned:
		if ball_owner_team == "home" and closest_distance < 28.0:
			var foul_prob := 0.10
			if league_campaign_type == "ASICOP":
				foul_prob = 0.25
			if is_dark_ai:
				foul_prob = 0.02
			if randf() < foul_prob:
				_trigger_foul(player_position, "home")
				return
			ball_owner_team = "away"
			last_touch_team = "away"
			red_carrier_index = closest_red
			tackle_cooldown = 0.5

	for i in range(away_players.size()):
		var target: Vector2
		var speed := RED_SPEED
		
		if is_dark_ai:
			speed *= 1.45

		if league_campaign_type == "ASICOP":
			speed *= 1.25

		if ball_owned and ball_owner_team == "away" and i == red_carrier_index:
			# El rival siempre ataca el arco contrario al propio, incluso tras el cambio de lado.
			var home_attacks_right: bool = (player_starts_left != is_second_half)
			var attack_x: float = FIELD_LEFT - 12.0 if home_attacks_right else FIELD_RIGHT + 12.0
			var attack_y: float = clamp(GOAL_CENTER_Y + (ball_position.y - GOAL_CENTER_Y) * 0.12, GOAL_TOP_Y + 8.0, GOAL_BOTTOM_Y - 8.0)
			target = Vector2(attack_x, attack_y)
			speed = RED_ATTACK_SPEED * (1.35 if is_dark_ai else 1.0)

			var should_shoot: bool = (away_players[i].x < FIELD_LEFT + 390.0) if home_attacks_right else (away_players[i].x > FIELD_RIGHT - 390.0)
			if is_dark_ai and ai_shot_cooldown <= 0.0 and randf() < 0.05:
				_ai_pass(away_players[i], i)
			elif should_shoot and ai_shot_cooldown <= 0.0:
				_ai_shoot(away_players[i])

		elif not ball_owned or ball_owner_team == "home":
			if i == closest_red and closest_distance < RED_CHASE_DISTANCE * 1.8:
				target = ball_position + Vector2(0.0, sign(away_players[i].y - ball_position.y) * 14.0)
			else:
				target = away_targets[i] if i < away_targets.size() else away_players[i]
				# El bloque rival acompaña la jugada y mantiene distancias entre compañeros.
				var away_attacks_right: bool = not (player_starts_left != is_second_half)
				var away_dir: float = 1.0 if away_attacks_right else -1.0
				if ball_owned and ball_owner_team == "home":
					target.x += clamp((ball_position.x - target.x) * 0.18, -85.0, 85.0)
					target.y += clamp((ball_position.y - target.y) * 0.22, -75.0, 75.0)
					if i % 3 == 0:
						target.x -= away_dir * 35.0
				speed = RED_RETURN_SPEED
		else:
			target = away_targets[i] if i < away_targets.size() else away_players[i]
			speed = RED_RETURN_SPEED

		target.x = clamp(target.x, FIELD_LEFT + 12.0, FIELD_RIGHT - 12.0)
		target.y = clamp(target.y, FIELD_TOP + 12.0, FIELD_BOTTOM - 12.0)
		# Evita que todos converjan en un único punto y produce desplazamiento continuo.
		var separation := Vector2.ZERO
		for j in range(away_players.size()):
			if j == i:
				continue
			var diff: Vector2 = away_players[i] - away_players[j]
			var dist: float = diff.length()
			if dist > 0.1 and dist <  30.0:
				separation += diff.normalized() * (30.0 - dist) * 0.8
		target += separation
		away_players[i] = away_players[i].move_toward(target, speed * delta)

func _ai_pass(from_pos: Vector2, from_index: int) -> void:
	if away_players.size() < 2:
		return
	var target_index := (from_index + randi_range(1, max(1, away_players.size() - 1))) % away_players.size()
	var target: Vector2 = away_players[target_index]
	ball_owned = false
	red_carrier_index = -1
	last_touch_team = "away"
	ball_velocity = (target - from_pos).normalized() * PASS_SPEED * 1.15
	ai_shot_cooldown = 0.35
	_stat_add("passes", "away")

func _update_referee(delta: float) -> void:
	if is_mate_referee:
		return

	referee_position = referee_position.move_toward(ball_position, 95.0 * delta)
	referee_position.x = clamp(referee_position.x, FIELD_LEFT + 20.0, FIELD_RIGHT - 20.0)
	referee_position.y = clamp(referee_position.y, FIELD_TOP + 10.0, FIELD_BOTTOM - 10.0)

func _ai_shoot(shooter_pos: Vector2) -> void:
	_stat_add("shots", "away")
	ball_owned = false
	red_carrier_index = -1
	ai_shot_cooldown = 1.2
	last_touch_team = "away"
	var home_attacks_right: bool = (player_starts_left != is_second_half)
	var target_x: float = FIELD_LEFT - 10.0 if home_attacks_right else FIELD_RIGHT + 10.0
	var target_y: float = randf_range(GOAL_TOP_Y + 3.0, GOAL_BOTTOM_Y - 3.0)
	var shoot_dir := (Vector2(target_x, target_y) - shooter_pos).normalized()
	ball_velocity = shoot_dir * SHOT_SPEED

func _update_ball(delta: float) -> void:
	if ball_owned:
		if ball_owner_team == "home":
			ball_position = player_position + last_direction * 23.0
			if Input.is_key_pressed(KEY_J): _pass_ball()
			elif Input.is_key_pressed(KEY_K): _shoot_ball()
		else:
			if red_carrier_index != -1 and red_carrier_index < away_players.size():
				var offset_x := -15.0 if not is_second_half else 15.0
				ball_position = away_players[red_carrier_index] + Vector2(offset_x, 0)
	else:
		ball_position += ball_velocity * delta
		ball_velocity = ball_velocity.move_toward(Vector2.ZERO, 650.0 * delta)

		if home_players.size() > 0 and ball_position.distance_to(player_position) < 30.0:
			ball_owned = true
			ball_owner_team = "home"
			last_touch_team = "home"
			red_carrier_index = -1
		else:
			for i in range(away_players.size()):
				if ball_position.distance_to(away_players[i]) < 25.0:
					ball_owned = true
					ball_owner_team = "away"
					last_touch_team = "away"
					red_carrier_index = i
					break

func _pass_ball() -> void:
	if not ball_owned or ball_owner_team != "home" or pass_cooldown > 0.0: return
	_stat_add("passes", "home")
	ball_owned = false
	last_touch_team = "home"
	ball_velocity = last_direction * PASS_SPEED
	pass_cooldown = 0.25

func _shoot_ball() -> void:
	if not ball_owned or ball_owner_team != "home" or shot_cooldown > 0.0: return
	_stat_add("shots", "home")
	ball_owned = false
	last_touch_team = "home"
	ball_velocity = last_direction * SHOT_SPEED
	shot_cooldown = 0.35

func _home_scores() -> void:
	home_score += 1
	pending_kickoff_team = "away"
	last_scoring_team = player_team_name
	_trigger_goal_celebration()

func _away_scores() -> void:
	away_score += 1
	pending_kickoff_team = "home"
	last_scoring_team = _get_current_opponent()
	_trigger_goal_celebration()

func _reset_after_goal(team_to_kick_off: String) -> void:
	ball_velocity = Vector2.ZERO
	ball_owned = true
	ball_owner_team = team_to_kick_off
	last_touch_team = team_to_kick_off
	_setup_formations()
	if home_players.size() > 0:
		selected_player = clamp(selected_player, 0, home_players.size() - 1)
		player_position = Vector2(640, 360)
		home_players[selected_player] = player_position
	ball_position = Vector2(640, 360)
	if team_to_kick_off == "away" and away_players.size() > 0:
		red_carrier_index = min(5, away_players.size() - 1)
		away_players[red_carrier_index] = Vector2(640, 360)
	else:
		red_carrier_index = -1

func _start_penalties() -> void:
	if game_mode != "COPA":
		return
	game_state = "PENALTIES"
	penalty_turn = 0
	home_penalties = 0
	away_penalties = 0
	_setup_penalty_turn()

func _setup_penalty_turn() -> void:
	penalty_state = "AIMING"
	penalty_shooter = "home" if penalty_turn % 2 == 0 else "away"
	penalty_target_y = GOAL_CENTER_Y
	var target_goal_x := FIELD_RIGHT
	var penalty_spot_x := FIELD_RIGHT - 160.0
	ball_position = Vector2(penalty_spot_x, GOAL_CENTER_Y)
	ball_velocity = Vector2.ZERO
	penalty_kicker_pos = ball_position + Vector2(-25.0, 0)
	penalty_keeper_user_y = GOAL_CENTER_Y
	penalty_keeper_pos = Vector2(target_goal_x, penalty_keeper_user_y)
	penalty_ai_wait = 0.0

func _process_penalties(delta: float) -> void:
	if game_mode != "COPA":
		game_state = "PLAYING"
		return

	if penalty_state == "AIMING":
		if penalty_shooter == "away":
			var keeper_dir := 0.0
			if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or touch_dir.y < -0.3:
				keeper_dir -= 1.0
			if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or touch_dir.y > 0.3:
				keeper_dir += 1.0
			penalty_keeper_user_y = clamp(penalty_keeper_user_y + keeper_dir * 250.0 * delta, GOAL_TOP_Y + 8.0, GOAL_BOTTOM_Y - 8.0)
			penalty_keeper_pos.y = penalty_keeper_user_y
			penalty_ai_wait += delta
			if penalty_ai_wait >= 0.8:
				_execute_penalty(Vector2(FIELD_RIGHT, randf_range(GOAL_TOP_Y + 5.0, GOAL_BOTTOM_Y - 5.0)))
		else:
			penalty_target_y += aim_direction * 120.0 * delta
			if penalty_target_y > GOAL_BOTTOM_Y - 10.0:
				aim_direction = -1
			elif penalty_target_y < GOAL_TOP_Y + 10.0:
				aim_direction = 1
			ball_position = penalty_kicker_pos + Vector2(25.0, 0)
			if Input.is_key_pressed(KEY_K):
				_execute_penalty(Vector2(FIELD_RIGHT, penalty_target_y))

	elif penalty_state == "KICKED":
		ball_position += ball_velocity * delta
		if penalty_shooter == "away":
			var keeper_dir := 0.0
			if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or touch_dir.y < -0.3:
				keeper_dir -= 1.0
			if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or touch_dir.y > 0.3:
				keeper_dir += 1.0
			penalty_keeper_user_y = clamp(penalty_keeper_user_y + keeper_dir * 250.0 * delta, GOAL_TOP_Y + 8.0, GOAL_BOTTOM_Y - 8.0)
			penalty_keeper_pos.y = penalty_keeper_user_y
		else:
			penalty_keeper_pos.y = move_toward(penalty_keeper_pos.y, penalty_target_y, 190.0 * delta)

		if ball_position.x >= FIELD_RIGHT:
			penalty_state = "FINISHED"
			var saved := penalty_keeper_pos.distance_to(ball_position) < 22.0
			var is_goal := not saved and ball_position.y >= GOAL_TOP_Y and ball_position.y <= GOAL_BOTTOM_Y
			if is_goal:
				if penalty_shooter == "home":
					home_penalties += 1
					last_scoring_team = player_team_name
				else:
					away_penalties += 1
					last_scoring_team = _get_current_opponent()
				_trigger_goal_celebration() if is_goal else _advance_penalty_turn()

	elif penalty_state == "FINISHED" and not celebration_active:
		_advance_penalty_turn()

func _execute_penalty(target: Vector2) -> void:
	penalty_state = "KICKED"
	penalty_target_y = target.y
	ball_velocity = (target - ball_position).normalized() * SHOT_SPEED

func _advance_penalty_turn() -> void:
	penalty_turn += 1
	if penalty_turn >= 10:
		if home_penalties != away_penalties or penalty_turn >= 22:
			_finish_penalties()
			return
	_setup_penalty_turn()

func _finish_penalties() -> void:
	if home_penalties > away_penalties:
		home_score += 1
		_calculate_end_game()
	elif away_penalties > home_penalties:
		away_score += 1
		copa_player_eliminated = true
		_calculate_end_game()

func _draw() -> void:
	draw_set_transform(camera_offset, 0.0, Vector2.ONE)
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#0a0a0c"))
	
	if game_state == "COIN_TOSS":
		_draw_coin_toss()
		return

	if game_state == "MENU":
		_draw_main_menu()
		return

	if game_state == "MOVIE":
		_draw_movie()
		return

	if game_state == "MATCH_PAUSE":
		_draw_match_pause()
		return

	if game_state == "MOVIE_MENU":
		_draw_movie_menu()
		return

	if game_state == "SELECT_CAMPAIGN":
		_draw_select_campaign_menu()
		return

	if game_state == "SELECT_FORMATION":
		_draw_formation_selection()
		return

	if game_state == "FIXTURE_SCREEN":
		_draw_fixture_screen()
		return

	if game_state == "SEASON_EVENT":
		_draw_season_event_banner()
		return

	if game_state == "CHAMPION_SCREEN":
		_draw_champion_screen()
		return

	if game_state == "CHAMPIONS_HISTORY":
		_draw_champions_history_screen()
		return

	if game_state == "GAME_OVER":
		_draw_game_over_screen()
		return

	var is_dark_field := false
	if game_mode == "PELICULA":
		if movie_phase == "MATCH" and not movie_intro_match:
			is_dark_field = true
		elif movie_phase == "FINAL_MATCH" or movie_phase == "KELPERS_MATCH":
			is_dark_field = true
	
	_draw_field(is_dark_field)
	_draw_goals()

	if game_state == "PENALTIES":
		_draw_player(penalty_kicker_pos, player_team_pattern if penalty_shooter == "home" else "solid", player_team_colors if penalty_shooter == "home" else [Color("#df4141")], true, false)
		_draw_player(penalty_keeper_pos, "solid", player_team_colors, false, false)
		if penalty_state == "AIMING" and penalty_shooter == "home":
			draw_line(ball_position, Vector2(FIELD_RIGHT, penalty_target_y), Color(1, 1, 0, 0.5), 2.0)
		elif penalty_shooter == "away":
			draw_string(ThemeDB.fallback_font, Vector2(250, 560), "[W/S o ↑/↓] CONTROLAR ARQUERO", HORIZONTAL_ALIGNMENT_CENTER, 780, 18, Color("#fff02f"))
	else:
		var is_dark_team := game_mode == "PELICULA" and movie_phase == "MATCH" and not movie_intro_match
		
		for i in range(home_players.size()):
			_draw_player(home_players[i], player_team_pattern, player_team_colors, i == selected_player, false)
		
		var current_opponent = _get_current_opponent()
		var away_pattern = "solid"
		var away_colors = [Color("#df4141")]
		
		for team_dict in active_color_options:
			if team_dict["name"] == current_opponent:
				away_pattern = team_dict["pattern"]
				away_colors = team_dict["colors"]
				break

		for i in range(away_players.size()):
			_draw_player(away_players[i], away_pattern, away_colors, false, is_dark_team)

		_draw_referee(referee_position)

	_draw_ball()
	_draw_hud()
	_draw_stamina_pulse_bar()
	_draw_confetti()
	_draw_tackle_power_bar()
	_draw_touch_controls()
	_draw_controls_bar()
	if formation_notice_timer > 0.0 and game_state == "PLAYING":
		var notice_rect := Rect2(Vector2(390, 92), Vector2(500, 58))
		draw_rect(notice_rect, Color(0.02, 0.04, 0.07, 0.88), true)
		draw_rect(notice_rect, Color("#fff02f"), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(410, 116), "EL RIVAL JUEGA " + opponent_formation, HORIZONTAL_ALIGNMENT_LEFT, 460, 22, Color("#fff02f"))
		draw_string(ThemeDB.fallback_font, Vector2(410, 139), _get_current_opponent(), HORIZONTAL_ALIGNMENT_LEFT, 460, 15, Color.WHITE)

	for i in range(home_players.size()):
		if i < player_stars.size() and player_stars[i] > 0:
			var star_pos: Vector2 = home_players[i] + Vector2(0, -40)
			var star_color := Color("#cd7f32")
			if player_stars[i] >= 10:
				star_color = Color("#ffd700")
			elif player_stars[i] >= 6:
				star_color = Color("#c0c0c0")
			
			var star_fill := PackedVector2Array()
			for j in range(10):
				var a := -PI / 2.0 + j * PI / 5.0
				var radius := 12.0 if j % 2 == 0 else 5.0
				star_fill.append(star_pos + Vector2(cos(a), sin(a)) * radius)
			draw_colored_polygon(star_fill, star_color)
			
			draw_string(ThemeDB.fallback_font, star_pos + Vector2(-5, 4), str(player_stars[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.BLACK)

	if game_state == "HALF_TIME_BANNER":
		_draw_half_time_banner()

	if celebration_active:
		_draw_fileteado_porteño_goal()

	if game_state == "SELECT_COLOR": 
		_draw_select_color_menu()
	elif game_state == "STANDINGS": 
		_draw_standings_table(Vector2(80, 70), Vector2(1120, 520))
	elif game_state == "POST_MATCH_TRANSITION":
		if show_match_results_screen:
			_draw_match_results_screen()
		else:
			_draw_post_match_notification()
	elif game_state == "PENALTIES": 
		_draw_penalties_ui()

func _draw_formation_selection() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#0a0f16"), true)
	draw_string(ThemeDB.fallback_font, Vector2(360, 100), "ELEGÍ TU FORMACIÓN", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#fff02f"))
	draw_string(ThemeDB.fallback_font, Vector2(360, 138), "Equipo: " + player_team_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	for i in range(FORMATION_NAMES.size()):
		var rect := Rect2(Vector2(330, 190 + i * 72), Vector2(620, 56))
		var chosen: bool = selected_formation == FORMATION_NAMES[i]
		draw_rect(rect, Color("#25465c") if chosen else Color("#17212b"), true)
		draw_rect(rect, Color("#fff02f") if chosen else Color("#607080"), false, 2.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 36), str(i + 1) + "   " + FORMATION_NAMES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#fff02f") if chosen else Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(330, 570), "Tocá una opción o presioná 1–5; ENTER para confirmar", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b8c6d4"))

func _draw_touch_controls() -> void:
	if DisplayServer.is_touchscreen_available() or touch_joystick_active or OS.has_feature("mobile"):
		var base_center = touch_joystick_center if touch_joystick_active else Vector2(160, 560)
		var knob_center = touch_joystick_pos if touch_joystick_active else base_center
		draw_circle(base_center, 60.0, Color(1, 1, 1, 0.15))
		draw_arc(base_center, 60.0, 0, TAU, 32, Color(1, 1, 1, 0.4), 2.0)
		draw_circle(knob_center, 25.0, Color(1, 1, 1, 0.4))
		
		_draw_touch_button(btn_pass_rect, "PASE\n(J)", Color("#fff02f"))
		_draw_touch_button(btn_shot_rect, "TIRO\n(K)", Color("#ff4444"))
		_draw_touch_button(btn_switch_rect, "CAMBIO\n(ESP)", Color("#75d6ff"))
		_draw_touch_button(btn_tackle_rect, "TACKLE\n(L)", Color("#38b000"))

func _draw_touch_button(rect: Rect2, label: String, color: Color) -> void:
	draw_rect(rect, Color(0, 0, 0, 0.4), true)
	draw_rect(rect, color, false, 2.0)
	draw_multiline_string(ThemeDB.fallback_font, rect.position + Vector2(0, 26), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 14, -1, color)

func _draw_coin_toss() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#05070a"), true)
	var panel := Rect2(Vector2(280, 180), Vector2(720, 360))
	draw_rect(panel, Color("#0e131d"), true)
	draw_rect(panel, Color("#d4af37"), false, 4.0)

	if coin_toss_phase == "TOSSING":
		draw_string(ThemeDB.fallback_font, Vector2(640, 250), "SORTEO INICIAL", HORIZONTAL_ALIGNMENT_CENTER, 720, 40, Color("#fff02f"))
		draw_string(ThemeDB.fallback_font, Vector2(640, 310), "Lanzando la moneda...", HORIZONTAL_ALIGNMENT_CENTER, 720, 24, Color("#75d6ff"))
	elif coin_toss_phase == "CHOOSING":
		draw_string(ThemeDB.fallback_font, Vector2(640, 230), "¡GANASTE EL SORTEO!", HORIZONTAL_ALIGNMENT_CENTER, 720, 34, Color("#55dd77"))
		draw_string(ThemeDB.fallback_font, Vector2(640, 290), "Elegí de qué lado querés empezar", HORIZONTAL_ALIGNMENT_CENTER, 720, 24, Color("#ffffff"))
		draw_string(ThemeDB.fallback_font, Vector2(640, 350), "[A / ←] IZQUIERDA      [D / →] DERECHA", HORIZONTAL_ALIGNMENT_CENTER, 720, 22, Color("#fff02f"))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(640, 250), "PERDISTE EL SORTEO", HORIZONTAL_ALIGNMENT_CENTER, 720, 34, Color("#ff5555"))
		draw_string(ThemeDB.fallback_font, Vector2(640, 310), "El rival eligió el lado.", HORIZONTAL_ALIGNMENT_CENTER, 720, 22, Color("#ffffff"))

func _draw_champions_history_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#07080c"), true)

	var panel_rect := Rect2(Vector2(260, 70), Vector2(760, 580))
	draw_rect(panel_rect, Color("#0e131d"), true)
	draw_rect(panel_rect, Color("#d4af37"), false, 4.0)
	draw_rect(Rect2(panel_rect.position + Vector2(7, 7), panel_rect.size - Vector2(14, 14)), Color("#75d6ff"), false, 1.5)

	draw_string(ThemeDB.fallback_font, Vector2(320, 125), "REGISTRO DE CAMPEONES", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("#d4af37"))
	draw_string(ThemeDB.fallback_font, Vector2(320, 155), "Historial de las competiciones disputadas", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

	var history := _get_champions_history_for_display()
	if history.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(640, 340), "Todavía no hay campeones registrados.", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.LIGHT_GRAY)
	else:
		var y := 205.0
		var edition := history.size()
		for entry in history:
			if y > 570.0:
				break
			var competition := String(entry.get("competition", ""))
			var division := String(entry.get("division", ""))
			var champion := String(entry.get("champion", ""))
			var label := competition + " - " + division if not division.is_empty() else competition
			draw_string(ThemeDB.fallback_font, Vector2(330, y), "#" + str(edition), HORIZONTAL_ALIGNMENT_LEFT, 70, 16, Color("#75d6ff"))
			draw_string(ThemeDB.fallback_font, Vector2(410, y), label, HORIZONTAL_ALIGNMENT_LEFT, 220, 16, Color.WHITE)
			draw_string(ThemeDB.fallback_font, Vector2(650, y), champion, HORIZONTAL_ALIGNMENT_LEFT, 300, 18, Color("#fff02f"))
			edition -= 1
			y += 45.0

	draw_string(ThemeDB.fallback_font, Vector2(640, 615), "ENTER / ESC / TOCA: VOLVER AL MENÚ", HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color("#75d6ff"))

func _draw_game_over_screen() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#07080c"), true)

	var panel_rect := Rect2(Vector2(300, 170), Vector2(680, 360))
	draw_rect(panel_rect, Color("#0e131d"), true)
	draw_rect(panel_rect, Color("#ff4444"), false, 5.0)

	draw_string(ThemeDB.fallback_font, Vector2(640, 270), "¡ELIMINADO DE LA COPA!", HORIZONTAL_ALIGNMENT_CENTER, -1, 36, Color("#ff4444"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 330), "Has perdido tu encuentro eliminatorio.", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(640, 405), "La competencia ha terminado para tu equipo.", HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.LIGHT_GRAY)
	draw_string(ThemeDB.fallback_font, Vector2(640, 475), "Presiona ENTER o toca para volver al menú", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color("#fff02f"))

func _draw_main_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#07080c"))
	
	if title_texture:
		var img_rect := Rect2(Vector2(390, 20), Vector2(500, 380))
		draw_texture_rect(title_texture, img_rect, false)
	else:
		_draw_fileteado_porteño_logo_fallback()

	var panel_rect := Rect2(Vector2(440, 360), Vector2(400, 330))
	draw_rect(panel_rect, Color("#0e131d"), true)
	draw_rect(panel_rect, Color("#d4af37"), false, 3.0)
	draw_rect(Rect2(panel_rect.position + Vector2(4, 4), panel_rect.size - Vector2(8, 8)), Color("#75d6ff"), false, 1.5)

	_draw_filete_spiral(Vector2(panel_rect.position.x + 15, panel_rect.position.y + 15), 1.0, 1.0)
	_draw_filete_spiral(Vector2(panel_rect.end.x - 15, panel_rect.position.y + 15), -1.0, 1.0)
	_draw_filete_spiral(Vector2(panel_rect.position.x + 15, panel_rect.end.y - 15), 1.0, -1.0)
	_draw_filete_spiral(Vector2(panel_rect.end.x - 15, panel_rect.end.y - 15), -1.0, -1.0)

	var opt1_rect := Rect2(Vector2(470, 385), Vector2(340, 55))
	draw_rect(opt1_rect, Color("#151d2a"), true)
	draw_rect(opt1_rect, Color("#d4af37"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(490, 428), "[1] LIGA", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff02f"))

	var opt2_rect := Rect2(Vector2(470, 450), Vector2(340, 55))
	draw_rect(opt2_rect, Color("#151d2a"), true)
	draw_rect(opt2_rect, Color("#d4af37"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(490, 493), "[2] COPA", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff02f"))

	var opt3_rect := Rect2(Vector2(470, 515), Vector2(340, 55))
	draw_rect(opt3_rect, Color("#151d2a"), true)
	draw_rect(opt3_rect, Color("#d4af37"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(490, 558), "[3] REGISTRO DE CAMPEONES", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff02f"))

	var opt4_rect := Rect2(Vector2(470, 580), Vector2(340, 55))
	draw_rect(opt4_rect, Color("#151d2a"), true)
	draw_rect(opt4_rect, Color("#d4af37"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(490, 618), "[4] HISTORIA: LA INVASIÓN", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ff3333"))

	draw_string(ThemeDB.fallback_font, Vector2(470, 665), "SELECCIONA TOCANDO LA OPCIÓN", HORIZONTAL_ALIGNMENT_CENTER, 340, 14, Color("#75d6ff"))

func _draw_movie_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#05070a"), true)
	var panel := Rect2(Vector2(330, 150), Vector2(620, 420))
	draw_rect(panel, Color("#0e131d"), true)
	draw_rect(panel, MOVIE_RED, false, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(330, 210), "HISTORIA: LA INVASIÓN", HORIZONTAL_ALIGNMENT_CENTER, 620, 38, MOVIE_RED)

	var opt1_rect := Rect2(Vector2(330, 250), Vector2(620, 50))
	draw_rect(opt1_rect, Color("#151d2a"), true)
	draw_string(ThemeDB.fallback_font, Vector2(330, 283), "[1] NUEVA PARTIDA", HORIZONTAL_ALIGNMENT_CENTER, 620, 22, MOVIE_CYAN)

	var opt2_rect := Rect2(Vector2(330, 310), Vector2(620, 50))
	draw_rect(opt2_rect, Color("#151d2a"), true)
	draw_string(ThemeDB.fallback_font, Vector2(330, 343), "[2] CARGAR PARTIDA", HORIZONTAL_ALIGNMENT_CENTER, 620, 22, Color.WHITE)

	var opt3_rect := Rect2(Vector2(330, 370), Vector2(620, 50))
	draw_rect(opt3_rect, Color("#151d2a"), true)
	draw_string(ThemeDB.fallback_font, Vector2(330, 403), "[ESC] VOLVER", HORIZONTAL_ALIGNMENT_CENTER, 620, 16, Color("#888a8f"))

	draw_string(ThemeDB.fallback_font, Vector2(330, 510), "LOS ADORADORES DE LA ESTRELLA", HORIZONTAL_ALIGNMENT_CENTER, 620, 18, Color("#77797d"))

func _draw_select_campaign_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#07080c"))
	var menu_rect := Rect2(Vector2(290, 90), Vector2(700, 540))
	draw_rect(menu_rect, Color("#0e131d"), true)
	draw_rect(menu_rect, Color("#d4af37"), false, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(330, 140), "LIGA", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#75d6ff"))

	var opt1_rect := Rect2(Vector2(330, 190), Vector2(620, 80))
	draw_rect(opt1_rect, Color("#151d2a"), true)
	draw_rect(opt1_rect, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(340, 220), "[1] ASÍ ES LA VIDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#fff02f"))
	draw_string(ThemeDB.fallback_font, Vector2(340, 250), "Elegí cualquiera de los 64 clubes y comenzá en LIGA A.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#ffffff"))

	var opt2_rect := Rect2(Vector2(330, 285), Vector2(620, 80))
	draw_rect(opt2_rect, Color("#151d2a"), true)
	draw_rect(opt2_rect, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(340, 315), "[2] HAMBRE DE GLORIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#fff02f"))
	draw_string(ThemeDB.fallback_font, Vector2(340, 345), "Elegí cualquiera de los 64 clubes y comenzá en LIGA D.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#ffffff"))

	var opt3_rect := Rect2(Vector2(330, 380), Vector2(620, 80))
	draw_rect(opt3_rect, Color("#151d2a"), true)
	draw_rect(opt3_rect, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(340, 410), "[3] CARGAR PARTIDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#fff02f"))
	draw_string(ThemeDB.fallback_font, Vector2(340, 440), "Retoma la última partida de Liga guardada.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#ffffff"))

	draw_string(ThemeDB.fallback_font, Vector2(330, 530), "CATEGORÍAS: LIGA A → LIGA B → LIGA C → LIGA D", HORIZONTAL_ALIGNMENT_CENTER, 620, 16, Color("#75d6ff"))
	if save_feedback_timer > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(330, 575), save_feedback_text, HORIZONTAL_ALIGNMENT_CENTER, 620, 16, Color("#ff7777"))

func _draw_select_color_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#07080c"))
	if game_mode == "PELICULA":
		draw_string(ThemeDB.fallback_font, Vector2(0, 65), "PELÍCULA — ELEGÍ TU EQUIPO", HORIZONTAL_ALIGNMENT_CENTER, SCREEN_WIDTH, 28, MOVIE_RED)
	var menu_rect := Rect2(Vector2(240, 60), Vector2(800, 600))
	draw_rect(menu_rect, Color("#0e131d"), true)
	draw_rect(menu_rect, Color("#d4af37"), false, 3.0)
	draw_rect(Rect2(menu_rect.position + Vector2(6, 6), menu_rect.size - Vector2(12, 12)), Color("#75d6ff"), false, 1.5)

	draw_string(ThemeDB.fallback_font, Vector2(280, 110), "SELECCIONA TU EQUIPO", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, Vector2(280, 140), "Toca en cualquier club para seleccionar | Toca a los lados para cambiar página", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#fff02f"))

	var page_size := 16
	var page := int(selected_color_idx / page_size)
	var page_start := page * page_size
	var page_end: int = min(page_start + page_size, int(active_color_options.size()))
	draw_string(ThemeDB.fallback_font, Vector2(780, 110), "PÁGINA " + str(page + 1) + "/" + str(ceili(float(active_color_options.size()) / page_size)), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#ffffff"))

	var start_y := 170
	var col_x1 := 280
	var col_x2 := 640
	for i in range(page_start, page_end):
		var local_i := i - page_start
		var team = active_color_options[i]
		var is_selected = (i == selected_color_idx)
		var x = col_x1 if local_i < 8 else col_x2
		var y = start_y + (local_i % 8) * 50
		var item_rect = Rect2(Vector2(x, y), Vector2(340, 42))
		var bg_col = Color("#151d2a") if not is_selected else Color("#223048")
		draw_rect(item_rect, bg_col, true)
		draw_rect(item_rect, Color("#d4af37") if is_selected else Color("#75d6ff", 0.3), false, 2.0 if is_selected else 1.0)
		var text_col = Color("#fff02f") if is_selected else Color("#ffffff")
		draw_string(ThemeDB.fallback_font, Vector2(x + 20, y + 27), str(i + 1) + ". " + String(team["name"]).capitalize(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, text_col)

func _draw_filete_spiral(pos: Vector2, scale_x: float, scale_y: float) -> void:
	draw_arc(pos, 8.0, 0, TAU, 16, Color("#d4af37"), 2.0)
	draw_circle(pos, 3.0, Color("#75d6ff"))

func _draw_season_event_banner() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#07080c"), true)
	var banner_rect := Rect2(Vector2(140, 140), Vector2(1000, 320))
	draw_rect(banner_rect, Color("#07080c"), true)
	draw_rect(banner_rect, Color("#d4af37"), false, 6.0)
	draw_rect(Rect2(banner_rect.position + Vector2(8, 8), banner_rect.size - Vector2(16, 16)), Color("#75d6ff"), false, 3.0)
	var elapsed := SEASON_EVENT_DURATION - season_event_timer
	var letters_to_show := int(clamp(elapsed * 10.0, 1, season_event_text.length()))
	var animated_str := season_event_text.substr(0, letters_to_show)
	var char_spacing := 72.0
	var start_x := 640.0 - (animated_str.length() * char_spacing) / 2.0
	var base_y := 330.0
	var time_val := Time.get_ticks_msec() * 0.008
	var main_color := Color("#ff3333") if season_event_text == "DESCENSO" else Color("#fff02f")
	if season_event_text == "ASCENSO" or season_event_text == "CLASIFICASTE":
		main_color = Color("#55dd77")
	for i in range(animated_str.length()):
		var wave_y := base_y + sin(time_val + i * 0.5) * 14.0
		var pos := Vector2(start_x + i * char_spacing, wave_y)
		draw_string(ThemeDB.fallback_font, pos + Vector2(3, 3), animated_str[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 58, Color("#000000"))
		draw_string(ThemeDB.fallback_font, pos, animated_str[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 58, main_color)
	draw_string(ThemeDB.fallback_font, Vector2(240, 420), "TOCA O PRESIONA [ENTER] PARA CONTINUAR", HORIZONTAL_ALIGNMENT_CENTER, 800, 16, Color("#ffffff"))

func _draw_champion_screen() -> void:
	if champion_bg_texture:
		draw_texture_rect(champion_bg_texture, Rect2(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#0e131d"), true)

	var banner_rect := Rect2(Vector2(340, 140), Vector2(600, 440))
	draw_rect(banner_rect, Color("#07080c"), true)
	draw_rect(banner_rect, Color("#d4af37"), false, 6.0)
	draw_rect(Rect2(banner_rect.position + Vector2(8, 8), banner_rect.size - Vector2(16, 16)), Color("#75d6ff"), false, 3.0)

	_draw_filete_spiral(Vector2(banner_rect.position.x + 30, banner_rect.position.y + 30), 1.0, 1.0)
	_draw_filete_spiral(Vector2(banner_rect.end.x - 30, banner_rect.position.y + 30), -1.0, 1.0)
	_draw_filete_spiral(Vector2(banner_rect.position.x + 30, banner_rect.end.y - 30), 1.0, -1.0)
	_draw_filete_spiral(Vector2(banner_rect.end.x - 30, banner_rect.end.y - 30), -1.0, -1.0)

	draw_string(ThemeDB.fallback_font, Vector2(640, 220), "¡CAMPEÓN!", HORIZONTAL_ALIGNMENT_CENTER, -1, 48, Color.GOLD)

	var champion_name := champion_team_name

	if game_mode == "LIGA":
		if standings.size() > 0:
			champion_name = String(standings[0]["name"])
		var division_text := _division_name(current_division)
		draw_string(ThemeDB.fallback_font, Vector2(640, 280), "¡Gloria eterna en la " + division_text + "!", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.WHITE)
	else:
		draw_string(ThemeDB.fallback_font, Vector2(640, 280), "¡Alzaste la Copa de los 64 Equipos!", HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.WHITE)

	if champion_name.is_empty():
		champion_name = player_team_name

	draw_string(ThemeDB.fallback_font, Vector2(640, 350), champion_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 32, Color("#fff02f"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 460), "Toca la pantalla o presiona ENTER para continuar", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.LIGHT_GRAY)

func _draw_fileteado_porteño_logo_fallback() -> void:
	var center := Vector2(640, 210)
	draw_arc(center, 140.0, 0, TAU, 64, Color("#d4af37"), 6.0)
	draw_arc(center, 125.0, 0, TAU, 64, Color("#75d6ff"), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(490, 215), "JUREMOS CON GLORIA MORIR", HORIZONTAL_ALIGNMENT_CENTER, 300, 20, Color.WHITE)

func _draw_tackle_power_bar() -> void:
	if is_charging_tackle and home_players.size() > 0:
		var valid_sel = clamp(selected_player, 0, home_players.size() - 1)
		var pos: Vector2 = home_players[valid_sel] + Vector2(-25, -35)
		draw_rect(Rect2(pos, Vector2(50, 8)), Color(0, 0, 0, 0.7), true)
		draw_rect(Rect2(pos, Vector2(50 * (tackle_power / 100.0), 8)), Color("#ff4444"), true)
		draw_rect(Rect2(pos, Vector2(50, 8)), Color("#d4af37"), false, 1.0)

func _draw_stamina_pulse_bar() -> void:
	var bar_pos := Vector2(440, 70)
	var bar_size := Vector2(400, 16)
	
	draw_rect(Rect2(bar_pos, bar_size), Color("#0e131d"), true)
	draw_rect(Rect2(bar_pos, bar_size), Color("#d4af37"), false, 1.5)
	
	var fill_w = bar_size.x * (stamina_bar_value / 100.0)
	var main_col = player_team_colors[0] if player_team_colors.size() > 0 else Color("#FF2A6D")
	draw_rect(Rect2(Vector2(bar_pos.x, bar_pos.y + 2), Vector2(fill_w, bar_size.y - 4)), main_col, true)
	
	var freq := 0.2
	for x_offset in range(int(bar_size.x) - 4):
		var px = bar_pos.x + 2 + x_offset
		var py = bar_pos.y + (bar_size.y / 2.0) + sin((x_offset + Time.get_ticks_msec() * freq) * 0.1) * 3.0
		draw_circle(Vector2(px, py), 1.0, Color("#75d6ff", 0.6))

	var heart_center = Vector2(bar_pos.x + bar_size.x / 2.0, bar_pos.y + bar_size.y / 2.0)
	draw_circle(heart_center + Vector2(-3, -2), 4.0, Color("#ff4444"))
	draw_circle(heart_center + Vector2(3, -2), 4.0, Color("#ff4444"))
	
	if accumulated_stars > 0:
		draw_string(ThemeDB.fallback_font, Vector2(bar_pos.x + bar_size.x + 10, bar_pos.y + 13), "★ x" + str(accumulated_stars), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#fff02f"))

func _draw_field(is_dark: bool) -> void:
	var total_w := FIELD_RIGHT - FIELD_LEFT
	var total_h := FIELD_BOTTOM - FIELD_TOP
	var outer_rect := Rect2(Vector2(FIELD_LEFT, FIELD_TOP), Vector2(total_w, total_h))

	if is_dark:
		var band_w := 200.0
		var index := 0
		for x in range(int(FIELD_LEFT - band_w), int(FIELD_RIGHT + band_w), int(band_w)):
			var pts1 := PackedVector2Array([
				Vector2(x, FIELD_TOP),
				Vector2(x + band_w * 0.5, FIELD_TOP + total_h * 0.5),
				Vector2(x + band_w, FIELD_TOP),
				Vector2(x + band_w, FIELD_TOP + 90.0),
				Vector2(x + band_w * 0.5, FIELD_TOP + total_h * 0.5 + 90.0),
				Vector2(x, FIELD_TOP + 90.0)
			])
			var pts2 := PackedVector2Array([
				Vector2(x, FIELD_BOTTOM),
				Vector2(x + band_w * 0.5, FIELD_BOTTOM - total_h * 0.5),
				Vector2(x + band_w, FIELD_BOTTOM),
				Vector2(x + band_w, FIELD_BOTTOM - 90.0),
				Vector2(x + band_w * 0.5, FIELD_BOTTOM - total_h * 0.5 - 90.0),
				Vector2(x, FIELD_BOTTOM - 90.0)
			])
			
			var col: Color = Color("#111111") if index % 2 == 0 else Color("#d9c89f")
			draw_colored_polygon(pts1, col)
			draw_colored_polygon(pts2, col)
			index += 1
		
		draw_rect(outer_rect, Color("#c7c8ca"), false, 4.0)
		draw_line(Vector2(640, FIELD_TOP), Vector2(640, FIELD_BOTTOM), Color("#c7c8ca", 0.35), 2.0)
		draw_arc(Vector2(640, 360), 80.0, 0, TAU, 40, Color("#ffffff", 0.85), 3.0, true)
		_draw_pentagram_star(Vector2(640, 360), 34.0, Color("#ffffff", 0.9))
		draw_rect(Rect2(Vector2(FIELD_LEFT, 210.0), Vector2(140.0, 300.0)), Color("#c7c8ca", 0.28), false, 2.0)
		draw_rect(Rect2(Vector2(FIELD_RIGHT - 140.0, 210.0), Vector2(140.0, 300.0)), Color("#c7c8ca", 0.28), false, 2.0)
		draw_rect(Rect2(Vector2(FIELD_LEFT, 275.0), Vector2(55.0, 170.0)), Color("#c7c8ca", 0.35), false, 2.0)
		draw_rect(Rect2(Vector2(FIELD_RIGHT - 55.0, 275.0), Vector2(55.0, 170.0)), Color("#c7c8ca", 0.35), false, 2.0)
	else:
		var stripe_count := 14
		var stripe_w := total_w / float(stripe_count)
		for i in range(stripe_count):
			var x_start := FIELD_LEFT + (i * stripe_w)
			var col := Color("#142d19") if i % 2 == 0 else Color("#1b3b22")
			draw_rect(Rect2(Vector2(x_start, FIELD_TOP), Vector2(stripe_w, total_h)), col, true)
		draw_rect(outer_rect, Color("#d4af37"), false, 4.0)
		draw_line(Vector2(640, FIELD_TOP), Vector2(640, FIELD_BOTTOM), Color("#ffffff", 0.4), 2.0)
		draw_arc(Vector2(640, 360), 80.0, 0, TAU, 32, Color("#ffffff", 0.4), 2.0, true)
		draw_circle(Vector2(640, 360), 4.0, Color("#ffffff", 0.6), true)
		draw_rect(Rect2(Vector2(FIELD_LEFT, 210.0), Vector2(140.0, 300.0)), Color("#ffffff", 0.35), false, 2.0)
		draw_rect(Rect2(Vector2(FIELD_RIGHT - 140.0, 210.0), Vector2(140.0, 300.0)), Color("#ffffff", 0.35), false, 2.0)
		draw_rect(Rect2(Vector2(FIELD_LEFT, 275.0), Vector2(55.0, 170.0)), Color("#ffffff", 0.45), false, 2.0)
		draw_rect(Rect2(Vector2(FIELD_RIGHT - 55.0, 275.0), Vector2(55.0, 170.0)), Color("#ffffff", 0.45), false, 2.0)
		draw_arc(Vector2(FIELD_LEFT + 4.0, FIELD_TOP + 4.0), 12.0, 0.0, PI / 2.0, 12, Color("#ffffff", 0.45), 2.0, true)
		draw_arc(Vector2(FIELD_LEFT + 4.0, FIELD_BOTTOM - 4.0), 12.0, -PI / 2.0, 0.0, 12, Color("#ffffff", 0.45), 2.0, true)
		draw_arc(Vector2(FIELD_RIGHT - 4.0, FIELD_TOP + 4.0), 12.0, PI / 2.0, PI, 12, Color("#ffffff", 0.45), 2.0, true)
		draw_arc(Vector2(FIELD_RIGHT - 4.0, FIELD_BOTTOM - 4.0), 12.0, PI, 3.0 * PI / 2.0, 12, Color("#ffffff", 0.45), 2.0, true)

func _draw_pentagram_star(center: Vector2, radius: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(5):
		var a := PI / 2.0 + i * TAU / 5.0
		pts.append(center + Vector2(cos(a), sin(a)) * radius)
	var pentagram := PackedVector2Array([pts[0], pts[2], pts[4], pts[1], pts[3], pts[0]])
	draw_polyline(pentagram, color, 2.5, true)

func _draw_goals() -> void:
	draw_rect(Rect2(Vector2(FIELD_LEFT - 35.0, GOAL_TOP_Y), Vector2(35.0, GOAL_BOTTOM_Y - GOAL_TOP_Y)), Color(1, 1, 1, 0.1), true)
	draw_rect(Rect2(Vector2(FIELD_LEFT - 35.0, GOAL_TOP_Y), Vector2(35.0, GOAL_BOTTOM_Y - GOAL_TOP_Y)), Color("#d4af37"), false, 2.0)
	
	draw_rect(Rect2(Vector2(FIELD_RIGHT, GOAL_TOP_Y), Vector2(35.0, GOAL_BOTTOM_Y - GOAL_TOP_Y)), Color(1, 1, 1, 0.1), true)
	draw_rect(Rect2(Vector2(FIELD_RIGHT, GOAL_TOP_Y), Vector2(35.0, GOAL_BOTTOM_Y - GOAL_TOP_Y)), Color("#d4af37"), false, 2.0)

func _draw_player(pos: Vector2, pattern: String, colors: Array, is_selected: bool, is_dark: bool = false) -> void:
	draw_circle(pos + Vector2(0, 8), 10.0, Color(0, 0, 0, 0.6), true)
	
	var r := Rect2(pos - Vector2(7.0, 12.0), Vector2(14.0, 18.0))
	
	if pattern == "solid":
		draw_rect(r, colors[0], true)
	elif pattern == "horizontal_3":
		var h := r.size.y / 3.0
		draw_rect(Rect2(r.position, Vector2(r.size.x, h)), colors[0], true)
		draw_rect(Rect2(r.position + Vector2(0, h), Vector2(r.size.x, h)), colors[1], true)
		draw_rect(Rect2(r.position + Vector2(0, h * 2), Vector2(r.size.x, h)), colors[2], true)
	elif pattern == "diagonal_stripe":
		draw_rect(r, colors[0], true)
		draw_line(Vector2(r.position.x, r.end.y - 2), Vector2(r.end.x, r.position.y + 2), colors[1], 4.0)
	elif pattern == "vertical_stripes":
		var w := r.size.x / 4.0
		for i in range(4):
			var col = colors[0] if i % 2 == 0 else colors[1]
			draw_rect(Rect2(Vector2(r.position.x + i * w, r.position.y), Vector2(w, r.size.y)), col, true)
	elif pattern == "two_blocks_vert":
		var w := r.size.x / 2.0
		draw_rect(Rect2(r.position, Vector2(w, r.size.y)), colors[0], true)
		draw_rect(Rect2(r.position + Vector2(w, 0), Vector2(w, r.size.y)), colors[1], true)
	elif pattern == "velez_v":
		draw_rect(r, colors[0], true) 
		var p1 = r.position + Vector2(2.0, 2.0)
		var p_tip = Vector2(r.position.x + r.size.x / 2.0, r.position.y + r.size.y * 0.7)
		var p2 = Vector2(r.end.x - 2.0, r.position.y + 2.0)
		var v_points := PackedVector2Array([p1, p_tip, p2])
		draw_polyline(v_points, colors[1], 3.0, true)
	elif pattern == "huracan_h":
		draw_rect(r, colors[0], true)
		var h_pos := pos + Vector2(-3, -6)
		draw_line(h_pos, h_pos + Vector2(0, 10), colors[1], 1.5)
		draw_line(h_pos + Vector2(6, 0), h_pos + Vector2(6, 10), colors[1], 1.5)
		draw_line(h_pos + Vector2(0, 5), h_pos + Vector2(6, 5), colors[1], 1.5)
	else:
		draw_rect(r, colors[0], true)

	draw_rect(r, Color("#111111"), false, 1.5)
	
	if is_dark:
		draw_line(pos + Vector2(-5, -22), pos + Vector2(-10, -31), Color("#d90429"), 3.0)
		draw_line(pos + Vector2(5, -22), pos + Vector2(10, -31), Color("#d90429"), 3.0)
		draw_circle(pos + Vector2(-3, -17), 2.5, Color("#ff2222"), true)
		draw_circle(pos + Vector2(3, -17), 2.5, Color("#ff2222"), true)
		draw_circle(pos + Vector2(-3, -17), 1.0, Color("#ffffff"), true)
		draw_circle(pos + Vector2(3, -17), 1.0, Color("#ffffff"), true)
	else:
		draw_circle(pos + Vector2(0.0, -16.0), 6.0, Color("#f5d6b0"), true)
		draw_circle(pos + Vector2(0.0, -16.0), 6.0, Color("#111111"), false, 1.0)

	if is_selected:
		draw_arc(pos, 18.0, 0, TAU, 16, Color("#fff02f"), 2.5, true)
		draw_line(pos + Vector2(0, -26), pos + Vector2(0, -20), Color("#fff02f"), 2.0)

func _draw_referee(pos: Vector2) -> void:
	draw_circle(pos + Vector2(0, 8), 10.0, Color(0, 0, 0, 0.6), true)
	
	if is_diablito_referee:
		var r := Rect2(pos - Vector2(6.0, 11.0), Vector2(12.0, 16.0))
		draw_rect(r, Color("#111111"), true)
		draw_rect(Rect2(pos - Vector2(6.0, -4.0), Vector2(12.0, 3.0)), Color("#ffffff"), true)
		draw_rect(Rect2(pos - Vector2(6.0, 2.0), Vector2(12.0, 3.0)), Color("#ffffff"), true)
		draw_rect(r, Color("#111111"), false, 1.0)
		draw_circle(pos + Vector2(0.0, -15.0), 5.5, Color("#ff3333"), true)
		draw_line(pos + Vector2(-4, -20), pos + Vector2(-8, -28), Color("#ff0000"), 3.0)
		draw_line(pos + Vector2(4, -20), pos + Vector2(8, -28), Color("#ff0000"), 3.0)
		draw_line(pos + Vector2(-5, 5), pos + Vector2(-15, 25), Color("#ff0000"), 2.0)
		draw_line(pos + Vector2(-15, 25), pos + Vector2(-20, 20), Color("#ff0000"), 2.0)
		draw_line(pos + Vector2(-15, 25), pos + Vector2(-10, 30), Color("#ff0000"), 2.0)
	elif is_mate_referee:
		draw_rect(Rect2(pos - Vector2(8.0, 4.0), Vector2(16.0, 12.0)), Color("#ff007f"), true)
		draw_circle(pos + Vector2(0.0, -6.0), 6.0, Color("#f5d6b0"), true)
		draw_rect(Rect2(pos + Vector2(-5.0, -12.0), Vector2(10.0, 4.0)), Color("#00ff66"), true)
		draw_circle(pos + Vector2(12.0, -2.0), 4.0, Color("#8b4513"), true)
		draw_line(pos + Vector2(10.0, -6.0), pos + Vector2(14.0, -6.0), Color("#c0c0c0"), 2.0)
	else:
		var r := Rect2(pos - Vector2(6.0, 11.0), Vector2(12.0, 16.0))
		draw_rect(r, Color("#ff007f"), true)
		draw_rect(r, Color("#111111"), false, 1.0)
		draw_circle(pos + Vector2(0.0, -15.0), 5.5, Color("#f5d6b0"), true)
		var cap_rect := Rect2(pos + Vector2(-5.0, -21.0), Vector2(10.0, 5.0))
		draw_rect(cap_rect, Color("#00ff66"), true)

func _draw_ball() -> void:
	draw_circle(ball_position + Vector2(0, 5), 7.0, Color(0, 0, 0, 0.5), true)
	draw_circle(ball_position, 7.0, Color("#ffffff"), true)
	draw_circle(ball_position, 7.0, Color("#000000"), false, 1.5)

func _draw_hud() -> void:
	var hud_rect := Rect2(Vector2(340, 15), Vector2(600, 50))
	draw_rect(hud_rect, Color("#0e131d"), true)
	draw_rect(hud_rect, Color("#d4af37"), false, 2.0)
	
	var elapsed_secs = int(match_elapsed_time)
	var display_minute = elapsed_secs + 1 if current_half == 1 else 45 + elapsed_secs
	var time_str := "%d'" % [clamp(display_minute, 1, 90)]
	var score_str := str(_display_home_score()) + "  -  " + str(_display_away_score())
	
	var home_name := _display_home_team()
	var away_name := _display_away_team()

	var main_col = player_team_colors[0] if player_team_colors.size() > 0 else Color.WHITE
	draw_string(ThemeDB.fallback_font, Vector2(370, 47), home_name.capitalize(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, main_col)
	draw_string(ThemeDB.fallback_font, Vector2(590, 47), score_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#ffffff"))
	draw_string(ThemeDB.fallback_font, Vector2(740, 47), away_name.capitalize(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#df4141"))
	draw_string(ThemeDB.fallback_font, Vector2(870, 47), time_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#fff02f"))

	if foul_card_timer > 0.0 and game_state != "HALF_TIME_BANNER":
		draw_string(ThemeDB.fallback_font, Vector2(380, 110), foul_card_text, HORIZONTAL_ALIGNMENT_CENTER, 520, 20, Color("#ff4444"))

func _draw_controls_bar() -> void:
	var bar_rect := Rect2(Vector2(40, 655), Vector2(1200, 45))
	draw_rect(bar_rect, Color("#07080c"), true)
	draw_rect(bar_rect, Color("#d4af37"), false, 1.5)
	
	var controls_text := "[WASD] MOVER  |  [SHIFT] SPRINT  |  [J] PASE  |  [K] TIRO  |  [ESPACIO] CAMBIAR  |  [L] TACKLE  |  [N] QUITE"
	draw_string(ThemeDB.fallback_font, Vector2(65, 683), controls_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#75d6ff"))

func _draw_confetti() -> void:
	for c in confetti_list:
		draw_set_transform(c["pos"], c["rot"], Vector2.ONE)
		draw_rect(Rect2(c["pos"] - c["size"] / 2.0, c["size"]), c["color"], true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_half_time_banner() -> void:
	var banner_rect := Rect2(Vector2(240, 200), Vector2(800, 320))
	draw_rect(banner_rect, Color("#07080c"), true)
	draw_rect(banner_rect, Color("#d4af37"), false, 5.0)
	draw_rect(Rect2(banner_rect.position + Vector2(6, 6), banner_rect.size - Vector2(12, 12)), Color("#75d6ff"), false, 2.5)

	_draw_filete_spiral(Vector2(banner_rect.position.x + 25, banner_rect.position.y + 25), 1.0, 1.0)
	_draw_filete_spiral(Vector2(banner_rect.end.x - 25, banner_rect.position.y + 25), -1.0, 1.0)
	_draw_filete_spiral(Vector2(banner_rect.position.x + 25, banner_rect.end.y - 25), 1.0, -1.0)
	_draw_filete_spiral(Vector2(banner_rect.end.x - 25, banner_rect.end.y - 25), -1.0, -1.0)

	draw_string(ThemeDB.fallback_font, Vector2(262, 280), "¡FIN DEL PRIMER TIEMPO!", HORIZONTAL_ALIGNMENT_CENTER, 760, 36, Color("#fff02f"))
	draw_string(ThemeDB.fallback_font, Vector2(262, 340), "INICIANDO SEGUNDO TIEMPO...", HORIZONTAL_ALIGNMENT_CENTER, 760, 24, Color("#75d6ff"))
	
	# Botón táctil visual para avanzar el entretiempo
	var btn_rect := Rect2(Vector2(360, 420), Vector2(560, 55))
	draw_rect(btn_rect, Color("#151d2a"), true)
	draw_rect(btn_rect, Color("#55dd77"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(360, 455), "TOCA O PRESIONA [ENTER] PARA CONTINUAR", HORIZONTAL_ALIGNMENT_CENTER, 560, 16, Color("#ffffff"))

func _draw_fixture_screen() -> void:
	var menu_rect := Rect2(Vector2(60, 40), Vector2(1160, 640))
	draw_rect(menu_rect, Color("#0e131d"), true)
	draw_rect(menu_rect, Color("#d4af37"), false, 3.0)
	
	if game_mode == "LIGA":
		var mode_title := "ASÍ ES LA VIDA" if league_campaign_type == "ASICOP" else "HAMBRE DE GLORIA"
		var camp_title := mode_title + " - " + _division_name(current_division)
		draw_string(ThemeDB.fallback_font, Vector2(80, 75), "JORNADA DE LIGA - " + camp_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#75d6ff"))
		
		draw_string(ThemeDB.fallback_font, Vector2(80, 115), "--- FECHA " + str(league_fixtures[current_fixture_index]["round"]) + " ---", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff02f"))
		var y_fix := 150
		for m in league_fixtures[current_fixture_index]["matches"]:
			var match_str := "%s  VS  %s" % [m["home"].capitalize(), m["away"].capitalize()]
			var is_player_match = (m["home"] == player_team_name or m["away"] == player_team_name)
			var col := Color("#fff02f") if is_player_match else Color("#ffffff")
			draw_string(ThemeDB.fallback_font, Vector2(80, y_fix), match_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col)
			y_fix += 25

		_draw_standings_table(Vector2(480, 70), Vector2(720, 520))

	else:
		var round_info = copa_rounds[copa_round_index]
		draw_string(ThemeDB.fallback_font, Vector2(400, 100), "COPA ARGENTINA - " + String(round_info["name"]), HORIZONTAL_ALIGNMENT_CENTER, 480, 26, Color("#75d6ff"))
		var player_match_text := ""
		for m in round_info["matches"]:
			if bool(m["is_player_match"]):
				player_match_text = "%s  VS  %s" % [String(m["home"]).capitalize(), String(m["away"]).capitalize()]
				break
		draw_string(ThemeDB.fallback_font, Vector2(240, 250), player_match_text, HORIZONTAL_ALIGNMENT_CENTER, 800, 30, Color("#fff02f"))
		draw_string(ThemeDB.fallback_font, Vector2(240, 310), str(round_info["matches"].size()) + " cruces en esta fase", HORIZONTAL_ALIGNMENT_CENTER, 800, 16, Color("#ffffff"))

	if fixture_timer >= FIXTURE_MIN_TIME:
		var btn_fixture := Rect2(Vector2(440, 610), Vector2(400, 45))
		draw_rect(btn_fixture, Color("#151d2a"), true)
		draw_rect(btn_fixture, Color("#55dd77"), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(440, 638), "TOCA O PRESIONA [ENTER] PARA INICIAR", HORIZONTAL_ALIGNMENT_CENTER, 400, 15, Color("#fff02f"))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(480, 645), "ESPERANDO...", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#75d6ff"))

func _draw_standings_table(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos, size), Color("#07080c"), true)
	draw_rect(Rect2(pos, size), Color("#d4af37"), false, 2.0)

	draw_string(ThemeDB.fallback_font, pos + Vector2(15, 25), "POS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(60, 25), "EQUIPO", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(250, 25), "PTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(295, 25), "PJ", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(335, 25), "GF", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(375, 25), "GC", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(415, 25), "DG", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(460, 25), "G", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(500, 25), "E", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(540, 25), "P", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(600, 25), "ULT. 5 PARTIDOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#75d6ff"))

	draw_line(pos + Vector2(10, 35), pos + Vector2(size.x - 10, 35), Color("#d4af37"), 1.0)

	var y_offset := 55
	for i in range(standings.size()):
		var t = standings[i]
		var col = Color("#fff02f") if t["name"] == player_team_name else Color("#ffffff")
		
		draw_string(ThemeDB.fallback_font, pos + Vector2(15, y_offset), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(60, y_offset), t["name"].capitalize(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(250, y_offset), str(t["pts"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(295, y_offset), str(t["pj"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(335, y_offset), str(t["gf"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(375, y_offset), str(t["gc"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(415, y_offset), str(t["dg"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(460, y_offset), str(t["pg"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(500, y_offset), str(t["pe"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)
		draw_string(ThemeDB.fallback_font, pos + Vector2(540, y_offset), str(t["pp"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)

		var recent_matches: Array = t["recent"]
		var circle_x = pos.x + 600
		for j in range(recent_matches.size()):
			var res_char = recent_matches[j]
			var circle_color = Color("#2ecc71") if res_char == "W" else (Color("#f1c40f") if res_char == "D" else Color("#e74c3c"))
			draw_circle(Vector2(circle_x + (j * 18), y_offset - 4), 6.0, circle_color)

		y_offset += 26

func _draw_penalties_ui() -> void:
	var panel_rect := Rect2(Vector2(360, 90), Vector2(560, 150))
	draw_rect(panel_rect, Color("#0e131d"), true)
	draw_rect(panel_rect, Color("#d4af37"), false, 3.0)

	var shooter_text := "TU TURNO" if penalty_shooter == "home" else "TURNO DEL RIVAL"
	draw_string(ThemeDB.fallback_font, Vector2(400, 130), shooter_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#fff02f"))

	var score_text := "PENALTIS  " + str(home_penalties) + " - " + str(away_penalties)
	draw_string(ThemeDB.fallback_font, Vector2(400, 165), score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#ffffff"))

	if penalty_shooter == "home" and penalty_state == "AIMING":
		draw_string(ThemeDB.fallback_font, Vector2(400, 205), "[K] DISPARAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#75d6ff"))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(400, 205), "PREPARANDO PENAL...", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#75d6ff"))

func _draw_post_match_notification() -> void:
	var banner_rect := Rect2(Vector2(160, 80), Vector2(960, 570))
	draw_rect(banner_rect, Color("#0e131d"), true)
	draw_rect(banner_rect, Color("#d4af37"), false, 3.0)

	var verdict := "EMPATASTE"
	var verdict_color := Color("#fff02f")
	if home_score > away_score:
		verdict = "GANASTE"
		verdict_color = Color("#55dd77")
	elif home_score < away_score:
		verdict = "PERDISTE"
		verdict_color = Color("#ff5555")
	draw_string(ThemeDB.fallback_font, Vector2(260, 130), verdict, HORIZONTAL_ALIGNMENT_CENTER, 760, 34, verdict_color)

	var opponent := _get_current_opponent()
	var home_name := _display_home_team()
	var away_name := _display_away_team()
	var result_text := "%s  %d - %d  %s" % [home_name.capitalize(), _display_home_score(), _display_away_score(), away_name.capitalize()]
	draw_string(ThemeDB.fallback_font, Vector2(250, 180), result_text, HORIZONTAL_ALIGNMENT_CENTER, 780, 22, Color("#ffffff"))

	draw_string(ThemeDB.fallback_font, Vector2(370, 225), "ESTADÍSTICA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, Vector2(680, 225), "VOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, Vector2(820, 225), "RIVAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#75d6ff"))
	var rows := [
		["Pases", "passes"], ["Corner", "corners"], ["Lateral", "throw_ins"],
		["Tiro libre", "free_kicks"], ["Foul", "fouls"], ["Penal", "penalties"],
		["Llegadas al arco", "shots"], ["Tarjetas amarillas", "yellow_cards"], ["Tarjetas rojas", "red_cards"]
	]
	var y := 255
	for row in rows:
		var vals: Array = match_stats.get(row[1], [0, 0])
		draw_string(ThemeDB.fallback_font, Vector2(370, y), row[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#ffffff"))
		draw_string(ThemeDB.fallback_font, Vector2(690, y), str(vals[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#fff02f"))
		draw_string(ThemeDB.fallback_font, Vector2(830, y), str(vals[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#ffffff"))
		y += 32

	# Botones táctiles visuales para Guardar y Continuar
	if game_mode == "LIGA":
		var save_btn := Rect2(Vector2(260, 585), Vector2(200, 45))
		draw_rect(save_btn, Color("#151d2a"), true)
		draw_rect(save_btn, Color("#75d6ff"), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(260, 613), "[S] GUARDAR", HORIZONTAL_ALIGNMENT_CENTER, 200, 15, Color("#75d6ff"))

		var cont_btn := Rect2(Vector2(480, 585), Vector2(520, 45))
		draw_rect(cont_btn, Color("#151d2a"), true)
		draw_rect(cont_btn, Color("#55dd77"), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(480, 613), "TOCA O [ENTER] CONTINUAR", HORIZONTAL_ALIGNMENT_CENTER, 520, 15, Color("#fff02f"))
	else:
		var cont_btn_copa := Rect2(Vector2(260, 585), Vector2(760, 45))
		draw_rect(cont_btn_copa, Color("#151d2a"), true)
		draw_rect(cont_btn_copa, Color("#55dd77"), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(260, 613), "TOCA O [ENTER] PARA CONTINUAR", HORIZONTAL_ALIGNMENT_CENTER, 760, 15, Color("#fff02f"))

func _draw_match_results_screen() -> void:
	var menu_rect := Rect2(Vector2(310, 100), Vector2(660, 520))
	draw_rect(menu_rect, Color("#0e131d"), true)
	draw_rect(menu_rect, Color("#d4af37"), false, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(450, 140), "RESULTADOS DE LA JORNADA", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#75d6ff"))

	var y := 190
	for res in all_match_results:
		var line := "%s  %d  -  %d  %s" % [res["home"].capitalize(), res["hg"], res["ag"], res["away"].capitalize()]
		draw_string(ThemeDB.fallback_font, Vector2(360, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ffffff"))
		y += 30

	var next_action_text = "TOCA O [ENTER] PARA VER POSICIONES" if game_mode == "LIGA" else "TOCA O [ENTER] PARA CONTINUAR LA COPA"
	
	var btn_res := Rect2(Vector2(370, 550), Vector2(540, 45))
	draw_rect(btn_res, Color("#151d2a"), true)
	draw_rect(btn_res, Color("#55dd77"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(370, 578), next_action_text, HORIZONTAL_ALIGNMENT_CENTER, 540, 14, Color("#fff02f"))

func _get_team_goal_colors(t_name: String) -> Array[Color]:
	if league_campaign_type == "HAMBRE":
		return [Color("#75d6ff"), Color("#ffffff")]
	
	var clean_name = t_name.to_lower().strip_edges()
	match clean_name:
		"boca":
			return [Color("#002B49"), Color("#FFD100")]
		"river", "independiente", "huracan", "union":
			return [Color("#FFFFFF"), Color("#D90429")]
		"racing":
			return [Color("#75d6ff"), Color("#ffffff")]
		"newells":
			return [Color("#D90429"), Color("#111111")]
		"central":
			return [Color("#FFD100"), Color("#002B49")]
		"lanus":
			return [Color("#800020"), Color("#7209B7")]
		"banfield":
			return [Color("#FFFFFF"), Color("#38B000")]
		"san lorenzo":
			return [Color("#002B49"), Color("#D90429")]
		"estudiantes":
			return [Color("#D90429"), Color("#FFFFFF")]
		"gimnasia", "velez":
			return [Color("#002B49"), Color("#FFFFFF")]
		"ferro":
			return [Color("#90EE90"), Color("#006400")]
		"colon":
			return [Color("#111111"), Color("#D90429")]
		_:
			return [Color("#fff02f"), Color("#ff4444")]

func _draw_fileteado_porteño_goal() -> void:
	var banner_rect := Rect2(Vector2(140, 140), Vector2(1000, 320))
	
	draw_rect(banner_rect, Color("#07080c"), true)
	draw_rect(banner_rect, Color("#d4af37"), false, 6.0)
	draw_rect(Rect2(banner_rect.position + Vector2(8, 8), banner_rect.size - Vector2(16, 16)), Color("#75d6ff"), false, 3.0)

	_draw_filete_spiral(Vector2(banner_rect.position.x + 30, banner_rect.position.y + 30), 1.0, 1.0)
	_draw_filete_spiral(Vector2(banner_rect.end.x - 30, banner_rect.position.y + 30), -1.0, 1.0)
	_draw_filete_spiral(Vector2(banner_rect.position.x + 30, banner_rect.end.y - 30), 1.0, -1.0)
	_draw_filete_spiral(Vector2(banner_rect.end.x - 30, banner_rect.end.y - 30), -1.0, -1.0)

	draw_line(Vector2(200, 190), Vector2(1080, 190), Color("#fff02f"), 4.0)
	draw_line(Vector2(200, 410), Vector2(1080, 410), Color("#fff02f"), 4.0)

	var elapsed := CELEBRATION_DURATION - celebration_timer
	var full_text := "GOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOL"
	var letters_to_show := int(clamp(elapsed * 12.0, 1, full_text.length()))
	var animated_str := full_text.substr(0, letters_to_show)

	var base_y := 280.0
	var time_val := Time.get_ticks_msec() * 0.008

	var goal_colors = _get_team_goal_colors(last_scoring_team)
	var col1 = goal_colors[0]
	var col2 = goal_colors[1]
	
	var is_dark_goal := false
	if game_mode == "PELICULA":
		if movie_phase == "MATCH" and last_scoring_team != player_team_name and not movie_intro_match:
			is_dark_goal = true
		elif movie_phase == "FINAL_MATCH" and last_scoring_team != player_team_name:
			is_dark_goal = true
	
	var goal_font: Font = ThemeDB.fallback_font
	var goal_text := animated_str
	var enemy_insult := ""
	
	if is_dark_goal and movie_goal_font != null:
		goal_font = movie_goal_font
		goal_text = "𝔖𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔒𝔏!"
		enemy_insult = "𝔗𝔲 𝔱𝔦𝔢𝔯𝔯𝔞 𝔰𝔢𝔯𝔞́ 𝔫𝔲𝔢𝔰𝔱𝔯𝔞, 𝔱𝔬𝔫𝔱𝔬 𝔞𝔯𝔤𝔢𝔫𝔱𝔦𝔫𝔬!"

	var goal_size := 54
	var total_text_width := 0
	
	if is_dark_goal:
		goal_size = 34
		var gothic_col := Color.WHITE if int(Time.get_ticks_msec() * 0.003) % 2 == 0 else Color.BLACK
		var outline_col := Color.BLACK if gothic_col == Color.WHITE else Color.WHITE
		
		var char_width := 25.0
		total_text_width = goal_text.length() * char_width
		var centered_start_x := (SCREEN_WIDTH - total_text_width) / 2.0
		
		for i in range(goal_text.length()):
			var char_str := goal_text[i]
			var wave_y := base_y + sin(time_val + i * 0.3) * 14.0
			var char_pos := Vector2(centered_start_x + (i * char_width), wave_y)
			
			draw_string(goal_font, char_pos + Vector2(3, 3), char_str, HORIZONTAL_ALIGNMENT_LEFT, -1, goal_size, outline_col)
			draw_string(goal_font, char_pos, char_str, HORIZONTAL_ALIGNMENT_LEFT, -1, goal_size, gothic_col)
		
		draw_string(goal_font, Vector2(55, 475), enemy_insult, HORIZONTAL_ALIGNMENT_CENTER, SCREEN_WIDTH - 110, 27, Color.WHITE)
	else:
		var char_width := 28.0
		total_text_width = goal_text.length() * char_width
		var centered_start_x := (SCREEN_WIDTH - total_text_width) / 2.0
		
		for i in range(goal_text.length()):
			var char_str := goal_text[i]
			var wave_y := base_y + sin(time_val + i * 0.3) * 14.0
			var char_pos := Vector2(centered_start_x + (i * char_width), wave_y)
			
			draw_string(goal_font, char_pos + Vector2(3, 3), char_str, HORIZONTAL_ALIGNMENT_LEFT, -1, goal_size, Color("#000000"))
			draw_string(goal_font, char_pos, char_str, HORIZONTAL_ALIGNMENT_LEFT, -1, goal_size, col1 if i % 2 == 0 else col2)

	var minute_str := "★ GOL A LOS " + str(goal_minute) + "' ST ★" if is_second_half else "★ GOL A LOS " + str(goal_minute) + "' PT"
	var home_name := _display_home_team()

func _draw_match_pause() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)), Color("#05070a"), true)
	var panel := Rect2(Vector2(220, 80), Vector2(840, 560))
	draw_rect(panel, Color("#0e131d"), true)
	draw_rect(panel, Color("#d4af37"), false, 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(220, 135), "PAUSA", HORIZONTAL_ALIGNMENT_CENTER, 840, 38, Color("#75d6ff"))
	draw_string(ThemeDB.fallback_font, Vector2(260, 180), "ESTRELLAS ACUMULADAS: " + str(accumulated_stars), HORIZONTAL_ALIGNMENT_CENTER, 760, 22, Color("#fff02f"))
	draw_string(ThemeDB.fallback_font, Vector2(260, 220), "Asignar estrellas al jugador seleccionado", HORIZONTAL_ALIGNMENT_CENTER, 760, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(300, 280), "JUGADOR: " + str(pause_selected_player + 1), HORIZONTAL_ALIGNMENT_CENTER, 680, 25, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(300, 330), "ESTRELLAS A ASIGNAR: " + str(pause_star_allocation), HORIZONTAL_ALIGNMENT_CENTER, 680, 25, Color("#fff02f"))

	var btn_prev = Rect2(Vector2(260, 440), Vector2(230, 40))
	var btn_next = Rect2(Vector2(510, 440), Vector2(230, 40))
	var btn_star_add = Rect2(Vector2(260, 485), Vector2(230, 40))
	var btn_star_sub = Rect2(Vector2(510, 485), Vector2(230, 40))
	var btn_resume = Rect2(Vector2(260, 530), Vector2(230, 40))
	var btn_exit = Rect2(Vector2(510, 530), Vector2(230, 40))

	draw_rect(btn_prev, Color("#151d2a"), true); draw_rect(btn_prev, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(260, 466), "< JUGADOR ANTERIOR", HORIZONTAL_ALIGNMENT_CENTER, 230, 13, Color.WHITE)

	draw_rect(btn_next, Color("#151d2a"), true); draw_rect(btn_next, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(510, 466), "JUGADOR SIGUIENTE >", HORIZONTAL_ALIGNMENT_CENTER, 230, 13, Color.WHITE)

	draw_rect(btn_star_add, Color("#151d2a"), true); draw_rect(btn_star_add, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(260, 511), "+ AGREGAR ESTRELLA", HORIZONTAL_ALIGNMENT_CENTER, 230, 13, Color("#fff02f"))

	draw_rect(btn_star_sub, Color("#151d2a"), true); draw_rect(btn_star_sub, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(510, 511), "- QUITAR ESTRELLA", HORIZONTAL_ALIGNMENT_CENTER, 230, 13, Color("#fff02f"))

	draw_rect(btn_resume, Color("#151d2a"), true); draw_rect(btn_resume, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(260, 556), "APLICAR Y REANUDAR", HORIZONTAL_ALIGNMENT_CENTER, 230, 13, Color("#55dd77"))

	draw_rect(btn_exit, Color("#151d2a"), true); draw_rect(btn_exit, Color("#d4af37"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(510, 556), "SALIR AL MENÚ", HORIZONTAL_ALIGNMENT_CENTER, 230, 13, Color("#ff5555"))
