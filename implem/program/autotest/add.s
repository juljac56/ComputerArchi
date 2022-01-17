# TAG = add
	.text

	add x31,x0,x0
	addi x9, x0, 0x009
	addi x8, x0, 0x008
	add x31,x9,x8

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000011
	# pout_end
