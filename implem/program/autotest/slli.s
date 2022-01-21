# TAG = slli
	.text

	slli x31,x0,0
	addi x1, x0, 0x009
	slli x31,x1,0x002

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000024
	# pout_end
