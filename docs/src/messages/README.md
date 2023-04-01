# Messages

## Message Parameters

The following section describes message parameters used in both control and status messages.

### Scaling Factors

Message definitions for numeric parameters such as temperatures or percentages often include a scaling factor to allow
for integer fields to be used during transmission and to save space on unneeded precision.
Measurement values are calculated using the following formula:

$ v_{real} =v_{message}/scalingfactor $

$ v_{message} =round(v_{real}*scalingfactor) $

Where $ round(x) = \lfloor x + 0.5 \rfloor $

```admonish example title="Example for VehicleAmbientTemperature"
Measurement: 16.76 °C ➡ scaling and rounding ➡ `Signal.value`: 168 ➡ Transmission ➡ Value interpreted by the backend: 16.8 °C
```

### Maximum / Minimum Values

The maximum and minimum value properties of message fields relate to the actual measurement value not the scaled
representation in the protobuf message.
If either the minimum or the maximum value isn't specified, the limit of the underlying protobuf type is used. In these
cases, clients aren't expected to validate the value against the missing bound.

Example:

A signal message for `VehicleStateOfCharge` containing a value of 1001 is invalid because after applying the scaling
factor of 10 this would result in a measurement value of 100.1 % which is above the 100 % maximum value.

### Timestamps

All timestamps within this protocol are expected to be in UTC unless specified otherwise.

### Phase Numbering

Phases are numbered according to their position in the vehicle's charge socket (e.g. L1 in a Type 2 socket is Phase 1
in this specification).
