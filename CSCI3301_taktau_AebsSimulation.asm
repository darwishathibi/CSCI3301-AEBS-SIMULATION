# CSCI 3301 Computer Architecture and Assembly Language (CAAL) Section: 1
# Title: Automatic Emergency Braking System (AEBS) Simulation
# Group Taktau, Members:
# 	1. Syed Muhammad Afiq Idid bin Syed Azli Idid (2218417)
# 	2. Mohamad Hafiz bin Mohd Jais (2218827)
# 	3. Danish Darwis bin Shathibi (2210665)
# 	4. Wan Mohamad Hariz bin Wan Marzuki (2213623)

.data 
    count:                  .word 0         
    str_prompt_lidar:       .asciiz "Please enter lidar value (meters): "
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
    li $t0, 0               # initialize counter to 0

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
    mul $t1, $a0, 4         
    lw $t2, lidar_values($t1)  
    lw $t3, speedometer_values($t1) 

    beq $t3, $zero, no_collision

    # convert speed to m/s and calculate ttc
    li $t4, 3600
    mul $t3, $t3, 1000       
    div $t3, $t3, $t4        
    mul $t2, $t2, 1     #we modify changes here as no need to multiply again with 1000 because already convert to speed  
    div $t5, $t2, $t3        
    mflo $t5                 

    sw $t5, ttc_values($t1)  
    jr $ra                   

no_collision:
    li $t5, -1               
    sw $t5, ttc_values($t1)  
    jr $ra

warning_system_module:
    # check ttc and trigger warnings
    lw $t0, count                 
    mul $t1, $t0, 4               
    lw $t2, ttc_values($t1)       
    lw $t3, fcw                   

    # compare ttc with fcw
    blt $t2, $t3, warn_driver     
    j clear_warning               

warn_driver:
    # turn on warning light
    li $a0, 1                     
    sw $a0, warning_light_status  

    # display warning message
    la $a0, str_warning_light     
    li $v0, 4                     
    syscall

    # print warning light status
    la $a0, str_warning_status    
    li $v0, 4
    syscall
    lw $a0, warning_light_status  
    li $v0, 1                     
    syscall
    j end_warning_module          

clear_warning:
    # turn off warning light
    li $a0, 0                     
    sw $a0, warning_light_status  

    # print clear message
    la $a0, str_clear             
    li $v0, 4
    syscall

    # print warning light status
    la $a0, str_warning_status    
    li $v0, 4
    syscall
    lw $a0, warning_light_status  
    li $v0, 1                     
    syscall

end_warning_module:
    la $a0, break_line            
    li $v0, 4
    syscall

    jr $ra 
