# TAG = slti
	.text

	addi x1, x0, 0x024
	addi x4, x0, 0x0
	addi x5, x0, -1

	slti x31, x1,0x021
	slti x31, x4,0x028
	slti x31, x5, 0
	slti x31, x4, -1

	# max_cycle 20000
	# pout_start
	# 00000000
	# 00000001
	# 00000001
	# 00000000
	# pout_end
