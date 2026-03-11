# macOS Apple Silicon QoS Analytics

[![macOS](https://img.shields.io/badge/macOS-Apple_Silicon-black.svg)]()
[![C/C++](https://img.shields.io/badge/Language-C/C++-blue.svg)]()
[![Assembly](https://img.shields.io/badge/Language-ARM_Assembly-red.svg)]()

This project focuses on a deep-dive investigation into the macOS thread scheduler, specifically targeting the Apple Silicon (M1/M2/M3) Asymmetric Multiprocessing (AMP) architecture and the **Quality of Service (QoS)** mechanism.



## Theoretical Background: P-Cores vs. E-Cores
Modern Apple processors utilize an AMP architecture consisting of:
* **Performance Cores (P-Cores):** High-power cores designed for resource-intensive tasks (compiling, rendering, active UI). High energy consumption.
* **Efficiency Cores (E-Cores):** Energy-efficient cores for background processes. They operate at lower frequencies, drastically saving battery life.

To help the macOS scheduler determine which core should handle a specific thread, developers assign **Quality of Service (QoS)** classes.

## Project Scope
This tool analyzes how the operating system distributes processes across physical CPU cores based on their assigned QoS class, utilizing C/C++ and low-level ARM Assembly instructions. We investigate the primary classes:
1. `User Interactive` (Highest priority, UI, animations)
2. `User Initiated` (User waiting for results, data loading)
3. `Utility` (Long-running tasks, progress bars)
4. `Background` (Backups, indexing, syncing)

## Key Findings

Through the analysis of the QoS mechanism, several architectural behaviors were confirmed:

1. **Strict Background Isolation:** Threads with the `Background` QoS are strictly confined to E-Cores by the scheduler. The OS prevents them from executing on P-Cores even if the P-Cores are completely idle. This ensures that background tasks never cause thermal throttling or battery drain.
2. **Aggressive P-Core Utilization:** `User Interactive` and `User Initiated` threads are instantly dispatched to Performance cores. If P-Cores are saturated, the system may enlist E-Cores as auxiliary processors to prevent bottlenecks.
3. **DVFS Management:** QoS dictates not only the core type but also controls the frequency (Dynamic Voltage and Frequency Scaling). Lowering the QoS for a heavy computational task increases execution time but decreases power consumption exponentially.
4. **Developer Implications:** Misusing QoS (e.g., running heavy math on the main thread or using `User Interactive` for parsing) destroys the device's thermal budget. Proper thread tagging allows applications to run efficiently without impacting battery life.
