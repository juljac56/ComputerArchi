# TAG = blt
	.text

        blt x0,x0, juju	
	addi x31, x0, 0x6
	addi x30, x0, -1
	addi x23, x0, 23
	blt x30,x31, juju

	
juju:
	addi x31, x0, 0x9
	blt x23, x0, juju
	addi x31, x0, 0x15

	# max_cycle 100
	# pout_start
	# 00000006
	# 00000009
	# 00000015
	# pout_end
