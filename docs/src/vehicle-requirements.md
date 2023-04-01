# Vehicle Requirements

This document describes the requirements to the vehicles with respect to general behavior and behavior required for
different features in the charge and load management.
Also required input data for the charge and load management are defined.

## General Requirements and Vehicle Behavior

The following section defines the mandatory vehicle behavior and required vehicle data such that it can be controlled by
the charge and load management.

### General Vehicle Behavior

**Communication readiness:**
During driving or as long as the charging plug is connected to the charging point, the vehicle has to be able to send and
receive messages to and from the charge and load management.

**Amperage limits:**
The amperage limits are defined in the control messages [`SetChargingPowerRequest`][sts.v2.control.SetChargingPowerRequest],
[`SetChargingScheduleRequest`][sts.v2.control.SetChargingScheduleRequest] and
[`SetFallbackChargingScheduleRequest`][sts.v2.control.SetFallbackChargingScheduleRequest].
They have to be met at all times and must not be exceeded.
Furthermore, they should be realized as good as possible.

**Communication protocol:**
The communication between the vehicles and the charge and load management is realized by the interface defined and
described in the [specification](./).

### Required Vehicle Data

**VIN:**
The vehicle identification number of the vehicle.

**License plate:**
The official alphanumeric designation of the vehicle, e.g. `XX-1234E`.

**Producer:**
The name of the producing company.

**Model series:**
The name of the model series which is shown in the charge and load management.

**Configuration name:**
A unique configuration name which can be randomly chosen.
It is the identifier for a configuration which consists of a specific collection of vehicle specific parameters like
battery capacity, etc.
These vehicle parameters are described in the following section concerning feature specific data requirements.

**Icon:**
Icon or pictogram (as png format) of the vehicle model series which is shown in the charge and load management.

## Feature Related Requirements

In the following, we describe the features supported in the charge and load management and their corresponding
requirements regarding vehicle behavior and vehicle data.

### Charging

#### Vehicle Behavior

The load and charge management uses two messages to communicate the charging instructions to the vehicle.
These are [`SetChargingScheduleRequest`][sts.v2.control.SetChargingScheduleRequest] and
[`SetFallbackChargingScheduleRequest`][sts.v2.control.SetFallbackChargingScheduleRequest].

The first message type (`SetChargingScheduleRequest`) is used to send a charging plan which defines the charging
instruction for 24 h starting with the timestamp of the first instruction.
Therefore it is also possible to send charging plans which start at a future point in time or in the past.

The second message type (`SetFallbackChargingScheduleRequest`) defines a fallback plan, which can be executed endlessly.
This plan is also defined for an interval of 24 h starting always at midnight.
The fallback plan should be executed endlessly, if no standard 24 h charging plan is valid.
This also means that if a standard 24 h plan starts in one hour, the fallback plan should be used until the standard
plan starts.

With these two types of charging plans, we have a combination which ensures the charging of the vehicles in case of a
system outage.

Additionally, we have a third message [`SetChargingPowerRequest`][sts.v2.control.SetChargingPowerRequest] for
sending charging instructions.
This message type is only used for debugging purpose or for end of line tests of the vehicle.

For further details, take a look at the description of the [control messages](./messages/control/).

#### Required Vehicle Data

The following data are required in the charge and load management to charge the vehicles based on a calculated charging plan.
Currently, only AC charging is supported.

**Number of phases:**
The number of AC phases used by the vehicle to charge.

**Charging characteristic:**

```admonish warning
The following charging characteristics are still a draft definition and can change in future.
```

Choose one of the following charging characteristics which resemble the charging behavior of the vehicle.

* *phase adjustable:*
  The amperage for charging can be changed continuously between 0 A and a maximum value.
  For vehicles with more than one phase, it is possible to use a different amperage for charging on each phase.
* *equal adjustable:*
  The amperage for charging can be changed continuously between 0 A and a maximum value.
  For vehicles with more than one phase, we assume that the amperage used on each phase is identical.
  Nevertheless, we will give an amperage limit for each phase separately.
  If the charging amperage falls below the sent values due to adaptions from the battery management system (e.g. the
  battery temperature is too high, charging is in the CV phase) the equal distribution may be violated.
  As already mentioned, we have the constraint that the given amperage limits must not be exceeded.
