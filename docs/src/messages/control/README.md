# Control Messages

Control messages allow the backend to issue requests to the vehicle in a request/response pattern.

## General Behavior

This section explains the general behavior which is shared between all control messages.

### Current Limitations

Current limitations are used by multiple messages such as `SetChargingPowerRequest`, `SetChargingScheduleRequest`,
`SetFallbackChargingScheduleRequest` and are therefore defined in this section.

For the proto3 type see [sts.v2.ValuePerPhase].

| Field Name | proto3 Type    | Unit  | Minimum Value  | Maximum Value | Scaling Factor |
| :--------: | -------------- | :---: | :------------: | :-----------: | :------------: |
|   phase1   | optional int32 |   A   |      None      |     None      |      100       |
|   phase2   | optional int32 |   A   |      None      |     None      |      100       |
|   phase3   | optional int32 |   A   |      None      |     None      |      100       |

Positive values describe an AC charging current limit on the specific phase, the vehicle is not allowed to surpass.
When receiving a positive limit, the vehicle is not allowed to provide power to the grid.
Negative values describe an AC discharging current limit on the specific phase, the vehicle is not allowed to surpass.
When receiving a negative limit, the vehicle is not allowed to receive power from the grid.
Negative values for the current limit's are only set if the vehicle supports power to grid.
The vehicle is expected to match the given limits as close as possible.

### Realized Current Limitations

Current limitations are used by multiple messages such as `SetChargingPowerResponse`, `SetChargingScheduleResponse`,
`SetFallbackChargingScheduleResponse` and are therefore defined in this section.

For the proto3 type see [sts.v2.ValuePerPhase].

| Field Name | proto3 Type    | Unit  | Minimum Value  | Maximum Value | Scaling Factor |
| :--------: | -------------- | :---: | :------------: | :-----------: | :------------: |
|   phase1   | optional int32 |   A   |      None      |     None      |      100       |
|   phase2   | optional int32 |   A   |      None      |     None      |      100       |
|   phase3   | optional int32 |   A   |      None      |     None      |      100       |

The message contains the current limits actually applied by the vehicle.
For example if on phase 1 a limit of 5.9 A was requested, however the vehicle can only limit the amperage on multiples of
1 A the response field will contain 5 A.
The response values are only dependent on static limitations set by the charging system such as minimum current, maximum
current or resolution.
Dynamic restrictions such as temperatures or state of charge are not taken into account when determining the Realized
Current Limitations.

### Command Timeout

