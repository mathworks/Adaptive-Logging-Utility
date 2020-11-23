# Adaptive-Logging-Utility
Logging and environment utilities for MATLAB coding

NEEDS:

1. I want to be able to choose the amount of information displayed in the MATLAB Command Window during the execution of a MATLAB software.

2. This logging level should automatically adjust depending on whether the code is being developed or used in production.

3. I want to easily debug any error in my code.

4. I want to automatically disable some time-consuming defensive programming commands in production mode, once they've been validated in a test phase.

5. I want to allow the end user to switch to a defensive mode where more errors are detected during the execution.

SOLUTION:

- A log level is defined that follows the Log4j log levels: OFF/FATAL/ERROR/WARN/INFO/DEBUG/TRACE

  Reference: https://en.wikipedia.org/wiki/Log4j

- A environment mode is defined that follows the Development, Testing, Acceptance and Production (DTAP) standard with the 4 following environment modes: DEV/TEST/UAT/PROD

  Reference: https://en.wikipedia.org/wiki/Development,_testing,_acceptance_and_production

- The log level is automatically adjusted according to the environment mode.

  Examples:
  
  If the log level is WARN, then all FATAL, ERROR and WARN messages are enabled.
  
  In UAT mode, the minimal log level is WARN. So the log level cannot be set to OFF, FATAL or ERROR.
  
  In PROD mode, only WARN and INFO message can be displayed.

- In DEV mode, any error pauses the execution and switches MATLAB to debug mode.

- The FATAL message includes a logical expression whose execution is skipped in PROD mode.

EXAMPLE:

>> devel.example
