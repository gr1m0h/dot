# Property Tests

Use when correctness can be expressed independently of individual examples. Establish the public contract before deriving properties; do not copy the implementation into the oracle.

Choose relevant invariants: decode(encode(x)) preserves the defined value, normalization is idempotent, ordering preserves required relations, or operations preserve a domain constraint. State preconditions and intentional information loss explicitly. An inverse pair sharing the same defect can pass a roundtrip, so add independent examples or a reference oracle when warranted.

Generate valid domain inputs by construction rather than excessive filtering. Include important boundary values and meaningful structural variation. Use the existing framework, bounded case counts, deterministic seeds where supported, and shrinking. Report minimized counterexamples and retain them as regression examples when useful. Do not weaken a failing property until evidence establishes that the property contradicts the actual contract.

Primary example: [fast-check properties](https://fast-check.dev/docs/core-blocks/properties/). Follow the target framework's current documentation; this reference does not require installing that framework.
