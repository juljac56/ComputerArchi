# TAG = sltu
	.text

	addi x1, x0, 0x024
	addi x2, x0, 0x021
	addi x3, x0, -1

	sltu x31, x0, x2
	sltu x31, x0, x3
	sltu x31,x3,x0
	sltu x31, x1, x0

	# max_cycle 20000
	# pout_start
	# 00000001
	# 00000001
	# 00000000
	# 00000000
	# pout_end
