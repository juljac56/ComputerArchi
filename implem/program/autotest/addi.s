# TAG = addi
	.text

	addi x31,x0,0      # Test chargement d'une valeur nulle
	addi x31,x0,0x001
	addi x31,x31,0x123  
	

	# max_cycle 50
	# pout_start
	# 00000000
	# 00000001
	# 00000124
	# pout_end
