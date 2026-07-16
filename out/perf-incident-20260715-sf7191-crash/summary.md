Incident: User report that cmux DEV sf7191 crashed during extension dogfood
Symptom: Tagged app disappeared
Evidence: `cmux-debug-sf7191.log`, `unified-log-excerpt.txt`, and `diagnostic-report-inventory.txt` in this directory
Root cause: PID 94955 received SIGTERM at 2026-07-15 15:53:00.975 -0700. This is an external or deliberate termination, not an exception crash. The debug log shows normal timer and session-save activity from 15:49 through 15:52:55, with no fatal, abort, assertion, exception, or crash entry. The app was relaunched as PID 80404 at 15:54:38 and later exited voluntarily at 15:54:55.
Fix: None. This evidence does not identify an app defect.
Proof: RunningBoard recorded `domain:signal(2) code:SIGTERM(15)` for PID 94955. No cmux crash report was created in the 15:45 through 15:56 window.
Principled or hacky: Principled triage because the conclusion uses process-exit status, app logs, and the crash-report inventory instead of inferring from disappearance.
Residual risk: A different termination outside the inspected time window is not covered. SIGTERM evidence cannot name the sender by itself, but it rules out a native exception crash for this process exit.
Next: Correlate the SIGTERM timestamp with the dogfood harness cleanup command. No crash fix is justified from this incident.
