# TAG = sra
	.text

	sra x31,x0,0
	addi x1, x0, 0x009
	addi x2, x0, 0x002
	addi x3, x0, -1
	sra x31,x1,x2
	sra x31, x3, x2

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000002
	# FFFFFFFF
	# pout_end
