# BE VHDL 2026 — B2

Travaux VHDL sur carte DE0-Nano (Cyclone IV E, EP4CE22F17C6), horloge 50 MHz,
sous Quartus Prime 18.1 Lite et ModelSim-Altera.

## `TP_VHDL/`

Un dossier par système, contenant le code VHDL, son testbench ModelSim et les captures associées.

| Dossier | Ce que fait le système |
|---|---|
| `compteur_appuis/` | Compteur du nombre d'appuis sur le bouton, machine à 2 états. Sortie `led` 4 bits, comptage 0 → 9 puis rebouclage. |
| `compteur_temporel/` | Diviseur d'horloge (`max = 50 000 000`, soit 1 s à 50 MHz) puis incrémentation de `led` de 0 à 9. |
| `compteur_timer/` | Machine à 4 états + timer 20 ms (`max_timer = 1 000 000`). À l'appui le timer démarre, l'appui n'est compté que si le bouton est encore enfoncé au bout des 20 ms. |
| `decalage_droite/` | Compteur en anneau à décalage à droite sur 4 bits : 1000 → 0100 → 0010 → 0001 → 1000. Base de temps `max = 25 000 000` (0,5 s par décalage). |
| `pwm/` | PWM par comparateur : dent de scie 0 → 1023 et comparaison `compteur < rapport_cyclique`. 750/1024 ≈ 73 %, porteuse à 50 MHz / 1024 ≈ 48,8 kHz. |
| `pwm_variable/` | Même comparateur, mais le rapport cyclique est réglé par le bouton : +250 par appui, de 0 à 1000 puis rebouclage. |
