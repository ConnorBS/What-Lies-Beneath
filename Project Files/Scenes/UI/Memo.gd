extends MenuClass

var pageAssetLocation = "res://Assets/JournalEntries/Page"

func _on_BottomButtonMargin_Back():
	emit_signal("Back")


func _on_BottomButtonMargin_Cancel():
	pass # Replace with function body.

func load_window():
	var newJournalPage = PlayerInventory.get_current_journal_Page()
	_update_journal_texture(newJournalPage.pageNumber)
	_check_to_hide_previous_button()
	_check_to_hide_next_button()


func _check_to_hide_previous_button()->void:
	if PlayerInventory.is_this_the_first_page():
		get_node("%PreviousJournalPage").hide()
	else:
		get_node("%PreviousJournalPage").show()


func _check_to_hide_next_button()->void:
	if PlayerInventory.is_there_another_page():
		get_node("%NextJournalPage").show()
	else:
		get_node("%NextJournalPage").hide()


func _on_PreviousPage_pressed():
	get_parent().click_success()
	var newJournalPage = PlayerInventory.get_previous_journal_Pages()
	if newJournalPage != null:
		_update_journal_texture(newJournalPage.pageNumber)
		_check_to_hide_previous_button()
		_check_to_hide_next_button()
		


func _on_NextPage_pressed():
	get_parent().click_success()
	var newJournalPage = PlayerInventory.get_next_journal_Pages()
	if newJournalPage != null:
		_update_journal_texture(newJournalPage.pageNumber)
		_check_to_hide_previous_button()
		_check_to_hide_next_button()


func _update_journal_texture(page_number:int)->void:
	get_node("%JournalPage").texture = load("res://Assets/JournalEntries/Page"+str(page_number)+".png")
