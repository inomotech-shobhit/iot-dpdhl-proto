# Charging Schedule

## SetChargingScheduleRequest

The mqtt topic for this message type is: `<manufacturerId>/ctl/request/<boxId>/chargingSchedule`
At each point in time a vehicle can only store one instance of either SetChargingPowerRequest or SetChargingScheduleRequest.
There is no priority between SetChargingPowerRequest or SetChargingScheduleRequest, the newest instance of each is executed.
Requests get overwritten immediately when received and the timestamp of the previously set ChargingPowerRequest or
ChargingScheduleRequest is older than that of the received command.

```admonish warning
Even if the schedule in the request is already in the past at time of reception or is invalid, existing power request
or schedules get deleted and fallback power is applied.
```

| Field Name                     | proto3 Type                             | Short Description                                           |
| :----------------------------- | --------------------------------------- | ----------------------------------------------------------- |
| request                        | [RpcRequest][sts.v2.control.RpcRequest] | Request metadata                                            |
| charging_schedule              | ChargingSchedule                        | 24 hour charging schedule                                   |
| charging_schedule.power_slices | repeated PowerSlice                     | Individual current limitations within the charging schedule |
| power_slices.id                | uint32                                  | Consecutive number for the power slices                     |
| power_slices.start             | [google.protobuf.Timestamp]             | Timestamp stating the validity of this slice                |
| power_slices.max_ac_current    | [sts.v2.ValuePerPhase]                  | Current limitations of this slice                           |

### Field Description: request

Contains request specific metadata. See [RpcRequest][sts.v2.control.RpcRequest]

### Field Description: charging_schedule

A charging schedule consists of a sequence of power slices.
Each charging schedule is valid until 24 h after the start timestamp of the first power slice.
The power slices are expected to be ordered by `power_slices.start`.
As `power_slices.id` is assigned consecutively by ascending order of `power_slices.start`, the slices are therefore also
ordered ascending by id.
As long as the current time from vehicle is not within the time window defined by the first `power_slice.start` and first
`power_slice.start + 24h`, the vehicle is expected to use fallback charging power, if any was defined.

### Field Description: charging_schedule.power_slices

This field is expected to contain up to 128 power slices.
A power slice is valid from it's start until the start of the subsequent slice.

### Field Description: power_slices.id

The id field is used to identify a specific slice within one schedule, enabling the response to reference individual slices.
Ids are consecutive starting at 1 and are assigned in ascending order by `start`.

### Field Description: power_slices.start

This field describes the start of the valid period for this power slice.

### Field Description: power_slices.max_ac_current

