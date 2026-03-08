varible "alb_name" {
	type = string
	default = "web-server-alb"
}

variable "tg_name" {
	type = string
	default = "webserver-tg"
}

variable "deregistration_delay" {
	type = number
	default = 30
}
