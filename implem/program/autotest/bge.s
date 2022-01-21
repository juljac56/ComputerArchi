# TAG = blt
	.text

        blt x0,x0, juju	
	addi x31, x0, 0x6
	addi x30, x0, 0x8
	blt x31,x30, juju

	
juju:
	addi x31, x0, 0x9
	blt x31,x30, juju
	addi x31, x0, 0


	# max_cycle 100
	# pout_start
	# 00000006
	# 00000009
	# 00000000
	# pout_end
