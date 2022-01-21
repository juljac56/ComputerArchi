# TAG = beq
	.text

        beq x0,x0, juju	
	addi x31, x0, 0x6

	
juju:
	addi x31, x0, 0x5

	# max_cycle 100
	# pout_start
	# 00000005
	# pout_end
