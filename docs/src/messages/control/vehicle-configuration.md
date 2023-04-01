# Vehicle Configuration

## SetVehicleConfigurationRequest

The mqtt topic for this message type is: `<manufacturerId>/ctl/request/<boxId>/vehicleConfiguration`
This message is used to set specific parameters in a vehicle and to get the current configuration.
If a specific section or value should not be changed, it is omitted from the request.
For getting the current configuration all optional top level fields should be omitted.

| Field Name                                               | proto3 Type                              | Short Description                                               | Default Value |
| :------------------------------------------------------- | ---------------------------------------- | --------------------------------------------------------------- | :-----------: |
| request                                                  | [RpcRequest][sts.v2.control.RpcRequest]  | Request metadata                                                |      n/a      |
| vehicle_general_configuration                            | optional SetVehicleGeneralConfiguration  | General vehicle configuration                                   |      n/a      |
| vehicle_general_configuration.command_timeout            | optional [google.protobuf.Duration]      | Used to set the time a vehicle will consider a command as valid |     30 s      |
| vehicle_position_configuration                           | optional SetVehiclePositionConfiguration | Configuration for the `VehiclePositionStatus` Message           |      n/a      |
| vehicle_position_configuration.on_change_distance        | optional uint32                          | Used to configure triggering by location change                 |       0       |
| vehicle_position_configuration.send_on_change_plugged_in | optional bool                            | Switch to enable triggering by charge plug message              |     false     |
| vehicle_position_configuration.send_on_change_ignition   | optional bool                            | Switch to enable triggering by ignition message                 |     false     |
| vehicle_position_configuration.minimum_sending_period    | optional [google.protobuf.Duration]      | Configurable minimum sending period                             |       0       |

### Field Description: request

Contains request specific metadata. See [RpcRequest][sts.v2.control.RpcRequest]

### Field Description: vehicle_general_configuration

Used to set general settings for the vehicle.

### Field Description: vehicle_general_configuration.command_timeout

This field is used to set a duration which is used by the vehicle to determine the validity of a command message.
See [Command Timeout](./#command-timeout) for details.

### Field Description: vehicle_position_configuration

This section contains settings for the [VehiclePositionStatus](../status.md#vehiclepositionstatus) message.

### Field Description: vehicle_position_configuration.on_change_distance

This field describes the minimum distance in respect to the last transmitted message to trigger a sending on change.
If this is set to 0, no message will be triggered due to changes in distance.

| proto3 Type | Unit  | Minimum Value | Maximum Value | Scaling Factor |
| ----------- | :---: | :-----------: | :-----------: | :------------: |
| uint32      |   m   |       0       |      None     |       1        |

### Field Description: vehicle_position_configuration.send_on_change_plugged_in

If this is set to `true`, a position message gets sent directly after a
[VehicleChargePlugStatus](../status.md#vehiclechargeplugstatus) message was sent, disregarding the `on_change_distance`
but still observing the rate limits.

### Field Description: vehicle_position_configuration.send_on_change_ignition

If this is set to `true`, a position message gets sent directly after a
[VehicleIgnitionStatus](../status.md#vehicleignitionstatus) message was sent, disregarding the `on_change_distance` but
still observing the rate limits.

### Field Description: vehicle_position_configuration.minimum_sending_period

This field configures the minimum sending period for the [VehiclePositionStatus](../status.md#vehiclepositionstatus) message.
A duration of 0 will disable triggering messages due to the minimum_sending_period.

## SetVehicleConfigurationResponse

The mqtt topic for this message type is: `<manufacturerId>/ctl/response/<boxId>/vehicleConfiguration`
This message contains the current configuration of the vehicle.

| Field Name                                               | proto3 Type                               | Short Description                                                             |
| :------------------------------------------------------- | ----------------------------------------- | ----------------------------------------------------------------------------- |
| response                                                 | [RpcResponse][sts.v2.control.RpcResponse] | Response Metadata                                                             |
| vehicle_general_configuration                            | `GetVehicleGeneralConfiguration`          | General vehicle configuration                                                 |
| vehicle_general_configuration.command_timeout            | [google.protobuf.Duration]                | Contains the current value for the command timeout set in the vehicle         |
| vehicle_position_configuration                           | `GetVehiclePositionConfiguration`         | Configuration for the VehiclePositionStatus message                           |
| vehicle_position_configuration.on_change_distance        | uint32                                    | Information about the on change triggering                                    |
| vehicle_position_configuration.send_on_change_plugged_in | bool                                      | Status of the on change sending when the vehicle's plug status is changed     |
| vehicle_position_configuration.send_on_change_ignition   | bool                                      | Status of the on change sending when the vehicle's ignition status is changed |
| vehicle_position_configuration.minimum_sending_period    | [google.protobuf.Duration]                | Information about the minimum sending period                                  |

```admonish info
For descriptions of fields shared with the request see [SetVehicleConfigurationRequest](#setvehicleconfigurationrequest)
```

### Field Description: response

Contains response specific metadata. See [RpcResponse][sts.v2.control.RpcResponse]

[google.protobuf.Duration]: https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Duration
[sts.v2.control.RpcRequest]: ./#rpcrequest
[sts.v2.control.RpcResponse]: ./#rpcresponse
