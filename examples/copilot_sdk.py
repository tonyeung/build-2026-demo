"""GitHub Copilot CLI SDK — Path A.

Programmatic control of the local `copilot` CLI via JSON-RPC. Spawns a CLI
session, sends a prompt, streams the response.

Auth is whatever the local `copilot` CLI is signed in as — `gh auth login`
in the dev container handles it.

    pip install github-copilot-sdk
    python examples/copilot_sdk.py
"""

import asyncio

from copilot_sdk import Client, SessionConfig  # type: ignore[import-not-found]


async def main() -> None:
    async with Client() as client:
        session = await client.create_session(
            SessionConfig(model="gpt-5"),
        )
        async for event in session.send("Summarize this repo in two sentences."):
            if event.type == "assistant_message_delta":
                print(event.content, end="", flush=True)
        print()


if __name__ == "__main__":
    asyncio.run(main())
