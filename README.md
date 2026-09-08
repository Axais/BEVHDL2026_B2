# BE VHDL 2026 — B2

Travaux VHDL sur carte DE0-Nano (Cyclone IV E, EP4CE22F17C6), horloge 50 MHz,
sous Quartus Prime 18.1 Lite et ModelSim-Altera.
`rst` et `bouton` sont **actifs à l'état bas** (touches KEY de la carte).

## `TP_VHDL/`

Un dossier par système, contenant le code VHDL, son testbench ModelSim et les captures associées.

| Dossier | Ce que fait le système |
|---|---|
| `compteur_appuis/` | Compteur du nombre d'appuis sur le bouton, machine à 2 états. Sortie `led` 4 bits, comptage 0 → 9 puis rebouclage. Aucun anti-rebond : chaque rebond est compté. |
| `compteur_temporel/` | Diviseur d'horloge (`max = 50 000 000`, soit 1 s à 50 MHz) puis incrémentation de `led` de 0 à 9. |
| `compteur_timer/` | Machine à 4 états + timer 20 ms (`max_timer = 1 000 000`). À l'appui le timer démarre ; l'appui n'est compté que si le bouton est encore enfoncé au bout des 20 ms. |
| `decalage_droite/` | Compteur en anneau à décalage à droite sur 4 bits : 1000 → 0100 → 0010 → 0001 → 1000. Base de temps `max = 25 000 000` (0,5 s par décalage). |
| `pwm/` | PWM par comparateur : dent de scie 0 → 1023 et comparaison `compteur < rapport_cyclique`. 750/1024 ≈ 73 %, porteuse à 50 MHz / 1024 ≈ 48,8 kHz. |
| `pwm_variable/` | Même comparateur, mais le rapport cyclique est réglé par le bouton : +250 par appui, de 0 à 1000 puis rebouclage. |

## Contenu d'un dossier

- `<systeme>.vhd` — le code VHDL, structuré en partie séquentielle / combinatoire / sorties
- `tb_<systeme>.vht` — le testbench ModelSim : fixe les entrées et affiche la sortie sur plusieurs scénarios
- les captures ModelSim, et pour `compteur_timer` le diagramme d'états en PNG et SVG

`decalage_droite/` n'a pas encore de capture.

## Constantes de simulation

Les testbenches surchargent les generics par une constante déclarée en tête de fichier, pour pouvoir raccourcir les temporisations sans toucher au code de synthèse :

| Testbench | Constante | Valeur |
|---|---|---|
| `tb_compteur_temporel.vht` | `max_sim` | 50 000 000 → 1 s par incrémentation |
| `tb_compteur_timer.vht` | `max_timer_sim` | 1 000 000 → 20 ms de temporisation |
| `tb_decalage_droite.vht` | `max_sim` | 5 (raccourci) |
| `tb_pwm.vht` | `max_sim` | 1024 |

Attention : une seconde simulée fait 50 millions de coups d'horloge. Pour un essai rapide, réduire la constante.

## Simulation

Sous Quartus : *Tools → Run Simulation Tool → RTL Simulation*.
L'entité de plus haut niveau se choisit dans *Assignments → Settings → General → Top-level entity*.
Les broches `led[3..0]` sont déjà affectées — les six systèmes utilisent la même sortie.
