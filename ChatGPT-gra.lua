-- Prosta gra tekstowa w języku Lua

-- Ustawienia labiryntu
local maze = {
    {"#", "#", "#", "#", "#", "#", "#"},
    {"#", " ", " ", " ", "#", " ", "#"},
    {"#", " ", "#", " ", "#", " ", "#"},
    {"#", " ", "#", " ", " ", " ", "#"},
    {"#", " ", "#", "#", "#", " ", "#"},
    {"#", " ", " ", " ", "#", "E", "#"},
    {"#", "#", "#", "#", "#", "#", "#"}
}

-- Pozycja startowa gracza
local player = {x = 2, y = 2}

-- Funkcja do wyświetlania labiryntu
local function printMaze()
    for y = 1, #maze do
        for x = 1, #maze[y] do
            if x == player.x and y == player.y then
                io.write("P ")
            else
                io.write(maze[y][x] .. " ")
            end
        end
        io.write("\n")
    end
end

-- Funkcja do poruszania się gracza
local function movePlayer(direction)
    local newX, newY = player.x, player.y
    if direction == "w" then
        newY = newY - 1
    elseif direction == "s" then
        newY = newY + 1
    elseif direction == "a" then
        newX = newX - 1
    elseif direction == "d" then
        newX = newX + 1
    else
        print("Nieznany kierunek!")
        return
    end

    -- Sprawdzenie, czy ruch jest możliwy
    if maze[newY][newX] ~= "#" then
        player.x = newX
        player.y = newY
    else
        print("Nie możesz tam iść!")
    end
end

-- Główna pętla gry
local function gameLoop()
    while true do
        printMaze()
        print("Podaj kierunek (w, a, s, d) lub q aby wyjść:")
        local input = io.read()

        if input == "q" then
            print("Dziękujemy za grę!")
            break
        end

        movePlayer(input)

        if maze[player.y][player.x] == "E" then
            printMaze()
            print("Gratulacje! Znalazłeś wyjście!")
            break
        end
    end
end

-- Uruchomienie gry
gameLoop()
