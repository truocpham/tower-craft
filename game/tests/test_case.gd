class_name TestCase
extends RefCounted
## Base class for test scripts.

var failures: Array[String] = []
## Set by the runner so scene tests can reach the tree.
var tree: SceneTree


func check(cond: bool, msg: String = "check failed") -> void:
	if not cond:
		failures.append(msg)


func check_eq(actual, expected, msg: String = "") -> void:
	if actual != expected:
		failures.append("%s expected %s, got %s" % [msg, str(expected), str(actual)])


func check_near(actual: float, expected: float, msg: String = "") -> void:
	if absf(actual - expected) > 0.0001:
		failures.append("%s expected %s, got %s" % [msg, str(expected), str(actual)])
