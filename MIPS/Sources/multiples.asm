# Edisc -- 24/08/2020
# multiples.asm -- takes two numbers A and B, and prints out
#		all the multiples of A from A to A * B.
#		If B <= 0, then no multiples are printed.
# Registers used:
#		$t0		- used to hold A
#		$t1		- used to hold B
# 		$t2		- used to store S, the sentinel value A*B
#		$t3		- used to store m, the current multiple of A.

	.text
main:
	## read A into $t0, B into $t1

	## print "Inut A:\n"
	la	$a0, inputA_msg
	li	$v0, 4
	syscall

	## Read A into $t0
	li	$v0, 5
	syscall
	move	$t0, $v0

	## print "Inut B:\n"
	la	$a0, inputB_msg
	li	$v0, 4
	syscall

	## Read B into $t1
	li	$v0, 5
	syscall
	move	$t1, $v0

	blez	$t1, exit			# if B <= 0, exit

	mul 	$t2, $t0, $t1		# S = A * B
	move	$t3, $t0			# m = A

loop:
	## print out $t3
	move $a0, $t3
	li $v0, 1
	syscall

	beq 	$t2, $t3, endloop 	# if m >= S, we're done
	add		$t3, $t3, $t0		# otherwise, m = m + A

	## Print a space
	la 	$a0, space_msg
	li	$v0, 4
	syscall

	b loop

endloop:

exit:
	li $v0, 10
	syscall




# Data of program
	.data
inputA_msg:		.asciiz "Input A:\n"
inputB_msg:		.asciiz "Input B:\n"
space_msg:		.ascii "  "