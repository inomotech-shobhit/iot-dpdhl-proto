# Protobuf Data Types

This section describes the proto3 data types used to transmit the messages specified in the Vehicle Communication
Protocol Version 2.

## General

The protobuf definition for the general message types can be found in the `sts/v2/types.proto` file.

### ValuePerPhase

This message is used to encapsulate measurements taken from a circuit with up to three phases.

| Field # |  Name  | Modifier | Type  | Description                                             |
| :-----: | :----: | -------- | ----- | :------------------------------------------------------ |
|    1    | phase1 | optional | int32 | Provides a value for phase 1 of a multi phase AC system |
|    2    | phase2 | optional | int32 | Provides a value for phase 2 of a multi phase AC system |
|    3    | phase3 | optional | int32 | Provides a value for phase 3 of a multi phase AC system |

```admonish info
All values are optional, if the given measurement is not available at the measuring entity
(e.g. phase3 for a vehicle with 2 phases) the value shall be omitted. If the value is available but the measurement is
0, a 0 value shall be transmitted.
```

## Services

Services are provided by the vehicle to allow the backend to send requests.
This section only gives a overview of the message types and their respective fields.
For semantic specification see [Control Messages](messages/control/)

### General Pattern

Each service request has a corresponding service response defined in the proto3 service definition.

#### RpcIdentifier

Both, request and response share a field called rpc_id of this type.

| Field # |   Name    | Modifier | Type                           | Description                                      |
| :-----: | :-------: | -------- | ------------------------------ | :----------------------------------------------- |
|    1    |    id     |          | bytes                          | Correlation Id between request and response      |
|    2    | timestamp |          | [google.protobuf.Timestamp][1] | Timestamp at which the request/response was sent |

#### RpcRequest

This message type is used as a field in all request messages.

| Field # |  Name  | Modifier | Type               | Description         |
| :-----: | :----: | -------- | ------------------ | :------------------ |
|    1    | rpc_id |          | [RpcIdentifier][3] | Request information |

#### RpcResponse

This message type is used as a field in all response messages.

| Field # |  Name  | Modifier | Type               | Description          |
| :-----: | :----: | -------- | ------------------ | :------------------- |
|    1    | rpc_id |          | [RpcIdentifier][3] | Response information |
|    2    | status |          | RpcStatus          | Response status      |

### VehiclePreconditioningService

This service allows for control of a vehicles cabin preconditioning.

### VehiclePowerService

This service allows for control of a vehicles power and charging settings.

## VehicleStatus

### Signal

The Signal message type is used to transmit non aggregated data.
For semantic field specification see the actual [status message definitions](messages/status.md).
The protobuf definition for the general message types can be found in the `sts/v2/vehicle_status/signal.proto` file.

This message represents a singular measurement or status change

| Field# | Name      | Type                           | Modifiers | Description                                                                      |
| :----: | --------- | ------------------------------ | --------- | :------------------------------------------------------------------------------- |
|   1    | timestamp | [google.protobuf.Timestamp][1] |           | Timestamp at which the measurement was taken                                     |
|   2    | value     |                                | oneof*    | Actual type dependent on the type of measurement transmitted within this message |

```admonish info
**Exactly one** of the permitted types listed below has to be present.
```

The following types, messages and enumerations are encapsulated within the value field:

| Name                   | Type                  | Description                                                             |
| ---------------------- | --------------------- | ----------------------------------------------------------------------- |
| text                   | string                | Generic text message                                                    |
| real_number            | double                | Generic floating point message                                          |
| integer_number         | sint64                | Generic integer message                                                 |
| position               | Position              | GPS position                                                            |
| charge_plug_status     | ChargePlugStatus      | Information about the vehicle's charge plug                             |
| online_status          | OnlineStatus          | Information about the vehicle's connection with the backend             |
| ignition_status        | IgnitionStatus        | Information about the vehicle's ignition state                          |
| preconditioning_status | PreconditioningStatus | Information about the state of the cabin preconditioning                |
| charging_dc_power_max  | ChargingDcPowerMax    | Information about the vehicle's maximum achievable dc charging power    |
| value_per_phase        | [ValuePerPhase][2]    | Generic multi phase measurement message                                 |
| ac_current_realized    | ACCurrentRealized     | Information about the current limits the vehicle is currently realizing |

[1]: https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Timestamp
[2]: #valueperphase
[3]: #rpcidentifier
