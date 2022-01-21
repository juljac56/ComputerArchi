# TAG = slt
	.text

	addi x1, x0, 0x024
	addi x2, x0, 0x021
	addi x3, x0, 0x028
	addi x4, x0, 0x0
	addi x5, x0, -1
	slt x31, x1, x2
	slt x31, x4, x3
	slt x31, x5, x4
	slt x31, x4, x5

	# max_cycle 20000
	# pout_start
	# 00000000
	# 00000001
	# 00000001
	# 00000000
	# pout_end
