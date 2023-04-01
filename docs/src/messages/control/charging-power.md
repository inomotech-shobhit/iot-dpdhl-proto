# Charging Power

## SetChargingPowerRequest

The mqtt topic for this message type is: `<manufacturerId>/ctl/request/<boxId>/chargingPower`.  
At each point in time a vehicle can only store one instance of either SetChargingPowerRequest or SetChargingScheduleRequest.
There is no priority between SetChargingPowerRequest or SetChargingScheduleRequest, the newest instance of each is executed.
Requests get overwritten immediately when received and the timestamp of the previously set ChargingPowerRequest or
ChargingScheduleRequest is older than that of the received command, even if start and end of the stored and received
requests are not overlapping.
As soon as a request gets overwritten the vehicle will either start executing the new request if the current time is
between start and end of the request or apply fallback power.
If any charging schedule (using `SetChargingScheduleRequest`) is present in the vehicle this gets also permanently deleted.
After the end of the power request the vehicle will not continue executing any charging schedule previously set but will
go into fallback charging until a new power request or charging schedule is submitted.
Outside of the charging windows delimited by the fields start and end, the vehicle is expected to use fallback charging
power, if any was defined.
Even if the end time specified in the request is already in the past at time of reception or the request is invalid,
existing power request or schedules get deleted and fallback power is applied.

|   Field Name   | proto3 Type                                                | Short Description                    |
| :------------: | ---------------------------------------------------------- | ------------------------------------ |
|    request     | [RpcRequest][sts.v2.control.RpcRequest]                    | Request metadata                     |
|     start      | optional [google.protobuf.Timestamp]                       | Start of charging request            |
|      end       | [google.protobuf.Timestamp]                                | End of charging request              |
| max_ac_current | [sts.v2.ValuePerPhase]                                     | Current limitations for this request |

### Field Description: request

Contains request specific metadata. See [RpcRequest][sts.v2.control.RpcRequest]

### Field description: start

Optional field which describes the start time of the charging window. If not set, the charging window will start at
message reception.
The timestamp specified in this field must be earlier than the timestamp specified within end.

### Field description: end

This field describes the end of the charging window.
After the charging window has expired the vehicle will go into fallback charging if any fallback charging has been set.
The timestamp specified in this field must be later than the timestamp specified within start.

### Field description: max_ac_current

See [Current Limitations](./#current-limitations)

## SetChargingPowerResponse

The mqtt topic for this message type is: `<manufacturerId>/ctl/response/<boxId>/chargingPower`

|         Field Name         | proto3 Type                                                     | Short Description                |
| :------------------------: | --------------------------------------------------------------- | -------------------------------- |
|          response          | [RpcResponse][sts.v2.control.RpcResponse]                       | Response metadata                |
| realized_charging_schedule | [sts.v2.ValuePerPhase]                                          | Currents realized by the vehicle |

### Field Description: response

Contains response specific metadata. See [RpcResponse][sts.v2.control.RpcResponse]

### Field description: realized_charging_schedule

See [Realized Current Limitations](./#realized-current-limitations).
If the request could not be processed (e.g. due to an internal error or a bad request) this field is expected not to be set.

[google.protobuf.Timestamp]: https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Timestamp
[sts.v2.control.RpcRequest]: ./#rpcrequest
[sts.v2.control.RpcResponse]: ./#rpcresponse
[sts.v2.ValuePerPhase]: ../../protobuf-data-types.md#valueperphase
