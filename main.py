import os
from pathlib import Path

os.environ["SWI_HOME_DIR"] = r"D:\prolog\swipl"
os.environ["PATH"] = r"D:\prolog\swipl\bin;" + os.environ["PATH"]

import janus_swi


def load_prolog_file(prolog_file: str) -> None:

    janus_swi.consult(prolog_file)


def python_tasks_to_prolog(tasks: list[dict]) -> str:


    prolog_tasks = []

    for task in tasks:
        task_id = task["id"]
        time = int(task["time"])
        priority = int(task["priority"])


        prolog_tasks.append(f"task({task_id},{time},{priority})")

    return "[" + ",".join(prolog_tasks) + "]"


def solve_knapsack(tasks: list[dict], max_time: int) -> dict:


    tasks_term = python_tasks_to_prolog(tasks)

    query_text = "solve_from_string(Tasks, MaxTime, Ids, TotalTime, TotalPriority)"

    bindings = {
        "Tasks": tasks_term,
        "MaxTime": max_time,
    }

    result = janus_swi.query_once(query_text, bindings)

    if not result["truth"]:
        raise RuntimeError("Prolog не нашёл решение")

    return {
        "ids": result["Ids"],
        "total_time": result["TotalTime"],
        "total_priority": result["TotalPriority"],
    }


def main() -> None:
    prolog_file = str(Path("engine.pl").resolve())

    load_prolog_file(prolog_file)

    tasks = [
        {"id": "a", "time": 2, "priority": 6},
        {"id": "b", "time": 2, "priority": 3},
        {"id": "c", "time": 6, "priority": 5},
        {"id": "d", "time": 5, "priority": 4},
        {"id": "e", "time": 4, "priority": 6},
    ]

    max_time = 8

    result = solve_knapsack(tasks, max_time)

    print("Входные задачи:")
    for task in tasks:
        print(
            f"  id={task['id']}, "
            f"time={task['time']}, "
            f"priority={task['priority']}"
        )

    print(f"\nОграничение по времени: {max_time}")
    print("\nЛучшее решение:")
    print("  Выбранные задачи:", result["ids"])
    print("  Суммарное время:", result["total_time"])
    print("  Суммарный приоритет:", result["total_priority"])


if __name__ == "__main__":
    main()
