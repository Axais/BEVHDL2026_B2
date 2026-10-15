# BE 2026 — SOPC Nios II : PWM + anémomètre

**Alexandre Aragones** — M2 SME, groupe B2 — DE0-Nano (Cyclone IV E), Quartus 18.1 Lite

## Objectif

Valider un SOPC Nios II intégrant le PWM et la fonction simple « anémomètre ». Faute
d'oscilloscope, le PWM produit par le SOPC est renvoyé sur l'entrée de l'anémomètre : le
Nios impose une fréquence et vérifie que l'anémomètre mesure la même.

## Démarche

1. **Fonction simple** `gestion_anemometre` : machine de Moore à 4 états qui compte les
   fronts de l'entrée pendant 1 s, ce qui donne directement la fréquence en Hz sur 8 bits.
2. **Interfaces Avalon** : chaque entité est enveloppée dans un composant `avalon_*` dont
   les entrées deviennent des registres, avec un process d'écriture et un de lecture
   (méthode du document COMPOSANT-NIOS). Le bit `valid` de l'anémomètre est mémorisé
   jusqu'à sa lecture, sinon il ne dure que 20 ns en mode continu.
3. **Platform Designer** : Nios II/e, RAM 32 Ko, System ID, JTAG UART et les deux composants.

   ![Système dans Platform Designer](SOPC/Captures/platform_designer_SOPC_pwm_anemo.png)

4. **Haut niveau** `SOPC.vhd` : relie la sortie du PWM à l'entrée de l'anémomètre (vue RTL).

   ![Vue RTL de SOPC.vhd](SOPC/Captures/rtl_view_SOPC_pwm_anemo.png)

5. **Logiciel** `main.c` (Eclipse) : impose six fréquences au PWM et affiche la mesure.

## Résultats

**En simulation** (GHDL, `SOPC/tb_chaine_sopc.vht`), les deux composants rebouclés mesurent
exactement la consigne de 10 à 250 Hz, et 0 quand le PWM est arrêté.

**Sur la carte**, console Eclipse :

![Console Eclipse](SOPC/Captures/eclipse_console_SOPC_pwm_anemometre.png)

Les LED affichent la mesure en binaire, LED7 à gauche et LED0 à droite :

| 100 Hz = `0110 0100` | 250 Hz = `1111 1010` |
|---|---|
| ![LED à 100 Hz](SOPC/Captures/affichage_led_100Hz.jpg) | ![LED à 250 Hz](SOPC/Captures/affichage_led_250Hz.jpg) |

L'écart est nul parce que le PWM et la fenêtre d'une seconde partagent la même horloge à
50 MHz. Avec le vrai capteur, asynchrone, la méthode garde une erreur de ±1 Hz (1 LSB).

## Fichiers

```
BE_2026/
├── gestion_anemometre/   fonction simple et son interface Avalon
├── pwm/                  PWM et son interface Avalon
├── SOPC/                 projet Quartus, système Platform Designer, SOPC.vhd, main.c, captures
└── pwm_moteur/           première ébauche du PWM, non utilisée dans le SOPC
```
