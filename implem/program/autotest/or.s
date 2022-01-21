# TAG = or
	.text

        or x31,x0,x0
	addi x9, x0, 0x024
	addi x8, x0, 0x021
	or x31,x9,x8

	# max_cycle 200
	# pout_start
	# 00000000
	# 00000025
	# pout_end
