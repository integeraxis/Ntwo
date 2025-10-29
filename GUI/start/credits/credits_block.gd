@tool
extends VBoxContainer

@export var title := "":
	set(new_value):
		title = new_value
		$Title.text = title


@export var credit_lines : Array[CreditLineRes]

func _ready() -> void:
	if not Engine.is_editor_hint():
		set_credit_lines()
		#set_process(false)

func _process(_delta: float) -> void:
	set_credit_lines()


#TODO: make the urls clickable
func set_credit_lines():
	$content.text = ""

	for line in credit_lines:
		if line == null:
			continue
		if line.url == null or line.credited_work == null or line.credited_person == null:
			continue
		
	
		#var bbcode = '[center][url link="' +line.url+ '"]'+line.credited_work+"[/url]    -    "+line.credited_person+"[/center]"
		var bbcode = "[center]"+line.credited_work+"    -    "+line.credited_person+"[/center]"
		$content.text += bbcode

#this signal gets sent when you click on a url
func _on_content_meta_clicked(meta: Variant) -> void:
	print("opening: "+meta)
	OS.shell_open(str(meta))
