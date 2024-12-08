# CSCI3301-AEBS-SIMULATION

## Sensor-Based Collision Avoidance System

### 1. Sensor Data Reading and Preprocessing Module (Darwis)
**Tasks**:
- Develop code to interface with the camera, speedometer, and LiDAR sensors.
- Implement preprocessing steps for data received from each sensor (e.g., filtering noise or normalizing data).

**Components**:
- `read_camera()`
- `read_speedometer()`
- `read_lidar()`
- `sensor_preprocessing_data()`

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
