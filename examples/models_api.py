"""GitHub Models direct API — Path B.

Plain HTTP. No SDK. The call shape is the demo. Token comes from
$GITHUB_TOKEN (must be a fine-grained PAT with Models:Read).

    python examples/models_api.py

Conference-WiFi fallback: set MODELS_OFFLINE=1 to return a checked-in fixture
without making an HTTP call. Output is identical in shape to a live response.
"""

import json
import os
import pathlib
import sys
import urllib.request


def main() -> int:
    if os.environ.get("MODELS_OFFLINE") == "1":
        fixture = pathlib.Path(__file__).parent / "models_api_fixture.json"
        with fixture.open() as f:
            data = json.load(f)
        print(data["choices"][0]["message"]["content"])
        return 0

    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        print("GITHUB_TOKEN is not set (see .devcontainer/.env)", file=sys.stderr)
        return 1

    body = json.dumps(
        {
            "model": "openai/gpt-4.1",
            "messages": [
                {"role": "user", "content": "Name three things to say on stage when a demo hangs."}
            ],
        }
    ).encode()

    req = urllib.request.Request(
        "https://models.github.ai/inference/chat/completions",
        data=body,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
    )

    with urllib.request.urlopen(req) as resp:
        data = json.load(resp)

    print(data["choices"][0]["message"]["content"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
