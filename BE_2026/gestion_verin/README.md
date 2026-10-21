# Fonction complexe : gestion du vérin — analyse fonctionnelle

D'après la spécification des interfaces du pilote de barre franche (T. Perisse) et la carte
d'interface vérin.

## Rôle

Le circuit commande le vérin électrique qui déplace la barre. Il produit le PWM et le sens du
moteur, envoyés au pont en H DRV8835 de la carte d'interface. Il coupe le moteur quand la
barre atteint une butée, et lit la position de la barre (`angle_barre`) sur le convertisseur
MCP3201. Le Nios le pilote par 6 registres Avalon.

## Découpage

Comme conseillé, `gestion_verin` est découpé en **3 process**, chacun simulable seul :

1. **Gestion du PWM** : fabrique le signal `pwm` à partir de `freq` et `duty` ;
2. **Contrôle des butées** : coupe le PWM quand la barre est en butée ;
3. **Gestion de l'ADC MCP3201** : lit `angle_barre` toutes les 100 ms.

Comme pour l'anémomètre, l'interface Avalon est dans un composant enveloppe,
`avalon_gestion_verin`, avec un process d'écriture et un de lecture. C'est lui qui présente au
Nios les ports du symbole de la spécification.

![Schéma fonctionnel](schema_fonctionnel_verin.png)

## Entrées / sorties

Composant complet `avalon_gestion_verin` (symbole de la spécification) :

| Signal | Sens | Rôle |
|---|---|---|
| `clk` | entrée | horloge 50 MHz |
| `reset_n` | entrée | reset du bus, actif à 0 |
| `chipselect`, `write_n`, `address[2..0]`, `writedata[31..0]` | entrées | bus Avalon |
| `data_in` | entrée | sortie série du MCP3201 |
| `readdata[31..0]` | sortie | bus Avalon |
| `out_pwm` | sortie | PWM du moteur, coupé en butée |
| `out_sens` | sortie | sens de rotation (0 = gauche) |
| `cs_n` | sortie | sélection du MCP3201, active à 0 |
| `clk_adc` | sortie | horloge série du MCP3201 |

Cœur `gestion_verin` (les 3 process, sans le bus) :

| Signal | Sens | Rôle |
|---|---|---|
| `clk`, `raz_n` | entrées | horloge 50 MHz, remise à zéro active à 0 |
| `freq[15..0]`, `duty[15..0]` | entrées | période et durée à l'état haut du PWM, en coups d'horloge |
| `enable_pwm` | entrée | 1 = PWM actif |
| `sens` | entrée | sens demandé (0 = gauche) |
| `butee_g[11..0]`, `butee_d[11..0]` | entrées | limites gauche et droite de `angle_barre` |
| `data_in` | entrée | sortie série du MCP3201 |
| `out_pwm`, `out_sens` | sorties | commande du pont en H |
| `cs_n`, `clk_adc` | sorties | commande du MCP3201 |
| `angle_barre[11..0]` | sortie | position de la barre |
| `fin_course_g`, `fin_course_d` | sorties | 1 quand la butée correspondante est atteinte |

## Registres

| Registre | Adresse | Type | Bits |
|---|---|---|---|
| `freq` | 0 | R/W | b15..b0 : période du PWM, f = 50 MHz / `freq` (2000 → 25 kHz) |
| `duty` | 1 (4) | R/W | b15..b0 : durée à l'état haut (`freq`/2 → 50 %) |
| `butee_g` | 2 (8) | R/W | b15..b0 : butée gauche, 0 à 4095 |
| `butee_d` | 3 (12) | R/W | b15..b0 : butée droite, 0 à 4095 |
| `config` | 4 (16) | R/W | b0 `raz_n`, b1 `enable_pwm`, b2 `sens` |
| | | R | b3 `fin_course_d`, b4 `fin_course_g` |
| `angle_barre` | 5 (20) | R | b11..b0 : position de la barre |

La remise à zéro du cœur est active si le bus est en reset ou si le bit `raz_n` de `config`
vaut 0, comme pour les composants du SOPC.

## Les 3 process

**1. Gestion du PWM** (reprend le PWM validé dans le SOPC)
- `divide` : `compteur` va de 0 à `freq` − 1 puis repart à 0, ce qui fixe la période ;
- `compare` : `pwm` vaut 1 tant que `compteur` est inférieur à `duty`.
Si `enable_pwm` = 0, le compteur reste à 0 et `pwm` à 0.

**2. Contrôle des butées** (`controle_butees`)
- `fin_course_g` = 1 si `angle_barre` ≤ `butee_g`, `fin_course_d` = 1 si `angle_barre` ≥
  `butee_d`. La gauche correspond aux petites valeurs, comme dans l'exemple du prof
  (`butee_g` = 410, `butee_d` = 1320) ;
