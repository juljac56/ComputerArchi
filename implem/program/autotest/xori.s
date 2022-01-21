# TAG = xori
	.text

        xori x31,x0,0
	addi x9, x0, 0x024 
	xori x31,x9,0x021

	# max_cycle 200
	# pout_start
	# 00000000
	# 00000005
	# pout_end
