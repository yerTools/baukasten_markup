# TL-DR

BKM ist eine geplante, statisch typisierte Markup-Sprache, deren Hauptziel es ist, aus einem eigenen CMS heraus statisches HTML zu generieren. Im Gegensatz zu herkömmlichen Markup-Sprachen wie Markdown ist BKM darauf ausgelegt, komplexe Webseiten (darunter Seiten, Blogs und Wikis) mit Tailwind CSS und DaisyUI als Styling-Grundlage ohne dynamischen oder nutzerspezifischen Inhalt zu erstellen. Der Fokus liegt darauf, dass Administratoren den Content über das CMS pflegen, während BKM als Transformations- und Layout-Engine fungiert, um ein konsistentes, wartbares und robustes End-HTML zu erzeugen.

Das Konzept setzt auf eine strenge Trennung von Markup und Code. Während Text weitestgehend einfach und minimalistisch gestaltet werden soll (ähnlich wie bei Markdown), werden für Struktur, Layout und Logik nur definierte Funktionen, Widgets und Komponenten genutzt. Dadurch soll vermieden werden, dass rohes HTML direkt eingebunden wird. Die wenigen verbleibenden dynamischen Aspekte (etwa Metaprogrammierung oder rekursive Funktionsaufrufe anstelle von Loops) erfolgen über eine klar definierte, minimalistische "Programmiersprache", die ausschließlich innerhalb von Funktionskörpern erlaubt ist.

Ein wichtiger Grundgedanke von BKM ist, dass jede erweiterte Funktionalität, jedes Formatierungssymbol (wie `*` für Kursivschrift) oder jede logische Operation durch deklarierte Funktionen oder Operatoren in der Standardbibliothek realisiert wird. So bleibt die Kernsprache klein und flexibel. Gleichzeitig ist geplant, mehrsprachige Inhalte, Labeling, AST-Transformationen und eventuell sogar die Integration von Counter-Mechanismen bereitzustellen, um komplexere Szenarien komfortabel abzudecken.

Insgesamt soll BKM ein erweiterbares Grundgerüst bilden, das durch eine saubere Typisierung und minimale Syntax eine verständliche, vorhersehbare und einheitliche Codebasis ermöglicht. Das finale Ziel ist eine Entwickler- und Administratorenfreundliche, rein statische HTML-Generierungsumgebung, die auf einem soliden, formal definierten Fundament steht, leicht erweiterbar ist und durch den Compiler-First-Ansatz frühzeitig Fehler erkennt und vermeidet.

# Projekt Baukasten-Markup (BKM)

Das Ziel von BKM ist, statisches HTML zu generieren. Dabei kommt es im CMS "Baukasten" zum Einsatz und stellt das Grundgerüst für die Webseite dar.
Es gibt keinen dynamischen oder nutzerspezifischen Inhalt, sondern es wird nur durch den Administrator über das CMS verwaltet und davon werden statische Seiten erstellt.
Dabei sollen voll funktionsfähige Seiten, Blogs und Wikis erstellt werden können, damit sehr viele Use-Cases von Vereinen und kleinen Unternehmen umgesetzt werden können.
Für Styling und Layout wird dabei auf Tailwind CSS und DaisyUI gesetzt.
Es muss zwar möglich sein, "rohes" HTML einzufügen, dies muss aber mit so "viel" Aufwand passieren, dass man lieber die vorhandene Funktionalität verwendet.
Durch das Verschachteln von Widgets/Komponenten/Funktionen können komplexe Seiten und weitere Widgets/Komponenten/Funktionen erstellt werden.
Es muss möglich sein, die Seite in mehreren Sprachen darzustellen. Dabei könnte es einen impliziten Standard geben und explizite Alternativtexte bereitgestellt werden.
BKM muss dabei explizit typisiert sein, um Code verständlicher zu machen und Fehler durch den Compiler erkennen zu können.
Es muss so wenig Escaping bzw. "Noise" in Fließtexten vorkommen und Formatierungen bzw. Layout müssen dabei so implizit und automatisch wie möglich sein, ähnlich wie in Markdown.
Innerhalb von Logik oder Metaprogrammierung muss der Code so explizit und klar wie möglich sein, damit man keine falschen Annahmen machen kann und sich dieser selbsterklärt.
Kommentare müssen möglich sein, um Dinge erklären zu können oder Inhalte "auszublenden", wobei für Letzteres eventuell auch eine Alternative gesucht werden könnte.
Es existiert keine "Runtime", da das Programm keine "Laufzeit" hat, sondern nur von dem Compiler in HTML übersetzt wird. Somit werden Funktionen von diesem aufgerufen, ähnlich wie bei SASS.

## Wichtig

