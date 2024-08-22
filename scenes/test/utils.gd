#
# Funzioni di utilità generale
#
extends Node


# abilita/disabilita la visualizzazione dei log
static var debug = true


# stampa un messaggio di log sulla console, anteponendo data e ora al messaggio.
static func log(msg):
	if debug:
		var date_time = Time.get_datetime_string_from_system()
		print(date_time+" "+msg)

