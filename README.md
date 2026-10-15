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

## `BE_2026/`

Bureau d'études : même organisation qu'en TP, un dossier par module.
Le compte rendu de l'étape SOPC (Nios II + PWM + anémomètre) est dans
[`BE_2026/README.md`](BE_2026/README.md).

| Dossier | Ce que fait le système |
|---|---|
| `gestion_anemometre/` | Mesure de la fréquence de l'anémomètre par comptage des fronts pendant 1 s. Machine de Moore à 4 états (`attente`, `mesure`, `fin`, `attente_acq`), deux modes pilotés par `continu` et `start_stop` : monocoup avec acquittement, ou relance immédiate. Résultat sur 8 bits dans `data_anemometre`, recopié sur `led` pour la vérification sur carte. |
| `pwm/` | PWM dont la fréquence et le rapport cyclique sont réglés par le Nios. |
| `SOPC/` | Système Nios II (Platform Designer) avec le PWM et l'anémomètre, validé sur carte. |
| `pwm_moteur/` | PWM par comparateur (`max = 1024`, rapport cyclique 500/1024) avec inversion du sens de rotation à chaque appui. Machine à 2 états `attente` / `appui` pour ne compter qu'une fois un appui maintenu. |
