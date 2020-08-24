.text

main:
	## print string
	la 		$a0, input_msg
	li 		$v0, 4
	syscall

	## Get input 
	la 		$a0, string_space
	li 		$a1, 1024
	li 		$v0, 8
	syscall

	la 		$t0, string_space
	li		$t2, 0					# Initialize sum = 0.

get_sign:
	li		$t3, 1					
	lb		$t1, ($t0)				# grab the "sign"
	bne		$t1, '-', positive		# if not "-", do nothing.
	li		$t3, -1					# otherwise, set t3 = -1, and
positive:
	addu	$t0, $t0, 1				# skip over the sign

sum_loop:
	lb		$t1, ($t0)				# load the byte *S into $t1,
	addu	$t0, $t0, 1				# and increment S.

	## use 10 instead of '\n' due to SPIM bug
	beq		$t1, 10, end_sum_loop	# if $t1 == \n, branch out of loop.

	blt		$t1, '0', end_sum_loop	# make sure 0 <= t1
	bgt		$t1, '9', end_sump_loop	# make sure 9 >= t1


check_over_flow:
	li 		$t4, 10
	mult	$t2, $t4
	mfhi	$t5
	bnez	$t5, overflow
	mflo	$t2

	blt 	$t2, $t0, overflow 		# make sure that it isn't negative
end_check_over_flow:

	sub		$t1, $t1, '0'			# t1 -= '0'
	add		$t2, $t2, $t1			# t2 += t1

	b 		sum_loop

	mul		$t2, $t2, $t3			# set the sign properly

print_number:
	move 	$a0, $t2
	li		$v0, 1
	syscall



end_sum_loop:
	la		$a0, error_msg
	li		$v0, 4
	syscall
	b 		exit


overflow:
	la 		$a0, overflow_msg
	li		$v0, 4
	syscall

exit:
	li		$v0, 10
	syscall

	.data

string_space:	.space 1024
overflow_msg:	.asciiz "Overflow\n"
input_msg:		.asciiz "Input the number:\n"
error_msg:		.asciiz "Error!\n"