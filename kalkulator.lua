-- Funkcja dodawania
local function add(a, b)
    return a + b
end

-- Funkcja odejmowania
local function subtract(a, b)
    return a - b
end

-- Funkcja mnozenia
local function multiply(a, b)
    return a * b
end

-- Funkcja dzielenia
local function divide(a, b)
    if b == 0 then
        print("Shit error=syntax because 0")
        return nil
    end
    return a / b
end

-- Funkcja do wczytywania liczby od uzytkownika
local function getNumber(prompt)
    print(prompt)
    local input = io.read()
    local number = tonumber(input)
    if not number then
        print("Blad: Podana wartosc nie jest liczba!")
        return getNumber(prompt)
    end
    return number
end

-- Funkcja do wczytywania operacji od uzytkownika
local function getOperation()
    print("Podaj operacje (+, -, *, /):")
    local operation = io.read()
    if operation == "+" or operation == "-" or operation == "*" or operation == "/" then
        return operation
    else
        print("Blad: Nieznana operacja!")
        return getOperation()
    end
end

-- Glowna funkcja kalkulatora
local function calculator()
    local num1 = getNumber("Podaj pierwsza liczbe:")
    local num2 = getNumber("Podaj druga liczbe:")
    local operation = getOperation()

    local result
    if operation == "+" then
        result = add(num1, num2)
    elseif operation == "-" then
        result = subtract(num1, num2)
    elseif operation == "*" then
        result = multiply(num1, num2)
    elseif operation == "/" then
        result = divide(num1, num2)
    end

    if result then
        print("Wynik: " .. result)
    end
end

-- Uruchomienie kalkulatora
calculator()
