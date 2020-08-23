	# add.asm-- A program that computes the sum of 1 and 2,
	# leaving the result in register $t0

main:
		
	## Get first numer from user, put into $t0.
	li 		$v0, 5			# load syscall read_int into $v0
	syscall
	move  	$t0, $v0		# move the number read into $t0.

	## Get second number from user,put into $t1.
	li 		$v0, 5			# load syscall read_int into $v0
	syscall
	move  	$t1, $v0		# move the number read into $t1  

	add 	$t2, $t0,$t1 	# compute the sum.

	## Print out $t2.
	move 	$a0, $t2		# move the number to print into $a0.
	li 		$v0, 1			# load syscall print_int into $v0.
	syscall

	li  	$v0, 10			# syscall code 10 is for exit
	syscall					# make the syscall