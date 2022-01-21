# TAG = sltiu
	.text

	addi x1, x0, 0x024
	addi x2, x0, -1

	sltiu x31, x0, 0x021
	sltiu x31, x0, -1
	sltiu x31,x2,0
	sltiu x31, x1, 0

	# max_cycle 20000
	# pout_start
	# 00000001
	# 00000001
	# 00000000
	# 00000000
	# pout_end
