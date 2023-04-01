# Vehicle Communication Protocol v2

This document provides the entrypoint for the specification of the Vehicle Communication Protocol Version 2.

## Overview

At its core, the protocol is based on the lightweight publish/subscribe messaging transport [MQTT](https://mqtt.org).
The MQTT message payloads are encoded using [Protocol Buffers (proto3)](https://developers.google.com/protocol-buffers/docs/proto3).

More details can be found in the [MQTT Transport](./mqtt-transport.md) chapter.
Protocol specific proto3 messages are defined in the [Protobuf Data Types](./protobuf-data-types.md) chapter.

## A note on version compatibility

The protocol is versioned according to [Semantic Versioning 2.0.0]. This section re-uses definitions from the Semantic
Versioning specification.

The following actions are considered breaking (i.e. backwards-incompatible) changes:

* Causing a breaking change in the wire format of an existing message. This can be caused by changing the protobuf type
  of an existing field.
* Changing the semantics of an existing message or field. This includes modifications to the following:
  * Unit.
  * Scaling factor.
  * Minimum or maximum value.
* Changing the message type for an established MQTT topic.
* Changing the subtype of a status message as defined [here](messages/status.md).
* Adding a new field to an existing message that is semantically required (i.e. if the message should be rejected if
  field is missing).

```admonish warning
Only the binary wire format is considered for compatibility. The canonical JSON encoding may change across minor
versions, as the encoding is using the field names.
```

The following changes are considered backwards-compatible and require a minor version bump:

* Renaming an existing field or message to correct a typo or to clarify its purpose.
* Creating a new field inside of an existing message.
* Creating a new message along with a corresponding MQTT topic mapping.

```admonish info
Because of these rules, minor version bumps may cause breaking changes in the generated code. This isn't considered
a breaking change in the protocol.
```

[Semantic Versioning 2.0.0]: https://semver.org
