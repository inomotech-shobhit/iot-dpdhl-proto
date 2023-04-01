# Charge Statistics

Starts as soon as the vehicle is plugged in and ends once it is unplugged again.

Topic Layout: `<manufacturerId>/C/<boxId>`

## Message Fields

| Field Name         | proto3 Type     | Unit | Description                                                                           |
|--------------------|-----------------|------|---------------------------------------------------------------------------------------|
| vin                | string          |      | Vehicle identification number                                                         |
| timestamp_start    | uint32          | s    | Unix time the charging started at                                                     |
| timestamp_end      | uint32          | s    | Unix time the charging ended at                                                       |
| soc_percent_start  | float           | %    | State of charge in percent at the start                                               |
| soc_percent_end    | float           | %    | State of charge in percent at the end                                                 |
| ac_energy          | optional uint32 | kW⋅h | Total AC energy flowing from the charging station [^ac_energy]                        |
| dc_energy          | optional float  | kW⋅h | Total DC energy flowing to the battery [^dc_energy]                                   |
| pac_avg            | optional uint32 | W    | Mean power during charging                                                            |
| pac_max            | optional float  | W    | Max power during charging                                                             |
| lat                | optional float  | °    | Latitude the vehicle was charging at                                                  |
| lon                | optional float  | °    | Longitude the vehicle was charging at                                                 |

[^ac_energy]: $ \int_{t_{start}}^{t_{end}}P_{AC}(t)dt $

[^dc_energy]: $ \int_{t_{start}}^{t_{end}}P_{DC}(t)dt $