* *phase semi-adjustable:*
  The vehicle can charge with different predefined AC amperage values, e.g. 2 A, 5 A, 9 A, 16 A.
  These values have to be named if the vehicle is of this type.
  For vehicles with more than one phase, it is possible to use a different value from these predefined amperage values
  on each phase.
  We assume, that the set of predefined amperage values is identical for each phase.
* *equal semi-adjustable:*
  The vehicle can charge with different predefined AC amperage values, e.g. 2 A, 5 A, 9 A, 16 A.
  These values have to be named if the vehicle is of this type.
  For vehicles with more than one phase, we assume that the amperage used on each phase is identical.
  Nevertheless, we will give an amperage limit for each phase separately.
  If the charging amperage falls below the sent values due to adaptions from the battery management system (e.g. the
  battery temperature is too high, charging is in the CV phase) the equal distribution may be violated.
  As already mentioned, we have the constraint that the given amperage limits must not be exceeded.
* *non-adjustable:*
  The charging of the vehicle can only be turned on or off.
  If it is turned on, the vehicle is charging with its maximum power defined below.

```admonish info
Vehicles of type `non-adjustable` do not support all features of the charge and load management.
```

**Battery capacity:**
The maximum battery capacity in Wh.

**Maximum power:**
The maximum AC power in W which can be used for charging the vehicle.
For a vehicle with more than one phase, we assume that the maximum power is evenly distributed over the phases, e.g. a
vehicle with 10 800 W maximum power and three phases can use a maximum of 3600 W on each phase.

### Preconditioning

#### Vehicle Behavior

The vehicle should provide the possibility to heat the cabin interior which is called preconditioning.
Cooling the vehicle interior is an optional addition to this feature.
To control the heating or cooling of the cabin, we send preconditioning plans by the message [`SetPreconditioningScheduleRequest`][sts.v2.control.SetPreconditioningScheduleRequest].
For each preconditioning event in this plan, we give a starting time and a duration.
In this time window the vehicle should heat/cool the cabin interior.

The energy used to heat/cool the cabin has to be taken from the vehicle battery.
Heating/Cooling the cabin with energy from the charging station is not supported/allowed.

Optionally, the vehicle can support disabling heating/cooling if specific values are exceeded, e.g. if the ambient
temperature exceeds 4 °C the preconditioning is inhibited and the vehicle does not heat the cabin.
The details about this behavior are described in the message specification.

Furthermore, it is optional that the vehicle supports heating/cooling to a target temperature.
The given duration must not be exceeded.

#### Required Vehicle Data

**Average power consumption:**
The average power consumption from the vehicle battery in W required to heat the cabin interior.

**Cooling option:**
Yes/No describing if cooling of the cabin interior is possible.

**SoC inhibit option:**
Yes/No describing if the usage of a inhibit SoC is possible.

**Ambient temperature inhibit option:**
Yes/No describing if the usage of a inhibit ambient temperature is possible.

**Target temperature option:**
Yes/No describing if target temperature for the cabin interior can be defined.

### AC/DC Conversion

#### Vehicle Behavior

The energy loss due to the conversion from AC to DC can be considered in the calculation of charging plans.
Due to simplicity, we assume a constant efficiency factor.
For vehicles which support bidirectional charging, also the energy loss from the conversion from DC to AC can be taken
into account.

#### Required Vehicle Data

**Conversion efficiency factor AC --> DC:**
The efficiency factor $ \eta_{charging} $ for the AC-DC conversion described by $ p_{DC} = \eta_{charging}\cdot p_{AC} $.
Therefore, the efficiency factor is a value between 0 and 1.
If no loss should be modelled, set the factor to 1.

**Conversion efficiency factor DC --> AC:**
The efficiency factor $ \eta_{discharging} $ for the DC-AC conversion described by
$ p_{AC} = \eta_{discharging}\cdot p_{DC} $.
Therefore, the efficiency factor is a value between 0 and 1.
If no loss should be modelled, set the factor to 1.

[sts.v2.control.SetChargingPowerRequest]: ./messages/control/charging-power.md#setchargingpowerrequest
[sts.v2.control.SetChargingScheduleRequest]: ./messages/control/charging-schedule.md#setchargingschedulerequest
[sts.v2.control.SetFallbackChargingScheduleRequest]: ./messages/control/charging-schedule.md#setfallbackchargingschedulerequest
[sts.v2.control.SetPreconditioningScheduleRequest]: ./messages/control/preconditioning-schedule.md#setpreconditioningschedulerequest
