# TAG = bne
	.text

        bne x0,x0, juju	
	addi x31, x0, 0x6
	addi x31, x0, 0x8
	bne x0, x31, juju

	
juju:
	addi x31, x0, 0x5


	# max_cycle 100
	# pout_start
	# 00000006
	# 00000008
	# 00000005
	# pout_end
