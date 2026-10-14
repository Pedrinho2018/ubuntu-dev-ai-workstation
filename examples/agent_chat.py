"""Chat local LangGraph com historico SQLite. Sem ferramentas que executam shell."""
from __future__ import annotations

import argparse
import os
from pathlib import Path

os.environ.setdefault("LANGGRAPH_STRICT_MSGPACK", "true")

from langchain_ollama import ChatOllama  # noqa: E402
from langgraph.checkpoint.sqlite import SqliteSaver  # noqa: E402
from langgraph.graph import END, START, MessagesState, StateGraph  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(description="Chat local com memoria por thread")
    parser.add_argument("prompt")
    parser.add_argument("--thread", default="local")
    parser.add_argument("--model", default=os.environ.get("OLLAMA_MODEL", "qwen3:4b"))
    args = parser.parse_args()

    state_home = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
    state_dir = state_home / "ubuntu-dev-ai-workstation" / "agents"
    state_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    os.chmod(state_dir, 0o700)

    model = ChatOllama(model=args.model, base_url="http://127.0.0.1:11434")
    graph = StateGraph(MessagesState)

    def respond(state: MessagesState) -> dict:
        return {"messages": [model.invoke(state["messages"])]}

    graph.add_node("respond", respond)
    graph.add_edge(START, "respond")
    graph.add_edge("respond", END)

    old_umask = os.umask(0o077)
    try:
        with SqliteSaver.from_conn_string(str(state_dir / "chat.sqlite3")) as saver:
            agent = graph.compile(checkpointer=saver)
            result = agent.invoke(
                {"messages": [{"role": "user", "content": args.prompt}]},
                config={"configurable": {"thread_id": args.thread}},
            )
    finally:
        os.umask(old_umask)

    print(result["messages"][-1].content)


if __name__ == "__main__":
    main()
