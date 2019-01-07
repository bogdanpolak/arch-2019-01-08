# Rozgrzewka

## Konfiguracja Git-a

1. Pobranie i instalacja Git dla Windows
    * https://git-scm.com/download/win
1. Stworzenie konfiguracji Git-a `plik .gitconfig`:
	* Dane użytkownika
	```sh
	git config --global user.email "you@example.com"
	git config --global user.name "Your Name"
	```
1. Dodanie aliasów do analizy historii  w formie drzewa
	* Modyfikacja pliku pliku konfiguracyjnego `.gitconfig` (lokalizacja: `C:\Users\{{użytkownik}}`)
	```
	[alias]
		graph1 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
		graph2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
		lg = !"git graph1"
	```
1. Zmiana edytora
    * Klasyczny notatnik - Notepad
    ```sh
    git config --global core.editor C:\Windows\notepad.exe
    ```
    * Notepad++ (**zalecany**)
    ```sh
    git config --global core.editor "'C:/Program Files (x86)/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
    ```
	
1. Konto na GitHub
	* Założenie konta GitHub-ie
	* https://github.com/join


> *Zadanie*
> * Dopisanie swoich danych (imię, nazwisko, github nick)

* Zespół A
* Zespół B
* Zespół C
* Zespół D


1. [Praca z Git](#praca-z-git)
    * Klonowanie repozytorium
    * Używanie git-a z linii poleceń
1. Artykuł wprowadzający `GitLearn.md` [zobacz](./GitLearn.md).
1. Artykuł praca z gałęziami w Git `WorkingWithBranches.md` [zobacz](./WorkingWithBranches.md)
1. Strategie scalania gałęzi - odpowiedzi ze `stackoverflow.com`
    * [Q: What is the difference between `git merge` and `git merge --no-ff`?](https://stackoverflow.com/questions/9069061/what-is-the-difference-between-git-merge-and-git-merge-no-ff)


