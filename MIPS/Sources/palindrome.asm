##	Edisc	-- 24/08/2020
## palindrome.asm -- reads a line of text and tests if it is a palindrome.
##	Register usage:
##	$t1		- A.
##	$t2		- B.
##	$t3		- the character at address A
##	$t4		- the character at address B.
##	$v0		- stscall parameter / return values
##	$a0		- syscall parameters
##	$a1		- syscall parameters

	.text
main:						# PIM starts by jumping to main
							## read the string S:
	la	$a0, string_space
	li 	$a1, 1024
	li 	$v0, 8 				# load "read_string" code into $v0
	syscall

	la 	$t1, string_space	#	A = S
	la 	$t2, string_space 	## we need to move B to the end 
length_loop:				#		of the string:
	lb	$t3, ($t2)			# load the byte at B into $t3
	beqz	$t3, end_length_loop	# if $t3 == 0, branch out of loop.
	addu	$t2, $t2, 1		# otherwise, increment B,
	b 		length_loop 	# and repeat

end_length_loop:
	subu	$t2, $t2, 2		## subtract 2 to move B back past
							#		the '\0' and '\n'

test_loop:
	bge 	$t1, $t2, is_palin 	# if A >= B, it's a palindrome

	lb		$t3, ($t1)		# load the byte at address A into $t3.
	lb		$t4, ($t2)		# load the byte at address B into $t4

	bne		$t3, $t4, not_palin 	# if $t3 != $t4, not a palindrome
									# Otherwise,
	addu 	$t1, $t1, 1		# increment A,
	subu	$t2, $t2, 1		# decrement B,
	b 		test_loop		# and repeat the loop

is_palin:
	la $a0, is_palin_msg
	li $v0, 4
	syscall

	b exit

not_palin:
	la $a0, not_palin_msg
	li $v0, 4
	syscall

exit:
	li $v0, 10
	syscall


	.data
string_space:	.space 1024	# set aside 1024 bytes for the string.
is_palin_msg:	.asciiz "This is a palindrome\n"
not_palin_msg:	.asciiz "This is not a palindrome\n"