# TAG = sll
	.text

	sll x31,x0,x0
	addi x1, x0, 0x009
	addi x2, x0, 0x002
	sll x31,x1,x2

	
	addi x3, x0, 0x009
	addi x4, x0, 0x002
	sll x31,x0,x4

	addi x4, x0, 0x020
	sll x31,x3,x4
	
	addi x4, x0, 0x021
	sll x31,x3,x4

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000024
	# 00000000
	# 00000009
	# pout_end
