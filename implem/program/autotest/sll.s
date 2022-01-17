# TAG = sll
	.text

	sll x31,x0,x0
	addi x1, x0, 0x009
	addi x2, x0, 0x002
	sll x31,x1,x2

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000024
	# pout_end
