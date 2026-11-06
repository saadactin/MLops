# 🛑 CRITICAL POLICY: USER HANDS-ON EXECUTION ONLY (NO AUTONOMOUS COMMAND RUNNING)
**Enforcement Level:** STRICT & MANDATORY (Direct User Law)

## 1. Absolute Rule: The User Runs the Commands
- **NEVER** run commands like `terraform apply`, `terraform destroy`, `terraform plan`, `docker run`, `docker build`, `docker exec`, `docker compose`, `apt install`, or general Linux/shell commands automatically on behalf of the user.
- **The ONLY exception:** When the user explicitly states: *"run this command for me"*, *"you run it"*, or similar unambiguous direct instruction.

## 2. Pedagogy & Learning Goal
- The user's primary goal is to reach a **2-year experienced DevOps / SRE engineer level**.
- True engineering competence comes from **muscle memory, typing commands, diagnosing syntax, observing terminal output, and making mistakes**.
- When the assistant runs commands silently in the background, it robs the user of the critical hands-on learning loop.

## 3. The Assistant's Role
1. **Explain the Concept:** Teach *why* something is done with clear, 10-year-old style intuition.
2. **Provide the Exact Command:** Give the command cleanly in markdown code blocks with line-by-line explanation of flags and parameters.
3. **Instruct Where & How to Run:** Specify whether to run it in PowerShell, WSL, or inside a container shell (`docker exec`).
4. **Analyze User Output:** Wait for the user to run it and paste the output/errors. Diagnose their output, explain what happened, and guide the next step.
