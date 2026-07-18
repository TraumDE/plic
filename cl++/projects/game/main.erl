-module(main).
-export([start/0]).

start() ->
    try
        Options = [binary, {packet, 0}, {active, false}, {reuseaddr, true}],
    Listen_response = gen_tcp:listen(8080, Options),
    Socket = element(2, Listen_response),
    Accept_res = gen_tcp:accept(Socket),
    Client = element(2, Accept_res),
    Rounds = ask_for_rounds(Client),
    lists:foreach(fun(I) ->
    Result = ask_for_answer(Client, I, Rounds),
    game(Client, Result)
end, lists:seq(1, Rounds)),
    gen_tcp:close(Client),
    gen_tcp:close(Socket)
    catch
        throw:{'__clx_return', ReturnValue} -> 
        ReturnValue
    end.

game(Client,Answer) ->
    try
        Computer_choice = clx_std:random(1, 3),
    case clx_std:to_boolean(Computer_choice == 1) of
    true -> 
        case clx_std:to_boolean(Answer == 2) of
    true -> 
        gen_tcp:send(Client, unicode:characters_to_binary("Вы выиграли!\n"));
    _ ->
        gen_tcp:send(Client, unicode:characters_to_binary("Вы проиграли!\n"))
end;
    _ ->
        case clx_std:to_boolean(Computer_choice == 2) of
    true -> 
        case clx_std:to_boolean(Answer == 3) of
    true -> 
        gen_tcp:send(Client, unicode:characters_to_binary("Вы выиграли!\n"));
    _ ->
        gen_tcp:send(Client, unicode:characters_to_binary("Вы проиграли!\n"))
end;
    _ ->
        case clx_std:to_boolean(Answer == 1) of
    true -> 
        gen_tcp:send(Client, unicode:characters_to_binary("Вы выиграли!\n"));
    _ ->
        gen_tcp:send(Client, unicode:characters_to_binary("Вы проиграли!\n"))
end
end
end,
    timer:sleep(2000)
    catch
        throw:{'__clx_return', ReturnValue} -> 
        ReturnValue
    end.

ask_for_answer(Client,I,Rounds) ->
    try
        clear_screen(Client),
    gen_tcp:send(Client, unicode:characters_to_binary("1 - ножницы | 2 - камень | 3 - бумага\n")),
    gen_tcp:send(Client, unicode:characters_to_binary("Раунд " ++ integer_to_list(I) ++ "/" ++ integer_to_list(Rounds) ++ "\n")),
    Result = read_int(Client),
    Status = element(1, Result),
    case clx_std:to_boolean(Status == ok) of
    true -> 
        case clx_std:to_boolean(element(2, Result) >= 1) of
    true -> 
        case clx_std:to_boolean(element(2, Result) =< 3) of
    true -> 
        throw({'__clx_return', element(2, Result)});
    _ ->
        gen_tcp:send(Client, unicode:characters_to_binary("Ошибка ввода: Введите число от 1 до 3!\n")),
    timer:sleep(2000),
    throw({'__clx_return', ask_for_answer(Client, I, Rounds)})
end;
    _ ->
        gen_tcp:send(Client, unicode:characters_to_binary("Ошибка ввода: Введите число от 1 до 3!\n")),
    timer:sleep(2000),
    throw({'__clx_return', ask_for_answer(Client, I, Rounds)})
end;
    _ ->
        gen_tcp:send(Client, unicode:characters_to_binary("Ошибка ввода: Введите число!\n")),
    timer:sleep(2000),
    throw({'__clx_return', ask_for_answer(Client, I, Rounds)})
end
    catch
        throw:{'__clx_return', ReturnValue} -> 
        ReturnValue
    end.

ask_for_rounds(Client) ->
    try
        clear_screen(Client),
    gen_tcp:send(Client, unicode:characters_to_binary("Игра: Камень, ножницы, бумага\n")),
    gen_tcp:send(Client, unicode:characters_to_binary("Введи количество раундов: ")),
    Rounds = read_int(Client),
    Status = element(1, Rounds),
    case clx_std:to_boolean(Status == ok) of
    true -> 
        throw({'__clx_return', element(2, Rounds)});
    _ ->
        gen_tcp:send(Client, unicode:characters_to_binary("Ошибка ввода: Введите число!\n")),
    timer:sleep(2000),
    throw({'__clx_return', ask_for_rounds(Client)})
end
    catch
        throw:{'__clx_return', ReturnValue} -> 
        ReturnValue
    end.

read_int(Client) ->
    try
        Response = gen_tcp:recv(Client, 0),
    Raw_data = element(2, Response),
    Bytes_size = byte_size(Raw_data) - 1,
    Cleaned_data = binary_part(Raw_data, 0, Bytes_size),
    Parsed_data = binary_to_list(Cleaned_data),
    Trimmed_data = string:trim(Parsed_data),
    Rounds = try list_to_integer(Trimmed_data) of __TryRes -> {ok, __TryRes} catch _:__TryErr -> {error, __TryErr} end,
    throw({'__clx_return', Rounds})
    catch
        throw:{'__clx_return', ReturnValue} -> 
        ReturnValue
    end.

clear_screen(Client) ->
    try
        gen_tcp:send(Client, "\e[2J\e[H")
    catch
        throw:{'__clx_return', ReturnValue} -> 
        ReturnValue
    end.