# TAG = srli
	.text

	srli x31,x0,0
	addi x1, x0, 0x009
	srli x31,x1,0x2

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000002
	# pout_end
