# TAG = sw
	.text
	
	li x12, 0x00000001
	li x23, 0x00001020
	sw x12,0(x23)
	lw x31, 0(x23)

	# max_cycle 200
	# pout_start
	# 00000001
	# pout_end
