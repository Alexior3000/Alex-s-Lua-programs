-- Funkcja do wczytywania wejścia od użytkownika
local function getInput(prompt)
    print(prompt)
    return io.read()
end

-- Funkcja do wczytywania liczby od użytkownika
local function getNumber(prompt)
    local input = getInput(prompt)
    local number = tonumber(input)
    if input == "admin" or input == "exit" then
        return input
    elseif not number then
        print("Blad: Podana wartosc nie jest liczba!")
        return getNumber(prompt)
    end
    return number
end

-- Główna funkcja gry
local function guessNumberGame()
    math.randomseed(os.time())
    local randomNumber = math.random(1, 1000)
    
    while true do
        local input = getNumber("Podaj liczbe od 1 do 1000 (wpisz 'exit' aby zakonczyc):")
        
        if input == "admin" then
            print("Wylosowana liczba to: " .. randomNumber)
        elseif input == "exit" then
            print("Konczenie programu. Do widzenia!")
            break
        elseif input == randomNumber then
            print("Wygrales! Wylosowana liczba to rzeczywiscie: " .. randomNumber)
            break
        else
            print("Nie zgadles. Sprobuj ponownie!")
        end
    end
end

-- Uruchomienie gry
guessNumberGame()
