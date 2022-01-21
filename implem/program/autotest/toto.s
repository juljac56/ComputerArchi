# TAG = toto
	.text

        beq x0, x0, juju
	
juju:
	bne x0, x0, juju
	blt x0, x0, juju
	bltu x0, x0, juju

		

	# max_cycle 200
	# pout_start
	# 00000000
	# 00000005
	# pout_end
