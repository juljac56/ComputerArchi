# TAG = add
	.text

	add x31,x0,x0
	addi x9, x0, 0x009
	addi x8, x0, 0x008
	add x31,x9,x8

	addi x11, x0, -2
	addi x10, x0, 0x008
	add x31,x10,x11
	
	addi x12, x0, -2
	addi x13, x0, -2
	add x31,x12,x13
	
	addi x14, x0, 0x7FF
	addi x15, x0, 0x7FF
	add x31,x14,x15

	

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000011
	# 00000006
	# fffffffc
	# 00000ffe
	# pout_end
