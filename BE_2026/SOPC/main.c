#include "sys/alt_stdio.h"
#include "system.h"
#include "alt_types.h"
#include <stdio.h>
#include <unistd.h>

/* Horloge du SOPC */
#define CLK 50000000

/* Composant avalon_pwm
 *   freq    : periode en coups d'horloge, f = CLK / freq
 *   duty    : nombre de coups a l'etat haut
 *   control : b0 raz_n, b1 enable
 */
#define pwm_freq    (volatile unsigned int *) (AVALON_PWM_0_BASE + 0)
#define pwm_duty    (volatile unsigned int *) (AVALON_PWM_0_BASE + 4)
#define pwm_control (volatile unsigned int *) (AVALON_PWM_0_BASE + 8)

#define PWM_RAZ_N   0x00000001
#define PWM_ENABLE  0x00000002

/* Composant avalon_anemometre
 *   config : b0 raz_n, b1 continu, b2 start_stop
 *   code   : b9 valid, b7..b0 data
 */
#define ane_config (volatile unsigned int *) (AVALON_ANEMOMETRE_0_BASE + 0)
#define ane_code   (volatile unsigned int *) (AVALON_ANEMOMETRE_0_BASE + 4)

#define ANE_RAZ_N      0x00000001
#define ANE_CONTINU    0x00000002
#define ANE_START_STOP 0x00000004

#define ANE_VALID      0x00000200
#define ANE_DATA       0x000000FF

char buffer[20];

void afficher(const char *texte, int valeur)
{
    sprintf(buffer, "%d", valeur);
    alt_putstr(texte);
    alt_putstr(buffer);
}

void regler_pwm(unsigned int hz, unsigned int pourcent)
{
    unsigned int periode = CLK / hz;

    *pwm_freq    = periode;
    *pwm_duty    = periode / 100 * pourcent;
    *pwm_control = PWM_RAZ_N | PWM_ENABLE;
}

/* deux fenetres de mesure pour etre sur d'en avoir une complete */
unsigned int mesurer(void)
{
    usleep(2500000);
    return *ane_code & ANE_DATA;
}

/* attend le bit valid (100 ms par essai, 3 s au plus) et renvoie le temps en ms */
int attendre_valid(void)
{
    int n = 0;

    while (!(*ane_code & ANE_VALID) && n < 30) {
        usleep(100000);
        n++;
    }
    return n * 100;
}

void afficher_code(const char *texte)
{
    unsigned int lecture = *ane_code;

    alt_putstr(texte);
    afficher("valid = ", (lecture & ANE_VALID) ? 1 : 0);
    afficher(" | mesure = ", (int)(lecture & ANE_DATA));
    alt_putstr(" Hz\n");
}

int main()
{
    unsigned int rapports[4]  = {25, 50, 75, 90};
    unsigned int consignes[6] = {10, 25, 50, 100, 200, 250};
    unsigned int freq_lu, duty_lu, control_lu, mesure;
    int i, temps;

    alt_putstr("\nValidation SOPC : PWM bouclee sur l'anemometre\n");

    *ane_config = 0;
    usleep(1000);
    *ane_config = ANE_RAZ_N | ANE_CONTINU;

    /* 1. Registres du PWM : ecriture puis relecture, 4 rapports cycliques */
    alt_putstr("\n1. PWM a 50 Hz : ecriture puis relecture des registres\n");
    alt_putstr("rapport | freq lu | duty lu | control lu | rapport lu | mesure\n");

    for (i = 0; i < 4; i++) {

        regler_pwm(50, rapports[i]);

        freq_lu    = *pwm_freq;
        duty_lu    = *pwm_duty;
        control_lu = *pwm_control;
        mesure     = mesurer();

        afficher("  ", (int)rapports[i]);
        afficher(" %  | ", (int)freq_lu);
        afficher(" | ", (int)duty_lu);
        afficher("  |     ", (int)control_lu);
        afficher("      |    ", (int)(duty_lu * 100 / freq_lu));
        afficher(" %    | ", (int)mesure);
        alt_putstr(" Hz\n");
    }

    /* 2. Frequence : la mesure de l'anemometre doit egaler la consigne */
    alt_putstr("\n2. Frequence (rapport 50 %)\n");
    alt_putstr("consigne (Hz) | mesure (Hz) | ecart\n");

    for (i = 0; i < 6; i++) {

        regler_pwm(consignes[i], 50);
        mesure = mesurer();

        afficher("      ", (int)consignes[i]);
        afficher("    |      ", (int)mesure);
        afficher("    |   ", (int)mesure - (int)consignes[i]);
        alt_putstr("\n");
    }

    /* 3. Anemometre en monocoup : une seule mesure par start */
    alt_putstr("\n3. Anemometre en monocoup (PWM a 100 Hz)\n");

    regler_pwm(100, 50);

    *ane_config = 0;
    usleep(1000);
    *ane_config = ANE_RAZ_N;
    (void)*ane_code;                      /* efface un valid memorise */
    afficher_code("avant start         : ");

    *ane_config = ANE_RAZ_N | ANE_START_STOP;
    temps = attendre_valid();
    afficher("start               : valid recu apres ", temps);
    alt_putstr(" ms\n");
    afficher_code("                      ");

    regler_pwm(200, 50);
    usleep(2500000);
    afficher_code("PWM passee a 200 Hz : ");

    *ane_config = ANE_RAZ_N;
    usleep(1000);
    (void)*ane_code;                      /* efface le valid memorise */
    afficher_code("stop                : ");

    *ane_config = ANE_RAZ_N | ANE_START_STOP;
    temps = attendre_valid();
    afficher("nouveau start       : valid recu apres ", temps);
    alt_putstr(" ms\n");
    afficher_code("                      ");

    /* 4. Retour en continu */
    alt_putstr("\nMesure en continu (PWM a 100 Hz)\n");

    *ane_config = ANE_RAZ_N | ANE_CONTINU;
    regler_pwm(100, 50);

    while (1) {

        unsigned int lecture = *ane_code;

        if (lecture & ANE_VALID) {
            afficher("Vent : ", (int)(lecture & ANE_DATA));
            alt_putstr(" Hz\n");
        }

        usleep(500000);
    }

    return 0;
}
