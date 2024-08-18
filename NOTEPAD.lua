-- Funkcja do czyszczenia ekranu
function clear_screen()
    -- Komenda czyszczenia ekranu dla systemu Unix (Linux, macOS)
    os.execute("clear")
    -- Komenda czyszczenia ekranu dla systemu Windows
    -- os.execute("cls")
end

-- Funkcja do wyświetlenia menu
function show_menu()
    clear_screen()
    print("\n----- MENU -----")
    print("1. Stwórz nową notatkę")
    print("2. Przeglądaj notatkę")
    print("3. Edytuj notatkę")
    print("4. Usuń notatkę")
    print("5. Wyświetl wszystkie notatki")
    print("6. Wyjście")
    print("-----------------")
    print("Wybierz opcję: ")
end

-- Funkcja do formatowania nazwy pliku
function format_file_name(name)
    return name:match("^.+%.txt$") and name or name .. ".txt"
end

-- Funkcja do sprawdzenia, czy plik istnieje
function file_exists(file_name)
    local file = io.open(file_name, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

-- Funkcja do tworzenia nowej notatki
function create_note()
    clear_screen()
    print("Podaj nazwę nowej notatki (bez rozszerzenia .txt):")
    local file_name = format_file_name(io.read())
    
    if file_exists(file_name) then
        print("Notatka o tej nazwie już istnieje. Spróbuj ponownie.")
        os.execute("sleep 2")
        return
    end
    
    print("Wpisz treść notatki (aby zakończyć, wpisz 'KONIEC'): ")
    local file = io.open(file_name, "w")
    
    if file then
        while true do
            local text = io.read()
            if text == "KONIEC" then break end
            file:write(text .. "\n")
        end
        file:close()
        print("Notatka '" .. file_name .. "' została zapisana.")
    else
        print("Błąd przy tworzeniu notatki.")
    end
    
    os.execute("sleep 2")
end

-- Funkcja do przeglądania notatki
function view_note()
    clear_screen()
    print("Podaj nazwę notatki do odczytu (bez rozszerzenia .txt):")
    local file_name = format_file_name(io.read())
    
    if file_exists(file_name) then
        local file = io.open(file_name, "r")
        if file then
            print("\nZawartość notatki '" .. file_name .. "':")
            print("-------------------")
            for line in file:lines() do
                print(line)
            end
            print("-------------------")
            file:close()
        end
    else
        print("Nie udało się otworzyć notatki. Upewnij się, że plik istnieje.")
    end
    
    os.execute("sleep 3")
end

-- Funkcja do edytowania notatki
function edit_note()
    clear_screen()
    print("Podaj nazwę notatki do edycji (bez rozszerzenia .txt):")
    local file_name = format_file_name(io.read())
    
    if file_exists(file_name) then
        local file = io.open(file_name, "r")
        if file then
            print("\nObecna zawartość notatki:")
            print("-------------------")
            for line in file:lines() do
                print(line)
            end
            print("-------------------")
            file:close()
            
            print("Wpisz nową treść notatki (aby zakończyć, wpisz 'KONIEC'): ")
            file = io.open(file_name, "w")
            if file then
                while true do
                    local text = io.read()
                    if text == "KONIEC" then break end
                    file:write(text .. "\n")
                end
                file:close()
                print("Notatka '" .. file_name .. "' została zaktualizowana.")
            else
                print("Błąd przy zapisie notatki.")
            end
        end
    else
        print("Nie udało się otworzyć notatki do edycji. Upewnij się, że plik istnieje.")
    end
    
    os.execute("sleep 3")
end

-- Funkcja do usuwania notatki
function delete_note()
    clear_screen()
    print("Podaj nazwę notatki do usunięcia (bez rozszerzenia .txt):")
    local file_name = format_file_name(io.read())
    
    if file_exists(file_name) then
        print("Czy na pewno chcesz usunąć notatkę '" .. file_name .. "'? (tak/nie): ")
        local decision = io.read()
        if decision:lower() == "tak" then
            local result = os.remove(file_name)
            if result then
                print("Notatka '" .. file_name .. "' została usunięta.")
            else
                print("Nie udało się usunąć notatki.")
            end
        else
            print("Operacja usunięcia anulowana.")
        end
    else
        print("Nie udało się znaleźć notatki o podanej nazwie.")
    end
    
    os.execute("sleep 3")
end

-- Funkcja do wyświetlania wszystkich notatek
function list_notes()
    clear_screen()
    print("Lista wszystkich notatek:")
    local found = false
    local p = io.popen('ls *.txt')  -- Użyj komendy do listowania plików w bieżącym katalogu
    for file in p:lines() do
        print("- " .. file)
        found = true
    end
    p:close()
    
    if not found then
        print("Brak notatek.")
    end
    
    os.execute("sleep 3")
end

-- Główna pętla programu
while true do
    show_menu()
    local choice = io.read()
    
    if choice == "1" then
        create_note()
    elseif choice == "2" then
        view_note()
    elseif choice == "3" then
        edit_note()
    elseif choice == "4" then
        delete_note()
    elseif choice == "5" then
        list_notes()
    elseif choice == "6" then
        clear_screen()
        print("Wyjście...")
        break
    else
        clear_screen()
        print("Nie rozpoznano wyboru. Spróbuj ponownie.")
        os.execute("sleep 2")
    end
end
