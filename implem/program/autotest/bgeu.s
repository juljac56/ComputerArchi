# TAG = bgeu
	.text

        bgeu x0,x0, juju	
	addi x31, x0, 0x6
	addi x30, x0, 0x8
	bgeu x31,x30, juju

	
juju:
	addi x31, x0, 0x9
	addi x30, x0, -1
	bgeu x31,x30, juju
	addi x31, x0, 0x8

	 
	


	# max_cycle 100
	# pout_start
	# 00000009
	# 00000008
	# pout_end
