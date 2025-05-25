class_name BulletData extends Resource

@export var speed := 300;
@export var drag := 0.1;
@export var gravity := 9.81
@export var mass := 0.005 # 5g

@export var damage := 250;

@export var base_inaccuracy := 0.05;

@export var amount := 1;

@export var NEL_coefficient:= 0.8;
@export var ricochet_angle:= PI/6

@export var trail_material:Material

@export var lifetime:=2000;
