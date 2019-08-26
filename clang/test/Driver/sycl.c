// RUN: %clang -### --sycl -c %s 2>&1 | FileCheck %s --check-prefix=DEFAULT
// RUN: %clang -### --sycl %s 2>&1 | FileCheck %s --check-prefix=DEFAULT
// RUN: %clang -### --sycl -fno-sycl-use-bitcode -c %s 2>&1 | FileCheck %s --check-prefix=NO-BITCODE
// RUN: %clang -### -target spir64-unknown-linux-sycldevice -c -emit-llvm %s 2>&1 | FileCheck %s --check-prefix=TARGET
// RUN: %clang -### --sycl -c -emit-llvm %s 2>&1 | FileCheck %s --check-prefix=COMBINED

// DEFAULT: "-triple" "spir64-unknown-{{.*}}-sycldevice"{{.*}} "-fsycl-is-device"{{.*}} "-emit-llvm-bc"
// DEFAULT: "-internal-isystem" "{{.*lib.*clang.*include}}"
// DEFAULT-NOT: "{{.*}}llvm-spirv"{{.*}} "-spirv-max-version=1.1"{{.*}} "-spirv-ext=+all"
// NO-BITCODE: "-triple" "spir64-unknown-{{.*}}-sycldevice"{{.*}} "-fsycl-is-device"{{.*}} "-emit-llvm-bc"
// NO-BITCODE: "{{.*}}llvm-spirv"{{.*}} "-spirv-max-version=1.1"{{.*}} "-spirv-ext=+all"
// TARGET: "-triple" "spir64-unknown-linux-sycldevice"{{.*}} "-fsycl-is-device"{{.*}} "-emit-llvm-bc"
// COMBINED: "-triple" "spir64-unknown-{{.*}}-sycldevice"{{.*}} "-fsycl-is-device"{{.*}} "-emit-llvm-bc"

// -fsycl-help tests
// Test with a bad argument is expected to fail
// RUN: not %clang -fsycl-help=foo %s 2>&1 | FileCheck %s --check-prefix=SYCL-HELP-BADARG
// RUN: %clang -### -fsycl-help=gen %s 2>&1 | FileCheck %s --check-prefix=SYCL-HELP-GEN
// RUN: %clang -### -fsycl-help=fpga %s 2>&1 | FileCheck %s --check-prefix=SYCL-HELP-FPGA
// RUN: %clang -### -fsycl-help=x86_64 %s 2>&1 | FileCheck %s --check-prefix=SYCL-HELP-CPU
// RUN: %clang -### -fsycl-help %s 2>&1 | FileCheck %s --check-prefixes=SYCL-HELP-GEN,SYCL-HELP-FPGA,SYCL-HELP-CPU
// SYCL-HELP-BADARG: unsupported argument 'foo' to option 'fsycl-help='
// SYCL-HELP-GEN: Emitting help information for ocloc
// SYCL-HELP-GEN: Use triple of 'spir64_gen-unknown-{{.*}}-sycldevice' to enable ahead of time compilation
// SYCL-HELP-FPGA: Emitting help information for aoc
// SYCL-HELP-FPGA: Use triple of 'spir64_fpga-unknown-{{.*}}-sycldevice' to enable ahead of time compilation
// SYCL-HELP-CPU: Emitting help information for ioc64
// SYCL-HELP-CPU: Use triple of 'spir64_x86_64-unknown-{{.*}}-sycldevice' to enable ahead of time compilation
