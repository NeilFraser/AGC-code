#!/usr/bin/python3
"""
Blockly AGC: yaYUL Interface.
Neil Fraser (mostly written by Claude AI)
https://github.com/NeilFraser/AGC-code

CGI script to:
1. Save POST 'code' property to 'blockly.agc'
2. Execute 'yaYUL blockly/main.agc'
3. Copy 'main.agc.bin' to 'agc-bin/<uuid>'
4. Return the UUID to the caller
5. Delete any file in 'agc-bin' older than 1 day

Uses a file-based semaphore with a 60-second expiry to allow
only one execution at a time.
"""

import cgi_utils
import glob
import json
import os
import re
import shutil
import subprocess
import time
import uuid

DATA_PATH = "/home/neil/html/software/blockly-agc/data/"
SEMAPHORE_FILE = DATA_PATH + "yaYUL.lock"
SEMAPHORE_TIMEOUT = 60      # seconds
YAYUL_BINARY  = "/home/neil/virtualagc/yaYUL/yaYUL"
CODE_PATH  = "/home/neil/virtualagc/blockly-agc/"
YAYUL_INPUT   = "Main.agc"  # Relative to CODE_PATH
BLOCKLY_FILE  = CODE_PATH + "Blockly.agc"
YAYUL_OUTPUT  = CODE_PATH + "Main.agc.bin"
MAX_AGE_SECONDS = 86400     # Binary files over 1 day old are deleted.


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def send_response(payload: dict, http_status: str = "200 OK"):
  print(f"Status: {http_status}")
  print("Content-Type: application/json")
  print()
  print(json.dumps(payload))


def acquire_semaphore():
  # Atomically acquire the semaphore.
  # Returns failure message (empty string if success).
  now = time.time()

  while os.path.exists(SEMAPHORE_FILE):
    try:
      age = now - os.path.getmtime(SEMAPHORE_FILE)
      if age < SEMAPHORE_TIMEOUT:
        time.sleep(1)
      os.remove(SEMAPHORE_FILE)   # expired — remove and fall through
    except OSError as e:
      return f"Error checking semaphore: {e}"

  try:
    fd = os.open(SEMAPHORE_FILE, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    os.write(fd, str(os.getpid()).encode())
    os.close(fd)
    return ""
  except FileExistsError:
    # Semaphore was just acquired by another process.  Try again.
    return acquire_semaphore()
  except OSError as e:
    return f"Could not create semaphore: {e}"


def release_semaphore():
  """Remove the semaphore file (best-effort)."""
  try:
    if os.path.exists(SEMAPHORE_FILE):
      os.remove(SEMAPHORE_FILE)
  except OSError:
    pass


def cleanup_old_bins():
  """Delete .bin files in DATA_PATH that are older than MAX_AGE_SECONDS."""
  if not os.path.isdir(DATA_PATH):
    return
  cutoff = time.time() - MAX_AGE_SECONDS
  for filepath in glob.glob(os.path.join(DATA_PATH, "*.bin")):
    try:
      if os.path.isfile(filepath) and os.path.getmtime(filepath) < cutoff:
        os.remove(filepath)
    except OSError:
      pass  # best-effort; don't abort on cleanup errors


def strip_duplicate_numbers(code: str) -> str:
  # Find all occurrences of lines starting with "NUM" in the framework files.
  nums = set()
  for filepath in glob.glob(os.path.join(CODE_PATH, "*.agc")):
    if filepath == BLOCKLY_FILE:
      continue  # Don't read any previously saved Blockly.agc file.
    with open(filepath, "r", encoding="utf-8") as f:
      for line in f:
        m = re.match(r"^\s*NUM(\d+)\s", line)
        if m:
          num = m.group(1)
          nums.add(num)

  # Comment out duplicate NUM definitions from the input code.
  for num in nums:
    code = re.sub(rf"^(NUM{num}\s.*\n)", r"#\1", code, flags=re.MULTILINE)
  return code



# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
  if os.environ.get("REQUEST_METHOD", "GET").upper() != "POST":
    send_response({"status": "error", "message": "Only POST requests are accepted."}, "405 Method Not Allowed")
    return

  # Parse POST data
  forms = cgi_utils.parse_post()
  code = forms["code"]

  if code is None:
    send_response({"status": "error", "message": "Missing 'code' field in POST data."}, "400 Bad Request")
    return

  # Acquire semaphore
  reason = acquire_semaphore()
  if reason:
    send_response({"status": "error", "message": reason}, "503 Service Unavailable")
    return

  code = strip_duplicate_numbers(code)

  try:
    # ------------------------------------------------------------------
    # 1. Save code to file
    # ------------------------------------------------------------------
    try:
      with open(BLOCKLY_FILE, "w", encoding="utf-8") as f:
        f.write(code)
    except OSError as e:
      send_response({"status": "error", "message": f"Failed to write {BLOCKLY_FILE}: {e}"}, "500 Internal Server Error")
      return

    # ------------------------------------------------------------------
    # 2. Run yaYUL assembler
    # ------------------------------------------------------------------
    try:
      result = subprocess.run(
        [YAYUL_BINARY, YAYUL_INPUT],
        cwd=CODE_PATH,
        capture_output=True,
        text=True,
        timeout=SEMAPHORE_TIMEOUT,
      )
    except FileNotFoundError:
      send_response({"status": "error", "message": f"Assembler binary '{YAYUL_BINARY}' not found."}, "500 Internal Server Error")
      return
    except subprocess.TimeoutExpired:
      send_response({"status": "error", "message": "Assembler timed out."}, "500 Internal Server Error")
      return

    if result.returncode != 0:
      send_response({
        "status": "error",
        "message": "Assembler failed.",
        "stdout": result.stdout,
        "stderr": result.stderr,
      }, "422 Unprocessable Entity")
      return

    # ------------------------------------------------------------------
    # 3. Copy compiled binary to agc-bin/<uuid>.bin
    # ------------------------------------------------------------------
    if not os.path.isfile(YAYUL_OUTPUT):
      send_response({"status": "error", "message": f"Compiled binary '{YAYUL_OUTPUT}' not found after assembly."}, "500 Internal Server Error")
      return

    file_uuid = str(uuid.uuid4()) + ".bin"
    dest_path = os.path.join(DATA_PATH, file_uuid)

    try:
      shutil.copy2(YAYUL_OUTPUT, dest_path)
    except OSError as e:
      send_response({"status": "error", "message": f"Failed to copy binary: {e}"}, "500 Internal Server Error")
      return

    # ------------------------------------------------------------------
    # 4. Return UUID
    # ------------------------------------------------------------------
    send_response({"status": "ok", "uuid": file_uuid})

  finally:
    release_semaphore()
    # ------------------------------------------------------------------
    # 5. Clean up stale bins (runs even on error paths)
    # ------------------------------------------------------------------
    cleanup_old_bins()


if __name__ == "__main__":
  main()
