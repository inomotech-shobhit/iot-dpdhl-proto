# Drive Statistics

Starts when the ignition is turned on and the vehicle is unplugged. Ends when the vehicle is plugged in or the ignition
is turned off and remains off for at least 30 minutes.

Topic Layout: `<manufacturerId>/A/<boxId>`

## Message Fields

The fields are documented in multiple clusters. They're all part of the same message.

### Basic

| Field Name         | proto3 Type     | Unit | Description                                              |
|--------------------|-----------------|------|----------------------------------------------------------|
| vin                | string          |      | Vehicle identification number                            |
| timestamp_start    | uint32          | s    | Unix time the drive started at                           |
| timestamp_end      | uint32          | s    | Unix time the drive ended at                             |
| km_start           | float           | km   | Kilometer reading at the start of the drive              |
| km_end             | float           | km   | Kilometer reading at the end of the drive                |
| soc_percent_start  | float           | %    | State of charge at the start of the drive                |
| soc_percent_end    | float           | %    | State of charge at the end of the drive                  |
| driving_time       | optional float  | s    | Total driving time in seconds                            |
| belt_use_count     | optional uint32 |      | Amount of times the driver seat belt was used            |
| hand_brake_count   | optional uint32 |      | Amount of times the hand brake was engaged               |
| delivery_stops     | optional uint32 |      | Amount of times the vehicle stopped for a delivery       |

### Ignition

| Field Name         | proto3 Type     | Unit | Description                                              |
|--------------------|-----------------|------|----------------------------------------------------------|
| ignition_count     | optional uint32 |      | Amount of times the ignition was turned on               |
| ignition_time      | optional float  | s    | Total duration in seconds the ignition was turned on for |

### Drive Mode

| Field Name         | proto3 Type     | Unit | Description                                              |
|--------------------|-----------------|------|----------------------------------------------------------|
| drivemode_d_time   | optional float  | s    | Time in seconds spent in drive mode D                    |
| drivemode_n_time   | optional float  | s    | Time in seconds spent in drive mode N                    |
| drivemode_r_time   | optional float  | s    | Time in seconds spent in drive mode R                    |
| drivemode_e_time   | optional float  | s    | Time in seconds spent in drive mode E                    |
| drivemode_p_time   | optional float  | s    | Time in seconds spent in drive mode P                    |

### Energy

| Field Name         | proto3 Type     | Unit | Description                                              |
|--------------------|-----------------|------|----------------------------------------------------------|
| energy_integrated  | optional float  | kW⋅h | Total energy used                                        |
| recuperated_energy | optional float  | kW⋅h | Energy in kWh recuperated                                |

### Door

| Field Name         | proto3 Type     | Unit | Description                                              |
|--------------------|-----------------|------|----------------------------------------------------------|
| door_open_count    | optional uint32 |      | Amount of times any of the doors were open               |
| door_lock_count    | optional uint32 |      | Amount of times the doors were locked                    |

### Position

| Field Name         | proto3 Type     | Unit | Description                                              |
|--------------------|-----------------|------|----------------------------------------------------------|
| lat_start          | optional float  | °    | Latitude of the vehicle at the start of the drive        |
| lon_start          | optional float  | °    | Longitude of the vehicle at the start of the drive       |
| lat_end            | optional float  | °    | Latitude of the vehicle at the end of the drive          |
| lon_end            | optional float  | °    | Longitude of the vehicle at the end of the drive         |

### Speed

| Field Name         | proto3 Type     | Unit | Description                                              |
|--------------------|-----------------|------|----------------------------------------------------------|
| speed_max          | optional float  | km/h | Max speed in km/h                                        |
| speed_avg          | optional float  | km/h | Average speed in km/h when the vehicle was running       |