- `out_pwm` = 0 si le moteur va vers une butée atteinte (`sens` = 0 et `fin_course_g` = 1, ou
  `sens` = 1 et `fin_course_d` = 1), sinon `out_pwm` = `pwm`. Le moteur peut toujours repartir
  dans l'autre sens ;
- `out_sens` = `sens`.

Les butées valent 0 au démarrage : tant que le Nios ne les a pas écrites, `fin_course_d` = 1
et le moteur ne peut pas aller à droite.

**3. Gestion de l'ADC MCP3201** : regroupe les 5 fonctions secondaires de la spécification
- `gene_1M` : divise 50 MHz par 50, donne un top `top_1M` à 1 MHz qui cadence la machine à
  états ;
- `gene_start_conv` : donne un top `start_conv` toutes les 100 ms, soit 10 mesures de l'angle
  par seconde ;
- `pilote_adc` : machine à états qui baisse `cs_n`, fabrique `clk_adc`, puis remonte `cs_n` et
  mémorise `angle_barre` ;
- `compt_fronts` : compte les fronts montants de `clk_adc` pour savoir quand la lecture est
  finie ;
- `rec_dec` : registre à décalage qui récupère `data_in` à chaque front montant de `clk_adc`.

## Signaux internes

| Signal | Process | Rôle |
|---|---|---|
| `compteur` | 1 | position dans la période du PWM, de 0 à `freq` − 1 |
| `pwm` | 1 → 2 | PWM avant le contrôle des butées |
| `fin_course_g`, `fin_course_d` | 2 | butée atteinte ; aussi relus par le Nios dans `config` |
| `cpt_1M`, `top_1M` | 3 | division de 50 MHz ; `top_1M` vaut 1 un coup d'horloge par µs |
| `cpt_100ms`, `start_conv` | 3 | division à 100 ms ; `start_conv` lance une lecture |
| `ep`, `es` | 3 | état présent et état suivant de `pilote_adc` |
| `nb_fronts` | 3 | nombre de fronts montants de `clk_adc` depuis la baisse de `cs_n` (0 à 15) |
| `registre` | 3 | registre à décalage de `rec_dec` ; ses 12 derniers bits donnent l'angle |
| `angle_barre` | 3 → 2 | dernière position lue, gardée jusqu'à la lecture suivante |

## Échange avec le MCP3201

D'après la documentation du MCP3201 : la conversion démarre quand `cs_n` passe à 0. Le
convertisseur change sa sortie sur les fronts descendants de `clk_adc` ; on la lit sur les
fronts montants. L'horloge ne doit pas dépasser 1,6 MHz (alimentation 5 V).

| Front montant de `clk_adc` | `data_in` |
|---|---|
| 1 et 2 | rien d'utile : le MCP3201 échantillonne l'entrée analogique |
| 3 | bit nul (0) |
| 4 à 15 | B11 (poids fort) … B0 |

Après le 15ᵉ front montant, les 12 derniers bits de `registre` forment `angle_barre`.

Choix : `pilote_adc` inverse `clk_adc` à chaque `top_1M`, donc `clk_adc` = 500 kHz. Une lecture
dure 15 × 2 µs = 30 µs, très court devant les 100 ms entre deux mesures.

Machine à états proposée pour `pilote_adc` :

| État | `cs_n` | `clk_adc` | Rôle | Passe à |
|---|---|---|---|---|
| `repos` | 1 | 0 | attend `start_conv` | `lecture` si `start_conv` = 1 |
| `lecture` | 0 | inversée à chaque `top_1M` | 15 fronts montants, `rec_dec` décale `data_in` | `fin` quand `nb_fronts` = 15 |
| `fin` | 1 | 0 | `angle_barre` ← 12 derniers bits de `registre` | `repos` |

## Validation prévue en simulation

1. **Process PWM** : `pwm` pour plusieurs valeurs de `freq` et `duty`, et `enable_pwm` à 0.
2. **Process butées** : on fait varier `angle_barre`, `sens` et les butées ; `out_pwm` doit
   être coupé seulement vers la butée atteinte.
3. **Process ADC** : le testbench imite le MCP3201 (il renvoie une valeur connue, bit par bit,
   sur les fronts descendants de `clk_adc`) ; on vérifie `cs_n`, `clk_adc` et `angle_barre`.
4. **Ensemble `gestion_verin`** : les 3 process reliés.
5. **`avalon_gestion_verin`** : écriture puis relecture des 6 registres, puis intégration
   dans le SOPC et essai sur la carte d'interface vérin.