See [Current Limitations](./#current-limitations)

## SetChargingScheduleResponse

The mqtt topic for this message type is: `<manufacturerId>/ctl/response/<boxId>/chargingSchedule`

| Field Name                              | proto3 Type                               | Short Description                         |
| :-------------------------------------- | ----------------------------------------- | ----------------------------------------- |
| response                                | [RpcResponse][sts.v2.control.RpcResponse] | Response metadata                         |
| realized_charging_schedule              | optional ChargingSchedule                 | Charging schedule realized by the vehicle |
| realized_charging_schedule.power_slices | repeated PowerSlice                       | Slices realized by the vehicle            |
| power_slices.id                         | uint32                                    | Consecutive number for the power slices   |
| power_slices.start                      | [google.protobuf.Timestamp]               | Shall not be set                          |
| power_slices.max_ac_current             | [sts.v2.ValuePerPhase]                    | Current limitations of this slice         |

### Field Description: response

Contains response specific metadata. See [RpcResponse][sts.v2.control.RpcResponse]

### Field Description: realized_charging_schedule

This field is expected to contain the same number of slices present in the request.
Requests containing more than 128 slices should be responded to using [RpcResponse.Status][sts.v2.control.RpcResponse]
set to `RPC_STATUS_BAD_REQUEST`.
If the request could not be processed (e.g. due to an internal error or a bad request) this field is expected not to be set.

### Field Description: power_slices.id

For each `power_slices.id` present in the [SetChargingScheduleRequest](#setchargingschedulerequest) a respective
power slice with matching id should be present.

### Field Description: power_slices.start

This field is ignored by the receiver. To reduce transmitted data volume, the sender is expected not to set this field.

## SetFallbackChargingScheduleRequest

The mqtt topic for this message type is: `<manufacturerId>/ctl/request/<boxId>/fallbackChargingSchedule`

A fallback charging schedule is used to define a charging schedule which is executed when the vehicle cannot communicate
with the backend.
As long as there is no valid charging schedule or charging power setting, the fallback charging schedule becomes valid.
The fallback charging schedule is repeated every day and the individual slices are defined in reference to midnight.
At each point in time a vehicle can only store one FallbackChargingSchedule.
Requests get overwritten immediately when received and the timestamp of the previously set FallbackChargingSchedule is
older than that of the received command.

| Field Name                                       | proto3 Type                             | Short Description                                  |
| :----------------------------------------------- | --------------------------------------- | -------------------------------------------------- |
| request                                          | [RpcRequest][sts.v2.control.RpcRequest] | Request metadata                                   |
| fallback_charging_schedule                       | FallbackChargingSchedule                | Fallback charging schedule repeating every 24 h    |
| fallback_charging_schedule.fallback_power_slices | repeated FallbackPowerSlice             | Individual current limitations within the schedule |
| fallback_power_slices.id                         | uint32                                  | Consecutive number for the power slices            |
| fallback_power_slices.offset_from_midnight       | [google.protobuf.Duration]              | Offset since midnight                              |
| fallback_power_slices.max_ac_current             | [sts.v2.ValuePerPhase]                  | Currents realized by the vehicle                   |

### Field Description: request

Contains request specific metadata. See [RpcRequest][sts.v2.control.RpcRequest]

### Field Description: fallback_charging_schedule.fallback_power_slices

This field is expected to contain up to 128 fallback power slices.
Slices are ordered ascending by their `offset_from_midnight` and implicitly by their id.

### Field Description: fallback_power_slices.id

The id field is used to identify a specific slice within one schedule, enabling the response to reference individual slices.
Ids are consecutive starting at 1 and are assigned in ascending order by `offset_from_midnight`.

### Field Description: fallback_power_slices.offset_from_midnight

The first power slice's `offset_from_midnight` should always be 0 so it is valid since midnight.
The valid period for a slice begins with it's `offset_from_midnight` and end with the `offset_from_midnight` of the
following slice.
The `offset_from_midnight` has to be smaller than 24 h.
There shall not be any duplicate slices with the same value for `offset_from_midnight`.
The last slice within a `FallbackChargingSchedule` is valid until midnight the next day, at which the schedule will
repeat itself.

### Field Description: fallback_power_slices.max_ac_current

See [Current Limitations](./#current-limitations)

## SetFallbackChargingScheduleResponse

The mqtt topic for this message type is: `<manufacturerId>/ctl/response/<boxId>/fallbackChargingSchedule`

| Field Name                                                | proto3 Type                               | Short Description                         |
| :-------------------------------------------------------- | ----------------------------------------- | ----------------------------------------- |
| response                                                  | [RpcResponse][sts.v2.control.RpcResponse] | Response metadata                         |
| realized_fallback_charging_schedule                       | optional FallbackChargingSchedule         | Fallback schedule realized by the vehicle |
| realized_fallback_charging_schedule.fallback_power_slices | repeated FallbackPowerSlice               | Slices realized by the vehicle            |
| fallback_power_slices.id                                  | uint32                                    | Consecutive number for the power slices   |
| fallback_power_slices.offset_from_midnight                | [google.protobuf.Duration]                | Shall not be set                          |
| fallback_power_slices.max_ac_current                      | [sts.v2.ValuePerPhase]                    | Current limitations of this slice         |

### Field Description: response

Contains response specific metadata. See [RpcResponse][sts.v2.control.RpcResponse]

### Field Description: realized_fallback_charging_schedule

This field is expected to contain the same number of slices present in the request.
Requests containing more than 128 slices should be responded to using [RpcResponse.Status][sts.v2.control.RpcResponse]
set to `RPC_STATUS_BAD_REQUEST`.
If the request could not be processed (e.g. due to an internal error or a bad request) this field is expected not to be set.

### Field Description: fallback_power_slices.id

For each `fallback_power_slice.id` present in the [SetFallbackChargingScheduleRequest](#setfallbackchargingschedulerequest)
a respective fallback power slice with matching id should be present.

### Field Description: fallback_power_slices.offset_from_midnight

This field is ignored by the receiver. To reduce transmitted data volume, the sender is expected not to set this field.

### Field Description: fallback_power_slices.max_ac_current

See [Realized Current Limitations](./#realized-current-limitations)

[google.protobuf.Duration]: https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Duration
[google.protobuf.Timestamp]: https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Timestamp
[sts.v2.control.RpcRequest]: ./#rpcrequest
[sts.v2.control.RpcResponse]: ./#rpcresponse
[sts.v2.ValuePerPhase]: ../../protobuf-data-types.md#valueperphase
