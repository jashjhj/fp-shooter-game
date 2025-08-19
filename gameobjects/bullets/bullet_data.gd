class_name BulletData extends Resource

@export var speed := 300;
@export var drag := 0.1;
@export var gravity := 9.81
@export var mass := 0.005 # 5g

@export var damage := 10;

@export var base_inaccuracy := 0.005;

@export var amount:int = 1;

##Newtons experimental law / coefficient of restitution
@export var NEL_coefficient:= 0.8;
@export var ricochet_angle:= PI/9

@export var trail_material:Material

@export var lifetime:float = 2;
