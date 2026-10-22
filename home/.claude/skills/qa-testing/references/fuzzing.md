# Fuzzing

Use for unexpected-input robustness, parsers, protocol decoders, and crash or hang exploration. Identify the function boundary and allowed effects; prefer a pure local harness.

Inspect existing fuzz targets and tools. Seed the corpus with small valid and malformed inputs and select generation or mutation according to the input structure. Establish time, memory, input-size, process, and output limits before execution. Use a temporary isolated workspace and dummy data; do not target production or shared services. Do not install or run untrusted packages just to obtain a fuzzer.

Preserve the failing input, seed, invocation, limits, and relevant tool configuration. Minimize crashes and timeouts separately and distinguish harness faults from target faults. If native tooling exists, use appropriate sanitizers where practical. A crash alone does not prove a security vulnerability; report the observed failure and conditions without upgrading its impact. A clean bounded run does not establish absence of defects.

Primary example: [Go fuzzing](https://go.dev/doc/security/fuzz/). Follow the target framework's current documentation; this reference does not require installing that framework.
