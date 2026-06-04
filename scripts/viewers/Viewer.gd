class_name Viewer
extends Control
var model: RefCounted = null

func setup(_model: RefCounted):
	model = _model
	model.node = self