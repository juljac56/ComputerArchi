# TAG = srai
	.text

	srai x31,x0,0
	addi x1, x0, 0x009
	addi x2, x0, 0x002
	addi x3, x0, -1
	srai x31,x1,0x002
	srai x31, x3, 0x02

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000002
	# FFFFFFFF
	# pout_end
