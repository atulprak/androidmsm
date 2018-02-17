<h1>Using the fuzzer code in qseecom.c</h1>

The modified qseecom.c creates a debug interface via /sys/kernel/debug/debug_qseecom. A file in that fuzzprobability can be used to enable or disable fuzzing.

By default, the value in that is 0. That means no fuzzing. A non-zero value implies fuzzing. Lower positive values imply less fuzzing. The value should be between 0 and 255.

Other relevant files include those in /sys/kernel/debug/tzdbg.
