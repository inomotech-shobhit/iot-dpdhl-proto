# Preconditioning Schedule

## SetPreconditioningScheduleRequest

The mqtt topic for this message type is: `<manufacturerId>/ctl/request/<box-id>/preconditioningSchedule`
At each point in time a vehicle can only store one PreconditioningSchedule.
Requests get overwritten immediately when received and the timestamp of the previously set PreconditioningSchedule is
older than that of the received command.

| Field Name                                                 | proto3 Type                                  | Short Description                                                                                    |
| :--------------------------------------------------------- | -------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| request                                                    | [RpcRequest][sts.v2.control.RpcRequest]      | Request metadata                                                                                     |
| preconditioning_schedule                                   | PreconditioningSchedule                      | Preconditioning schedule                                                                             |
| preconditioning_schedule.preconditioning_slices            | PreconditioningSlice                         | Individual preconditioning Events within the schedule                                                |
| preconditioning_slices.id                                  | uint32                                       | Consecutive number for the preconditioning events                                                    |
| preconditioning_slices.start                               | [google.protobuf.Timestamp]                  | Timestamp when the precondition for the specific event should start                                  |
| preconditioning_slices.duration                            | [google.protobuf.Duration]                   | Duration since start for which the preconditioning is valid                                          |
| preconditioning_slices.preconditioning_mode                | enum PreconditioningMode                     | Selects between heating and cooling                                                                  |
| preconditioning_slices.inhibit_soc                         | optional uint32                              | Provides a way to inhibit preconditioning below a certain state of charge                            |
| preconditioning_slices.inhibit_ambient_temperature_heating | optional uint32                              | Provides a way to inhibit preconditioning due to a certain temperature                               |
| preconditioning_slices.inhibit_ambient_temperature_cooling | optional uint32                              | Provides a way to inhibit preconditioning due to a certain temperature                               |
| preconditioning_slices.cabin_target_temperature            | optional uint32                              | Provides a way to specify an interior target temperature for vehicles with automatic climate control |

### Field Description: request

Contains request specific metadata. See [RpcRequest][sts.v2.control.RpcRequest].

### Field Description: preconditioning_schedule

Each preconditioning schedule consists of up to 8 preconditioning slices.
The `preconditioning_slices` are expected to be ordered by `preconditioning_slices.start`.
As `preconditioning_slices.id` is assigned consecutively by ascending order of `preconditioning_slices.start`, the
slices are therefore also ordered ascending by id.
`preconditioning_slices` are expected to never overlap.

### Field Description: preconditioning_slices.id

The id field is used to identify a specific slice within one schedule, enabling the
[VehiclePreconditioningStatus Message](../status.md#vehiclepreconditioningstatus) to reference individual slices.
Ids are consecutive starting at 1 and are assigned in ascending order by `preconditioning_slices.start`.

### Field Description: preconditioning_slices.start

Timestamp at which the preconditioning for this slice should start.

### Field Description: preconditioning_slices.duration

This field sets the duration for which the preconditioning should be executed in reference to `preconditioning_slices.start`.

### Field Description: preconditioning_slices.preconditioning_mode

This field defines the mode for the preconditioning to be executed:

| Enum Value                       | Description                                           |
| -------------------------------- | ----------------------------------------------------- |
| PRECONDITIONING_MODE_UNSPECIFIED | Should never be sent                                  |
| PRECONDITIONING_MODE_AUTO        | The vehicle should heat or cool the cabin as required |
| PRECONDITIONING_MODE_HEATING     | The vehicle should heat the cabin if required         |
| PRECONDITIONING_MODE_COOLING     | The vehicle should cool the cabin if required         |

### Field Description: preconditioning_slices.inhibit_soc

| proto3 Type | Unit  | Minimum Value | Maximum Value | Scaling Factor |
| ----------- | :---: | :-----------: | :-----------: | :------------: |
| uint32      |   %   |       0       |      100      |       10       |

This optional field specifies a minimum State of Charge required for the preconditioning to start.
This value is only evaluated at the start of the preconditioning.
Dropping below while preconditioning will not cancel the ongoing preconditioning.

### Field Description: preconditioning_slices.inhibit_ambient_temperature_heating

| proto3 Type | Unit  | Minimum Value | Maximum Value | Scaling Factor |
| ----------- | :---: | :-----------: | :-----------: | :------------: |
| sint32      |  °C   |    -273.2     |     None      |       10       |

This optional field specifies a maximum temperature above which the preconditioning in `PRECONDITIONING_MODE_HEATING`
will not start.
If `PRECONDITIONING_MODE_AUTO` is set the vehicle will not heat the cabin if the ambient temperature at the start of the
preconditioning is above the set value.
This value is only evaluated at the start of the preconditioning.
Rising above while preconditioning will not cancel the ongoing preconditioning.

### Field Description: preconditioning_slices.inhibit_ambient_temperature_cooling

| proto3 Type | Unit  | Minimum Value | Maximum Value | Scaling Factor |
| ----------- | :---: | :-----------: | :-----------: | :------------: |
| sint32      |  °C   |    -273.2     |     None      |       10       |

This optional field specifies a maximum temperature below which the preconditioning in `PRECONDITIONING_MODE_COOLING`
will not start.
If `PRECONDITIONING_MODE_AUTO` is set the vehicle will not cool the cabin if the ambient temperature at the start of the
preconditioning is below the set value.
This value is only evaluated at the start of the preconditioning.
Dropping below while preconditioning will not cancel the ongoing preconditioning.

### Field Description: preconditioning_slices.cabin_target_temperature

| proto3 Type | Unit  | Minimum Value | Maximum Value | Scaling Factor |
| ----------- | :---: | :-----------: | :-----------: | :------------: |
| sint32      |  °C   |    -273.2     |     None      |       10       |

For vehicles without automatic climate control: This field is ignored.
Preconditioning will **always** stop after the time specified by `duration` even if the `cabin_target_temperature` has
not been reached.
Heating/Cooling is done as specified in preconditioning_slices.preconditioning_mode.
For vehicles with automatic climate control: this field specifies a desired cabin temperature.

```admonish info
This field is required when using `PRECONDITIONING_MODE_AUTO`.
```

## SetPreconditioningScheduleResponse

The mqtt topic for this message type is: `<manufacturerId>/ctl/response/<box-id>/preconditioningSchedule`

| Field Name | proto3 Type                               | Short Description |
| :--------- | ----------------------------------------- | ----------------- |
| response   | [RpcResponse][sts.v2.control.RpcResponse] | Response metadata |

### Field Description: response

Contains response specific metadata. See [RpcResponse][sts.v2.control.RpcResponse]

[google.protobuf.Duration]: https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Duration
[google.protobuf.Timestamp]: https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Timestamp
[sts.v2.control.RpcRequest]: ./#rpcrequest
[sts.v2.control.RpcResponse]: ./#rpcresponse
