# CSCI 3301 Computer Architecture and Assembly Language (CAAL) Section: 1
# Title: Automatic Emergency Braking System (AEBS) Simulation
# Group Taktau, Members:
# 	1. Syed Muhammad Afiq Idid bin Syed Azli Idid (2218417)
# 	2. Mohamad Hafiz bin Mohd Jais (2218827)
# 	3. Danish Darwis bin Shathibi (2210665)
# 	4. Wan Mohamad Hariz bin Wan Marzuki (2213623)

.data 
    count:                  .word 0         
    str_welcome:            .asciiz "WELCOME TO AEBS SIMULATION BY TAKTAUPASEPA\n"
    str_prompt_lidar:       .asciiz "\nPlease enter lidar value (meters): "
    str_invalid_lidar:      .asciiz "Invalid lidar value. Must be >= 4 meters.\n"
    str_prompt_speedometer: .asciiz "Please enter speedometer value (km/h): "
    str_invalid_speed:      .asciiz "Invalid speed value. Must be >= 0 km/h.\n"
    str_camera_result:      .asciiz "Camera resolution: 1280x720\n"
    str_lidar_result:       .asciiz "Lidar value: "
    str_speedometer_result: .asciiz "Speedometer value: "
    str_ttc_result:         .asciiz "Time-to-Collision in ms (TTC): "
    str_fcw_result:         .asciiz "Forward Collision Warning (FCW) threshold: "
    break_line:             .asciiz "\n"
    str_warning_light:      .asciiz "WARNING: Collision imminent! Warning light ON.\n"
    str_clear:              .asciiz "Clear: No immediate danger.\n"
    str_warning_status:     .asciiz "Warning light status (1=ON, 0=OFF): "


    # sensor storage variables
    lidar_values:           .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    speedometer_values:     .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ttc_values:             .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

    # fixed constants
    min_lidar:              .word 4
    fcw:                    .word 270
    warning_light_status:   .word 0
	
.text 
main: 
    # Print the welcome message
    la $a0, str_welcome    # Load address of the welcome string
    li $v0, 4              # Syscall code for printing a string
    syscall

    li $t0, 0              # Initialize counter to 0

loop: 
    bge $t0, 10, end_loop   # exit loop if t0 >= 10

    # read and validate lidar value
    jal read_lidar          
    blt $v0, 4, invalid_lidar
    
    mul $t1, $t0, 4         # calculate byte offset for t0
    sw $v0, lidar_values($t1) # store lidar value

    # read and validate speedometer value
    jal read_speedometer    
    blt $v0, 0, invalid_speed

    sw $v0, speedometer_values($t1) # store speedometer value

    # print lidar value
    la $a0, str_lidar_result
    li $v0, 4
    syscall
    lw $a0, lidar_values($t1)  
    li $v0, 1
    syscall

    # add a breakline
    la $a0, break_line
    li $v0, 4
    syscall

    # print speedometer value
    la $a0, str_speedometer_result
    li $v0, 4
    syscall
    lw $a0, speedometer_values($t1)  
    li $v0, 1
    syscall

    # add a breakline
    la $a0, break_line
    li $v0, 4
    syscall

    # print camera resolution
    la $a0, str_camera_result
    li $v0, 4
    syscall

    # calculate and print ttc
    move $a0, $t0          
    jal calculate_TTC       

    la $a0, str_ttc_result
    li $v0, 4
    syscall

    lw $a0, ttc_values($t1) 
    li $v0, 1
    syscall

    # add a breakline
    la $a0, break_line
    li $v0, 4
    syscall

    # print fcw value
    la $a0, str_fcw_result
    li $v0, 4
    syscall
    lw $a0, fcw
    li $v0, 1
    syscall

    # add a breakline
    la $a0, break_line
    li $v0, 4
    syscall

    # call warning system module
    sw $t0, count  # update count with the current loop index
    jal warning_system_module   

    la $a0, break_line      
    li $v0, 4
    syscall

    addi $t0, $t0, 1        # increment counter
    j loop                  

invalid_lidar:
    la $a0, str_invalid_lidar
    li $v0, 4
    syscall
    j loop

invalid_speed:
    la $a0, str_invalid_speed
    li $v0, 4
    syscall
    j loop

end_loop: 
    li $v0, 10              # exit program
    syscall

# function to read lidar
read_lidar:
    la $a0, str_prompt_lidar
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    jr $ra

# function to read speedometer
read_speedometer:
    la $a0, str_prompt_speedometer
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    jr $ra

# calculate time-to-collision (ttc)
calculate_TTC:
    mul $t1, $a0, 4			# Calculate byte offset for array access: t1 = a0 * 4 (since each word is 4 bytes)         
    lw $t2, lidar_values($t1)		# Load lidar value from lidar_values array at index t1 
    lw $t3, speedometer_values($t1) 	# Load speedometer value from speedometer_values array at index t1

    beq $t3, $zero, no_collision	# If speedometer value is 0 (speed = 0 km/h), jump to no_collision (no collision possible)

    # convert speed to m/s and calculate ttc
    li $t4, 3600		# Load constant 3600 (seconds in an hour) into t4
    mul $t3, $t3, 1000		# Convert speed from km/h to m/h: t3 = t3 * 1000       
    div $t3, $t3, $t4    	# Convert speed from m/h to m/s: t3 = t3 / 3600
    
    # Calculate TTC (Time-to-Collision) in milliseconds     
    mul $t2, $t2, 1000    	# Convert lidar distance from meters to millimeters: t2 = t2 * 1000
    div $t5, $t2, $t3		# Calculate TTC: t5 = t2 / t3 (distance in mm / speed in m/s = time 		
    mflo $t5			# Move the quotient (TTC in ms) from the division result into t5                 

    sw $t5, ttc_values($t1)	# Store the calculated TTC value into ttc_values array at index t1  
    jr $ra                 	  

no_collision:
    li $t5, -1			# If speed is 0, set TTC to -1 (indicating no collision)               
    sw $t5, ttc_values($t1)	# Store -1 in ttc_values array at index t1 	
    jr $ra

warning_system_module:
    # Check TTC and trigger warnings
    lw $t0, count                 # Load the current counter value
    mul $t1, $t0, 4               # Calculate byte offset for t0
    lw $t2, ttc_values($t1)       # Load TTC value for the current sensor data
    lw $t3, fcw                   # Load FCW threshold

    # Compare TTC with FCW threshold
    blt $t2, $t3, warn_driver     # If TTC < FCW, warn the driver
    j clear_warning               # Otherwise, clear warning

warn_driver:
    # Turn ON warning light
    li $t4, 1                     # Set warning light status to 1
    sw $t4, warning_light_status  # Update status in memory

    # Display warning message
    la $a0, str_warning_light     
    li $v0, 4                     
    syscall

    # Display warning light status
    la $a0, str_warning_status    
    li $v0, 4                     
    syscall
    lw $a0, warning_light_status  # Load updated status
    li $v0, 1                     
    syscall
    j end_warning_module          # Exit module

clear_warning:
    # Turn OFF warning light
    li $t4, 0                     # Set warning light status to 0
    sw $t4, warning_light_status  # Update status in memory

    # Display "clear" message
    la $a0, str_clear             
    li $v0, 4
    syscall

    # Display warning light status
    la $a0, str_warning_status    
    li $v0, 4
    syscall
    lw $a0, warning_light_status  # Load updated status
    li $v0, 1                     
    syscall

end_warning_module:
    la $a0, break_line            # Add a breakline for clarity
    li $v0, 4
    syscall

    jr $ra                        # Return from module