When receiving a command message the vehicle will use the set [command_timeout](./vehicle-configuration.md#setvehicleconfigurationrequest)
to determine if a command is still valid.
If the timestamp specified inside the [RpcIdentifier](#rpcidentifier) which is sent with every request / response is
within the interval of:

$ \lbrack time - command\_timeout, time + command\_timeout \rbrack $

Where $ time $ is the current Unix time (Seconds since the Unix epoch assuming UTC).

then the command is considered valid. If the timestamp is outside of that range the command is considered as invalid.
If the command was a request an appropriate response using [RpcResponse.status](#rpcresponse) set to
`RPC_STATUS_COMMAND_TIMEOUT` should be sent.

### Common subtypes

This section contains the specification of messages used by the control messages to transport information about the request/response.

#### RpcIdentifier

This message type is used as a field in all requests/responses to provide common metadata.

##### Message Fields

| Field Name | proto3 Type                    | Description                                                      |
| :--------: | ------------------------------ | :--------------------------------------------------------------- |
|     id     | bytes                          | Used for correlation between request and response                |
|   client   | RpcClient                      | Used to signal the type of client sending the request / response |
| timestamp  | [google.protobuf.Timestamp]    | Timestamp at which the request/response was sent                 |

##### Field Description: id

Requests are matched to responses first by a pair of topics names and the box id encoded within the topic name.
Within a specific pair message of request and response type as well as box id specific topic mqtt topic, requests and
responses are correlated by their RpcIdentifier.id

Example:
For an example preconditioning request to a vehicle with an attached telematic unit with box id `sts-tcu1234` the following
parameters are used to correlate request and response.

* Request parameters
  * Topic: `ctl/request/sts-tcu1234/preconditioning`
  * id: `135e0b1188d84b26b3301425fcc90df5`
* Response Parameters
  * Topic: `ctl/response/sts-tcu1234/preconditioning`
  * id: `135e0b1188d84b26b3301425fcc90df5`

##### Field Description: client

| Enum Value                        | Description                            |
| --------------------------------- | -------------------------------------- |
| RPC_CLIENT_UNSPECIFIED            | Should never be sent                   |
| RPC_CLIENT_GX_DEV_TOOL            | Generic developer tool                 |
| RPC_CLIENT_GX_CHARGING_CONTROLLER | Generic charging controller            |
| RPC_CLIENT_WK_LLW                 | Ladeleitwarte (com.streetscooter.llw)  |
| RPC_CLIENT_WK_LULM                | Lade und Lastmanagement (com.iav.lulm) |
| RPC_CLIENT_WK_RAMPHASTOS          | Ramphastos (com.inomotech.ramphastos)  |
| RPC_CLIENT_VEHICLE                | The sending client is a vehicle        |

For responses by the vehicle the value shall be set to `RPC_CLIENT_VEHICLE`.

##### Field Description: timestamp

The timestamp is set to when the request/response is sent.
The timestamp is expected to be set in UTC.

#### RpcRequest

This message type is used as a wrapper for all metadata sent along with a request.

| Field Name | proto3 Type                     | Description                       |
| :--------: | ------------------------------- | :-------------------------------- |
|   rpc_id   | [RpcIdentifier](#rpcidentifier) | General request/response metadata |

#### RpcResponse

This message type is used as a wrapper for all metadata sent along with a response.

| Field Name | proto3 Type                     | Description                                   |
| :--------: | ------------------------------- | :-------------------------------------------- |
|   rpc_id   | [RpcIdentifier](#rpcidentifier) | General request/response metadata             |
|   status   | enum `RpcStatus`                | Response information to the submitted request |
|  message   | optional string                 | Custom message                                |

##### Field Description: status

The status field gives the requesting entity information about the state of the received request.

| Enum Value                 | Description                                                                |
| -------------------------- | -------------------------------------------------------------------------- |
| RPC_STATUS_UNSPECIFIED     | Should never be sent                                                       |
| RPC_STATUS_OK              | Request was processed successfully                                         |
| RPC_STATUS_BAD_REQUEST     | Malformed request                                                          |
| RPC_STATUS_UNIMPLEMENTED   | The receiving party does not support the requested feature                 |
| RPC_STATUS_INTERNAL_ERROR  | The request could not be processed correctly due to an internal error      |
| RPC_STATUS_COMMAND_TIMEOUT | The command received was not within the specified command timeout interval |

##### Field Description: message

Can be used by during implementation to deliver custom messages with the response. (e.g. error details)

### Topics

The following table describes the available pairs of request and response types as well as their topic identifiers.

All topics follow the pattern `ctl/request/<boxId>/<type>`.

| Request /<br>Response Message                                                 | `<type>`                   |
|-------------------------------------------------------------------------------|----------------------------|
| [SetChargingPowerRequest]<br>[SetChargingPowerResponse]                       | `chargingPower`            |
| [SetChargingScheduleRequest]<br>[SetChargingScheduleResponse]                 | `chargingSchedule`         |
| [SetFallbackChargingScheduleRequest]<br>[SetFallbackChargingScheduleResponse] | `fallbackChargingSchedule` |
| [SetPreconditioningScheduleRequest]<br>[SetPreconditioningScheduleResponse]   | `preconditioningSchedule`  |
| [SetVehicleConfigurationRequest]<br>[SetVehicleConfigurationResponse]         | `vehicleConfiguration`     |

[SetChargingPowerRequest]:             ./charging-power.md#setchargingpowerrequest
[SetChargingPowerResponse]:            ./charging-power.md#setchargingpowerresponse
[SetChargingScheduleRequest]:          ./charging-schedule.md#setchargingschedulerequest
[SetChargingScheduleResponse]:         ./charging-schedule.md#setchargingscheduleresponse
[SetFallbackChargingScheduleRequest]:  ./charging-schedule.md#setfallbackchargingschedulerequest
[SetFallbackChargingScheduleResponse]: ./charging-schedule.md#setfallbackchargingscheduleresponse
[SetPreconditioningScheduleRequest]:   ./preconditioning-schedule.md#setpreconditioningschedulerequest
[SetPreconditioningScheduleResponse]:  ./preconditioning-schedule.md#setpreconditioningscheduleresponse
[SetVehicleConfigurationRequest]:      ./vehicle-configuration.md#setvehicleconfigurationrequest
[SetVehicleConfigurationResponse]:     ./vehicle-configuration.md#setvehicleconfigurationresponse

[google.protobuf.Timestamp]: https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Timestamp
[sts.v2.ValuePerPhase]:      ../../protobuf-data-types.md#valueperphase
