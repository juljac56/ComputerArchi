# TAG = and
	.text

	and x31,x0,x0
	addi x9, x0, 0x024
	addi x8, x0, 0x021
	and x31,x9,x8

	# max_cycle 200
	# pout_start
	# 00000000
	# 00000020
	# pout_end
