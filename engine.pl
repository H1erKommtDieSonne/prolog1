% Есть список задач вида task(Id, Time, Priority)
% Нужно выбрать такие задачи, чтобы сумма Time не превышала MaxTime, сумма Priority была максимальной, для каждой задачи есть два варианта, взять её, не брать её




% Tasks - исходный список задач
% MaxTime - оставшееся доступное время
% Chosen - выбранные задачи
% TotalTime - суммарное время выбранных задач
% TotalPriority - суммарный приоритет выбранных задач



% Базовый случай рекурсии:
subset_with_limit([], _, [], 0, 0).

% Случай 1: берём первую задачу если её Time не превышает MaxTime
subset_with_limit(
    [task(Id, Time, Priority) | Rest],
    MaxTime,
    [task(Id, Time, Priority) | ChosenRest],
    TotalTime,
    TotalPriority
) :-
    Time =< MaxTime,
    NewMaxTime is MaxTime - Time,
    subset_with_limit(Rest, NewMaxTime, ChosenRest, RestTime, RestPriority),
    TotalTime is RestTime + Time,
    TotalPriority is RestPriority + Priority.

% Случай 2: не берём первую задачу
subset_with_limit(
    [_ | Rest],
    MaxTime,
    Chosen,
    TotalTime,
    TotalPriority
) :-
    subset_with_limit(Rest, MaxTime, Chosen, TotalTime, TotalPriority).




% Как сравниваем решения - лучше то, у которого больше суммарный приоритет, если приоритет одинаковый, лучше то, у которого меньше время


better_solution(
    sol(Chosen1, Time1, Priority1),
    sol(_, Time2, Priority2),
    sol(Chosen1, Time1, Priority1)
) :-
    Priority1 > Priority2, !.

better_solution(
    sol(Chosen1, Time1, Priority1),
    sol(_, Time2, Priority2),
    sol(Chosen1, Time1, Priority1)
) :-
    Priority1 =:= Priority2,
    Time1 =< Time2, !.

better_solution(
    _,
    sol(Chosen2, Time2, Priority2),
    sol(Chosen2, Time2, Priority2)
).



% рекурсивная обработка списка: если элемент один, он и есть лучший, если элементов хотя бы два, сравниваем первые два, оставляем лучший и продолжаем


best_from_list([One], One).

best_from_list([First, Second | Rest], Best) :-
    better_solution(First, Second, Better),
    best_from_list([Better | Rest], Best).



% Сначала собираем все допустимые решения через findall, потом из них выбираем лучшее.


best_solution(Tasks, MaxTime, BestChosen, BestTime, BestPriority) :-
    findall(
        sol(Chosen, Time, Priority),
        subset_with_limit(Tasks, MaxTime, Chosen, Time, Priority),
        Solutions
    ),
    best_from_list(Solutions, sol(BestChosen, BestTime, BestPriority)).



% из списка task() делаем список только идентификаторов


chosen_ids([], []).

chosen_ids([task(Id, _, _) | Rest], [Id | IdRest]) :-
    chosen_ids(Rest, IdRest).



% возвращаем не сами task(), а только список Id


solve(Tasks, MaxTime, Ids, TotalTime, TotalPriority) :-
    best_solution(Tasks, MaxTime, Chosen, TotalTime, TotalPriority),
    chosen_ids(Chosen, Ids).
