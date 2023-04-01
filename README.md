# Protobuf Files

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Project Structure

```raw
.
├── docs/         Protocol documentation.
├── sts/          Houses all the protobuf files.
├── tools/        Relevant tools for the project. See README.md for reference.
├── CHANGELOG.md  All changes related to the protobuf files.
└── README.md     What you're reading right now
```

### Protobuf packages

#### `sts.v1`

This package contains all the legacy message definitions. These messages were previously defined in the `c2c` package.
These definitions don't have to comply with the new Protobuf guidelines, but at the same time, no further changes
should be made to them.

The Protobuf files in this package are still based on the proto2 syntax.

#### `sts.v2`

This is the current version of the protocol and is fully documented [here](https://streetscooter.gitlab.io/tcu/proto-files/).

## Developer Reference

```sh
# lint protobuf files
tools/lint.sh

# format protobuf files
tools/format.sh

# serve the documentation in the docs/ dir
tools/docs.sh serve

# generate code as per `buf.gen.yaml`
tools/buf.sh generate
```

### Release Process

1. Update CHANGELOG.md with release.
2. Merge changes into default branch.
3. Create a tag with the new version with format `vX.Y.Z`.

### Protobuf Guidelines

The project strictly adheres to the following rules.
These rules are enforced using CI and can be tested locally using the scripts mentioned above.

- [Official Style Guide](https://developers.google.com/protocol-buffers/docs/style)
- [Buf Style Guide](https://docs.buf.build/best-practices/style-guide) (used by the linter tool)
- [Buf Format Style](https://docs.buf.build/format/style) (used by the formatter tool)