Alles kann sich ändern, egal ob Keywords, Syntax oder Konzepte. Hier beschriebene Dinge mit Keywords oder Syntax dienen vielmehr als Beispiele und können geändert werden. Davor muss sichergestellt werden, dass das Konzept in sich funktioniert und eine angenehme Benutzererfahrung bietet. BKM besteht dabei auch aus zwei "Sektionen", einmal Markup und einmal Code. Der Standard ist dabei Code, und durch das Erstellen von Funktionen kann in den Funktionskörpern Code eingefügt werden. Es existiert also auch eine sehr einfache Programmiersprache, die nur in Funktionskörpern verwendet werden kann. Dabei werden die Begriffe Code oder BKM oder Ähnliches teilweise austauschbar verwendet und es wird in diesem Dokument noch nicht zu 100 % differenziert. Dieses Dokument kann sich dabei auch selbst widersprechen. Das ist insofern unwichtig, da verschiedene Gedanken und Ideen festgehalten werden.

## Basics

- Inspiration von Markdown, Typst, Djot, Pug (aka. Jade), Jinja und Ähnlichem.
- Metaprogrammierung und Code-Generation, ähnlich wie in Jai.
- Definierbare Symbole wie die von Markdown, also, dass `*` für *kursiv* oder **fett** nicht Teil der Sprache ist, sondern der Metaprogrammierung.
- BKM muss dabei so wenig Syntax und Keywords wie möglich haben und alles andere durch eine umfangreiche Standardbibliothek ersetzen. (Go hier als Vorbild)
- Da CSS-Klassen eine wichtige Rolle spielen, sollten diese sehr leicht und zielgerichtet auf Elemente angewendet werden können.
- Inspiration von den Dingen hernehmen, die funktionieren.
- "Module" (ähnlich wie JavaScript/TypeScript) müssen mit `export` und `import` möglich sein können.
- Es gibt keine Loops, sondern nur Funktionen, die sich auch rekursiv aufrufen lassen können, die dann eine funktionale Programmierung ermöglichen.
- Variablen sind immer immutable, können aber in derselben Ebene von gleichnamigen Variablen ausgeblendet/überladen werden.
- Mutationen sind nur durch Transformationen des Codes oder des generierten HTML möglich.
- BKM wird dabei zuerst in Bytecode übersetzt und dann von einer Stackmachine ausgeführt.
- "Funktionscode" darf nicht direkt im Text vorkommen, sondern kann nur in einem Funktionskörper vorhanden sein. Dabei können nur Funktionsaufrufe direkt im Text vorkommen.
- Funktionen müssen entweder HTML oder Textcode als Rückgabewert haben. Dabei kann auch beides vermischt werden.
- Interaktive Elemente, die JavaScript-Code benötigen, sind "built-in" und können nicht direkt in BKM-Funktionscode geschrieben werden, sondern werden referenziert.

## Zu berücksichtigen

- "Globale" Variablen bzw. Mechanismen, um beispielsweise für mehrere Sprachen oder Umgebungen (wie Browser, PDF) unterschiedliche Ausgaben zu erzeugen.
- Bearbeiten der Seite über einen GUI-Drag-and-Drop-Editor oder vergleichbare Mechanismen, um die Seite einfacher bearbeiten zu können.
- Wie können Seiten und Unterseiten erstellt werden, wie könnte man die Ordnerstruktur organisieren, sodass Bibliotheken und die eigentlichen Seiten getrennt sind.

## Datentypen

