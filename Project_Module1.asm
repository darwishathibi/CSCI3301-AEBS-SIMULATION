.data 
    count: 	.word 0        		 	
    str_prompt_lidar:		.asciiz "Please enter lidar value: "
    str_prompt_speedometer:	.asciiz "Please enter speedometer value: "
    str_prompt_camera:		.asciiz "No need to enter (just display from fixed constant) value: "
    str_lidar_result:		.asciiz "Lidar value: "
    str_speedometer_result:	.asciiz "Speedometer value: "
    str_camera_result:		.asciiz "Camera resolution: "
    str_x:			.asciiz "x"
    break_line: 		.asciiz "\n"
    
    #Fixed Constant
    min_lidar:		.word 4			#set the minimum 4 meter distance between 2 cars before AEBS turn on
    camera_width:	.word 1280		#width of the camera
    camera_height:	.word 720		#height of the camera
    
#################################################
# Module 1: Darwis                              #
# Sensor Data Reading and Preprocessing Module  #
#################################################
.text 
main: 
	li $t0, 0           	#initialize counter to 0 (t0 = 0)
 
loop: 
    	bge $t0, 10, end_loop 	#if t0 >= 10, exit the loop           
    
    	jal read_lidar		#jump to read lidar in meters (distance between 2 cars) and return back
    	move $s0, $v0		#save lidar value in $s0
    	
    	jal read_speedometer	#jump to read speedometer in km/h return back
    	move $s1, $v0		#save speedometer value in $s1
    	
    	#print lidar value
    	la $a0, str_lidar_result
    	li $v0, 4
    	syscall
    	
    	move $a0, $s0		#move lidar value to print
    	li $v0, 1		#syscall to print integer
    	syscall
    	
    	la $a0, break_line	#new line
    	li $v0, 4
    	syscall   
    	
    	#print speedometer value
    	la $a0, str_speedometer_result
    	li $v0, 4
    	syscall
    	
    	move $a0, $s1		#move speedometer value to print
    	li $v0, 1		#syscall to print integer
    	syscall
    	
    	la $a0, break_line	#new line
    	li $v0, 4
    	syscall  
    	
    	#print camera resolution
    	la $a0, str_camera_result
    	li $v0, 4
    	syscall
    	
    	lw $a0, camera_width	#print width
    	li $v0, 1
    	syscall
    	
    	la $a0, str_x		#print "x"
    	li $v0, 4
    	syscall
    	
    	lw $a0, camera_height	#print height
    	li $v0, 1
    	syscall
    	
    	#make space for next loop
    	la $a0, break_line	#new line
    	li $v0, 4
    	syscall
    	
    	la $a0, break_line	#new line
    	li $v0, 4
    	syscall      
    	
    	addi $t0, $t0, 1    	#increment the counter (t0 = t0 + 1) 
    	j loop              	#jump back to the start of the loop
 
end_loop: 
    	li $v0, 10          
    	syscall
    	
#function to read_lidar
read_lidar:
    	la $a0, str_prompt_lidar		#print prompt
    	li $v0, 4
    	syscall   
    	
    	#read integer input
    	li $v0, 5
    	syscall
    	
    	jr $ra			#return to caller with value in $v0
	
#function to read_speedometer
read_speedometer:
    	la $a0, str_prompt_speedometer		#print prompt
    	li $v0, 4
    	syscall   
    	
    	#read integer input
    	li $v0, 5
    	syscall
    	
    	jr $ra			#return to caller with value in $v0
    	
#function to read_camera
read_camera:
	la $a0, str_prompt_camera		#print display
    	li $v0, 4
    	syscall  

	jr $ra	