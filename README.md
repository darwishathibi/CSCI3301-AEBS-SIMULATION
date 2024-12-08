# CSCI3301-AEBS-SIMULATION
A simple collision avoidance system written in Python, designed for the Computer Architecture & Assembly Language (CSCI 3301) of Kuliyyah of Information, Communication & Technology in International Islamic University Malaysia (IIUM). The system includes modules for sensor data reading and preprocessing, Time-to-Collision (TTC) calculation, warning systems, and braking mechanisms, with tasks divided among team members for efficient development.

## Group Members
| No | Name              |
|----|-------------------|
| 1  | Syed Muhammad Afiq Idid  |
| 2  | Mohamad Hafiz |
| 3  | Darwis Shathibi [(GitHub)](https://github.com/darwishathibi)  |
| 4  | Wan Muhammad Hariz  |

## Instructor
Ts. Dr. Hafizah Binti Mansor

## Overview and Module

![image](https://github.com/user-attachments/assets/c2e71c9a-0ad4-4f9e-804c-14ab47ef4a7c)

### 1. Sensor Data Reading and Preprocessing Module (Darwis)
**Tasks**:
- Develop code to interface with the camera, speedometer, and LiDAR sensors.

**Components**:
- `read_camera()`
- `read_speedometer()`
- `read_lidar()`

---

### 2. Time-to-Collision (TTC) Calculation Module (Hariz)
**Tasks**:
- Implement the function to calculate Time-to-Collision (TTC) using preprocessed sensor data.
- Use relevant equations or algorithms to compute TTC.

**Components**:
- `calculate_TTC()`
- Handle logic for conditions like `TTC < FCW` and `TTC < PB_T`.

---

### 3. Warning System Module (Afiq)
**Tasks**:
- Develop logic to handle warnings:
  - Turn on the warning light if TTC is below the Forward Collision Warning (FCW) threshold.
  - Turn off the warning light otherwise.
- Display visual or audible warnings for the driver when required.

**Components**:
- `display_warning()`
- `turn_on_warning_light()`
- `turn_off_warning_light()`

---

### 4. Braking System Module (Hafiz)
**Tasks**:
- Implement the braking mechanism to apply brakes when `TTC < PB_T`.
- Ensure safety measures (e.g., gradually increase braking force, avoid abrupt stops).
- End the simulation after braking is applied.

**Components**:
- `apply_brake()`
- Handle the final exit logic (`end`).
