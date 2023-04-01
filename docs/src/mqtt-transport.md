# MQTT Transport

Messages are communicated using [MQTT](https://mqtt.org) over mutual TLS (mTLS).

```admonish note
Right now the broker is running [VerneMQ](https://vernemq.com), but clients must not rely on any broker-specific features.
```

Clients should use MQTT Version 3.1.1.

## Topic Layout

The following general message types exist in the protocol:

* [Status Messages](messages/status.md)
  * Allow the vehicle to transmit information without requiring a request
  * Topic layout: `<manufacturerId>/vehicleStatus/<boxId>/<component>/<messagetype>`
* [Control Messages](messages/control/)
  * Allow the backend to issue requests to the vehicle in a request/response pattern
  * Topic layout:
    * Request: `<manufacturerId>/ctl/request/<boxId>/<requestMessageType>`
    * Response: `<manufacturerId>/ctl/response/<boxId>/<responseMessageType>`
* [Statistics Messages](messages/statistics/)
  * Allow the vehicle to send aggregated information.
  * For compatibility reasons the topic depends on the statistics type.

## BoxIds

BoxIds are used within the topic identifiers to distinguish between the individual telematic units/vehicles.
All communication to and from a specific vehicle is identified by **exactly** one BoxId.

BoxId structure: `<manufacturerShort>-<telematicUnitShort><integer>`

Example of a BoxId for a StreetScooter(STS) Telematic Control Unit(TCU): `sts-tcu1234`

## ManufacturerIds

Manufacturer ids are assigned to each vehicle manufacturer to allow for wildcard authorization on topics based on a
manufacturer within the mqtt broker.

Id assignment is done on request alongside the setup of the [Client Certificates](mqtt-transport.md#tls-certificates).

## Connection

Host: `broker.streetscooter.eu`</br>
Port: `8883`

### TLS Certificates

Third parties are expected to provide their own PKI for securing the connection.
To this end, the third party creates a new CA, which is **exclusively** used for signing the client certificates used to
connect to the MQTT broker.
The CA's public key is shared with StreetScooter and cross-signed using the StreetScooter root certificate to establish
an alternate trust path, allowing the client certificates to be trusted by the broker.

The broker relies on the certificate's common name to identify the client. For this reason, the common name has to be
set to specific values as defined in the scenarios below.

All clients use the StreetScooter root certificate to verify the identity of the broker.

```admonish bug
Unfortunately, the StreetScooter broker certificate currently doesn't use the Subject Alternative Name extension to
specify its hostname. Instead, it uses the deprecated method of setting it in the CN.
This may cause issues with some TLS implementations.
```

#### Scenario: Telematic Unit to broker

Every telematic unit is expected to store its own private certificate as well as the public certificate of the
StreetScooter root CA.

Client certificates must have the subject's common name set to the [BoxId](#boxids).

![Backend to Backend](./img/mqtt-transport/tc-to-backend.drawio.svg)

#### Scenario: Backend to Backend

Client certificates must have the subject's common name set to the third party's assigned manufacturer id.

![Backend to Backend](./img/mqtt-transport/backend-to-backend.drawio.svg)