Da das Ganze in Gleam geschrieben wird und somit auf Erlang und JavaScript laufen soll, werden Limitationen von JavaScript mitgenommen.
Ebenso ist es kein Ziel, so effizient und "bare-metal" wie möglich zu sein, da das Ganze nur ein Generator für HTML ist und keine komplexen Berechnungen durchführen soll.
Dementsprechend ist JSON vermutlich vollkommen ausreichend, eventuell kann dies aber noch mit etwas "Erlang-Magie", wie beispielsweise Atoms, erweitert werden.
Grundsätzlich wird sich hierbei an den [Erlang-Datentypen](https://www.erlang.org/doc/system/data_types.html) orientiert. Da das Ganze in Gleam umgesetzt wird, gibt diese Sprache auch (sinnvolle) Limitationen vor, wie beispielsweise, dass es keine Arrays gibt, sondern nur Linked-Lists. Im Zweifel ist dabei Erlang der Wegweiser. Dementsprechend ist die Dokumentation der Erlang-Datentypen sehr entscheidend und sollte bekannt sein. [Look at it here! ;)](https://www.erlang.org/doc/system/data_types.html)

- **Zahlen**: Es wird alles als 64-Bit-Float behandelt. Damit bleiben 52-Bit Präzision für Integer übrig.  
  Mit Objekten oder Arrays können so auch Big-Integers implementiert werden, was eventuell schon in der Standardbibliothek gemacht wird.
  Dabei werden Infinity und NaN (ähnlich wie in Erlang) nicht unterstützt und resultieren in einem Fehler.
- **Strings**: In Erlang sind Strings UTF-8 und in JavaScript UTF-16, sie sind also laufzeitabhängig. Dies wirkt sich aber nicht auf das Verhalten aus.  
  Diese werden mit einfachen Anführungszeichen (`"`) oder mit drei oder mehr Anführungszeichen (`"""`) geschrieben. Zwei Anführungszeichen (`""`) stehen dabei für einen leeren String.  
  Ähnlich wie in Erlang können diese auch über mehrere Zeilen gehen und verhalten sich dabei so wie in Erlang, was Whitespace angeht.  
  Folgen mehrere Strings direkt aufeinander, werden diese miteinander verbunden.
- **Booleans**: Sind wie in Erlang nur die Atome `true` und `false`.
- **Atoms**: Existieren wie in Erlang und sind dabei die "Keys" von Objekten. Diese Literale werden in einfachen Anführungszeichen (`'`) geschrieben, benötigen sie aber nicht, wenn sie mit einem Kleinbuchstaben beginnen und nur Buchstaben, Ziffern, Unterstriche (`_`) und At-Zeichen (`@`) enthalten.
- **Funktionen**: Können ebenfalls übergeben werden und sind damit "first-class citizens".
- **Tupel**: Sind "Mixed-Type-Arrays" mit einer festen Anzahl an Elementen. Dabei können diese auch ein Atom als Alias für den Index haben und funktionieren damit wie Objekte.
- **Maps**: Sind Dictionaries mit einem Schlüssel und einem Wert.
- **Enums**: Diese sind dabei ähnlich wie Records in Gleam bzw. Enums in Rust. Sie bestehen aus einem Atom als Identifikator und einem Tupel (kann auch leer sein) für Werte.

## Syntax

Eine Mischung aus Gleam, Erlang, Elm und Haskell. Dabei ist noch nicht klar, ob BKM typisiert wird oder nicht. Typisierung wäre grundsätzlich sinnvoll, ist aber nicht trivial zu implementieren. BKM soll dabei sehr zugänglich für "Anfänger" sein, damit könnten komplexe Typisierungen den Zugang erschweren. Es ist dabei nicht geplant, komplexe Funktionen in BKM zu erschaffen, da es am Ende nur eine Markup-Sprache zum Generieren von HTML ist.

## Ideensammlung

### Allgemeines

Vielleicht wäre es sinnvoll, wenn man zwischen Content und Code unterscheidet. Also, dass diese komplett separat behandelt werden. Text außerhalb von Funktionskörpern wird automatisch in `<span>`-Objekte gepackt, wenn dieser nicht explizit für einen Funktionsaufruf escapt wird. Dies könnte ähnlich wie in Typst funktionieren.

Also, dass man z. B. `#Funktionsname(Args)` in den Text einfügen kann, um an dieser Stelle einen Funktionsaufruf zu machen. Dabei ist alles innerhalb der Klammern für die Argumente automatisch ein Code-Abschnitt, in dem alles Mögliche gemacht werden kann. In einem Funktionsabschnitt kann aber auch durch z. B. `[[Text Here]]` ein Text-Abschnitt dargestellt werden. So kann man Text innerhalb von Funktionskörpern für beispielsweise das Resultat verwenden. Möchte man also "Rich Content" als Funktionsargument verwenden, könnte das so aussehen: `Willkommen bei #SeitenName([[Rich Content Here]]), dir wird es gefallen.`.

Wenn Funktionen dabei wie in Haskell funktionieren, könnte man auch Argumente mit `()` und `[]` mischen, also dass man `foo(1, 2, 3)` auch mit `foo(1, 2)(3)`, `foo(1)(2, 3)` oder `foo[1](2, 3)` aufrufen kann. Dabei könnte alles innerhalb der eckigen Klammern (`[]`) als Text-Content und alles innerhalb der runden Klammern (`()`) als Code-Content interpretiert werden. In Kombination mit optionalen Argumenten kann man so Funktionen umsetzen, die als erstes Argument Text-Content annehmen und dann optional weitere Argumente für beispielsweise Styling oder Verhalten erhalten können.

Hat man nun Funktionsaufrufe oder Operatoren, wie beispielsweise diese aus Markdown, wird der `<span>` unterbrochen und eine Transformation bzw. ein Wrapping findet statt. So würde aus `Das funktioniert **hoffentlich** gut` das Folgende: `<span>Das funktioniert </span><strong>hoffentlich</strong><span> gut</span>` erzeugt werden. Eventuell könnte man auch `<span>` grundsätzlich weglassen, da es dann keine Auswirkungen auf die Ausgabe hat, wenn z. B. keine Klassen oder Attribute verwendet werden.  
Ein fiktionaler `%wrap-in-div%`-Operator würde dann einfach den Inhalt in ein `<div>` packen.

Man könnte einen sehr einfachen Escape-Mechanismus verwenden, da HTML eigene Möglichkeiten bietet, Steuerzeichen oder Unicode-Zeichen zu verwenden, und Strings in Funktionscode in der Regel nicht verwendet werden müssen. Dabei könnte man einfach einen Escape-Operator definieren, wie beispielsweise `\`, der so funktioniert, dass das nächste Unicode-Symbol eine "Escaped"-Flag bekommt und das `\` dementsprechend vor dem Lexing entfernt wird. Möchte man das Escape-Zeichen darstellen, so kann man diese Funktion mit einem `\` vor diesem aushebeln, indem man `\\` verwendet. Dabei matchen beim Parsen der Sprache nur Characters, die kein Escape-Flag haben. Somit kann man also verhindern, dass Sonderzeichen oder Zeichenfolgen als Operatoren oder Keywords erkannt werden, indem in diesen ein Escape-Flag gesetzt wird. Man kann also jedes Zeichen überall mit einem Escape-Operator verwenden, da dadurch kein neues Zeichen generiert wird, sondern einfach ein Escape-Flag gesetzt wird.  
Werden spezielle Zeichen in einem String benötigt, könnte man dies einfach mit einer eingebauten Funktion machen, also einem Funktionsaufruf, mit dem Unicode-Zahlenwerte als Argument.

### Metaprogrammierung

Vielleicht könnte dies ein ganz normaler Teil der Sprache innerhalb einer Funktion sein, eventuell, wie bei Jinja?  
Also, dass ich innerhalb der Funktion mit `{{` und `}}` ein Template für Code erstellen kann, die vor dem Ausführen der Zeile evaluiert und direkt daraufhin ausgeführt wird.

Es muss Label ähnlich wie in Typst geben können, damit diese per Query gefunden werden können. An den durch die Query gefundenen Stellen könnte es nun möglich sein, ein Prefix, Suffix oder Replace durchzuführen, damit bestimmte Dinge beispielsweise automatisch annotiert werden können.

Funktionen sollten wissen, von wo aus sie aufgerufen werden, damit man diese Informationen verwenden kann. Das soll dabei für jeden Call, als auch für jede Referenz abrufbar sein. Dabei sollen sie auch an den Punkt des Aufrufes (vor dem Aufruf bzw. danach) BKM-Code einfügen können. Hat man beispielsweise ein Bild, könnte so ein Ankerpunkt/Label hinzugefügt werden, damit dieses in einem Inhaltsverzeichnis oder Ähnlichem referenziert werden kann.

Counter, ähnlich wie `iota` in Go, könnten global, per Datei oder per Funktion definiert werden. Damit könnte man automatische Nummerierungen erstellen, die für Kapitel oder Seiten interessant wären. Diese könnte man dann vielleicht auch beeinflussen bzw. steuern, um diese zurückzusetzen oder auf einen Wert zu setzen.

Zum Definieren von "Operatoren" wie `*` (Stern) für *kursiv* oder **fett**, oder `#` (Raute) für Headings, oder `>` für Blockquotes bzw. `` ` `` (Backtick) für Inline- oder Multiline-Code, könnte man einen speziellen Syntax erstellen, der daraus eine Funktion erstellt, die dann die entsprechende Ausgabe erzeugt.

CSS-Klassen könnten durch einen dieser Operatoren umgesetzt werden. Dafür bräuchte man eine Möglichkeit, die fertige Ausgabe, also das generierte HTML, zu bekommen, um dieses dann mit den CSS-Klassen zu erweitern.

Es wäre vermutlich sinnvoll, dass man den AST von BKM, als auch von HTML, bekommen kann, damit dieser transformiert bzw. mutiert werden kann. Um unauflösbare zyklische Abhängigkeiten zu vermeiden, könnte man eventuell sagen, dass BKM-Code Befehl für Befehl ausgeführt wird und wenn dieser generiert wird, wird er auch direkt ausgeführt. Ist der generierte Code dabei an einer anderen Stelle (wie einem Label oder einer Manipulation im AST), ist der Kontext bei der Generierung an der aktuellen Stelle, bei der direkt darauffolgenden Ausführung jedoch an der Stelle des generierten Codes.

Wenn Operatoren über die Metaprogrammierung definiert werden können, wäre eine Prioritätsangabe durchaus sinnvoll.