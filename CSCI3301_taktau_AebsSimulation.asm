# CSCI 3301 Computer Architecture and Assembly Language (CAAL) Section: 1
# Title: Automatic Emergency Braking System (AEBS) Simulation
# Group Taktau, Members:
# 	1. Syed Muhammad Afiq Idid bin Syed Azli Idid (2218417)
# 	2. Mohamad Hafiz bin Mohd Jais (2218827)
# 	3. Danish Darwis bin Shathibi (2210665)
# 	4. Wan Mohamad Hariz bin Wan Marzuki (2213623)

# Initialize all variables
.data 
    count:                  .word 0         
    str_prompt_lidar:       .asciiz "Please enter lidar value (meters): "
    str_invalid_lidar:      .asciiz "Invalid lidar value. Must be >= 4 meters.\n"
    str_prompt_speedometer: .asciiz "Please enter speedometer value (km/h): "
    str_invalid_speed:      .asciiz "Invalid speed value. Must be >= 0 km/h.\n"
    str_camera_result:      .asciiz " Camera resolution: 1280x720\n"
    str_lidar_result:       .asciiz "Lidar value: "
    str_speedometer_result: .asciiz " Speedometer value: "
    str_ttc_result:         .asciiz "Time-to-Collision in ms(TTC): "
    break_line:             .asciiz "\n"
    str_warning_light:      .asciiz "WARNING: Collision imminent! Warning light ON.\n"
    str_clear:              .asciiz "Clear: No immediate danger.\n"
    str_warning_status:     .asciiz "Warning light status (1=ON, 0=OFF): "

    # Sensor storage variables
    lidar_values:           .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    speedometer_values:     .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ttc_values:             .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

    # Fixed Constants
    min_lidar:              .word 4          # Minimum distance (meters) before AEBS turns on
    fcw:                    .word 270        # Forward Collision Warning threshold in ms
    warning_light_status:   .word 0          # 0: OFF, 1: ON
	
.text 
main: 
    li $t0, 0               # Initialize counter to 0

loop: 
    bge $t0, 10, end_loop   # If t0 >= 10, exit the loop

    # Read and validate Lidar value
    jal read_lidar          # Jump to read_lidar
    blt $v0, 4, invalid_lidar
    
    mul $t1, $t0, 4         # Calculate byte offset for $t0
    sw $v0, lidar_values($t1) # Store Lidar value

    # Read and validate Speedometer value
    jal read_speedometer    # Jump to read_speedometer
    blt $v0, 0, invalid_speed

    sw $v0, speedometer_values($t1) # Store Speedometer value

    # Print Lidar value
    la $a0, str_lidar_result
    li $v0, 4
    syscall
    lw $a0, lidar_values($t1)  # Load and print lidar value
    li $v0, 1
    syscall

    # Print Speedometer value
    la $a0, str_speedometer_result
    li $v0, 4
    syscall
    lw $a0, speedometer_values($t1)  # Load and print speedometer value
    li $v0, 1
    syscall

    # Print Camera resolution
    la $a0, str_camera_result
    li $v0, 4
    syscall

    # Calculate and print TTC
    move $a0, $t0           # Pass current index to $a0
    jal calculate_TTC       # Call calculate_TTC function

    la $a0, str_ttc_result
    li $v0, 4
    syscall

    lw $a0, ttc_values($t1) # Load and print TTC value (fractional)
    li $v0, 1
    syscall

    # Call the Warning System Module
    jal warning_system_module   # Call Warning System Module to check and display warning

    la $a0, break_line      # Print newline
    li $v0, 4
    syscall

    addi $t0, $t0, 1        # Increment the counter
    j loop                  # Jump back to the start of the loop
    
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
    li $v0, 10              # Exit program
    syscall

# Function to read lidar
read_lidar:
    la $a0, str_prompt_lidar
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    jr $ra

# Function to read speedometer
read_speedometer:
    la $a0, str_prompt_speedometer
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    jr $ra

# Calculate Time-to-Collision (TTC) as a fraction
calculate_TTC:
    mul $t1, $a0, 4         # Calculate byte offset for index
    lw $t2, lidar_values($t1)  # Load Lidar value (distance)
    lw $t3, speedometer_values($t1) # Load Speedometer value (speed)

    # Check for speed == 0 to avoid division by zero
    beq $t3, $zero, no_collision

    # Convert speed to m/s (scaled by 1000 for fractional calculations): speed (m/s) = speed (km/h) * 1000 / 3600
    li $t4, 3600
    mul $t3, $t3, 1000       # Scale speed by 1000
    div $t3, $t3, $t4        # Convert to m/s

    # Calculate TTC: TTC = (Distance * 1000) / Speed
    mul $t2, $t2, 1000       # Scale distance by 1000
    div $t5, $t2, $t3        # Compute TTC (fractional, scaled)
    mflo $t5                 # Move quotient (TTC value) to $t5

    sw $t5, ttc_values($t1)  # Store TTC in ttc_values
    jr $ra                   # Return to caller

no_collision:
    li $t5, -1               # Indicate no collision possible
    sw $t5, ttc_values($t1)  # Store -1 in ttc_values
    jr $ra

warning_system_module:
    # Warning System Module: Check TTC and trigger warnings
    lw $t0, count                 # Load current index (counter)
    mul $t1, $t0, 4               # Calculate byte offset for index
    lw $t2, ttc_values($t1)       # Load TTC value
    lw $t3, fcw                   # Load FCW threshold

    # Debugging: Print TTC and FCW values
    la $a0, break_line            # Print newline
    li $v0, 4
    syscall

    lw $a0, ttc_values($t1)       # Print TTC value
    li $v0, 1
    syscall

    la $a0, break_line            # Print newline
    li $v0, 4
    syscall

    lw $a0, fcw                   # Print FCW value
    li $v0, 1
    syscall

    # Compare TTC with FCW
    blt $t2, $t3, warn_driver     # If TTC < FCW, branch to warn_driver
    j clear_warning               # Otherwise, jump to clear_warning

warn_driver:
    # Turn on warning light
    li $a0, 1                     # Load 1 into $a0 (warning light ON)
    sw $a0, warning_light_status  # Store status to memory

    # Display warning message
    la $a0, str_warning_light     # Load address of warning message
    li $v0, 4                     # Syscall for print string
    syscall

    # Print warning light status
    la $a0, str_warning_status    # Load status message ("Warning light status: ")
    li $v0, 4
    syscall
    lw $a0, warning_light_status  # Load warning light status (1 for ON)
    li $v0, 1                     # Print the value (0 or 1)
    syscall
    j end_warning_module          # Jump to end_warning_module

clear_warning:
    # Turn off warning light
    li $a0, 0                     # Load 0 into $a0 (warning light OFF)
    sw $a0, warning_light_status  # Store status to memory

    # Print clear message
    la $a0, str_clear             # Load address of clear message
    li $v0, 4                     # Syscall for print string
    syscall

    # Print warning light status
    la $a0, str_warning_status    # Load status message ("Warning light status: ")
    li $v0, 4
    syscall
    lw $a0, warning_light_status  # Load warning light status (0 for OFF)
    li $v0, 1                     # Print the value (0 or 1)
    syscall

end_warning_module:
    la $a0, break_line            # Print newline for better readability
    li $v0, 4
    syscall

    jr $ra                        # Return to caller
