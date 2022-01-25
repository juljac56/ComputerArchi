# TAG = beq
	.text

        beq x0,x0, juju	
	addi x31, x0, 0x6

	

	
juju:
	addi x31, x0, 0x5
	addi x23, x0, -1
	addi x24, x0, -1
	beq x24,x23, negatif	

negatif:
	addi x31,x0, 0x006


	# max_cycle 100
	# pout_start
	# 00000005
	# 00000006
	# pout_end
