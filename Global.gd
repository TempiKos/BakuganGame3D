extends Node

var selected_pack: String = ""
var selected_bakugan_set: Array = []

# Заготовленные наборы с правильной структурой данных
var bakugan_packs := {
	"Огненный": [
		{
			"name": "Saurus", 
			"mesh_path": "res://closed_obj/5DCE4AA322A1EE89835AF205F36DC641DA59B16E_Saurus Closed.obj",
			"texture_path": "res://TexturesBakugans/BF1CBB1F3B2434C729A43BFD7CA68AD94AA29AC4_saurus pyrus hd.png"
		},
		{
			"name": "Centipoid", 
			"mesh_path": "res://closed_obj/EB579F93B7C6EEF17E44E0EB82E020246903C408_Centipoid closed.obj",
			"texture_path": "res://TexturesBakugans/E74E0BC47084CD6AB00005FF2980F455F58F3E26_Pyrus Centipoid HD.jpg"
		},
		{
			"name": "Gargonoid", 
			"mesh_path": "res://closed_obj/12FFEE5D3A688D036EF6F63F79F0C81ACDF66D8D_Gargonoid Closed.obj",
			"texture_path": "res://TexturesBakugans/17D1D566D43C9BE453499D62CB17B01173B0D8EA_Pyrus Gargonoid HD.jpg"
		}
	],
	"Водный": [
		{
			"name": "Vladitor", 
			"mesh_path": "res://closed_obj/0CACCD4FB6242061D2120D23FD01231A5952B1F7_Vladitor_Closed.obj",
			"texture_path": "res://TexturesBakugans/aquas_vladitor_texture.png"
		},
		{
			"name": "Preyas", 
			"mesh_path": "res://closed_obj/preyas_closed.obj",
			"texture_path": "res://TexturesBakugans/aquas_preyas_texture.png"
		},
		{
			"name": "Juggernoid", 
			"mesh_path": "res://closed_obj/juggernoid_closed.obj",
			"texture_path": "res://TexturesBakugans/aquas_juggernoid_texture.png"
		}
	],
	"Тёмный": [
		{
			"name": "Exedra", 
			"mesh_path": "res://closed_obj/0CF7F255F90305138E755C576E1B51767995DE91_Exedra_Closed.obj",
			"texture_path": "res://TexturesBakugans/0686FC1CC6213289C6010C346921E5D4FB49842E_Darkus Vladitor HD.png"
		},
		{
			"name": "Reaper", 
			"mesh_path": "res://closed_obj/reaper_closed.obj",
			"texture_path": "res://TexturesBakugans/darkus_reaper_texture.png"
		},
		{
			"name": "Fear Ripper", 
			"mesh_path": "res://closed_obj/fear_ripper_closed.obj",
			"texture_path": "res://TexturesBakugans/darkus_fear_ripper_texture.png"
		}
	]
}

# Функция для получения данных о выбранном паке
func get_selected_pack_data():
	if selected_pack != "" and bakugan_packs.has(selected_pack):
		return bakugan_packs[selected_pack]
	return []

# Функция для получения конкретного бакугана по индексу
func get_bakugan_by_index(index: int):
	var pack_data = get_selected_pack_data()
	if index >= 0 and index < pack_data.size():
		return pack_data[index]
	return null

# Функция для получения количества бакуганов в выбранном паке
func get_bakugan_count():
	return get_selected_pack_data().size()
