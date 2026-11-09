extends SceneTree
## Runs every res://tests/test_*.gd. Each script extends TestCase and defines
## test_* methods. Exits non-zero if any test fails.

const TEST_DIR := "res://tests"


func _initialize() -> void:
	var failed := 0
	var passed := 0
	var files: Array[String] = []
	for f in DirAccess.get_files_at(TEST_DIR):
		if f.begins_with("test_") and f.ends_with(".gd"):
			files.append(f)
	files.sort()
	for f in files:
		var script: GDScript = load("%s/%s" % [TEST_DIR, f])
		if script.get_base_script() == null:
			continue  # helper, not a test case
		var case = script.new()
		case.tree = self
		for m in script.get_script_method_list():
			var name: String = m["name"]
			if not name.begins_with("test_"):
				continue
			case.failures.clear()
			await case.call(name)
			if case.failures.is_empty():
				passed += 1
				print("PASS %s::%s" % [f, name])
			else:
				failed += 1
				for msg in case.failures:
					print("FAIL %s::%s: %s" % [f, name, msg])
	print("%d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 or passed == 0 else 0)
