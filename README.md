# 🐉 Dragon Ball Versus

## Opis
Aplikacja mobilna stworzona we Flutterze wykorzystująca Dragon Ball API.
Gra polegająca na wybieraniu silniejszej postaci z uniwersum Dragon Ball.
Gracz dostaje dwie losowe postacie i musi wybrać tę z wyższym poziomem Ki.
Za każdy poprawny wybór rośnie streak. Gra kończy się przy błędnym wyborze.

## Jak grać
1. Kliknij ZAGRAJ na ekranie głównym
2. Wybierz postać która ma wyższe Ki (poziom mocy)
3. Za dobry wybór dostajesz punkt do streaka
4. Przy złym wyborze gra się kończy
5. Przytrzymaj kartę postaci aby zobaczyć jej szczegóły

## Ekrany
- **Ekran główny** - menu z najlepszym wynikiem i przyciskiem start
- **Ekran gry** - rozgrywka versus dwóch postaci
- **Ekran szczegółów** - szczegółowe informacje o postaci

## Technologie
- Flutter
- SQLite (sqflite) - tryb offline i zapis wyników
- REST API - Dragon Ball API (https://web.dragonball-api.com/)

## API
Aplikacja korzysta z [Dragon Ball API](https://web.dragonball-api.com/)
- `GET /api/characters?limit=100` - pobieranie listy postaci
- `GET /api/characters/{id}` - pobieranie szczegółów postaci

## Funkcje
- Tryb offline dzięki lokalnej bazie danych SQLite
- Zapis i wyświetlanie najlepszego wyniku
- Obsługa błędów sieciowych z fallbackiem do cache
- Filtrowanie postaci z nieznanym poziomem Ki

## Uwaga
Opisy postaci pochodzą z API i są w języku hiszpańskim.