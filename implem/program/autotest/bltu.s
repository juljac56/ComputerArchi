# TAG = bltu
	.text

        bltu x0,x0, juju	
	addi x31, x0, 0x1
	addi x30, x0, -1
	addi x23, x0, 23
	bltu x31,x30, juju

	
juju:
	addi x31, x0, 0x9
	bltu x23,x0, juju
	addi x31, x0, 0x15


	# max_cycle 100
	# pout_start
	# 00000001
	# 00000009
	# 00000015
	# pout_end
